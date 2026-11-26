---
name: infra-as-code
description: "Use for writing or reviewing Terraform/OpenTofu, Helm, Kubernetes, Kustomize, Argo CD GitOps, Ansible and IaC security review."
---

Write and review infrastructure-as-code (Terraform/OpenTofu, Kubernetes manifests, Helm, Kustomize, Argo CD GitOps, Ansible conventions) and audit it for security. Keep work offline and read-only unless told otherwise.

## Pick the tier

First check which tools exist on the machine (`kubectl`, `docker`, `terraform`/`tofu`, `helm`, `kustomize`, `kubeconform`, `tflint`, `checkov`, `trivy`, `kubescape`, `ansible`, `argocd`, `hadolint`, `osv-scanner`; for example `command -v <tool>` in bash or `Get-Command <tool>` in PowerShell). Use what is installed; for what is not, review by eye or use a pinned container. Ask before installing anything; do not assume a cluster is configured.

- **LOW** (read or explain a manifest/module, small fix): review by eye against the Rules and the checklists in `iac-review-1.md`. No tools.
- **MEDIUM** (write or review a module, chart or overlay): validate read-only and offline.
  - Kustomize render: `kubectl kustomize overlays/<env> > rendered.yaml`.
  - Manifest sanity without a cluster: `kubectl apply --dry-run=client --validate=false -f rendered.yaml`.
  - Terraform: `terraform fmt -check -recursive` and `validate` if a binary is available, else a pinned container: `docker run --rm -v ${PWD}:/w -w /w hashicorp/terraform:<pinned-tag> fmt -check -recursive` (look up the current tag first).
  - Helm: `helm lint` / `helm template` if installed (otherwise review templates by eye).
- **HIGH** (security audit, multi-tool stack, compliance review): add static scanners and fan out per area to subagents if the agent supports them (Terraform, K8s manifests, Helm/Kustomize, GitOps).
  - `uvx --from checkov==<pinned> checkov -d .` (pin after looking up the current version on PyPI).
  - Alternatives if not installed: `trivy config .` for IaC/image scanning, a Terraform registry MCP server for provider docs. Mention them; do not install or register them without approval.
  - Report by severity (CRITICAL/HIGH/MEDIUM/LOW) with `file:line` and fix; format in `iac-review-1.md`.

## Rules

1. **Read-only first, always.** Order: read, `fmt`/`lint`/`validate`/render, `plan`/`diff`/`--check`/`--dry-run`, and only then (after confirmation) mutate.
2. **Apply-type commands need explicit user confirmation each time**, naming target, scope and effect: `terraform apply|destroy|import|taint|force-unlock`, `terraform state rm|mv`, `kubectl apply|delete|patch|scale|replace|edit|drain|cordon|rollout restart`, `kubectl apply|delete -k`, `helm install|upgrade|uninstall|rollback`, `argocd app sync|delete|rollback`, `ansible-playbook` without `--check`, enabling Argo auto-sync. Run `kubectl config current-context` first and state it. Never add `-auto-approve`, `--force`, or `--grace-period=0` on your own initiative; never delete namespaces or use `--all`.
3. **Secrets never in plaintext or in git**: no secrets in `.tf`/`.tfvars`/values/kustomize literals/Ansible vars; state and kubeconfig files are secrets. Pass values as environment variables from your secret manager (for example `TF_VAR_db_password`), and use external secret managers in clusters (External Secrets, SOPS, Sealed Secrets). Example values in docs are placeholders (`example.com`).
4. **Verify against current docs** before writing provider arguments, chart values or API versions (web search or fetch, a library-docs MCP such as context7 if available); training data goes stale (for example PodSecurityPolicy no longer exists; use Pod Security Admission).
5. **Pin everything**: Terraform `required_version` and providers (`~>`), commit `.terraform.lock.hcl`, Helm dependency ranges, image tags/digests (never `latest`), container/tool versions in commands (no `@latest`, no `npx -y`).
6. **Kubernetes workloads**: requests and limits, readiness/liveness (and startup) probes, non-root, read-only root filesystem, no privilege escalation, drop ALL capabilities, seccomp `RuntimeDefault`, dedicated ServiceAccount with token automount off, PodDisruptionBudget for replicas > 1, default-deny NetworkPolicy, RBAC least privilege (no `cluster-admin` for apps, explicit verbs).
7. **Terraform**: underscore names, standard file layout, variables/outputs with `description` and `type`, remote backend with locking, separate state per environment (no workspaces for prod isolation), `for_each` for stable addressing, `sensitive = true`, no `0.0.0.0/0` ingress without justification. Terragrunt and cloud-specific repo conventions are out of scope.
8. **Kustomize/Helm/GitOps**: overlays are thin; namespace via transformer; generators over raw ConfigMap/Secret; `helm template` must render (no `lookup`); production sync needs PR approval and no unattended auto-sync; no manual `kubectl apply` in Argo-managed namespaces.
9. **Resource caps**: do not spin up kind/minikube/Docker Desktop Kubernetes or Molecule containers without asking (they can exhaust a small machine), and keep any local cluster to one small node.
10. **Config management**: for SSH-based host automation use `pyinfra` or Ansible, whichever the repo already uses; Ansible's control node needs Linux/macOS (WSL on Windows). Review Ansible, `--check`-run it and run it only after user approval; do not introduce either tool as a new dependency without asking.
11. **Review output**: findings first, ordered by severity, each with `file:line`, why it matters, and the fix; offer fixes as a diff and apply only with approval.

## References

- `references/terraform.md`: load when writing or reviewing Terraform/OpenTofu (layout, naming, modules, state, security, validation).
- `references/iac-review-1.md`: load for any IaC review: workflow, severity, Terraform, Kustomize and Kubernetes checklists.
- `references/iac-review-2.md`: load for Helm and GitOps checklists and the read-only validation command set.
- `references/kubernetes.md`: load when writing or reviewing Kubernetes manifests (resources, probes, security context, PDB, NetworkPolicy, RBAC).
- `references/k8s-security-policies.md`: load for Pod Security Admission, NetworkPolicy sets, RBAC design, admission policy, mesh mTLS.
- `references/helm.md`: load when creating or reviewing a Helm chart or values.
- `references/kustomize.md`: load when writing bases/overlays, generators and patches.
- `references/gitops.md`: load for Argo CD (Application, ApplicationSet, sync waves, promotion, external secrets).
- `references/ansible.md`: load when a repo has Ansible roles/playbooks or the user asks about Ansible vs pyinfra.

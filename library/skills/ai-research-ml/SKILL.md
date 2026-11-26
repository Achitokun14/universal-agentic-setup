---
name: ai-research-ml
description: "Use for ML research, fine-tuning, evaluation, local GGUF inference and paper-writing questions; indexes an on-demand skill library by topic."
---

# ML research index (topic -> path), on-demand library

Pointer skill: pick the topic, read ONE library `SKILL.md` (and only the needed `references/` file); do not bulk-load. Complements the `hf-cli` skill (Hub downloads/uploads, `hf download`) and `local-llm` skill (small local models for chores), if installed.

## Hardware reality (read first)

Check what the current machine has before planning (`nvidia-smi`, free RAM, CPU count). On a machine **without a CUDA GPU**, local work = llama.cpp/GGUF CPU inference, tiny-model smoke tests, data wrangling, analysis and writing. Pre-training, fine-tuning (LoRA/QLoRA/full), RL post-training, vLLM/SGLang serving and large evals need a **GPU host** (a cloud GPU such as Modal, Lambda or SkyPilot - guides are in the library - or a GPU machine the user owns). Never start a paid cloud job, upload data/models, or push anything without explicit user confirmation of provider, cost cap and target.

## Library location

`LIB` = the user's local clone of the Orchestra-Research `AI-research-SKILLs` library (MIT; 23 category folders, 98 skills, each `<category>/<skill>/SKILL.md` + `references/`). Ask the user where it is cloned (or whether to clone it); if it is absent, rely on the distilled references below. Search it with grep/ripgrep over `LIB` or a file search.

## Distilled references (read these first, they cover the common cases)

- `references/finetune-methods.md` - whether to fine-tune at all, SFT/DPO/KTO/GRPO routing, LoRA/QLoRA/PEFT, TRL, Unsloth, memory sizing.
- `references/eval.md` - eval-harness-first, goldens, graders, judge calibration, lm-evaluation-harness commands.
- `references/local-inference-gguf.md` - run/quantize GGUF with llama.cpp, sizing for low-RAM machines.
- `references/mlops.md` - MLflow tracking/registry, run records.
- `references/research-process.md` - two-loop research workflow, ideation frameworks.
- `references/paper-writing.md` - ML paper structure, citation-verification rule, venues, figures.

## Topic -> library path (relative to LIB; folder names = skill names)

**Research workflow / ideation / writing**
- Autonomous research orchestration: `0-autoresearch-skill` (templates/, references/)
- Brainstorming, creative thinking: `21-research-ideation/{brainstorming-research-ideas,creative-thinking-for-research}`
- Paper writing + LaTeX templates + checklists: `20-ml-paper-writing/{ml-paper-writing,systems-paper-writing,academic-plotting,presenting-conference-talks}`
- Research artifacts/provenance/review: `22-agent-native-research-artifact/{compiler,research-manager,rigor-reviewer}`

**Model architecture, tokenization, data**
- `01-model-architecture/{litgpt,mamba,nanogpt,rwkv,torchtitan}`; `02-tokenization/{huggingface-tokenizers,sentencepiece}`
- `05-data-processing/{nemo-curator,ray-data}`

**Fine-tuning**
- `03-fine-tuning/{peft,unsloth,axolotl,llama-factory}`

**Post-training / alignment (RL, preference)**
- `06-post-training/{trl-fine-tuning,grpo-rl-training,simpo,openrlhf,verl,slime,miles,torchforge}`
- Safety/guardrails: `07-safety-alignment/{constitutional-ai,llamaguard,nemo-guardrails,prompt-guard}`

**Distributed training / infrastructure**
- `08-distributed-training/{accelerate,deepspeed,pytorch-fsdp2,pytorch-lightning,ray-train,megatron-core}`
- GPU cloud: `09-infrastructure/{modal,lambda-labs,skypilot}`

**Optimization / quantization**
- `10-optimization/{gguf,awq,gptq,hqq,bitsandbytes,flash-attention,ml-training-recipes}`
- Emerging: `19-emerging-techniques/{knowledge-distillation,model-merging,model-pruning,speculative-decoding,long-context,moe-training}`

**Evaluation**
- `11-evaluation/{lm-evaluation-harness,bigcode-evaluation-harness,nemo-evaluator}`

**Inference / serving**
- `12-inference-serving/{llama-cpp,vllm,sglang,tensorrt-llm}` (only llama-cpp runs without a CUDA GPU)

**MLOps / observability**
- `13-mlops/{mlflow,weights-and-biases,tensorboard,swanlab}`; `17-observability/{langsmith,phoenix}`

**Agents, RAG, prompting**
- `14-agents/{a-evolve,autogpt,crewai,langchain,llamaindex}`
- `15-rag/{chroma,faiss,qdrant,pinecone,sentence-transformers}` (chroma/faiss/sentence-transformers run on CPU)
- `16-prompt-engineering/{dspy,guidance,instructor,outlines}`

**Mechanistic interpretability**
- `04-mechanistic-interpretability/{transformer-lens,nnsight,pyvene,saelens}` (small models run on CPU)

**Multimodal / robotics**
- `18-multimodal/{whisper,clip,llava,blip-2,segment-anything,stable-diffusion,audiocraft,openpi,openvla-oft,cosmos-policy}` (GPU-bound except tiny demos; local STT/OCR/vision may already be covered by the `local-llm` skill, if installed)

## How to use

1. Identify the topic; open the distilled reference if listed above; otherwise read `LIB/<category>/<skill>/SKILL.md` (largest ones are 10-40 KB: list the headings first, then read ranges).
2. State whether the step is runnable locally (CPU, small) or needs a GPU host; propose the host and a cost/time estimate and wait for approval before running remote work.
3. Check dependency versions before installing (`uv pip install <pkg>==<pin>` in a virtual env; never global; no unpinned `latest`); library snippets are illustrative and may be dated.
4. Never fabricate citations or benchmark numbers; fetch and verify (see `references/paper-writing.md`). Never print or paste API keys; pass them through environment variables (for example `HF_TOKEN`, `OPENAI_API_KEY`) injected from your secret manager.
5. Keep large artifacts (datasets, checkpoints, GGUFs) on a drive with enough free space, or in cloud storage, not in the repo.
6. For iterative metric work in a repo use the `autoresearch-loop` skill (if installed); for CI around ML code use `ci-cd`.

License: library MIT (c) Claude AI Research Skills Contributors; distillations carry attribution in each reference header.

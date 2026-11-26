# Licence choice (left to the repository owner)

No licence file is added for this folder: choosing one is the owner's decision. The repository root is MIT; the folder `library/` is not covered by that choice until the owner says so. Facts to decide with:

1. **Original text** (the consolidated skills' own wording, installers, scripts, tool manifests) can carry any licence the owner picks; MIT or Apache-2.0 would match the repository.
2. **Upstream-derived text** keeps the upstream licences listed per skill in `NOTICE.md` and `skills/*/SOURCES.md`. Most are MIT or Apache-2.0 (attribution must stay).
3. **Share-alike material (CC BY-SA 4.0)** is bundled in some skills (see `NOTICE.md` for the list). Those derived files must stay under CC BY-SA 4.0, so a single permissive licence cannot cover the whole folder unless those files are removed or kept in a clearly separate licence directory.
4. **Non-commercial material:** `research/references/academic.md` restates, in new words, the method of a project licensed CC BY-NC 4.0. Remove it if the folder is ever used commercially.
5. **Unstated upstream licences:** four references of `vercel-next-react` and a few others are rewritten from projects whose licence was not visible locally; verify upstream before publishing under a relaxed licence.

Suggested default if no further thought is wanted: MIT for original files, with `NOTICE.md` kept, and CC BY-SA 4.0 declared for the files listed in the share-alike section.

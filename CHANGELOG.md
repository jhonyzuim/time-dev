# Changelog

## v1.0 — 2026-09-25 — Fase 1 (base)

- Agentes: `tech-lead`, `backend-dev`, `frontend-dev`, `reviewer`.
- Comandos: `/feature`, `/fix`, `/plan`, `/review`, `/init-projeto`.
- Templates: `CLAUDE.template.md` e `plan.template.md`.
- Hooks opcionais por projeto (`.claude/qualidade.json`): formatação após edição e verificação ao fim de cada dev.
- Permissões globais: bloqueio de `.env`, `git commit`, `git push`, `rm -rf`.
- Instalador `scripts/instalar.js` (copia e mescla sem apagar configurações existentes).

---
description: Revisa o diff atual com o reviewer (somente leitura).
argument-hint: [caminho do plano, opcional]
---

Use o subagente `reviewer` para revisar as alterações atuais do repositório (git status + git diff, incluindo arquivos novos).
Plano de referência: $ARGUMENTS (se vazio, revise contra o CLAUDE.md e boas práticas).

Mostre o veredito e os achados exatamente como o reviewer entregar. Não corrija nada: pergunte se eu quero que os achados sejam enviados ao backend-dev ou frontend-dev.

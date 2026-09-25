---
description: Caminho rápido para bugs e ajustes pequenos (1–2 arquivos), com uma revisão no final.
argument-hint: <descrição do bug ou ajuste>
---

Correção pedida: $ARGUMENTS

1. Leia o CLAUDE.md e localize a causa. Se a correção exigir mais de 2–3 arquivos ou mexer em back e front ao mesmo tempo, pare e sugira /feature.
2. Se for um bug, escreva primeiro um teste que reproduz o problema (quando o projeto tiver testes para essa parte).
3. Corrija da forma mais simples que resolva a causa, seguindo os padrões do projeto.
4. Rode os testes e o lint definidos no CLAUDE.md.
5. Chame o subagente `reviewer` uma vez sobre o diff.
6. Mostre: causa encontrada, o que mudou, resultado real dos testes, veredito do revisor e uma mensagem de commit sugerida. Não faça commit.

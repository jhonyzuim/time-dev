---
description: Só planeja — chama o tech-lead e para, sem implementar nada.
argument-hint: <pedido ou ideia>
---

Pedido: $ARGUMENTS

Use o subagente `tech-lead` para analisar o pedido e criar o plano em `.claude/plans/`.
Depois mostre: resumo, camadas afetadas, contrato, perguntas em aberto e uma estimativa de tamanho (pequeno / médio / grande).
Não implemente nada. Se eu quiser seguir, eu digo "pode implementar o plano <caminho>" ou rodo /feature.

# Como evoluir o time

## Quando mexer em um agente

Só quando o **processo** mudar ou quando o mesmo erro aparecer em duas features diferentes em projetos diferentes.
Se o erro é de um projeto só (biblioteca, padrão, regra de negócio), a correção vai no `CLAUDE.md` daquele projeto.

## Sobrescrever um agente em um projeto

Crie `.claude/agents/<mesmo-nome>.md` dentro do repositório do projeto. O agente do projeto tem prioridade sobre o global.

## Adicionar um papel novo

1. Crie `agents/<nome>.md` com `name`, `description` (quando usar), `tools` e `model`.
2. Mantenha as 4 seções: Antes de começar, Como trabalhar, Limites, Entrega (formato fixo).
3. Se ele entra no fluxo, atualize `commands/feature.md`.
4. Registre no `CHANGELOG.md` e rode `node scripts/instalar.js`.

## Métricas para ajustar os prompts (primeiras 5–10 features)

- Quantas vezes o revisor achou algo BLOQUEANTE.
- Quantas rodadas de correção foram necessárias.
- Quantas vezes o plano precisou ser reescrito na aprovação 1.

Revisor que nunca acha nada, ou que sempre reprova, indica prompt a ajustar.

## Próximas fases

- **Fase 2:** ajustar hooks e prompts com base nas métricas; validar em um segundo projeto com stack diferente sem editar os agentes.
- **Fase 3:** empacotar como plugin; testar Agent Teams em features grandes.

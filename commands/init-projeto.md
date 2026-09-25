---
description: Prepara um repositório para o time — gera CLAUDE.md, pasta de planos e configuração de qualidade.
---

Prepare este repositório para trabalhar com o time (tech-lead, backend-dev, frontend-dev, reviewer).

1. Se já existir um CLAUDE.md na raiz, NÃO sobrescreva: leia, compare com `~/.claude/templates/CLAUDE.template.md` e me mostre só as seções que faltam, perguntando se devo acrescentá-las.

2. Se não existir, explore o repositório (package.json, composer.json, requirements.txt, pyproject.toml, *.csproj, docker-compose, README, pastas de testes, configuração de lint) e preencha o modelo `~/.claude/templates/CLAUDE.template.md` com o que conseguir descobrir: stack, comandos reais, estrutura de pastas e um recurso de referência bem feito para servir de padrão.
   - Onde não der para descobrir (regras de negócio, "nunca faça", glossário), deixe `<!-- PREENCHER -->` no lugar.
   - Não invente comandos: só coloque comandos que existem nos arquivos do projeto.

3. Crie a pasta `.claude/plans/` com um arquivo `.gitkeep`.

4. Crie `.claude/qualidade.json` com os comandos que os hooks do time devem usar, no formato:
   ```json
   {
     "formatar": "<comando que formata UM arquivo, usando {arquivo} no lugar do caminho — ou vazio>",
     "verificar": "<comando rápido de lint + testes que deve passar ao fim do trabalho de cada dev — ou vazio>"
   }
   ```
   Exemplos: `"npx prettier --write {arquivo}"`, `"npm run lint && npm test"`, `"vendor/bin/pint {arquivo}"`, `"php artisan test"`.
   Se não houver ferramenta adequada, deixe o valor vazio.

5. Mostre um resumo do que foi criado e a lista de itens `PREENCHER` que só eu posso responder.

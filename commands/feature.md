---
description: Fluxo completo do time — plano, implementação paralela back/front, revisão e correção.
argument-hint: <descrição da feature>
---

Você é o tech lead coordenando o time. Feature pedida: $ARGUMENTS

Siga estas etapas na ordem. Não pule etapas e não implemente código você mesmo — delegue.

1. TRIAGEM: leia o CLAUDE.md do projeto (se não existir, pare e sugira /init-projeto). Se a mudança couber em 1–2 arquivos de uma camada só, diga isso e sugira /fix em vez de continuar.

2. PLANO: use o subagente `tech-lead` para criar o plano em `.claude/plans/`.

3. APROVAÇÃO 1: mostre o resumo, o contrato e as perguntas em aberto. PARE e espere minha resposta. Se eu responder perguntas, repasse ao `tech-lead` para atualizar o plano.

4. IMPLEMENTAÇÃO: depois do meu ok, chame `backend-dev` e `frontend-dev` NA MESMA MENSAGEM para rodarem em paralelo, passando o caminho do plano a cada um. Se só uma camada for afetada, chame só o agente dela.

5. INTEGRAÇÃO: confira se o front usa exatamente o contrato que o back implementou e se há "Mudanças de contrato" no plano que o outro lado não aplicou. Rode os testes definidos no CLAUDE.md.

6. REVISÃO: chame o subagente `reviewer` passando o caminho do plano. Registre o veredito na seção "Revisão" do plano.

7. CORREÇÃO: se o veredito for MUDANÇAS NECESSÁRIAS, envie cada achado BLOQUEANTE ou IMPORTANTE ao agente responsável (back ou front) e chame o `reviewer` de novo. No máximo 2 rodadas; se ainda houver bloqueantes, pare e me mostre os achados.

8. FECHAMENTO: atualize o status do plano para CONCLUÍDO e me mostre:
   - arquivos alterados
   - resultado real dos testes
   - ressalvas do revisor
   - mensagem de commit sugerida (seguindo a convenção do CLAUDE.md)
   Não faça commit.

Regra geral: nunca diga que algo passou sem ter visto a saída do comando.

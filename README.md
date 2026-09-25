# Time Dev

Time de desenvolvimento genérico para o Claude Code: um **tech lead**, um **dev back-end**, um **dev front-end** e um **revisor**, reaproveitáveis em qualquer projeto. O que muda de projeto para projeto fica só no `CLAUDE.md` de cada repositório.

A decisão completa de arquitetura está na minuta (`Minuta — Time de Desenvolvimento com Claude Code.docx`).

## O time

| Agente | Papel | Edita código? | Modelo |
| --- | --- | --- | --- |
| `tech-lead` | Plano, contrato de API, divisão de tarefas | Não (só o plano) | opus |
| `backend-dev` | API, regras de negócio, banco, testes de back | Sim | sonnet |
| `frontend-dev` | Telas, estado, integração, testes de front | Sim | sonnet |
| `reviewer` | Revisão de segurança, contrato, testes e padrões | Não | opus |

## Comandos

| Comando | Quando usar |
| --- | --- |
| `/init-projeto` | Primeira vez em um repositório: gera `CLAUDE.md`, `.claude/plans/` e `.claude/qualidade.json` |
| `/feature <descrição>` | Feature que envolve back e/ou front: plano → sua aprovação → implementação paralela → revisão → correção |
| `/fix <bug>` | Bug ou ajuste pequeno (1–2 arquivos) |
| `/plan <ideia>` | Só planejar, sem implementar |
| `/review [plano]` | Revisar o diff atual |

## Estrutura deste repositório

```
Time Dev/
├── agents/        # os 4 agentes
├── commands/      # /feature, /fix, /plan, /review, /init-projeto
├── templates/     # modelos de CLAUDE.md do projeto e de plano
├── hooks/         # formatação automática e verificação de testes (Node)
├── global/        # CLAUDE.md e settings.json globais (preferências e permissões)
├── scripts/       # instalar.js
└── docs/          # documentação adicional
```

## Instalação

### Primeira vez (Windows, tudo de uma vez)

```powershell
cd "C:\Users\jzuim\OneDrive\Documentos\IA\Time Dev"
powershell -ExecutionPolicy Bypass -File scripts\preparar-windows.ps1 -GitHub https://github.com/<usuario>/time-dev.git
```

Instala Git, Node.js e Claude Code se faltarem, cria o repositório Git (commit inicial + tag `v1.0`), envia para o GitHub e instala o time. Sem `-GitHub`, faz tudo menos o envio.

### Atualizar o time depois de editar algo

```powershell
node scripts/instalar.js --simular   # mostra o que vai fazer
node scripts/instalar.js             # instala em C:\Users\jzuim\.claude
```

O instalador:
- copia `agents/`, `commands/`, `templates/` e `hooks/` para `~/.claude/`;
- insere as preferências de `global/CLAUDE.md` no seu `~/.claude/CLAUDE.md` entre marcadores, sem apagar o resto;
- mescla `global/settings.json` no seu `~/.claude/settings.json` (só acrescenta; guarda backup em `settings.json.bak`).

**Sempre edite aqui, nunca direto em `~/.claude`.** Depois de mudar algo, rode `node scripts/instalar.js` de novo.

## Uso em um projeto novo

1. Abra o terminal na pasta do projeto e rode `claude`.
2. `/init-projeto` e complete os itens marcados `PREENCHER` no `CLAUDE.md` gerado.
3. `/feature <o que você quer>` e acompanhe as duas aprovações.

## Hooks de qualidade

Os hooks só agem em projetos que têm `.claude/qualidade.json`:

```json
{
  "formatar": "npx prettier --write {arquivo}",
  "verificar": "npm run lint && npm test"
}
```

- **formatar** roda depois de cada arquivo editado. Não bloqueia.
- **verificar** roda quando `backend-dev` ou `frontend-dev` terminam. Se falhar, o erro volta para o agente corrigir (uma vez; depois libera para não entrar em loop).

## Segurança

O `settings.json` global bloqueia para todos os agentes: ler ou editar `.env`, `git commit`, `git push` e `rm -rf`. O commit é sempre seu.

## Versionamento

- `main` = versão estável, a que está instalada.
- Mudanças maiores em branch própria (ex.: `fase-2-hooks`) e depois merge.
- Tag a cada fase concluída (`v1.0`, `v2.0`). Registre em `CHANGELOG.md`.

// Hook SubagentStop: quando backend-dev ou frontend-dev terminam, roda o comando
// "verificar" de .claude/qualidade.json. Se falhar, devolve o erro ao agente (exit 2)
// para ele corrigir antes de entregar. Na segunda tentativa libera, evitando loop.
const { execSync } = require('child_process');
const { lerEntrada, lerQualidade, dirProjeto } = require('./time-dev-comum');

const DEVS = ['backend-dev', 'frontend-dev'];

const entrada = lerEntrada();
if (entrada.stop_hook_active) process.exit(0);

// Quando o Claude Code informa qual agente terminou, só verifica os devs.
const tipo = entrada.agent_type || entrada.subagent_type || '';
if (tipo && !DEVS.includes(tipo)) process.exit(0);

const raiz = dirProjeto(entrada);
const cfg = lerQualidade(raiz);
if (!cfg || !cfg.verificar) process.exit(0);

try {
  execSync(cfg.verificar, { cwd: raiz, stdio: 'pipe', timeout: 300000 });
  process.exit(0);
} catch (e) {
  const saida = `${e.stdout || ''}\n${e.stderr || ''}`.trim().split('\n').slice(-40).join('\n');
  process.stderr.write(
    `[time-dev] A verificação "${cfg.verificar}" falhou. Corrija antes de entregar:\n${saida}\n`
  );
  process.exit(2);
}

// Hook PostToolUse (Edit|Write): formata o arquivo recém-editado
// usando o comando "formatar" de .claude/qualidade.json. Nunca bloqueia o trabalho.
const { execSync } = require('child_process');
const path = require('path');
const { lerEntrada, lerQualidade, dirProjeto } = require('./time-dev-comum');

const entrada = lerEntrada();
const raiz = dirProjeto(entrada);
const cfg = lerQualidade(raiz);
const arquivo = entrada.tool_input && entrada.tool_input.file_path;

if (!cfg || !cfg.formatar || !arquivo) process.exit(0);

// Não formata arquivos fora do projeto nem planos/markdown internos do time.
const rel = path.relative(raiz, arquivo);
if (rel.startsWith('..') || rel.startsWith('.claude')) process.exit(0);

const comando = cfg.formatar.split('{arquivo}').join(`"${arquivo}"`);
try {
  execSync(comando, { cwd: raiz, stdio: 'ignore', timeout: 60000 });
} catch {
  // Formatador falhou (arquivo não suportado etc.): segue sem bloquear.
}
process.exit(0);

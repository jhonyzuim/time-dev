// Funções compartilhadas pelos hooks do Time Dev.
// Os hooks só agem em projetos que têm .claude/qualidade.json (criado pelo /init-projeto).
const fs = require('fs');
const path = require('path');

function lerEntrada() {
  try {
    const bruto = fs.readFileSync(0, 'utf8');
    return bruto ? JSON.parse(bruto) : {};
  } catch {
    return {};
  }
}

function lerQualidade(dirProjeto) {
  const arq = path.join(dirProjeto, '.claude', 'qualidade.json');
  if (!fs.existsSync(arq)) return null;
  try {
    return JSON.parse(fs.readFileSync(arq, 'utf8'));
  } catch {
    process.stderr.write(`[time-dev] ${arq} não é um JSON válido; hooks ignorados.\n`);
    return null;
  }
}

function dirProjeto(entrada) {
  return process.env.CLAUDE_PROJECT_DIR || entrada.cwd || process.cwd();
}

module.exports = { lerEntrada, lerQualidade, dirProjeto };

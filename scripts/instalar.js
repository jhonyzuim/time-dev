#!/usr/bin/env node
// Instala o Time Dev no Claude Code do usuário (~/.claude).
// Uso:  node scripts/instalar.js           (instala/atualiza)
//       node scripts/instalar.js --simular (mostra o que faria, sem gravar)
//
// - agents/, commands/, templates/, hooks/  -> copiados (o repositório é a fonte oficial)
// - global/CLAUDE.md -> inserido em ~/.claude/CLAUDE.md entre marcadores (o resto do arquivo é preservado)
// - global/settings.json -> mesclado em ~/.claude/settings.json (nada existente é removido; backup .bak)

const fs = require('fs');
const path = require('path');
const os = require('os');

const SIMULAR = process.argv.includes('--simular');
const RAIZ = path.resolve(__dirname, '..');
const DESTINO = path.join(process.env.CLAUDE_CONFIG_DIR || path.join(os.homedir(), '.claude'));
const INICIO = '<!-- time-dev:inicio -->';
const FIM = '<!-- time-dev:fim -->';

const log = (msg) => console.log((SIMULAR ? '[simulação] ' : '') + msg);

function garantirPasta(p) {
  if (!SIMULAR) fs.mkdirSync(p, { recursive: true });
}

function gravar(arq, conteudo) {
  garantirPasta(path.dirname(arq));
  if (!SIMULAR) fs.writeFileSync(arq, conteudo, 'utf8');
}

function copiarPasta(nome) {
  const origem = path.join(RAIZ, nome);
  const destino = path.join(DESTINO, nome);
  const arquivos = fs.readdirSync(origem).filter((f) => fs.statSync(path.join(origem, f)).isFile());
  garantirPasta(destino);
  for (const f of arquivos) {
    if (!SIMULAR) fs.copyFileSync(path.join(origem, f), path.join(destino, f));
  }
  log(`✔ ${nome}/: ${arquivos.length} arquivo(s) → ${destino}`);
}

function instalarClaudeMd() {
  const bloco = `${INICIO}\n${fs.readFileSync(path.join(RAIZ, 'global', 'CLAUDE.md'), 'utf8').trim()}\n${FIM}`;
  const arq = path.join(DESTINO, 'CLAUDE.md');
  let atual = fs.existsSync(arq) ? fs.readFileSync(arq, 'utf8') : '';
  const re = new RegExp(`${INICIO}[\\s\\S]*?${FIM}`);
  const novo = re.test(atual) ? atual.replace(re, bloco) : (atual.trim() ? atual.trimEnd() + '\n\n' : '') + bloco + '\n';
  gravar(arq, novo);
  log(`✔ CLAUDE.md global ${re.test(atual) ? 'atualizado' : 'criado/complementado'} → ${arq}`);
}

function mesclarSettings() {
  const arq = path.join(DESTINO, 'settings.json');
  const nosso = JSON.parse(fs.readFileSync(path.join(RAIZ, 'global', 'settings.json'), 'utf8'));
  let atual = {};
  if (fs.existsSync(arq)) {
    try {
      atual = JSON.parse(fs.readFileSync(arq, 'utf8'));
    } catch {
      console.error(`✘ ${arq} não é um JSON válido. Corrija-o e rode de novo. Nada foi alterado nele.`);
      process.exitCode = 1;
      return;
    }
    if (!SIMULAR) fs.copyFileSync(arq, arq + '.bak');
  }

  // Permissões: união das listas deny.
  atual.permissions = atual.permissions || {};
  const deny = new Set(atual.permissions.deny || []);
  (nosso.permissions.deny || []).forEach((r) => deny.add(r));
  atual.permissions.deny = [...deny];

  // Hooks: adiciona os nossos se o mesmo comando ainda não estiver registrado.
  atual.hooks = atual.hooks || {};
  for (const [evento, grupos] of Object.entries(nosso.hooks)) {
    atual.hooks[evento] = atual.hooks[evento] || [];
    const existentes = JSON.stringify(atual.hooks[evento]);
    for (const g of grupos) {
      const cmd = g.hooks[0].command;
      if (!existentes.includes(cmd)) atual.hooks[evento].push(g);
    }
  }

  gravar(arq, JSON.stringify(atual, null, 2) + '\n');
  log(`✔ settings.json mesclado (permissões + hooks) → ${arq}${fs.existsSync(arq + '.bak') ? ' (backup: settings.json.bak)' : ''}`);
}

console.log(`Time Dev — instalando de ${RAIZ}\n`);
garantirPasta(DESTINO);
['agents', 'commands', 'templates', 'hooks'].forEach(copiarPasta);
instalarClaudeMd();
mesclarSettings();
console.log('\nPronto. Abra o Claude Code em um projeto, rode /agents para ver o time e /init-projeto para preparar o repositório.');

# Prepara o Windows para o Time Dev, em um passo só.
# Uso (no PowerShell, dentro da pasta Time Dev):
#   powershell -ExecutionPolicy Bypass -File scripts\preparar-windows.ps1
#   powershell -ExecutionPolicy Bypass -File scripts\preparar-windows.ps1 -GitHub https://github.com/<usuario>/time-dev.git
#
# O que faz (e pula o que já estiver pronto):
#   1. Instala Git e Node.js LTS via winget, se faltarem
#   2. Instala o Claude Code, se faltar
#   3. Configura nome/e-mail do Git, se faltarem
#   4. Cria o repositório Git da pasta, com o primeiro commit e a tag v1.0
#   5. Liga ao GitHub e envia (se -GitHub for informado)
#   6. Instala o time em ~/.claude (scripts/instalar.js)

param([string]$GitHub = "")

$ErrorActionPreference = "Stop"
$Raiz = Split-Path -Parent $PSScriptRoot
Set-Location $Raiz

function Passo($t)  { Write-Host "`n==> $t" -ForegroundColor Cyan }
function Ok($t)     { Write-Host "    OK  $t" -ForegroundColor Green }
function Aviso($t)  { Write-Host "    !!  $t" -ForegroundColor Yellow }
function Tem($cmd)  { [bool](Get-Command $cmd -ErrorAction SilentlyContinue) }
function AtualizarPath {
  $env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
              [Environment]::GetEnvironmentVariable("Path", "User") + ";" +
              "$env:USERPROFILE\.local\bin"
}

# 1. Git e Node --------------------------------------------------------------
Passo "Verificando Git e Node.js"
foreach ($item in @(@{cmd="git"; id="Git.Git"; nome="Git"}, @{cmd="node"; id="OpenJS.NodeJS.LTS"; nome="Node.js LTS"})) {
  if (Tem $item.cmd) { Ok "$($item.nome) já instalado ($(& $item.cmd --version))" }
  else {
    if (-not (Tem "winget")) { throw "winget não encontrado. Instale $($item.nome) manualmente e rode de novo." }
    Write-Host "    Instalando $($item.nome)..."
    winget install --id $item.id -e --accept-source-agreements --accept-package-agreements
    AtualizarPath
    if (Tem $item.cmd) { Ok "$($item.nome) instalado" } else { throw "$($item.nome) instalado, mas não apareceu no PATH. Feche e abra o PowerShell e rode de novo." }
  }
}

# 2. Claude Code -------------------------------------------------------------
Passo "Verificando Claude Code"
AtualizarPath
if (Tem "claude") { Ok "Claude Code já instalado ($(claude --version))" }
else {
  Write-Host "    Instalando Claude Code (instalador oficial)..."
  Invoke-RestMethod https://claude.ai/install.ps1 | Invoke-Expression
  AtualizarPath
  if (Tem "claude") { Ok "Claude Code instalado" } else { Aviso "Instalado, mas o comando 'claude' só aparece num PowerShell novo." }
}

# 3. Identidade do Git --------------------------------------------------------
Passo "Configurando identidade do Git"
$nome  = git config --global user.name
$email = git config --global user.email
if (-not $nome)  { $nome  = Read-Host "    Seu nome para os commits";  git config --global user.name  "$nome" }
if (-not $email) { $email = Read-Host "    Seu e-mail para os commits"; git config --global user.email "$email" }
Ok "Commits como: $nome <$email>"

# 4. Repositório -------------------------------------------------------------
Passo "Criando o repositório Git"
if (Test-Path (Join-Path $Raiz ".git")) { Ok "Repositório já existe — pulando" }
else {
  git init -b main | Out-Null
  git add -A
  $msg = @"
feat: fase 1 do Time Dev

Agentes tech-lead, backend-dev, frontend-dev e reviewer; comandos
/feature, /fix, /plan, /review e /init-projeto; templates, hooks,
configurações globais e instalador.

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_01VaAFx7NuawvZvQ3NZSQ8Gw
"@
  git commit -q -m $msg
  git tag v1.0
  Ok "Primeiro commit criado na branch main, com a tag v1.0"
}

# 5. GitHub ------------------------------------------------------------------
if ($GitHub) {
  Passo "Enviando para o GitHub"
  if (git remote) { git remote set-url origin $GitHub } else { git remote add origin $GitHub }
  git push -u origin main --tags
  Ok "Enviado para $GitHub"
} else {
  Aviso "GitHub não informado. Depois, rode:  git remote add origin <url> ; git push -u origin main --tags"
}

# 6. Instalar o time ---------------------------------------------------------
Passo "Instalando o time em $env:USERPROFILE\.claude"
node scripts\instalar.js

Write-Host "`nTudo pronto." -ForegroundColor Green
Write-Host "Próximo passo: abra um PowerShell NOVO, entre na pasta de um projeto e rode 'claude'."
Write-Host "Na primeira vez ele pede login. Depois use /agents para ver o time e /init-projeto."

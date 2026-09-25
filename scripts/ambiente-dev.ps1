# Diagnóstico e instalação do ambiente de desenvolvimento no Windows.
#
# Só verificar (não instala nada) e gerar relatorios\ambiente.md:
#   powershell -ExecutionPolicy Bypass -File scripts\ambiente-dev.ps1
#
# Instalar o que faltar:
#   ... scripts\ambiente-dev.ps1 -Instalar essencial
#   ... scripts\ambiente-dev.ps1 -Instalar recomendado     (essenciais + recomendados)
#   ... scripts\ambiente-dev.ps1 -Instalar tudo            (inclui opcionais, como Docker e PHP)
#   ... scripts\ambiente-dev.ps1 -Instalar "DBeaver,Docker Desktop"   (itens específicos pelo nome)

param([string]$Instalar = "")

$ErrorActionPreference = "Continue"
$Raiz = Split-Path -Parent $PSScriptRoot

function AtualizarPath {
  $env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
              [Environment]::GetEnvironmentVariable("Path", "User") + ";" +
              "$env:USERPROFILE\.local\bin"
}

function Versao($cmd, $arg) {
  $c = Get-Command $cmd -ErrorAction SilentlyContinue
  if (-not $c) { return $null }
  # Ignora os atalhos falsos da Microsoft Store (python.exe em WindowsApps que só abre a loja).
  if ($c.Source -like "*\WindowsApps\python*") { return $null }
  try {
    $saida = & $cmd $arg 2>&1 | Select-Object -First 1
    if ($saida) { return ("$saida").Trim() } else { return "instalado" }
  } catch { return "instalado" }
}

function NoWinget($id) {
  $r = winget list -e --id $id --accept-source-agreements 2>$null | Out-String
  return ($r -match [regex]::Escape($id))
}

# Grupo | Nome | comando | argumento de versão | id do winget | para que serve
$lista = @(
  @("essencial",   "Git",              "git",     "--version", "Git.Git",                     "Controle de versão"),
  @("essencial",   "GitHub CLI",       "gh",      "--version", "GitHub.cli",                  "Login no GitHub, PRs e repositórios pelo terminal"),
  @("essencial",   "Node.js LTS",      "node",    "--version", "OpenJS.NodeJS.LTS",           "Front-end, ferramentas JS, hooks do Time Dev"),
  @("essencial",   "Python 3.12",      "python",  "--version", "Python.Python.3.12",          "Scripts, automações, back-ends em Python"),
  @("essencial",   "VS Code",          "code",    "--version", "Microsoft.VisualStudioCode",  "Editor de código"),
  @("essencial",   "PowerShell 7",     "pwsh",    "--version", "Microsoft.PowerShell",        "Terminal moderno (o do Windows é o 5.1)"),
  @("essencial",   "Windows Terminal", "wt",      "",          "Microsoft.WindowsTerminal",   "Abas e perfis de terminal"),
  @("essencial",   "Claude Code",      "claude",  "--version", "",                            "O próprio Time Dev"),
  @("recomendado", "pnpm",             "pnpm",    "--version", "pnpm.pnpm",                   "Gerenciador de pacotes JS rápido"),
  @("recomendado", "DBeaver",          "",        "",          "DBeaver.DBeaver.Community",             "Cliente visual de banco de dados (MySQL, Postgres, SQL Server...)"),
  @("recomendado", "Bruno",            "",        "",          "Bruno.Bruno",                 "Testar APIs (alternativa leve ao Postman, salva em arquivos no Git)"),
  @("recomendado", "7-Zip",            "",        "",          "7zip.7zip",                   "Compactar e extrair arquivos"),
  @("opcional",    "Docker Desktop",   "docker",  "--version", "Docker.DockerDesktop",        "Bancos e serviços em contêiner (exige WSL, pesado)"),
  @("opcional",    "PHP 8.4",          "php",     "--version", "PHP.PHP.8.4",                 "Projetos Laravel/PHP"),
  @("opcional",    "Composer",         "composer","--version", "Composer.Composer",           "Pacotes PHP"),
  @("opcional",    ".NET SDK 8",       "dotnet",  "--version", "Microsoft.DotNet.SDK.8",      "Projetos C#/.NET"),
  @("opcional",    "Java JDK 21",      "java",    "--version", "Microsoft.OpenJDK.21",        "Projetos Java/Android")
)

AtualizarPath
$temWinget = [bool](Get-Command winget -ErrorAction SilentlyContinue)

function Diagnosticar {
  $res = @()
  foreach ($i in $lista) {
    $v = $null
    if ($i[2]) { $v = Versao $i[2] $i[3] }
    if (-not $v -and $i[4] -and $temWinget) { if (NoWinget $i[4]) { $v = "instalado" } }
    $res += [pscustomobject]@{ Grupo=$i[0]; Nome=$i[1]; Status=$(if ($v) {"OK"} else {"FALTA"}); Versao=$(if ($v) {$v} else {""}); Id=$i[4]; Uso=$i[5] }
  }
  return $res
}

Write-Host "`nVerificando ferramentas..." -ForegroundColor Cyan
$res = Diagnosticar

# Instalação ---------------------------------------------------------------
if ($Instalar) {
  if (-not $temWinget) { Write-Host "winget não encontrado; instale o 'App Installer' pela Microsoft Store." -ForegroundColor Red; exit 1 }
  $grupos = switch ($Instalar) { "essencial" {@("essencial")} "recomendado" {@("essencial","recomendado")} "tudo" {@("essencial","recomendado","opcional")} default {@()} }
  $nomes  = if ($grupos.Count -eq 0) { $Instalar.Split(",") | ForEach-Object { $_.Trim() } } else { @() }
  $alvo = $res | Where-Object { $_.Status -eq "FALTA" -and (($grupos -contains $_.Grupo) -or ($nomes -contains $_.Nome)) }
  foreach ($t in $alvo) {
    Write-Host "`n==> Instalando $($t.Nome)" -ForegroundColor Cyan
    if ($t.Nome -eq "Claude Code") { Invoke-RestMethod https://claude.ai/install.ps1 | Invoke-Expression; continue }
    if ($t.Nome -eq "Docker Desktop") { Write-Host "    Docker precisa do WSL; ativando (pode pedir reinício)..."; wsl --install --no-distribution }
    winget install --id $t.Id -e --accept-source-agreements --accept-package-agreements
    if ($LASTEXITCODE -ne 0) { Write-Host "    !! Falhou ($LASTEXITCODE). Veja a mensagem acima." -ForegroundColor Yellow }
  }
  AtualizarPath
  Write-Host "`nVerificando de novo..." -ForegroundColor Cyan
  $res = Diagnosticar
}

# Configurações que não são programas ----------------------------------------
$extras = @()
if (Get-Command git -ErrorAction SilentlyContinue) {
  $extras += "Git user.name: $(git config --global user.name)"
  $extras += "Git user.email: $(git config --global user.email)"
  $extras += "Git init.defaultBranch: $(git config --global init.defaultBranch)"
  $extras += "Git core.autocrlf: $(git config --global core.autocrlf)"
  $extras += "Git credential.helper: $(git config --global credential.helper)"
}
if (Get-Command gh -ErrorAction SilentlyContinue) {
  $st = gh auth status 2>&1 | Out-String
  $extras += "GitHub CLI logado: $(if ($st -match 'Logged in') {'sim'} else {'não'})"
}
$wsl = (wsl --status 2>&1 | Out-String) -replace "`0", ""
$extras += "WSL: $(if ($wsl -match 'Default Version|Versão Padrão|Vers') {'ativado'} else {'não ativado'})"
$extras += "Modo desenvolvedor do Windows: $(if ((Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock' -ErrorAction SilentlyContinue).AllowDevelopmentWithoutDevLicense -eq 1) {'ligado'} else {'desligado'})"
$extras += "Caminhos longos (LongPathsEnabled): $(if ((Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem' -ErrorAction SilentlyContinue).LongPathsEnabled -eq 1) {'ligado'} else {'desligado'})"
$extras += "Windows: $((Get-CimInstance Win32_OperatingSystem).Caption) $((Get-CimInstance Win32_OperatingSystem).Version)"
$extras += "RAM: $([math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory/1GB)) GB | Disco C: livre: $([math]::Round((Get-PSDrive C).Free/1GB)) GB"
if (Test-Path "$env:USERPROFILE\.claude") {
  $ag = (Get-ChildItem "$env:USERPROFILE\.claude\agents" -Filter *.md -ErrorAction SilentlyContinue | ForEach-Object BaseName) -join ", "
  $extras += "Time Dev instalado em ~/.claude: agentes = $ag"
} else { $extras += "Time Dev instalado em ~/.claude: não" }

# Saída ----------------------------------------------------------------------
$res | Format-Table Grupo, Nome, Status, Versao -AutoSize
$extras | ForEach-Object { Write-Host "  $_" }

$pasta = Join-Path $Raiz "relatorios"
New-Item -ItemType Directory -Force -Path $pasta | Out-Null
$md = @("# Ambiente de desenvolvimento", "", "Gerado em $(Get-Date -Format 'yyyy-MM-dd HH:mm')", "",
        "| Grupo | Ferramenta | Status | Versão | Para que serve |", "| --- | --- | --- | --- | --- |")
$md += $res | ForEach-Object { "| $($_.Grupo) | $($_.Nome) | $($_.Status) | $($_.Versao) | $($_.Uso) |" }
$md += @("", "## Configurações", "")
$md += $extras | ForEach-Object { "- $_" }
$arq = Join-Path $pasta "ambiente.md"
[IO.File]::WriteAllLines($arq, $md, (New-Object Text.UTF8Encoding $false))
Write-Host "`nRelatório salvo em $arq" -ForegroundColor Green

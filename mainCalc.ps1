# Calcular taxa de sucesso dos requests
# Ivo Dias

# Configuracoes
$grupoRecursos = ""
$nomeLogicApp = ""
$AzSubscription = ""
$limitepaginas = "200"

# Funcoes
function Configurar-Modulo {
    param (
        $nomeModulo
    )
    # Caso ele exista, faz apenas a importacao
    if (Get-Module -ListAvailable -Name $nomeModulo) {
        Write-Host "Importando modulos"
        Import-Module $nomeModulo -Force
    } else {
        Write-Host "Instalando modulos necessarios"
        Install-Module $nomeModulo -AllowClobber -Force
        Import-Module $nomeModulo -Force
    }
}

# Verificacoes iniciais
Configurar-Modulo Az.LogicApp

# Conectar ao Azure
Connect-AzAccount
Set-AzContext -Subscription "$AzSubscription"

# Calcula a quantidade de retornos analisados
[int]$limitepaginas += 1
[int]$totalAnalisado = 30 * $limitepaginas

# Recebe o total de requests
$totalRun = Get-AzLogicAppRunHistory -ResourceGroupName "$grupoRecursos" -Name "$nomeLogicApp"  -FollowNextPageLink -MaximumFollowNextPageLink $limitepaginas
[int]$Run = $totalRun.count

# Recebe o total das falhas
$totalFalhas = $totalRun | Where-Object {$_.Status -eq "Failed"}
[int]$Fail = $totalFalhas.count

# Calcula taxa
[Float]$taxa = ($fail*100)/$run
$taxa = [math]::Round($taxa,2)

# Retorna a mensagem
Write-Host "Analise dos ultimos $totalAnalisado resultados"
Write-Host "Total de retornos encontrados: $Run"
Write-Host "Total de falhas encontrados: $Fail"
Write-Host "A taxa de falha foi de $taxa"
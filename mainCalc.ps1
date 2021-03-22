# Calcular taxa de sucesso dos requests
# Ivo Dias

# Configuracoes
$grupoRecursos = "" # Nome do Grupo de Recursos onde foi criado o App
$nomeLogicApp = "" # Nome do Logic App conforme esta no Azure
$AzSubscription = "" # ID da Subscricao no Azure
$limitepaginas = "200" # Limite de paginas para serem analisadas (30 resultados por pagina)

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
Configurar-Modulo Az.LogicApp # Faz a instalacao do modulo se necessario

# Conectar ao Azure
Connect-AzAccount # Conecta na conta (vai aparecer um prompt para entrar)
#Set-AzContext -Subscription "$AzSubscription" # Seleciona a subscricao (deixe comentado, pois nem sempre tem mais de uma na conta)

# Calcula a quantidade de retornos analisados
[int]$limitepaginas += 1
[int]$totalAnalisado = 30 * $limitepaginas

# Recebe o total de requests
$totalRun = Get-AzLogicAppRunHistory -ResourceGroupName "$grupoRecursos" -Name "$nomeLogicApp"  -FollowNextPageLink -MaximumFollowNextPageLink $limitepaginas
[int]$Run = $totalRun.count # Calcula a quantidade de retornos

# Recebe o total das falhas
$totalFalhas = $totalRun | Where-Object {$_.Status -eq "Failed"} # Filtra os que falharam com base no status
[int]$Fail = $totalFalhas.count # Calcula a quantidade de retornos

# Calcula taxa em %
[Float]$taxa = ($fail*100)/$run
$taxa = [math]::Round($taxa,2)

# Retorna a mensagem
Write-Host "Analise dos ultimos $totalAnalisado resultados"
Write-Host "Total de retornos encontrados: $Run"
Write-Host "Total de falhas encontrados: $Fail"
Write-Host "A taxa de falha foi de $taxa"
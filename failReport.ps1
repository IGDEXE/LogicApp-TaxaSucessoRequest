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

# Recebe todos os que falharam
Write-Host "Analisando as ultimas $totalAnalisado entradas"
$falhas = Get-AzLogicAppRunHistory -ResourceGroupName "$grupoRecursos" -Name "$nomeLogicApp"  -FollowNextPageLink -MaximumFollowNextPageLink $limitepaginas | Where-Object {$_.Status -eq "Failed"}
$totalFalhas = $falhas.count

# Exibe as falhas filtradas
Clear-Host
Write-Host "Historico de falhas"
Write-Host "Logic App name: $nomeLogicApp"
Write-Host "Total de execucoes analisadas: $totalAnalisado"
Write-Host "Total de falhas: $totalFalhas"
Write-Host "--------------------------------------------"
foreach ($falha in $falhas) {
    # Recebe os valores unicos de cada erro
    $id = $falha.Name
    $inicio = $falha.StartTime
    $fim = $falha.EndTime
    # Escreve na tela um pequeno relatorio
    Write-Host "ID do erro: $id"
    Write-Host "Inicio: $inicio - Fim: $fim"
    Write-Host "--------------------------------------------"
}
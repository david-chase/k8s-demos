param (
    [string]$namespace,
    [string]$n
 )

Write-Host ""
Write-Host ::: Get-Pods-By-Node v2 ::: -ForegroundColor Cyan
Write-Host ""

if( $n -ne "" ) { $namespace = $n }
if( $namespace -eq "" ) {
    Write-Host Running "kubectl get ns" -ForegroundColor Cyan
    kubectl get ns
    Write-Host `nPlease enter a namespace ('or "all"'): -ForegroundColor Green 
    $namespace = Read-Host
} # if( $namespace -eq "" )

$sRawOutput = kubectl get no
$aNodes = @()
# Write-Host $sRawOutput.Length
for( $i = 1; $i -le ( $sRawOutput.Length - 1 ); $i++ ) {
    $aNodes += $sRawOutput[ $i ].Split( " " )[ 0 ]
}

if( $namespace.ToLower() -ne "all" ) { 
    $sRawOutput = kubectl get po -n $namespace -o wide
    $iNameOffset = 0
    $iStatusOffset = 2
    $iRestartsOffset = 3
    $iAgeOffset = 4
    $iNodeOffset = 6
} else { 
    $sRawOutput = kubectl get po --all-namespaces -o wide 
    $iNameOffset = 1
    $iStatusOffset = 3
    $iRestartsOffset = 4
    $iAgeOffset = 5
    $iNodeOffset = 7
}

# Parse the pods info
$aPods = @()
for( $i = 1; $i -le ( $sRawOutput.Length - 1 ); $i++ ) {
    $aSplitString = $sRawOutput[ $i ] -split '\s+'
    $aPods += [PSCustomObject]@{ name = $aSplitString[ $iNameOffset ]; status = $aSplitString[ $iStatusOffset ]; `
        restarts = $aSplitString[ $iRestartsOffset ]; age = $aSplitString[ $iAgeOffset ]; node = $aSplitString[ $iNodeOffset ] }
}

foreach( $sNode in $aNodes ) {
    Write-Host $sNode -ForegroundColor Yellow
    $aPodsThisNode = $aPods | Where-Object { $_.node -Match $sNode }
    $aPodsThisNode | Select-Object -Property name, status, restarts, age | Out-Host
} # foreach( $sNode in $aNodes )

[CmdletBinding]

function DataFromJsonToCsv {
    param (
        [Parameter(Mandatory=$true)]$jsonfilepath,
        [Parameter(Mandatory=$true)][string]$csvFolderPath,
        [Parameter(Mandatory=$true)]$ActionObj
    )
    $outputTable = @()
    $baseName = $jsonfilepath.BaseName
    #$currenTime = (get-date((get-date).ToUniversalTime()) -Format o)
    $currenTime = (get-date((get-date).ToUniversalTime()) -Format yyyyMMddhhmmss)
    try {
        $jsonFile = Get-Content $_.FullName  | convertfrom-json 
        foreach($action in $actions){
            Write-Host $action -ForegroundColor Green
            $jconfigs = $jsonFile.$action
            foreach($jconfig in $jconfigs){
                    $id = $jconfig.'$id'
                    if($jconfig.source.'$description'){
                        $descr=$jconfig.source.'$description'
                    }
                    elseif ($jconfig.target.'$description') {
                        $descr=$jconfig.target.'$description'
                    }
                    else{$descr=$null}
                    Write-Host "$($action)-$($jconfig.name)-$($jconfig.action)-$($descr)" -ForegroundColor Blue
                    #write to csv
                    $jconfig | ConvertTo-Csv | Out-File "$csvFolderPath\$($currenTime)_$($baseName)_$($action)_$($id).csv"
                }
        }
        return 0
    }
    catch {
        $errorMessage = $_.Exception.Message
        Write-Host $errorMessage -ForegroundColor Red
        return 11
    }
    
}

### this might be conveted in input parameters
#Jspn folder Full Path
$jsonPath = "<Full Path to folder with json files>"
#csv output folder full path
$csvFolder = "<Full Path to folder that will contains csv files>"
##############################################

$actions = @('created','deleted','failed','skipped','unchanged','updated')
$jsonFiles = Get-ChildItem $jsonPath "*.json"

$jsonFiles | ForEach-Object{
    if ((DataFromJsonToCsv -jsonfilepath $_ -csvFolderPath $csvFolder -ActionObj $actions) -eq 0){
        Write-Host "$($_.Name) Processed successfully" 
    }
    else {
        Write-Host "$($_.Name) Processed with error"
        Write-Host $errorMessage -ForegroundColor Red
    }
}


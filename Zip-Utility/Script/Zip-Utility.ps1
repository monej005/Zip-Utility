#Please Update the loacal path below to your local path
param ([string] $fileName = "C:\LocalPath\Zip-Utility\Config\Zip-Utility.xml")

function Load-xml{
    param($FileName)
    if(!(test-path $FileName)){
        Write-Host "Unable to find : $FileName"
        Exit
    }
    $ErrorActinPreference = "Continue"
    $xml = New-Object System.Xml.XmlDocument
    $xml.PreserveWhitespace = $true
    $xml.Load($FileName)
    $xml
}

function Zip-Directory {
    param($Source)
    
    Compress-Archive -Path "$Source/*" -DestinationPath "$Source.zip" -Force
}

function Move-Item {
    param($SourceZip, $Destination)
    
    if(!(Test-Path -Path $SourceZip)){
        Write-Host ("Unable to find $SourceZip")
        Exit
    }
    if(!(Test-Path -Path $Destination))
    {
        New-Item -ItemType Directory -Force -Path $Destination
    }
    Copy-Item $SourceZip -Destination "$Destination\" -Force 
}

function Unzip-Directory {
    param($Source, $Destination)
    if(!(Test-Path -Path $Destination)){
    Write-Host ("Unable to find $Destination")
    #Exit
    }
    Expand-Archive -LiteralPath "$Destination\$(Split-Path -leaf $Source)" -DestinationPath $Destination -Force
}

#Load in XML
$xml=Load-xml -FileName $filename
$Directories = $xml.SelectNodes("Directories/Directory")

#Loop for each node
foreach ($Directory in $Directories) {
    $Source = $Directory.GetAttribute("Source")
    $SourceZip = "$Source.zip"
    $Destination = $Directory.GetAttribute("Destination")
    $DestinationZip = "$Destination.zip"
    
    Zip-Directory $Source
    Move-Item $SourceZip $Destination
    Unzip-Directory $SourceZip $Destination
}

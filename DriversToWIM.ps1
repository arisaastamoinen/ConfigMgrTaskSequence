# Drivers To WIM
$SiteCode = "AB1"
Set-Location "$($SiteCode):"

# SubTS for installing drivers
# Contains old-style driver packages for all models 
$tsName = 'Install Windows 10 version 1909 x64 Drivers'

# Get TS and its 'Apply Driver Pack' steps
$ts = Get-CMTaskSequence -Name $tsName
$tsStep = Get-CMTaskSequenceStep -InputObject $ts | where {$_.SmsProviderObjectPath -eq 'SMS_TaskSequence_ApplyDriverPackageAction'}

# Get driver pakcage details
$drvPackInfo = foreach ($x in $tsStep) {
    Get-CMDriverPackage -Id $x.DriverPackageID | Select PackageID,DriverManufacturer,Name,Description
}

# Ready start exporting drivers to disk
$exportPath = 'E:\ExportedDrivers'
if (-not(Test-Path -Path "$exportPath")) {
        New-Item -ItemType directory -Path "$exportPath"
}

foreach ($dpi in $drvPackInfo) {
    # Create directories and export
    if (-not(Test-Path -Path "$exportPath\$($dpi.DriverManufacturer)")) {
        New-Item -ItemType directory -Path "$exportPath\$($dpi.DriverManufacturer)"
    }
    if (-not(Test-Path -Path "$exportPath\$($dpi.DriverManufacturer)\$($dpi.Name)")) {
        New-Item -ItemType directory -Path "$exportPath\$($dpi.DriverManufacturer)\$($dpi.Name)"
    }
    Write-Output "Exporting drivers for '$($dpi.Name)' to $exportPath\$($dpi.DriverManufacturer)\$($dpi.Name)\$($dpi.PackageID).zip" 
    Export-CMDriverPackage -Id $dpi.PackageID -ExportFilePath "$exportPath\$($dpi.DriverManufacturer)\$($dpi.Name)\$($dpi.PackageID).zip"
}

Set-Location $exportPath

# Bits are on the disk, lets create WIM for each model
foreach ($dpi in $drvPackInfo) {
    if (Test-Path -Path "$exportPath\$($dpi.DriverManufacturer)\$($dpi.PackageID).wim") {
        Remove-Item "$exportPath\$($dpi.DriverManufacturer)\$($dpi.PackageID).wim" -Force
    }
    New-WindowsImage -ImagePath "$exportPath\$($dpi.DriverManufacturer)\$($dpi.PackageID).wim" `
        -CapturePath "$exportPath\$($dpi.DriverManufacturer)\$($dpi.Name)" -CompressionType Max `
        -Description "$($dpi.Description)" -Name "$($dpi.Name)"
    # We dont need this anymore
    Remove-Item "$exportPath\$($dpi.DriverManufacturer)\$($dpi.Name)" -Recurse -Force
}
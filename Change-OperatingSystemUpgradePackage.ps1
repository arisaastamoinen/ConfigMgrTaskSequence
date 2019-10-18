
# Task Sequence 
$ts = Get-CMTaskSequence -Name 'Windows 10 version 1909 In-Place Upgrade'

# New Upgrade OS Package
$pkg = Get-CMOperatingSystemUpgradePackage -Name 'Windows 10 Enterprise x64 version 1909'

# OS Upgrade step(s) in TS
$tsStep = Get-CMTaskSequenceStepUpgradeOperatingSystem -TaskSequenceId $ts.PackageID | select InstallPackageID,Name 

# Loop each upgrade step and change the Upgrade Package
foreach ($u in $tsStep) {
    $oldPkg = Get-CMOperatingSystemUpgradePackage -Id $($u.InstallPackageID) | select -ExpandProperty Name
    Write-Output "Upgrade Step [$($u.name)] before update has OperatingSystemUpgradePackage [$oldPkg]"
    Write-Output "Changing OperatingSystemUpgradePackage to [$($pkg.Name)]"
    Set-CMTaskSequenceStepUpgradeOperatingSystem -TaskSequenceId $ts.PackageID  -UpgradePackage $pkg
}




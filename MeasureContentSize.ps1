# Pick any of these
$TaskSequenceName = 'Windows 10 version 1909 Upgrade Readines (silent)'
$TaskSequenceName = 'Windows 10 version 1909 In-Place Upgrade'
$TaskSequenceName = 'Windows 10 version 1909 Bare Metal'

# Your Site Code
$SiteCode = "M42"

# Reference to the TS
$TSID = Get-WmiObject -Namespace ROOT\sms\Site_$SiteCode -Query "Select PackageID from SMS_PackageStatusDetailSummarizer where Name = '$TaskSequenceName'" |
    Select -ExpandProperty PackageID

# Packages in the TS
$PKGs = Get-WmiObject -Namespace ROOT\sms\Site_$SiteCode -Query "Select * from SMS_TaskSequencePackageReference where PackageID = '$TSID'" | 
    Select @{N='PackageName';E={$_.ObjectName}},@{N='Size (MB)';E={$($_.SourceSize / 1KB).ToString(",00")}} | Sort PackageName

# Measure it
$PKGs | Measure-Object "Size (MB)" -Sum

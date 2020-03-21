
# Connect to SCCM, change location
Set-Location SITEX01:

# This is the TS step name that we're going to fix
$FaultyTSStepName = 'Pre-Flight with multiple scenarios'

# Get Task Sequences which have the TS conditions you'd like to change
$tsAll = Get-CMTaskSequence | where {$_.Name -like 'Windows 10 Upgrade*'} | Select PackageID,Name

# You could/should filter more on the TS details but I'll leave it to Donna 

# New Conditions in the TS Step
# We're going to wipe out the old conditions and insert new
# 
# New TS 
# It doesn't matter which these conditions are, you have The Power!
$tsCond1 = New-CMTaskSequenceStepConditionVariable -OperatorType NotEquals -ConditionVariableName "_SMSTSLastActionRetCode" -ConditionVariableValue "-1"
$tsCond2 = New-CMTaskSequenceStepConditionVariable -OperatorType Equals -ConditionVariableName "PreFlightCheck" -ConditionVariableValue "1"

# loop loop
foreach ($ts in $tsall) {
    # Print the name so we know something is happening
    $ts.Name 

    # Old
    Set-CMTaskSequenceStepRunCommandLine -TaskSequenceId $ts.PackageID -StepName $FaultyTSStepName -ClearCondition
    # New
    Set-CMTaskSequenceStepRunCommandLine -TaskSequenceId $ts.PackageID -StepName $FaultyTSStepName  -AddCondition $tsCond1
    Set-CMTaskSequenceStepRunCommandLine -TaskSequenceId $ts.PackageID -StepName $FaultyTSStepName  -AddCondition $tsCond2
}

# That's it!


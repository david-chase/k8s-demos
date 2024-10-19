$sRoleName = "KarpenterNodeRole-dchase-karpenter-testing"

$aInstanceProfiles = aws iam list-instance-profiles-for-role --role-name $sRoleName --output json | ConvertFrom-json

    # $aInstanceProfiles | Out-Host
    # $aInstanceProfiles.Count | Out-Host
    # $aInstanceProfiles[ 0 ].InstanceProfileId | Out-Host

for( $i = 0; $i -lt $aInstanceProfiles.Count; $i++ ) {
    $aInstanceProfiles.InstanceProfiles[ $i ].InstanceProfileName | Out-Host
    aws iam remove-role-from-instance-profile --instance-profile-name $aInstanceProfiles.InstanceProfiles[ $i ].InstanceProfileName --role-name $sRoleName
}
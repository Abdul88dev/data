
#check if the Ms365 User existed
function check-MsolUser {
    param([string]$UserPrincipleName)

    $existed = $true 
    try 
    {
        $user=Get-MsolUser -UserPrincipalName $UserPrincipleName
    }
    catch 
    {
    $existed = $false
    }
    $existed
}


#connect to Ms365 
Connect-MsolService 
$domain = (Get-MsolDomain)
$users = Import-Csv -Path C:\data\Year1.csv
$password = ConvertTo-SecureString "Pa55w.rd1234" -AsPlainText -Force
foreach($user in $users)
{
$firsname = $user.FIRSTNAME
$lastname = $user.LASTNAME
$displayname = $firsname +" " +$lastname
$upn  = $firsname[0]+"."+ $lastname+"@"+$domain.name
    iF(!(check-MsolUser -UserPrincipleName $upn))
    {
         New-MsolUser -DisplayName $displayname -FirstName $firsname -LastName $lastname -UserPrincipalName $upn -UsageLocation US  -Password $password
    }
    else {
        Write-Verbose -Message 'The user you are trying to add already existed or duplicate UPN Name ' -Verbose
    }
}

#set a licence to the users with L 
$msusers=Get-MsolUser -UnlicensedUsersOnly
$licence = "M365x07744838:DESKLESSPACK"
foreach($msuser in $msusers)
{
    if($msuser.Displayname[0] -eq "l")
        {
           Get-MsolUser -UserPrincipalName $msuser.UserPrincipalName |Set-MsolUserLicense -AddLicenses $licence
        }
}



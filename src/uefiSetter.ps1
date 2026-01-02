### Elevation ###

# Get the ID and security principal of the current user account
$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)

# Get the security principal for the Administrator role
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator

# Check to see if we are currently running "as Administrator"
if ($myWindowsPrincipal.IsInRole($adminRole))
{
    # We are running "as Administrator" - so change the title and background color to indicate this
    $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + "(Elevated)"
    $Host.UI.RawUI.BackgroundColor = "DarkBlue"
    clear-host
}
else
{
    # We are not running "as Administrator" - so relaunch as administrator

    # Create a new process object that starts PowerShell
    $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";

    # Specify the current script path and name as a parameter
    $newProcess.Arguments = $myInvocation.MyCommand.Definition;

    # Indicate that the process should be elevated
    $newProcess.Verb = "runas";

    # Start the new process
    [System.Diagnostics.Process]::Start($newProcess);

    # Exit from the current, unelevated, process
    exit
}

### UEFI password setting ###

$scriptPath = $PSScriptRoot

function getManufacturer {
    $computerSystem = Get-WmiObject -Class Win32_ComputerSystem
    return $computerSystem.Manufacturer
}

function setPasswordHP {
    param (
        [string]$password
    )
    & "$scriptPath\HPQPswd.exe" /s /p"$password" /f"$scriptPath\mdp.bin"
    & "$scriptPath\BiosConfigUtility.exe" /npwdfile:"$scriptPath\mdp.bin" > $null 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Succès : La configuration du BIOS a ete appliquee." -ForegroundColor Green
    } else {
        Write-Host "Erreur : Un mot de passe Bios est deja defini ou la commande a echoue." -ForegroundColor Red
    }
}

$manufacturer = getManufacturer
Write-Host "Computer Manufacturer: $manufacturer"

if ($manufacturer -like "HP*") {
    $password = Read-Host "Enter the UEFI password to set"
    setPasswordHP -password $password
} elseif ($manufacturer -like "Dell") {
    Write-Host "Dell UEFI password setting is not yet implemented."
} else {
    Write-Host "Unsupported manufacturer: $manufacturer"
}
Write-Host -NoNewLine "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
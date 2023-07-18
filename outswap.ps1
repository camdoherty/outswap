# outswap0.1.ps1
# A simple command line interface for the Windows utility Display Manager 2 (dc2.exe)

# The path to the dc2.exe executable
$dc2 = "C:\Program Files\12noon Display Changer II\dc2.exe"

# The path to the outswap-configs.xml file
$configs = "C:\Users\$env:USERNAME\Documents\outswap-configs.xml"

# A function to display a menu with options
function Show-Menu {
    param (
        [string]$Title = 'Outswap Menu'
    )
    Clear-Host
    Write-Host "================ $Title ================"
    Write-Host "1. Save the current display config"
    Write-Host "2. Load a saved display config"
    Write-Host "3. Exit"
}

# A function to save the current display config
function Save-Config {
    param (
        [string]$Name # The name of the config
    )
    # The path to the config file
    $path = "C:\Users\$env:USERNAME\Documents\$Name.xml"
    
    # Save the current config using the -create switch
    & $dc2 -create="$path"

    # Create an XML element for the config
    $config = $configs.CreateElement("config")
    $config.SetAttribute("name", $Name)
    $config.SetAttribute("path", $path)

    # Append the element to the root of the XML file
    $configs.DocumentElement.AppendChild($config)

    # Save the XML file
    $configs.Save($configs.FullName)
}

# A function to load a saved display config
function Load-Config {
    param (
        [string]$Name # The name of the config
    )
    # Find the config element with the matching name attribute
    $config = $configs.SelectSingleNode("//config[@name='$Name']")

    # Get the path attribute of the config element
    $path = $config.GetAttribute("path")

    # Load the config using the -configure switch
    & $dc2 -configure="$path"
}

# Load the XML file or create a new one if it does not exist
if (Test-Path $configs) {
    $configs = xml
} else {
    $configs = New-Object xml
    $configs.LoadXml("<outswap></outswap>")
}

# Loop until the user exits
do {
    # Show the menu and get the user's choice
    Show-Menu
    $choice = Read-Host "Please make a selection"

    switch ($choice) {
        '1' {
            # Prompt the user to enter a name for the config and save it
            $name = Read-Host "Enter a name for the config"
            Save-Config -Name $name

            # Display a confirmation message and wait for input
            Write-Host "The current display config has been saved as '$name'"
            Write-Host "Press any key to continue ..."
            $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        '2' {
            # Get all the config elements from the XML file
            $configs = $configs.SelectNodes("//config")

            # Check if there are any saved configs
            if ($configs.Count -gt 0) {
                # Display a list of saved configs and get the user's choice
                Write-Host "Select a saved display config:"
                for ($i = 0; $i -lt $configs.Count; $i++) {
                    Write-Host "$($i + 1). $($configs[$i].GetAttribute('name'))"
                }
                $choice = Read-Host "Please make a selection"

                # Validate the user's choice and load the selected config
                if ($choice -ge 1 -and $choice -le $configs.Count) {
                    Load-Config -Name $($configs[$choice - 1].GetAttribute('name'))

                    # Display a confirmation message and wait for input
                    Write-Host "The display config '$($configs[$choice - 1].GetAttribute('name'))' has been loaded"
                    Write-Host "Press any key to continue ..."
                    $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
                } else {
                    # Display an error message and wait for input
                    Write-Host "Invalid selection"
                    Write-Host "Press any key to continue ..."
                    $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
                }
            } else {
                # Display an error message and wait for input
                Write-Host "No saved display configs found"
                Write-Host "Press any key to continue ..."
                $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            }
        }
        '3' {
            # Exit the loop
            break
        }
        default {
            # Display an error message and wait for input
            Write-Host "Invalid selection"
            Write-Host "Press any key to continue ..."
            $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
    }
} while ($true)

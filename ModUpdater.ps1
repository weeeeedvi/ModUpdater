Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

 $form = New-Object System.Windows.Forms.Form
 $form.Text = "Fabric Mod Version Updater"
 $form.Size = New-Object System.Drawing.Size(500, 300)
 $form.StartPosition = "CenterScreen"
 $form.FormBorderStyle = "FixedDialog"
 $form.MaximizeBox = $false

 $labelFile = New-Object System.Windows.Forms.Label
 $labelFile.Location = New-Object System.Drawing.Point(10, 20)
 $labelFile.Size = New-Object System.Drawing.Size(350, 20)
 $labelFile.Text = "No project folder selected"
 $form.Controls.Add($labelFile)

 $buttonBrowse = New-Object System.Windows.Forms.Button
 $buttonBrowse.Location = New-Object System.Drawing.Point(370, 15)
 $buttonBrowse.Size = New-Object System.Drawing.Size(100, 25)
 $buttonBrowse.Text = "Browse..."
 $buttonBrowse.Add_Click({
    $openFileDialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $openFileDialog.Description = "Select the ROOT folder of your mod (contains build.gradle)"
    if ($openFileDialog.ShowDialog() -eq "OK") {
        $script:folderPath = $openFileDialog.SelectedPath
        $labelFile.Text = $script:folderPath
    }
})
 $form.Controls.Add($buttonBrowse)

 $labelVersion = New-Object System.Windows.Forms.Label
 $labelVersion.Location = New-Object System.Drawing.Point(10, 60)
 $labelVersion.Size = New-Object System.Drawing.Size(300, 20)
 $labelVersion.Text = "Select new Minecraft Version:"
 $form.Controls.Add($labelVersion)

 $comboBox = New-Object System.Windows.Forms.ComboBox
 $comboBox.Location = New-Object System.Drawing.Point(10, 85)
 $comboBox.Size = New-Object System.Drawing.Size(460, 30)
 $comboBox.DropDownStyle = "DropDownList"

 $versions = @("1.21.1", "1.21.2", "1.21.3", "1.21.4", "1.21.8", "1.21.11")
 $comboBox.Items.AddRange($versions)
 $comboBox.SelectedIndex = 0
 $form.Controls.Add($comboBox)

 $labelStatus = New-Object System.Windows.Forms.Label
 $labelStatus.Location = New-Object System.Drawing.Point(10, 125)
 $labelStatus.Size = New-Object System.Drawing.Size(460, 80)
 $labelStatus.ForeColor = "Green"
 $labelStatus.Text = "Ready. (Select the folder containing build.gradle)"
 $form.Controls.Add($labelStatus)

 $buttonDone = New-Object System.Windows.Forms.Button
 $buttonDone.Location = New-Object System.Drawing.Size(190, 220)
 $buttonDone.Size = New-Object System.Drawing.Size(100, 35)
 $buttonDone.Text = "Done"
 $buttonDone.Add_Click({
    if (-not $script:folderPath) {
        $labelStatus.ForeColor = "Red"
        $labelStatus.Text = "Error: Please select a project folder first!"
        return
    }

    $selectedVersion = $comboBox.SelectedItem
    $labelStatus.ForeColor = "Black"
    $labelStatus.Text = "Working... Please wait."
    $form.Refresh()

    try {
        $loomVersion = "1.9-SNAPSHOT"
        $pluginId = "fabric-loom"
        if ($selectedVersion -ge "1.21.4" -and $selectedVersion -lt "1.21.11") {
            $loomVersion = "1.10-SNAPSHOT"
        } elseif ($selectedVersion -ge "1.21.11") {
            $loomVersion = "1.17.13"
            $pluginId = "net.fabricmc.fabric-loom-remap"
        }

        $buildGradlePath = Join-Path $script:folderPath "build.gradle"
        if (Test-Path $buildGradlePath) {
            $bgContent = Get-Content $buildGradlePath -Raw
            
            $oldPattern1 = "id 'fabric-loom' version '1.9-SNAPSHOT'"
            $oldPattern2 = "id 'fabric-loom' version '1.10-SNAPSHOT'"
            $oldPattern3 = "id 'net.fabricmc.fabric-loom-remap' version '1.17.13'"
            
            $newPattern = "id '$pluginId' version '$loomVersion'"
            
            if ($bgContent.Contains($oldPattern1)) {
                $bgContent = $bgContent.Replace($oldPattern1, $newPattern)
            } elseif ($bgContent.Contains($oldPattern2)) {
                $bgContent = $bgContent.Replace($oldPattern2, $newPattern)
            } elseif ($bgContent.Contains($oldPattern3)) {
                $bgContent = $bgContent.Replace($oldPattern3, $newPattern)
            } else {
                $labelStatus.ForeColor = "Red"
                $labelStatus.Text = "Error: Could not find Loom plugin in build.gradle"
                return
            }
            Set-Content -Path $buildGradlePath -Value $bgContent
        } else {
            $labelStatus.ForeColor = "Red"
            $labelStatus.Text = "Error: build.gradle not found in this folder!"
            return
        }

        $propsPath = Join-Path $script:folderPath "gradle.properties"
        if (Test-Path $propsPath) {
            $propsContent = Get-Content $propsPath
            $propsContent = $propsContent -replace "^minecraft_version=.*", "minecraft_version=$selectedVersion"
            
            $fabricMap = @{
                "1.21.1" = "0.116.14+1.21.1"
                "1.21.2" = "0.106.1+1.21.2"
                "1.21.3" = "0.118.1+1.21.5"
                "1.21.4" = "0.119.4+1.21.4"
                "1.21.8" = "0.133.14+1.21.9"
                "1.21.11" = "0.141.4+1.21.11"
            }
            $fabVer = $fabricMap[$selectedVersion]
            if ($fabVer) {
                $propsContent = $propsContent -replace "^fabric_version=.*", "fabric_version=$fabVer"
            }

            $yarnMap = @{
                "1.21.1" = "1.21.1+build.3"
                "1.21.2" = "1.21.2+build.1"
                "1.21.3" = "1.21.3+build.1"
                "1.21.4" = "1.21.4+build.7"
                "1.21.8" = "1.21.8+build.1"
                "1.21.11" = "1.21.11+build.6"
            }
            $yarnVer = $yarnMap[$selectedVersion]
            if ($yarnVer) {
                $propsContent = $propsContent -replace "^yarn_mappings=.*", "yarn_mappings=$yarnVer"
            }

            Set-Content -Path $propsPath -Value $propsContent
        }

        $modJsonPath = Join-Path $script:folderPath "src\main\resources\fabric.mod.json"
        if (Test-Path $modJsonPath) {
            $json = Get-Content $modJsonPath -Raw | ConvertFrom-Json
            if ($json.depends.minecraft -match "~(\d+\.\d+(?:\.\d+)?)") {
                $json.depends.minecraft = "~$selectedVersion"
                $newJson = $json | ConvertTo-Json -Depth 10
                Set-Content -Path $modJsonPath -Value $newJson
            }
        }

        $labelStatus.ForeColor = "Green"
        $labelStatus.Text = "Success! Updated to $selectedVersion.`nLoom: $pluginId $loomVersion`nFabric API: $fabVer`nYou can now run 'gradlew clean build'!"

    } catch {
        $labelStatus.ForeColor = "Red"
        $labelStatus.Text = "Error: $($_.Exception.Message)"
    }
})
 $form.Controls.Add($buttonDone)

# --- Added Credit Watermark (Fixed position and name) ---
 $labelCredits = New-Object System.Windows.Forms.Label
 $labelCredits.Location = New-Object System.Drawing.Point(420, 235)
 $labelCredits.Size = New-Object System.Drawing.Size(60, 20)
 $labelCredits.Text = "by weed6"
 $labelCredits.ForeColor = "DarkGray"
 $labelCredits.Font = New-Object System.Drawing.Font("Segoe UI", 8)
 $form.Controls.Add($labelCredits)
# -----------------------------

[void]$form.ShowDialog()

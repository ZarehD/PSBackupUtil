@{
    RootModule           = '.\Backup-FolderContents.psm1'
    ModuleVersion        = "1.2.7"
    GUID                 = "5488db86-a6a9-4754-9ac5-af0132c44355"
    Author               = "Zareh DerGevorkian"
    Copyright            = "(c) 2019-2020 Zareh DerGevorkian. All rights reserved"
    Description          = "PSBackupUtil™ - PowerShell backup utility for archiving folder contents"

    PowerShellVersion    = "5.1"
    CompatiblePSEditions = "Desktop", "Core"

    HelpInfoURI          = "https://github.com/ZarehD/PSBackupUtil"

    # DefaultCommandPrefix = ""

    RequiredModules      = @()

    NestedModules        = @()

    AliasesToExport      = @()

    CmdletsToExport      = @()

    # FunctionsToExport = @(
    #     "Backup-Folder"
    # )

    FileList             = @(
        ".\Backup-FolderContents.psm1"
    )

    VariablesToExport    = @()

    PrivateData          = @{
        PSData = @{
            ProjectUri   = "https://github.com/ZarehD/PSBackupUtil"
            LicenseUri   = "https://github.com/ZarehD/PSBackupUtil/blob/master/LICENSE"
            IconUri      = "https://github.com/ZarehD/PSBackupUtil/blob/master/logo.png"
            ReleaseNotes = "https://github.com/ZarehD/PSBackupUtil/blob/master/CHANGELOG.md"
            Tags         = @("PSEdition_Desktop", "PSEdition_Core", "Backup", "Disk_to_Disk")
        }
    }
}
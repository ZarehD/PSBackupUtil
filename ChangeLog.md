#### Version 1.3.1 - Dec 14, 2023
- BUGFIX: Foreach-$fig loop in Get-FilesForBackup, 'return $true' statement not returning $true!

#### Version 1.3.0 - Apr 16, 2023
- Publish to PowerShell Gallery

#### Version 1.2.7 - Mar 7, 2020
- Add license and platform badges
- Add logo icon
- Add NOTICE file
- Update copyright/Trademark notices
- Update links in PrivateData section in module manifest
- Rename functions to address PS script analyzer warnings
- Save script file with Utf8bom encoding

#### Version 1.2.6 - Mar 4, 2020
- Use Count property instead of Measure-Object cmdlet

#### Version 1.2.5 - Mar 4, 2020
- Use formal syntax with Measure-Object cmdlet

#### Version 1.2.4 - Mar 4, 2020
- BUGFIX: For partial backups, when setting $DtChangedAfter (used to determine which files changed since last archive), $DtLastPartial should be used only if it's greater than $DtLastFull
- Change logging level to Verbose for certain messages
- Debug-log file counts and other info in New-Backup function

#### Version 1.2.3 - Feb 29, 2020
- BUGFIX: Prevent error (just exit) when path passed to Update-NameFormatOfExistingFiles doesn't exist
- Module entry-point function now prints out caught exceptions instead of re-throwing them

#### Version 1.2.2 - Feb 27, 2020
- BUGFIX: Fix search for most recent archive file to reflect new archive file name format.
- BUGFIX: Fix how date value is extracted from archive files named using the new format.

#### Version 1.2.1 - Feb 27, 2020
- Hyphen chars are replaced with underscores in archive Base Name, whether specified as a parameter, or derived from the source pathname.
  - Hyphen chars are used as delimiters in the archive file name so they cannot be allowed in the base-name.

#### Version 1.2.0 - Feb 27, 2020
- Change format used for naming archive files
  - New format is: `<base-name>-<date>-<mode>.<extension>`
  - Makes it so all archive files, regardless of their mode marker, are naturally sorted in chronological order
- Date value used in naming archive files now includes the seconds value
- Existing archive file names are automatically updated to the new format

#### Version 1.1.3 - Feb 15, 2020
- Initial release on GitHub

#### Version 1.2.3 - Feb 29, 2020
- BUGFIX: Prevent error (just exit) when path passed to Update-NameFormatOfExistingFiles doesn't exist
- Module entry-point function now prints out caught exceptions instead of rethrowing them

#### Version 1.2.2 - Feb 27, 2020
- BUGFIX: Fix search for most recent archive file to reflect new archive file name format.
- BUGFIX: Fix how date value is extracted from archive files named using the new format.

#### Version 1.2.1 - Feb 27, 2020
- Hyphen chars are replaced with underscores in archive Base Name, whether specified as a parameter, or derrived from the source pathname.
  - Hyphen chars are used as delimiters in the archive file name so they cannot be allowed in the base-name.

#### Version 1.2.0 - Feb 27, 2020
- Change format used for naming archive files
  - New format is: `<base-name>-<date>-<mode>.<extension>`
  - Makes it so all archive files, regardless of their mode marker, are naturally sorted in chronological order
- Date value used in naming archive files now includes the seconds value
- Existing archive file names are automatically updated to the new format

#### Version 1.1.3 - Feb 15, 2020
- Initial release on GitHub


#### Version 1.2.1 - Feb 27, 2020
- Hyphen chars are replaced with underscores in archive Base Name, whether specified as a parameter, or derrived from the source pathname.
  - Hyphen chars are used as delimiters in the archive file name so they cannot be allowed in the base-name.

#### Version 1.2.0 - Feb 27, 2020
- Change format used for naming archive files
  - New format is: <base-name>-<date>-<mode>.<extension>
  - Makes it so all archive files, regardless of their mode marker, are naturally sorted in chronological order
- Date value used in naming archive files now includes the seconds value

#### Version 1.1.3 - Feb 15, 2020
- Initial release on GitHub

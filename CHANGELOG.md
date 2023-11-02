# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog],
and this project adheres to [Semantic Versioning].

## [Unreleased]

### Added

- WHATWG IDNA functions

### Changed

- **BREAKING!** Names of options updated to match UTS46 flags
- Unicode version updated to 15.1
- UTS46 functions now support Revision 31

### Fixed

- IDNA2008 functions now support not only labels, but full domains 

## [0.1.0] - 2023-08-05

### Added

- Initial implementation. ([@skryukov])

[@skryukov]: https://github.com/skryukov

[Unreleased]: https://github.com/skryukov/uri-idna/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/skryukov/uri-idna/commits/v0.1.0

[Keep a Changelog]: https://keepachangelog.com/en/1.0.0/
[Semantic Versioning]: https://semver.org/spec/v2.0.0.html

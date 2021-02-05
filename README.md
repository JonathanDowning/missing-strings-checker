# Xcode Empty Strings Checker
Github Action which checks .stringsdict and .strings (e.g. `Localizable.strings`) files for empty strings.

## Example usage

```yml
name: Check Missing Strings

on:
  pull_request:
    paths:
      - '**/*.stringsdict'
      - '**/*.strings'

jobs:
  missing-strings:
    name: Check Missing Strings
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Check Missing Strings
        uses: JonathanDowning/empty-strings-checker@v1
```

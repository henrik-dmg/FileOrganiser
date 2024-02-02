# FileOrganiser

A CLI tool to organise files into folders based on their creation date.

## Installation

### Script

```bash
curl -s https://raw.githubusercontent.com/henrik-dmg/FileOrganiser/main/Scripts/remote-install.sh | bash
```

I recommend to read the script before executing it. It will clone the repository into a temporary directory, compile it and then copy it to `/usr/local/bin/file-organiser`.

### From Source

```bash
git clone https://github.com/henrik-dmg/FileOrganiser.git
cd FileOrganiser
swift build -c release
ln -s .build/release/file-organiser /usr/local/bin/file-organiser # or any other directory in your $PATH
```

### Manual

- Download the executable for your system from the latest release
- Move it to `/usr/local/bin/file-organiser` or any other directory in your `$PATH`

## Usage

The tool has two subcommands: `copy` and `move`. If you use `copy`, source files will remain in their original location. If you use `move`, source files will be moved to the target directory and the original folder structure will be lost.
The options and arguments are the same for both.

Example:

```bash
file-organiser move ~/Some/Source/Directory ~/Some/Target/Directory --date-strategy year
```

### Options

#### `--file-pattern`

An optional file name pattern. Only files matching this pattern will be moved or copied.

#### `--date-strategy`

The strategy with which files are grouped into subfolders. For the available options, please refer to the section [Date Grouping Strategies](#date-grouping-strategies).

#### `--dry-run`

Only print the actions that would be performed, but do not actually perform them

#### `--verbose`

Prints additional information during processing

#### `--soft-fail`

Keeps the tool running when a failure occurs for individual files

## Date Grouping Strategies

Files are grouped by their creation date. The following strategies are available:

### `year`

The most basic option. It will simply create one folder for every year.
Example:

```
.
├── 2022
│   ├── file-from-2022
│   └── other-file-from-2022
├── 2023
│   ├── file-from-2023
│   └── other-file-from-2022
└── 2024
    ├── file-from-2024
    └── other-file-from-2024
```

### `month`

Similar to `year`, but files will be moved into subfolders for each month as well. This is the default option. I use this option to organise my photos from my camera for example.
Example:

```
.
├── 2022
│   ├── 04
│   │   ├── file-from-april-2022
│   └── 08
│       └── other-file-from-august-2022
├── 2023
│   └── 07
│       └── file-from-july-2023
└── 2024
    ├── 10
    │   └── file-from-october-2024
    └── 12
        └── other-file-from-december-2024
```

### `day`

Similar to `month`, but files will be moved into subfolders for each day as well.
I guess this one is not very useful unless you create a lot of files every day.
Specifying `month` will result in the following folder structure:

```
.
├── 2022
│   ├── 04
│   │   └── 2024-04-01
|   │       └── file-from-april-01-2022
│   └── 08
│       └── 2024-08-29
│           └── file-from-august-29-2022
└── 2024
    ├── 10
    │   └── 2024-10-16
    │       └── file-from-october-16-2024
    └── 12
        └── 2024-12-31
            └── file-from-december-31-2024
```

## Contributing

If you have any ideas for improvements, please feel free to open an issue or a pull request :)

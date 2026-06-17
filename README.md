# Clish Console

A powerful, modular command-line interface framework built entirely in Bash. Clish Console provides a structured approach to building CLI applications with strict namespacing, declarative options, and comprehensive input/output utilities.

## Features

- **Strict Namespacing**: All functions follow a consistent naming convention to prevent collisions
- **Declarative Options**: Define command options and arguments in a clean, declarative way
- **Interactive Input**: Helper functions for user prompts, confirmations, secrets, and choices
- **Rich Output**: Table rendering, colored logging, and progress bars
- **Dual Mode**: Supports both packaged (compiled) and development modes
- **Command Discovery**: Automatically discovers and loads commands from `bin/commands` directory

## Project Structure

```
src/
├── bootstrap.sh          # Entry point with global options handling
├── core/
│   ├── init.sh           # Color constants and global configuration
│   ├── input.sh          # Interactive input helpers
│   ├── output.sh         # Table output formatting
│   ├── log.sh            # Logging utilities
│   ├── options.sh        # Declarative option parsing
│   └── progress.sh       # Progress bar utilities
└── console/
    ├── kernel.sh         # Command execution kernel
    └── help.sh           # Help system
```

## Core Modules

### Bootstrap (`bootstrap.sh`)

The entry point that handles global options:

- `-V, --version`: Show version
- `-h, --help`: Show global help
- `-q, --quiet`: Suppress output
- `-v, -vv, -vvv`: Increase verbosity
- `--no-interaction`: Disable interactive prompts
- `--debug`: Enable debug mode (set -x)

### Input Helpers (`core/input.sh`)

| Function | Description |
|----------|-------------|
| `clish_console_core_input_ask` | Prompt for input with optional default value |
| `clish_console_core_input_secret` | Prompt for secret input (hidden) |
| `clish_console_core_input_confirm` | Confirmation prompt (Y/n) |
| `clish_console_core_input_choice` | Interactive selection menu |

### Output Helpers (`core/output.sh`)

| Function | Description |
|----------|-------------|
| `clish_console_core_output_table` | Render formatted tables with headers |

### Logging (`core/log.sh`)

| Function | Description |
|----------|-------------|
| `clish_console_core_log_emergency` | System is unusable |
| `clish_console_core_log_alert` | Action must be taken immediately |
| `clish_console_core_log_critical` | Critical conditions |
| `clish_console_core_log_error` | Error conditions |
| `clish_console_core_log_warning` | Warning conditions |
| `clish_console_core_log_notice` | Normal but significant condition |
| `clish_console_core_log_info` | Informational messages |
| `clish_console_core_log_debug` | Debug-level messages |
| `clish_console_core_log_success` | Success messages (green) |

### Options System (`core/options.sh`)

Declarative option definition:

```bash
clish_console_core_options_option "name" --arg "Description"
clish_console_core_options_argument "arg_name" "Argument description"
clish_console_core_options_parse "$(clish_console_core_options_generate_spec)" "$@"
```

### Progress Bar (`core/progress.sh`)

```bash
clish_console_core_progress_start 100
clish_console_core_progress_advance 10
```

### Command Kernel (`console/kernel.sh`)

Discovers and executes commands from `bin/commands`. Commands can be organized in subdirectories for grouping.

## Command Structure

Each command file should define:

```bash
cmd_example_handle() {
    # Command logic here
    clish_console_core_log_info "Executing example command"
}

cmd_example_options() {
    clish_console_core_options_option "verbose" "Enable verbose output"
    clish_console_core_options_argument "file" "Target file"
}

cmd_example_description() {
    echo "An example command that demonstrates the framework"
}
```

## Usage

```bash
# Show global help
./console

# Run a command
./console <command> [options] [arguments]

# Get help for a specific command
./console <command> --help
```

## License

MIT

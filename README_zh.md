# Clish Console

一个功能强大的模块化命令行界面框架，完全基于 Bash 构建。Clish Console 提供了一种结构化的方法来构建 CLI 应用程序，具有严格的命名空间、声明式选项和全面的输入/输出工具。

## 特性

- **严格命名空间**: 所有函数遵循一致的命名约定，防止冲突
- **声明式选项**: 以清晰、声明式的方式定义命令选项和参数
- **交互式输入**: 用户提示、确认、密码和选择的辅助函数
- **丰富输出**: 表格渲染、彩色日志和进度条
- **双模式支持**: 支持打包（编译）和开发两种模式
- **命令发现**: 自动从 `bin/commands` 目录发现并加载命令

## 项目结构

```
src/
├── bootstrap.sh          # 入口点，处理全局选项
├── core/
│   ├── init.sh           # 颜色常量和全局配置
│   ├── input.sh          # 交互式输入辅助函数
│   ├── output.sh         # 表格输出格式化
│   ├── log.sh            # 日志工具
│   ├── options.sh        # 声明式选项解析
│   └── progress.sh       # 进度条工具
└── console/
    ├── kernel.sh         # 命令执行内核
    └── help.sh           # 帮助系统
```

## 核心模块

### Bootstrap (`bootstrap.sh`)

入口点，处理全局选项：

- `-V, --version`: 显示版本
- `-h, --help`: 显示全局帮助
- `-q, --quiet`: 抑制输出
- `-v, -vv, -vvv`: 增加详细程度
- `--no-interaction`: 禁用交互式提示
- `--debug`: 启用调试模式 (set -x)

### 输入辅助函数 (`core/input.sh`)

| 函数 | 描述 |
|------|------|
| `clish_console_core_input_ask` | 提示输入，支持可选默认值 |
| `clish_console_core_input_secret` | 提示输入密码（隐藏） |
| `clish_console_core_input_confirm` | 确认提示 (Y/n) |
| `clish_console_core_input_choice` | 交互式选择菜单 |

### 输出辅助函数 (`core/output.sh`)

| 函数 | 描述 |
|------|------|
| `clish_console_core_output_table` | 渲染带表头的格式化表格 |

### 日志系统 (`core/log.sh`)

| 函数 | 描述 |
|------|------|
| `clish_console_core_log_emergency` | 系统不可用 |
| `clish_console_core_log_alert` | 必须立即采取行动 |
| `clish_console_core_log_critical` | 严重条件 |
| `clish_console_core_log_error` | 错误条件 |
| `clish_console_core_log_warning` | 警告条件 |
| `clish_console_core_log_notice` | 正常但重要的条件 |
| `clish_console_core_log_info` | 信息性消息 |
| `clish_console_core_log_debug` | 调试级别消息 |
| `clish_console_core_log_success` | 成功消息（绿色） |

### 选项系统 (`core/options.sh`)

声明式选项定义：

```bash
clish_console_core_options_option "name" --arg "描述"
clish_console_core_options_argument "arg_name" "参数描述"
clish_console_core_options_parse "$(clish_console_core_options_generate_spec)" "$@"
```

### 进度条 (`core/progress.sh`)

```bash
clish_console_core_progress_start 100
clish_console_core_progress_advance 10
```

### 命令内核 (`console/kernel.sh`)

从 `bin/commands` 发现并执行命令。命令可以组织在子目录中进行分组。

## 命令结构

每个命令文件应该定义：

```bash
cmd_example_handle() {
    # 命令逻辑
    clish_console_core_log_info "执行示例命令"
}

cmd_example_options() {
    clish_console_core_options_option "verbose" "启用详细输出"
    clish_console_core_options_argument "file" "目标文件"
}

cmd_example_description() {
    echo "一个演示框架用法的示例命令"
}
```

## 使用方法

```bash
# 显示全局帮助
./console

# 运行命令
./console <command> [options] [arguments]

# 获取特定命令的帮助
./console <command> --help
```

## 许可证

MIT

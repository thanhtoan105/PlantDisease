---
type: 'agent_requested'
description: 'Example description'
---

# MCP Server Configuration Synchronization Rule

## Purpose

Synchronize MCP (Model Context Protocol) server configurations across Claude Code, VS Code, Windsurf, Cursor, and Claude Desktop applications.

## Configuration File Locations

### macOS

- **Claude Desktop**: `~/Library/Application Support/Claude/claude_desktop_config.json`
- **Cursor**: `~/.cursor/mcp.json`
- **Windsurf**: `~/.codeium/windsurf/mcp_config.json`
- **Claude Code**: `~/.claude.json` (contains more than just MCP configs)
- **VS Code (User)**: `~/Library/Application Support/Code/User/settings.json` (under `mcp.servers`)

### Windows

- **Claude Desktop**: `%APPDATA%\Claude\claude_desktop_config.json`
- **Cursor**: `%USERPROFILE%\.cursor\mcp.json`
- **Windsurf**: `%USERPROFILE%\.codeium\windsurf\mcp_config.json`
- **VS Code (User)**: `%APPDATA%\Code\User\settings.json` (under `mcp.servers`)

### Linux

- **Claude Desktop**: `~/.config/Claude/claude_desktop_config.json`
- **Cursor**: `~/.cursor/mcp.json`
- **Windsurf**: `~/.codeium/windsurf/mcp_config.json`
- **VS Code (User)**: `~/.config/Code/User/settings.json` (under `mcp.servers`)

## Configuration Format Differences

### Claude Desktop & Cursor Format

```json
{
	"mcpServers": {
		"server-name": {
			"command": "npx",
			"args": ["-y", "package-name"],
			"env": {
				"ENV_VAR": "value"
			}
		}
	}
}
```

### VS Code Format

```json
{
	"mcp": {
		"servers": {
			"server-name": {
				"command": "npx",
				"args": ["-y", "package-name"],
				"env": {
					"ENV_VAR": "value"
				}
			}
		}
	}
}
```

### Claude Code Format

**Note**: Claude Code (the CLI tool) does not currently support MCP server configurations. The `.claude.json` file contains project settings and other configurations but does not include MCP servers.

## Synchronization Script

```bash
#!/bin/bash

# MCP Server Configuration Synchronizer
# This script finds and compares MCP server configurations across different applications

# Color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration file paths
CLAUDE_DESKTOP_CONFIG="$HOME/Library/Application Support/Claude/claude_desktop_config.json"
CURSOR_CONFIG="$HOME/.cursor/mcp.json"
CLAUDE_CODE_CONFIG="$HOME/.claude.json"

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo -e "${RED}Error: jq is not installed. Please install it with: brew install jq${NC}"
    exit 1
fi

echo "🔍 MCP Server Configuration Synchronizer"
echo "======================================="
echo ""

# Function to extract MCP servers from a config file
extract_servers() {
    local file="$1"
    local format="$2"

    if [ ! -f "$file" ]; then
        echo "{}"
        return
    fi

    if [ "$format" = "vscode" ]; then
        jq -r '.mcp.servers // {}' "$file" 2>/dev/null || echo "{}"
    else
        jq -r '.mcpServers // {}' "$file" 2>/dev/null || echo "{}"
    fi
}

# Function to get server names from JSON
get_server_names() {
    echo "$1" | jq -r 'keys[]' 2>/dev/null | sort
}

# Check which config files exist
echo "📁 Checking configuration files:"
echo ""

if [ -f "$CLAUDE_DESKTOP_CONFIG" ]; then
    echo -e "${GREEN}✓${NC} Claude Desktop: $CLAUDE_DESKTOP_CONFIG"
    CLAUDE_DESKTOP_SERVERS=$(extract_servers "$CLAUDE_DESKTOP_CONFIG" "standard")
else
    echo -e "${RED}✗${NC} Claude Desktop: Not found"
    CLAUDE_DESKTOP_SERVERS="{}"
fi

if [ -f "$CURSOR_CONFIG" ]; then
    echo -e "${GREEN}✓${NC} Cursor: $CURSOR_CONFIG"
    CURSOR_SERVERS=$(extract_servers "$CURSOR_CONFIG" "standard")
else
    echo -e "${RED}✗${NC} Cursor: Not found"
    CURSOR_SERVERS="{}"
fi

if [ -f "$CLAUDE_CODE_CONFIG" ]; then
    echo -e "${GREEN}✓${NC} Claude Code: $CLAUDE_CODE_CONFIG"
    CLAUDE_CODE_SERVERS=$(extract_servers "$CLAUDE_CODE_CONFIG" "standard")
else
    echo -e "${RED}✗${NC} Claude Code: Not found"
    CLAUDE_CODE_SERVERS="{}"
fi

# Find VS Code workspace configs
echo ""
echo "🔍 Searching for VS Code workspace configs..."
VSCODE_CONFIGS=$(find ~ -path "*/.vscode/mcp.json" -type f 2>/dev/null | head -10)
if [ -n "$VSCODE_CONFIGS" ]; then
    echo -e "${GREEN}✓${NC} Found VS Code workspace configs:"
    echo "$VSCODE_CONFIGS" | while read -r config; do
        echo "  - $config"
    done
else
    echo -e "${YELLOW}⚠${NC} No VS Code workspace configs found"
fi

echo ""
echo "📊 Server Analysis:"
echo "=================="

# Get all unique server names
ALL_SERVERS=$(echo "$CLAUDE_DESKTOP_SERVERS $CURSOR_SERVERS $CLAUDE_CODE_SERVERS" | \
    jq -s 'add | keys' | jq -r '.[]' | sort -u)

# Create arrays for tracking
declare -a COMMON_SERVERS=()
declare -a CLAUDE_DESKTOP_ONLY=()
declare -a CURSOR_ONLY=()
declare -a CLAUDE_CODE_ONLY=()

# Analyze each server
for server in $ALL_SERVERS; do
    in_claude_desktop=$(echo "$CLAUDE_DESKTOP_SERVERS" | jq --arg s "$server" 'has($s)')
    in_cursor=$(echo "$CURSOR_SERVERS" | jq --arg s "$server" 'has($s)')
    in_claude_code=$(echo "$CLAUDE_CODE_SERVERS" | jq --arg s "$server" 'has($s)')

    count=0
    [ "$in_claude_desktop" = "true" ] && ((count++))
    [ "$in_cursor" = "true" ] && ((count++))
    [ "$in_claude_code" = "true" ] && ((count++))

    if [ $count -ge 2 ]; then
        COMMON_SERVERS+=("$server")
    elif [ "$in_claude_desktop" = "true" ] && [ $count -eq 1 ]; then
        CLAUDE_DESKTOP_ONLY+=("$server")
    elif [ "$in_cursor" = "true" ] && [ $count -eq 1 ]; then
        CURSOR_ONLY+=("$server")
    elif [ "$in_claude_code" = "true" ] && [ $count -eq 1 ]; then
        CLAUDE_CODE_ONLY+=("$server")
    fi
done

# Display results
echo ""
echo "🤝 Common Servers (in 2+ apps):"
if [ ${#COMMON_SERVERS[@]} -eq 0 ]; then
    echo "  None"
else
    for server in "${COMMON_SERVERS[@]}"; do
        echo -e "  ${GREEN}•${NC} $server"

        # Show which apps have it
        apps=""
        [ "$(echo "$CLAUDE_DESKTOP_SERVERS" | jq --arg s "$server" 'has($s)')" = "true" ] && apps+="Claude Desktop, "
        [ "$(echo "$CURSOR_SERVERS" | jq --arg s "$server" 'has($s)')" = "true" ] && apps+="Cursor, "
        [ "$(echo "$CLAUDE_CODE_SERVERS" | jq --arg s "$server" 'has($s)')" = "true" ] && apps+="Claude Code, "
        apps=${apps%, }
        echo "    In: $apps"
    done
fi

echo ""
echo "📱 App-Specific Servers:"

if [ ${#CLAUDE_DESKTOP_ONLY[@]} -gt 0 ]; then
    echo -e "\n  ${YELLOW}Claude Desktop only:${NC}"
    for server in "${CLAUDE_DESKTOP_ONLY[@]}"; do
        echo "  • $server"
    done
fi

if [ ${#CURSOR_ONLY[@]} -gt 0 ]; then
    echo -e "\n  ${YELLOW}Cursor only:${NC}"
    for server in "${CURSOR_ONLY[@]}"; do
        echo "  • $server"
    done
fi

if [ ${#CLAUDE_CODE_ONLY[@]} -gt 0 ]; then
    echo -e "\n  ${YELLOW}Claude Code only:${NC}"
    for server in "${CLAUDE_CODE_ONLY[@]}"; do
        echo "  • $server"
    done
fi

# Configuration differences for common servers
echo ""
echo "🔧 Configuration Differences:"
echo "============================"

for server in "${COMMON_SERVERS[@]}"; do
    echo ""
    echo "Server: $server"
    echo "---------------"

    # Get configurations from each app
    claude_desktop_config=$(echo "$CLAUDE_DESKTOP_SERVERS" | jq --arg s "$server" '.[$s]' 2>/dev/null)
    cursor_config=$(echo "$CURSOR_SERVERS" | jq --arg s "$server" '.[$s]' 2>/dev/null)
    claude_code_config=$(echo "$CLAUDE_CODE_SERVERS" | jq --arg s "$server" '.[$s]' 2>/dev/null)

    # Compare configurations
    configs_match=true

    if [ "$claude_desktop_config" != "null" ] && [ "$cursor_config" != "null" ]; then
        if [ "$claude_desktop_config" != "$cursor_config" ]; then
            configs_match=false
        fi
    fi

    if [ "$configs_match" = true ]; then
        echo -e "  ${GREEN}✓${NC} Configurations match across apps"
    else
        echo -e "  ${RED}✗${NC} Configurations differ:"

        if [ "$claude_desktop_config" != "null" ]; then
            echo "    Claude Desktop:"
            echo "$claude_desktop_config" | jq . | sed 's/^/      /'
        fi

        if [ "$cursor_config" != "null" ] && [ "$cursor_config" != "$claude_desktop_config" ]; then
            echo "    Cursor:"
            echo "$cursor_config" | jq . | sed 's/^/      /'
        fi

        if [ "$claude_code_config" != "null" ] && [ "$claude_code_config" != "$claude_desktop_config" ] && [ "$claude_code_config" != "$cursor_config" ]; then
            echo "    Claude Code:"
            echo "$claude_code_config" | jq . | sed 's/^/      /'
        fi
    fi
done

# Summary
echo ""
echo "📈 Summary:"
echo "=========="
total_servers=$(echo "$ALL_SERVERS" | wc -w | tr -d ' ')
echo "Total unique servers: $total_servers"
echo "Common servers: ${#COMMON_SERVERS[@]}"
echo "App-specific servers: $((total_servers - ${#COMMON_SERVERS[@]}))"

# Sync recommendation
echo ""
echo "💡 Sync Recommendations:"
echo "======================="

if [ ${#COMMON_SERVERS[@]} -gt 0 ]; then
    echo "• Review configuration differences for common servers"
fi

total_unique=$((${#CLAUDE_DESKTOP_ONLY[@]} + ${#CURSOR_ONLY[@]} + ${#CLAUDE_CODE_ONLY[@]}))
if [ $total_unique -gt 0 ]; then
    echo "• Consider adding app-specific servers to other apps for consistency"
fi

echo ""
echo "To sync configurations manually, copy the mcpServers section between config files."
echo "Remember to adjust the format for VS Code (wrap in 'mcp.servers' instead of 'mcpServers')."
```

## Usage Instructions

1. Save the script above as `mcp-sync.sh`
2. Make it executable: `chmod +x mcp-sync.sh`
3. Use the script with various options:

### Basic Usage

```bash
# List all servers and show differences
./mcp-sync.sh

# Show help
./mcp-sync.sh --help
```

### Switching Between Local and Global Configurations

```bash
# Switch a server from local path to global npm package
./mcp-sync.sh --to-global terminator --app cursor

# Switch a server from global npm package to local path
./mcp-sync.sh --to-local peekaboo --app claude-desktop
```

### Features

The script will:

- Locate all MCP configuration files on your system
- Parse and compare server configurations
- Show which servers are common across apps
- Show which servers are unique to specific apps
- Highlight configuration differences for common servers
- Provide recommendations for synchronization
- **NEW**: Switch servers between local development paths and global npm packages

### Switching Details

**Local to Global (`--to-global`)**:

- Converts a local file path configuration to use `npx` with an npm package
- Automatically recognizes common servers (terminator, agent, automator, conduit, peekaboo)
- Prompts for npm package name for unknown servers
- Preserves environment variables and other settings

**Global to Local (`--to-local`)**:

- Converts an npm package configuration to use a local file path
- Automatically detects file type and selects appropriate command (node, python, bash)
- Validates that the local file exists (with option to continue anyway)
- Preserves environment variables and other settings

## Manual Synchronization Steps

1. **Identify differences**: Run the script to see which servers differ
2. **Choose source of truth**: Decide which app has the correct configuration
3. **Copy configurations**:
   - For Claude Desktop/Cursor: Copy the entire server object from `mcpServers`
   - For VS Code: Copy to `mcp.servers` (note the different structure)
4. **Handle sensitive data**: Be careful with API keys and passwords
5. **Test**: Restart the applications to ensure configurations work

## Security Considerations

- **API Keys**: Store sensitive keys in environment variables when possible
- **Passwords**: Avoid storing passwords in plain text in config files
- **File Permissions**: Ensure config files have appropriate permissions (600)
- **Version Control**: Don't commit config files with sensitive data

## Automation Ideas

1. **Scheduled sync**: Use cron to run the sync script regularly
2. **Git hooks**: Sync configs when pulling/pushing changes
3. **Config templating**: Use a template system to generate configs from a single source
4. **Environment-based**: Use different configs for different environments

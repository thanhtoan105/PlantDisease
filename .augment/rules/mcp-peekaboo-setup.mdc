---
description: Automated setup for Peekaboo vision-enabled MCP server
globs: ""
alwaysApply: false
---

# MCP Peekaboo Setup

This rule sets up the Peekaboo MCP server, which provides screenshot capture and AI-powered vision analysis capabilities.

## Overview

Peekaboo is a Model Context Protocol server that enables Claude to:
- Take screenshots of your screen
- Analyze images using AI vision models
- Support both OpenAI and Ollama providers

## Prerequisites

- macOS 14.0+ (Sonoma or later)
- Node.js 20.0+
- OpenAI API key (stored in `~/.zshrc`)
- Optional: Ollama with vision models installed

## Configuration

Add this to your Claude Desktop configuration (`~/Library/Application Support/Claude/claude_desktop_config.json`):

```json
{
  "mcpServers": {
    "peekaboo": {
      "command": "npx",
      "args": [
        "-y",
        "@steipete/peekaboo-mcp"
      ],
      "env": {
        "PEEKABOO_AI_PROVIDERS": "openai/gpt-4o,ollama/llava:latest",
        "OPENAI_API_KEY": "<READ_FROM_ZSHRC>",
        "PEEKABOO_LOG_LEVEL": "info",
        "PEEKABOO_DEFAULT_SAVE_PATH": "~/Desktop"
      }
    }
  }
}
```

## Security Setup

To securely extract the OpenAI API key from `~/.zshrc`:

```bash
# Extract API key from .zshrc
export OPENAI_API_KEY=$(grep "export OPENAI_API_KEY=" ~/.zshrc | cut -d'"' -f2)

# Update Claude config with the actual key
jq --arg key "$OPENAI_API_KEY" \
  '.mcpServers.peekaboo.env.OPENAI_API_KEY = $key' \
  ~/Library/Application\ Support/Claude/claude_desktop_config.json > tmp.json && \
  mv tmp.json ~/Library/Application\ Support/Claude/claude_desktop_config.json
```

## Available Tools

Once configured, you'll have access to:

1. **peekaboo_capture_screenshot**
   - Takes a screenshot of the entire screen or a specific display
   - Saves to the default path or specified location

2. **peekaboo_analyze_screenshot**
   - Captures and analyzes a screenshot with AI
   - Uses the configured AI providers for vision analysis

## Usage Examples

### Basic Screenshot
```
Take a screenshot of my screen
```

### Screenshot with Analysis
```
Take a screenshot and tell me what application is currently in focus
```

### Multi-monitor Support
```
Take a screenshot of display 2
```

## Troubleshooting

1. **Permission Issues**
   - Grant screen recording permission to Terminal/Claude
   - System Preferences → Privacy & Security → Screen Recording

2. **API Key Issues**
   - Verify `OPENAI_API_KEY` is set in `~/.zshrc`
   - Check the key is valid and has sufficient credits

3. **Ollama Connection**
   - Ensure Ollama is running: `ollama serve`
   - Verify vision model is installed: `ollama pull llava:latest`

## Provider Configuration

### OpenAI Only
```json
"PEEKABOO_AI_PROVIDERS": "openai/gpt-4o"
```

### Ollama Only
```json
"PEEKABOO_AI_PROVIDERS": "ollama/llava:latest"
```

### Multiple Providers (Fallback)
```json
"PEEKABOO_AI_PROVIDERS": "openai/gpt-4o,ollama/llava:latest"
```

## Log Levels

- `error`: Only errors
- `warn`: Errors and warnings
- `info`: General information (default)
- `debug`: Detailed debugging information

## Related Resources

- [Peekaboo MCP Repository](https://github.com/steipete/peekaboo-mcp)
- [Model Context Protocol Docs](https://modelcontextprotocol.io)
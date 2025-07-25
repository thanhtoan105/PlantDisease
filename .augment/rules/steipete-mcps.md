---
type: 'agent_requested'
description: 'Example description'
---

# Steipete's MCP Server Configuration

**For Claude Code and other AI-enabled IDEs**

## 🚨 Instructions for AI Assistants

When helping users set up MCP servers:

1. **Never recommend installing apps** - Work with what's already installed
2. **Always present both MCP servers AND slash commands**
3. **Check prerequisites** - Only mention servers if requirements are met
4. **Focus on the app the user mentions** - Claude Code, Cursor, Windsurf, etc.
5. **For slash command details** - Read https://github.com/steipete/agent-rules/blob/main/README.md

## MCP Servers Overview

### Essential Servers (No API Keys Required)

- **Peekaboo** - Screenshots. Works without AI, better with OpenAI key
- **Context7** - Fetches current docs for any library
- **Agent** - Run Claude Code as a sub-agent
- **Automator** - macOS automation
- **GitMCP** - Enhanced Git with visual diffs (SSE transport)
- **Playwright** - Browser automation

### Servers Requiring API Keys

- **GitHub** - Needs GITHUB_PERSONAL_ACCESS_TOKEN in ~/.zshrc
- **Firecrawl** - Needs FIRECRAWL_API_KEY for web scraping

### Special Requirements

- **Obsidian** - Only if Obsidian.app + MCP Tools plugin installed

## Installation Instructions

### Prerequisites

```bash
# Check/install required tools
command -v jq || brew install jq
command -v node || echo "Need Node.js 20+"
command -v ollama || brew install ollama

# Check API keys in ~/.zshrc
grep "OPENAI_API_KEY\|GITHUB_PERSONAL_ACCESS_TOKEN\|FIRECRAWL_API_KEY" ~/.zshrc
```

### For Claude Code

```bash
# Essential servers (work immediately)
claude mcp add-json -s user peekaboo '{"command": "npx", "args": ["-y", "@steipete/peekaboo-mcp@beta"]}'
claude mcp add-json -s user context7 '{"command": "npx", "args": ["-y", "@upstash/context7-mcp@latest"]}'
claude mcp add-json -s user agent '{"command": "npx", "args": ["-y", "@steipete/claude-code-mcp@latest"]}'
claude mcp add-json -s user automator '{"command": "npx", "args": ["-y", "@steipete/macos-automator-mcp@latest"], "env": {"LOG_LEVEL": "INFO"}}'
claude mcp add-json -s user playwright '{"command": "npx", "args": ["@playwright/mcp@latest"]}'
claude mcp add -s user -t sse gitmcp https://gitmcp.io/docs

# With API keys (check ~/.zshrc first)
claude mcp add-json -s user github '{"command": "npx", "args": ["-y", "@modelcontextprotocol/server-github"], "env": {"GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_..."}}'
claude mcp add-json -s user firecrawl-mcp '{"command": "npx", "args": ["-y", "firecrawl-mcp"], "env": {"FIRECRAWL_API_KEY": "fc-..."}}'

# If Obsidian.app exists
claude mcp add-json -s user obsidian-mcp-tools '{"command": "/Users/steipete/Documents/steipete/.obsidian/plugins/mcp-tools/bin/mcp-server", "env": {"OBSIDIAN_API_KEY": "f1de8ac30724ecb05988c8eb2ee9b342b15f7b91eaba3fc8b0b5280dce3aca22"}}'
```

### For Claude Desktop

Claude Desktop only supports stdio transport. Create or update `~/Library/Application Support/Claude/claude_desktop_config.json`:

```json
{
	"mcpServers": {
		"peekaboo": {
			"command": "npx",
			"args": ["-y", "@steipete/peekaboo-mcp@beta"],
			"env": {
				"PEEKABOO_AI_PROVIDERS": "openai/gpt-4o,ollama/llava:latest",
				"OPENAI_API_KEY": "sk-..."
			}
		},
		"context7": {
			"command": "npx",
			"args": ["-y", "@upstash/context7-mcp@latest"]
		},
		"agent": {
			"command": "npx",
			"args": ["-y", "@steipete/claude-code-mcp@latest"]
		},
		"automator": {
			"command": "npx",
			"args": ["-y", "@steipete/macos-automator-mcp@latest"],
			"env": { "LOG_LEVEL": "INFO" }
		},
		"playwright": {
			"command": "npx",
			"args": ["@playwright/mcp@latest"]
		}
	}
}
```

Note: Claude Desktop cannot use GitMCP (SSE) or GitHub with HTTP transport.

### For Cursor

Create or update `~/.cursor/mcp.json`:

```json
{
	"mcpServers": {
		"peekaboo": {
			"command": "npx",
			"args": ["-y", "@steipete/peekaboo-mcp@beta"],
			"env": {
				"PEEKABOO_AI_PROVIDERS": "openai/gpt-4o,ollama/llava:latest",
				"OPENAI_API_KEY": "sk-..."
			}
		},
		"context7": {
			"command": "npx",
			"args": ["-y", "@upstash/context7-mcp@latest"]
		},
		"gitmcp": {
			"transport": "sse",
			"url": "https://gitmcp.io/docs"
		}
		// Add other servers following the same pattern
	}
}
```

### For Windsurf

Create or update `~/.codeium/windsurf/mcp_config.json` with the same format as Cursor.

### For VS Code

Update `~/Library/Application Support/Code/User/settings.json`:

```json
{
	"mcp.servers": {
		"peekaboo": {
			"command": "npx",
			"args": ["-y", "@steipete/peekaboo-mcp@beta"]
		}
		// Note: VS Code uses mcp.servers not mcpServers
	}
}
```

## Slash Commands (Project Rules)

Install 20+ development commands for Claude Code:

```bash
git clone https://github.com/steipete/agent-rules.git
cd agent-rules
bash install-project-rules.sh
```

For detailed descriptions of each command, have Claude read:

- https://github.com/steipete/agent-rules/blob/main/README.md
- https://github.com/steipete/agent-rules/tree/main/project-rules

Available commands include:

- **Git**: /commit, /commit-fast, /bug-fix, /pr-review, /analyze-issue
- **Code**: /check, /clean, /code-analysis
- **Docs**: /create-docs, /mermaid, /add-to-changelog
- **Dev**: /implement-task, /context-prime, /five
- **Swift**: /modern-swift
- **Meta**: /create-command, /continuous-improvement, and more

## API Key Setup

Add to `~/.zshrc`:

```bash
export OPENAI_API_KEY="sk-..."              # For Peekaboo AI vision
export GITHUB_PERSONAL_ACCESS_TOKEN="ghp-..." # For GitHub MCP (needs repo scope)
export FIRECRAWL_API_KEY="fc-..."           # For Firecrawl
```

Then run `source ~/.zshrc`

## Common Issues

- **JSON errors**: Use proper quotes in JSON commands
- **Claude Desktop**: Only supports stdio (no SSE/HTTP)
- **Permissions**: Grant Screen Recording for Peekaboo
- **Restart required**: After config changes

## Tips

- Use `-s user` flag to install servers globally in Claude Code
- API keys should be in ~/.zshrc, not hardcoded
- Always extract keys from environment variables
- Ensure local paths exist before adding (e.g., Obsidian MCP server)
- Use `mcp-sync.sh` to compare configs across different apps

## Terminal Title Trick

When running multiple Claude Code instances, it's hard to know which terminal is working on which project. Add this `cly` function to your `~/.zshrc` to solve this:

```bash
cly () {
    local folder=${PWD:t}
    echo -ne "\033]0;$folder — Claude\007"  # Set terminal title
    "$HOME/.claude/local/claude" --dangerously-skip-permissions "$@"
    local exit_code=$?
    echo -ne "\033]0;%~\007"  # Restore title
    return $exit_code
}
```

**What it does:**

- Shows the current folder name in your terminal tab (e.g., "agent-rules — Claude")
- Bypasses permission prompts with `--dangerously-skip-permissions`
- Restores the original terminal title when Claude exits
- Makes it easy to identify which Claude instance is working on which project

**Usage:** Instead of typing `claude`, type `cly` to start Claude Code with dynamic terminal titles.

Learn more about this terminal title trick and other Claude Code tips at: https://steipete.me/posts/2025/commanding-your-claude-code-army

## Presentation Template

```
I'll help you set up [APP] with MCP servers and slash commands.

Based on your system:

MCP Servers to install:
✓ Peekaboo - Screenshots (works without AI)
✓ Context7 - Documentation fetching
✓ Agent - Sub-agent capabilities
✓ GitMCP - Enhanced Git operations
[✓ GitHub - If API key found]
[✓ Obsidian - If app exists]

Plus 20 slash commands:
• /commit, /bug-fix, /pr-review, /check...

Ready to proceed?
```

## Sync Tool

Use `mcp-sync.sh` to compare configs across apps:
https://github.com/steipete/agent-rules/blob/main/global-rules/mcp-sync.sh

---

For detailed server descriptions, visit: https://github.com/steipete/agent-rules

# Spry Plugin for Claude Code & Codex

First-party AI support for Spry applications.

## What's Included

- **spry-docs** skill — Authoritative Spry framework guidance
- **spry-debugging** skill — Debugging playbooks with MCP-first workflows
- **spry-mcp** server — Local project inspection via MCP tools

## Installation

### Claude Code

```bash
# Install the plugin
claude plugins install spry
```

Or manually, add to `~/.claude/settings.json`:

```json
{
  "plugins": {
    "spry": {
      "source": "<path-to-spry-repo>/.spry-plugin"
    }
  }
}
```

### MCP Server

The MCP server runs via `dart run spry mcp` in any Spry project directory. No additional installation needed — it's part of the Spry package.

## MCP Tools

When connected, the MCP server provides:

| Tool | Description |
|---|---|
| `spry.get_project_info` | Route count, target, version summary |
| `spry.get_config` | Effective build configuration |
| `spry.list_routes` | All routes with methods and source files |
| `spry.list_middleware` | Global and scoped middleware |
| `spry.list_error_handlers` | Scoped error handlers |
| `spry.explain_route` | Match a request to its route, middleware, and errors |
| `spry.get_openapi_status` | OpenAPI generation config |
| `spry.get_client_status` | Client generation config |

## Requirements

- Dart SDK ^3.10.0
- Spry package (any recent version)
- A Spry project with `spry.config.dart`

## Development

The plugin source lives in this directory (`.spry-plugin/`). Skills follow the [Agent Skills specification](https://agentskills.io/specification) and live in `skills/`. MCP server code is in `lib/src/mcp/`.

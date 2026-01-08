# Brooklyn Marketplace

A personal collection of Claude Code plugins.

## Installation

```bash
curl -fsSL https://raw.githubusercontent.com/AnthonySu/brooklyn-marketplace/main/install.sh | bash
```

Then restart Claude Code.

## Plugins

### claude-settings-sync

Sync Claude Code settings across devices via GitHub Gists.

**Setup:** After installation, run `/claude-settings-sync:setup`

**Commands:**
| Command | Description |
|---------|-------------|
| `/claude-settings-sync` | Show sync status |
| `/claude-settings-sync:setup` | Configure GitHub token |
| `/claude-settings-sync:push` | Upload settings to Gist |
| `/claude-settings-sync:pull` | Download settings from Gist |
| `/claude-settings-sync:uninstall` | Disable this plugin |

## Uninstall

**Remove entire marketplace:**
```bash
~/.claude/plugins/marketplaces/brooklyn-marketplace/uninstall.sh
```

**Disable single plugin only:**
```bash
~/.claude/plugins/marketplaces/brooklyn-marketplace/claude-settings-sync/uninstall.sh
```

## Manual Configuration

Add to `~/.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "brooklyn-marketplace": {
      "source": {
        "source": "github",
        "repo": "AnthonySu/brooklyn-marketplace"
      }
    }
  },
  "enabledPlugins": {
    "claude-settings-sync@brooklyn-marketplace": true
  }
}
```

## License

MIT

# Brooklyn Marketplace

A personal collection of Claude Code plugins.

## Plugins

### claude-settings-sync

Sync Claude Code settings across devices via GitHub Gists.

**Commands:**
- `/claude-settings-sync` - Show sync status
- `/claude-settings-sync:setup` - Configure your GitHub token
- `/claude-settings-sync:push` - Upload settings to Gist
- `/claude-settings-sync:pull` - Download settings from Gist

## Installation

### Quick Install (Recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/AnthonySu/brooklyn-marketplace/main/claude-settings-sync/install.sh | bash
```

### Manual Configuration

Add to your Claude Code settings (`~/.claude/settings.json`):

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

Then clone the repo:

```bash
git clone https://github.com/AnthonySu/brooklyn-marketplace.git ~/.claude/plugins/marketplaces/brooklyn-marketplace
```

## License

MIT

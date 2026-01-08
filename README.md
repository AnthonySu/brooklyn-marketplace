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

Add to your Claude Code settings:

```json
{
  "extraKnownMarketplaces": {
    "brooklyn-marketplace": {
      "source": {
        "source": "github",
        "repo": "AnthonySu/brooklyn-marketplace"
      }
    }
  }
}
```

## License

MIT

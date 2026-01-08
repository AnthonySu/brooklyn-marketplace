---
description: Uninstall claude-settings-sync plugin and brooklyn-marketplace
allowed-tools: Bash, Read, AskUserQuestion
---

# Uninstall Settings Sync

Completely remove the claude-settings-sync plugin and brooklyn-marketplace.

## What This Removes

- brooklyn-marketplace directory (`~/.claude/plugins/marketplaces/brooklyn-marketplace/`)
- Plugin entries from Claude Code configuration files
- Sync configuration (GitHub token, Gist ID)
- Local backup files

## What This Keeps

- Your GitHub Gist with synced settings (not deleted remotely)
- Your actual Claude Code settings (only the sync plugin is removed)

## Uninstall Steps

Run the uninstall script:

```bash
~/.claude/plugins/marketplaces/brooklyn-marketplace/claude-settings-sync/uninstall.sh
```

The script will:
1. Ask for confirmation
2. Remove the marketplace from `settings.json`
3. Clean up `known_marketplaces.json`
4. Clean up `installed_plugins.json`
5. Remove sync config and local backups
6. Delete the marketplace directory

After uninstall, tell the user to restart Claude Code.

## Alternative: One-liner

If the local files are corrupted, run:

```bash
curl -fsSL https://raw.githubusercontent.com/AnthonySu/brooklyn-marketplace/main/claude-settings-sync/uninstall.sh | bash
```

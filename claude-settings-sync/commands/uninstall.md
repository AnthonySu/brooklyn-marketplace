---
description: Disable claude-settings-sync plugin
allowed-tools: Bash, Read, AskUserQuestion
---

# Uninstall Settings Sync

Disable the claude-settings-sync plugin and remove its configuration.

## Two Options

### Option 1: Disable Plugin Only (Default)

This keeps the brooklyn-marketplace installed for other plugins.

```bash
~/.claude/plugins/marketplaces/brooklyn-marketplace/claude-settings-sync/uninstall.sh
```

**Removes:**
- Plugin from enabledPlugins
- Sync configuration (GitHub token, Gist ID)
- Local backup files

**Keeps:**
- brooklyn-marketplace (for other plugins)
- Your GitHub Gist (not deleted remotely)

### Option 2: Remove Entire Marketplace

This removes brooklyn-marketplace and all its plugins.

```bash
~/.claude/plugins/marketplaces/brooklyn-marketplace/uninstall.sh
```

## Steps for Option 1 (Plugin Only)

Run the plugin uninstall script:

```bash
~/.claude/plugins/marketplaces/brooklyn-marketplace/claude-settings-sync/uninstall.sh
```

The script will:
1. Ask for confirmation
2. Disable plugin in `settings.json`
3. Remove from `installed_plugins.json`
4. Remove sync config and local backups

After uninstall, tell the user to restart Claude Code.

To re-enable later, set `"claude-settings-sync@brooklyn-marketplace": true` in enabledPlugins.

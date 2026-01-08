#!/bin/bash
# uninstall.sh - Uninstaller for claude-settings-sync plugin only
#
# This removes just the plugin configuration and disables it,
# but keeps the brooklyn-marketplace installed for other plugins.
#
# To remove the entire marketplace, use:
#   ~/.claude/plugins/marketplaces/brooklyn-marketplace/uninstall.sh

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

# Paths
CLAUDE_DIR="$HOME/.claude"
PLUGINS_DIR="$CLAUDE_DIR/plugins"
MARKETPLACE_NAME="brooklyn-marketplace"
PLUGIN_NAME="claude-settings-sync"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"
INSTALLED_PLUGINS_FILE="$PLUGINS_DIR/installed_plugins.json"
SYNC_CONFIG_DIR="$PLUGINS_DIR/plugins-config"
SYNC_BACKUPS_DIR="$CLAUDE_DIR/sync-backups"

log_info() { echo -e "${CYAN}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

echo ""
echo -e "${YELLOW}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${YELLOW}║${NC}${BOLD}     Claude Settings Sync - Plugin Uninstaller              ${NC}${YELLOW}║${NC}"
echo -e "${YELLOW}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if jq is available
if ! command -v jq &> /dev/null; then
    log_error "jq is required but not installed."
    echo "Install with: brew install jq (macOS) or apt install jq (Linux)"
    exit 1
fi

# Confirm uninstall
echo -e "${YELLOW}This will:${NC}"
echo "  - Disable the claude-settings-sync plugin"
echo "  - Remove sync configuration (GitHub token, Gist ID)"
echo "  - Remove local backup files"
echo ""
echo -e "${CYAN}Note:${NC} The brooklyn-marketplace will remain installed."
echo "      To remove everything, run the marketplace uninstall instead."
echo ""
read -p "Continue? [y/N] " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Uninstall cancelled."
    exit 0
fi

PLUGIN_KEY="${PLUGIN_NAME}@${MARKETPLACE_NAME}"

# Disable plugin in settings.json
log_info "Disabling plugin in settings.json..."
if [ -f "$SETTINGS_FILE" ]; then
    SETTINGS=$(cat "$SETTINGS_FILE")
    SETTINGS=$(echo "$SETTINGS" | jq --arg plugin "$PLUGIN_KEY" '
        if .enabledPlugins[$plugin] then
            .enabledPlugins[$plugin] = false
        else . end
    ')
    echo "$SETTINGS" | jq '.' > "$SETTINGS_FILE"
    log_success "Disabled $PLUGIN_NAME"
else
    log_warn "settings.json not found, skipping"
fi

# Remove from installed_plugins.json
log_info "Removing from installed_plugins.json..."
if [ -f "$INSTALLED_PLUGINS_FILE" ]; then
    INSTALLED=$(cat "$INSTALLED_PLUGINS_FILE")
    INSTALLED=$(echo "$INSTALLED" | jq --arg plugin "$PLUGIN_KEY" '
        if .plugins then
            .plugins |= del(.[$plugin])
        else . end
    ')
    echo "$INSTALLED" | jq '.' > "$INSTALLED_PLUGINS_FILE"
    log_success "Removed plugin entry"
else
    log_warn "installed_plugins.json not found, skipping"
fi

# Remove sync config
log_info "Removing sync configuration..."
if [ -f "$SYNC_CONFIG_DIR/sync-config.json" ]; then
    rm -f "$SYNC_CONFIG_DIR/sync-config.json"
    log_success "Removed sync-config.json"
else
    log_warn "No sync config found, skipping"
fi

# Remove backups
log_info "Removing local backups..."
if [ -d "$SYNC_BACKUPS_DIR" ]; then
    rm -rf "$SYNC_BACKUPS_DIR"
    log_success "Removed sync-backups directory"
else
    log_warn "No backups found, skipping"
fi

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║${NC}${BOLD}          Plugin Disabled Successfully!                     ${NC}${GREEN}║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "The claude-settings-sync plugin has been disabled."
echo "Please restart Claude Code to complete the removal."
echo ""
echo -e "${CYAN}Note:${NC} Your GitHub Gist was NOT deleted."
echo "To delete it, visit: https://gist.github.com"
echo ""
echo "To re-enable this plugin later, set in settings.json:"
echo "  \"enabledPlugins\": { \"$PLUGIN_KEY\": true }"
echo ""

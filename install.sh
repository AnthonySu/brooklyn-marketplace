#!/bin/bash
# install.sh - Automated installer for brooklyn-marketplace
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/AnthonySu/brooklyn-marketplace/main/install.sh | bash

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
MARKETPLACES_DIR="$PLUGINS_DIR/marketplaces"
MARKETPLACE_NAME="brooklyn-marketplace"
INSTALL_DIR="$MARKETPLACES_DIR/$MARKETPLACE_NAME"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"
KNOWN_MARKETPLACES_FILE="$PLUGINS_DIR/known_marketplaces.json"
INSTALLED_PLUGINS_FILE="$PLUGINS_DIR/installed_plugins.json"

REPO_URL="https://github.com/AnthonySu/brooklyn-marketplace.git"

# Plugins to enable (add more here as marketplace grows)
PLUGINS=("claude-settings-sync")

log_info() { echo -e "${CYAN}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

echo ""
echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}${BOLD}        Brooklyn Marketplace - Installer                    ${NC}${CYAN}║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check prerequisites
log_info "Checking prerequisites..."

if ! command -v git &> /dev/null; then
    log_error "git is required but not installed."
    exit 1
fi

if ! command -v jq &> /dev/null; then
    log_error "jq is required but not installed."
    echo "Install with: brew install jq (macOS) or apt install jq (Linux)"
    exit 1
fi

if [ ! -d "$CLAUDE_DIR" ]; then
    log_error "Claude Code directory not found at $CLAUDE_DIR"
    echo "Please install and run Claude Code first."
    exit 1
fi

log_success "Prerequisites OK"

# Create directories if needed
log_info "Setting up directories..."
mkdir -p "$MARKETPLACES_DIR"
mkdir -p "$PLUGINS_DIR"

# Clone or update repository
if [ -d "$INSTALL_DIR" ]; then
    log_info "Existing installation found, updating..."
    cd "$INSTALL_DIR"
    git pull origin main 2>/dev/null || git pull origin master 2>/dev/null || log_warn "Could not update, using existing version"
else
    log_info "Cloning repository..."
    git clone "$REPO_URL" "$INSTALL_DIR"
fi

# Make all scripts executable
log_info "Setting script permissions..."
find "$INSTALL_DIR" -name "*.sh" -exec chmod +x {} \;

# Update settings.json
log_info "Updating settings.json..."

if [ ! -f "$SETTINGS_FILE" ]; then
    echo '{}' > "$SETTINGS_FILE"
fi

SETTINGS=$(cat "$SETTINGS_FILE")

# Add marketplace to extraKnownMarketplaces
SETTINGS=$(echo "$SETTINGS" | jq --arg name "$MARKETPLACE_NAME" --arg repo "AnthonySu/$MARKETPLACE_NAME" '
    .extraKnownMarketplaces //= {} |
    .extraKnownMarketplaces[$name] = {
        "source": {
            "source": "github",
            "repo": $repo
        }
    }
')

# Enable all plugins
for PLUGIN in "${PLUGINS[@]}"; do
    PLUGIN_KEY="${PLUGIN}@${MARKETPLACE_NAME}"
    SETTINGS=$(echo "$SETTINGS" | jq --arg plugin "$PLUGIN_KEY" '
        .enabledPlugins //= {} |
        .enabledPlugins[$plugin] = true
    ')
    log_info "Enabled plugin: $PLUGIN"
done

echo "$SETTINGS" | jq '.' > "$SETTINGS_FILE"
log_success "Updated settings.json"

# Update known_marketplaces.json
log_info "Updating known_marketplaces.json..."

if [ ! -f "$KNOWN_MARKETPLACES_FILE" ]; then
    echo '{}' > "$KNOWN_MARKETPLACES_FILE"
fi

KNOWN=$(cat "$KNOWN_MARKETPLACES_FILE")
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")

KNOWN=$(echo "$KNOWN" | jq --arg name "$MARKETPLACE_NAME" --arg repo "AnthonySu/$MARKETPLACE_NAME" --arg path "$INSTALL_DIR" --arg ts "$TIMESTAMP" '
    .[$name] = {
        "source": {
            "source": "github",
            "repo": $repo
        },
        "installLocation": $path,
        "lastUpdated": $ts
    }
')

echo "$KNOWN" | jq '.' > "$KNOWN_MARKETPLACES_FILE"
log_success "Updated known_marketplaces.json"

# Update installed_plugins.json
log_info "Updating installed_plugins.json..."

if [ ! -f "$INSTALLED_PLUGINS_FILE" ]; then
    echo '{"version": 2, "plugins": {}}' > "$INSTALLED_PLUGINS_FILE"
fi

INSTALLED=$(cat "$INSTALLED_PLUGINS_FILE")

for PLUGIN in "${PLUGINS[@]}"; do
    PLUGIN_KEY="${PLUGIN}@${MARKETPLACE_NAME}"
    PLUGIN_PATH="$INSTALL_DIR/$PLUGIN"

    # Get version from plugin.json if exists
    PLUGIN_VERSION="1.0.0"
    if [ -f "$PLUGIN_PATH/.claude-plugin/plugin.json" ]; then
        PLUGIN_VERSION=$(jq -r '.version // "1.0.0"' "$PLUGIN_PATH/.claude-plugin/plugin.json")
    fi

    INSTALLED=$(echo "$INSTALLED" | jq --arg plugin "$PLUGIN_KEY" --arg path "$PLUGIN_PATH" --arg version "$PLUGIN_VERSION" --arg ts "$TIMESTAMP" --arg home "$HOME" '
        .version = 2 |
        .plugins[$plugin] = [{
            "scope": "project",
            "installPath": $path,
            "version": $version,
            "installedAt": $ts,
            "lastUpdated": $ts,
            "isLocal": false,
            "projectPath": $home
        }]
    ')
done

echo "$INSTALLED" | jq '.' > "$INSTALLED_PLUGINS_FILE"
log_success "Updated installed_plugins.json"

# Done!
echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║${NC}${BOLD}              Installation Complete!                        ${NC}${GREEN}║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "Installed plugins:"
for PLUGIN in "${PLUGINS[@]}"; do
    echo "  - $PLUGIN"
done
echo ""
echo "Next steps:"
echo "  1. Restart Claude Code (or start a new session)"
echo "  2. Run /claude-settings-sync:setup to configure settings sync"
echo ""
echo "To uninstall the entire marketplace:"
echo "  $INSTALL_DIR/uninstall.sh"
echo ""

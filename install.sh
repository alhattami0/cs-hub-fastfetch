#!/usr/bin/env bash

set -e

# ---------------- Colors ----------------
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
CYAN="\e[36m"
RESET="\e[0m"
BOLD="\e[1m"

# ---------------- Paths ----------------
CONFIG_DIR="$HOME/.config/fastfetch"
ASSETS_DIR="assets"
CONFIGS_DIR="configs"
SCREENSHOTS_DIR="screenshots"

# ---------------- UI ----------------
clear
echo -e "${CYAN}${BOLD}"
echo "╔══════════════════════════════════════╗"
echo "║   CS HUB Fastfetch Theme Installer   ║"
echo "╚══════════════════════════════════════╝"
echo -e "${RESET}"

# --------------------------------------------------
# 1. Ensure project directories exist
# --------------------------------------------------
echo -e "${BLUE}📁 Ensuring project directories...${RESET}"
mkdir -p "$ASSETS_DIR" "$CONFIGS_DIR" "$SCREENSHOTS_DIR"

# --------------------------------------------------
# 2. Check fastfetch
# --------------------------------------------------
if ! command -v fastfetch >/dev/null 2>&1; then
  echo -e "${YELLOW}⚠ fastfetch not found. Installing...${RESET}"

  if command -v apt >/dev/null 2>&1; then
    sudo apt update && sudo apt install -y fastfetch
  elif command -v pacman >/dev/null 2>&1; then
    sudo pacman -Sy --noconfirm fastfetch
  elif command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y fastfetch
  else
    echo -e "${RED}✖ Unsupported package manager.${RESET}"
    exit 1
  fi
else
  echo -e "${GREEN}✔ fastfetch is installed${RESET}"
fi

# --------------------------------------------------
# 3. Create fastfetch config directory
# --------------------------------------------------
echo -e "${BLUE}📁 Creating ~/.config/fastfetch${RESET}"
mkdir -p "$CONFIG_DIR"

# --------------------------------------------------
# 4. Load themes
# --------------------------------------------------
THEMES=($(ls "$ASSETS_DIR" | sed 's/\..*$//'))

if [ ${#THEMES[@]} -eq 0 ]; then
  echo -e "${RED}✖ No themes found in assets/${RESET}"
  exit 1
fi

echo
echo -e "${CYAN}${BOLD}🎨 Select a theme:${RESET}"
for i in "${!THEMES[@]}"; do
  printf "  ${CYAN}%d${RESET}) %s\n" "$((i+1))" "${THEMES[$i]}"
done

read -rp "$(echo -e "${BOLD}> Choice:${RESET} ")" THEME_CHOICE

if ! [[ "$THEME_CHOICE" =~ ^[0-9]+$ ]] || [ "$THEME_CHOICE" -lt 1 ] || [ "$THEME_CHOICE" -gt "${#THEMES[@]}" ]; then
  echo -e "${RED}✖ Invalid theme selection. Exiting.${RESET}"
  exit 1
fi

THEME="${THEMES[$((THEME_CHOICE-1))]}"

# --------------------------------------------------
# 5. Select layout
# --------------------------------------------------
echo
echo -e "${CYAN}${BOLD}🧩 Select layout:${RESET}"
echo "  1) sample_1 (compact)"
echo "  2) sample_2 (extended)"

read -rp "$(echo -e "${BOLD}> Choice:${RESET} ")" SAMPLE_CHOICE

case "$SAMPLE_CHOICE" in
  1) SAMPLE_FILE="sample_1" ;;
  2) SAMPLE_FILE="sample_2" ;;
  *)
    echo -e "${RED}✖ Invalid layout selection. Exiting.${RESET}"
    exit 1
    ;;
esac

CONFIG_FILE="$THEME-$SAMPLE_FILE.jsonc"
SCREENSHOT_FILE="$SCREENSHOTS_DIR/$THEME-$SAMPLE_FILE.png"

# --------------------------------------------------
# 6. Screenshot preview
# --------------------------------------------------
echo
echo -e "${CYAN}👀 Preview: ${BOLD}$THEME ($SAMPLE_FILE)${RESET}"

if command -v kitty >/dev/null 2>&1 && [ -f "$SCREENSHOT_FILE" ]; then
  sleep 1
  clear
  kitty +kitten icat --clear
  kitty +kitten icat --scale-up "$SCREENSHOT_FILE"
else
  echo -e "${YELLOW}⚠ Preview unavailable (kitty or screenshot missing)${RESET}"
fi

# --------------------------------------------------
# 7. Verify config
# --------------------------------------------------
if [ ! -f "$CONFIGS_DIR/$CONFIG_FILE" ]; then
  echo -e "${RED}✖ Config not found: $CONFIG_FILE${RESET}"
  exit 1
fi

# --------------------------------------------------
# 8. Apply configuration
# --------------------------------------------------
echo
echo -e "${BLUE}📦 Copying assets...${RESET}"
cp -r "$ASSETS_DIR" "$CONFIG_DIR/"

echo -e "${BLUE}⚙ Applying configuration...${RESET}"
cp "$CONFIGS_DIR/$CONFIG_FILE" "$CONFIG_DIR/config.jsonc"

echo
echo -e "${GREEN}${BOLD}✔ Installation complete!${RESET}"
echo -e "${CYAN}➡ Run 'fastfetch' to see your new theme.${RESET}"

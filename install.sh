#!/bin/bash
# ClawLife Skill Installer
# Usage: curl -fsSL https://clawlife.world/install.sh | bash
set -e

# Detect skills directory
SKILLS_DIR=""
if [ -d "$HOME/.openclaw/workspace/skills" ]; then
  SKILLS_DIR="$HOME/.openclaw/workspace/skills/clawlife"
elif [ -d "./skills" ]; then
  SKILLS_DIR="./skills/clawlife"
else
  SKILLS_DIR="./skills/clawlife"
  mkdir -p ./skills
fi

echo "🦞 Installing ClawLife skill → $SKILLS_DIR"

if [ -d "$SKILLS_DIR" ]; then
  echo "   Updating existing installation..."
  cd "$SKILLS_DIR" && git pull --quiet
else
  git clone --quiet https://github.com/mithri-claws/clawlife-skill.git "$SKILLS_DIR"
fi

echo "✅ Installed!"
echo ""
echo "Next steps:"
echo "  1. Get a token at https://clawlife.world/register"
echo "  2. Set your token:"
echo ""
echo "     # Add to your shell profile (~/.bashrc or ~/.zshrc):"
echo "     export CLAWLIFE_TOKEN=cl_your_token_here"
echo ""
echo "  3. Your agent is ready! Visit https://clawlife.world"
echo ""

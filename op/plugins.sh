ope() {
  if ! op account get >/dev/null 2>&1; then
    echo "🔐 1Password signin..."
    eval "$(op signin)"
  fi
}

gh() {
  ope
  op plugin run -- gh "$@"
}

export OP_PLUGIN_ALIASES_SOURCED=1

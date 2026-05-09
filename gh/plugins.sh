# gh CLI shell integration
#
# 認証トークンの取り扱いを OS 別に切り替える。
#   - macOS: 素の gh を使う。`gh auth login` でトークンが macOS Keychain に保存される。
#   - WSL/Linux: 1Password CLI 経由で取得する (gh を関数で上書きして op plugin run でラップ)。

# 1Password にサインインしていなければサインインする共通ヘルパ
ope() {
  if ! op account get >/dev/null 2>&1; then
    echo "🔐 1Password signin..."
    eval "$(op signin)"
  fi
}

case "${OSTYPE}" in
  darwin*)
    # 何もしない: gh は keychain ベースで動作する
    ;;
  linux*|msys*|cygwin*)
    gh() {
      ope
      op plugin run -- gh "$@"
    }

    export OP_PLUGIN_ALIASES_SOURCED=1
    ;;
esac

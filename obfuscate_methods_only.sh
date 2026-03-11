#!/bin/bash
# =============================================================================
# 轻量级方法混淆脚本 - Lightweight Method Obfuscation Script
# 专门针对 min/ 目录，**只混淆方法名**，不碰类名、变量和字符串，保证业务和 SDK 正常运行。
# 用法: bash obfuscate_methods_only.sh <目标目录>
# =============================================================================

set -e

TARGET_DIR="${1:?请传入目标目录 Usage: $0 <dir>}"
TARGET_DIR="${TARGET_DIR%/}"

if [ ! -d "$TARGET_DIR" ]; then
  echo "❌ 目录不存在: $TARGET_DIR"
  exit 1
fi

# ---------- 备份 ----------
BACKUP_DIR="${TARGET_DIR}_backup_methods_$(date +%Y%m%d_%H%M%S)"
cp -r "$TARGET_DIR" "$BACKUP_DIR"
echo "✅ 已备份到: $BACKUP_DIR"

# ---------- 提取并重命名方法 ----------
echo ""
echo "🔍 开始扫描并混淆自定义方法名..."

# 1. 扫描出所有的 private / fileprivate / internal 自定义方法
# 排除系统方法、协议方法 (以 init, deinit, viewDidLoad, application, didSelect, webView, userNotificationCenter 等开头的方法)
# 排除 @objc 方法 (通常是供 webview 交互或按钮点击使用)
# 这里使用 perl 提取 func 关键字后面的方法名
METHOD_LIST=$(find "$TARGET_DIR" -name "*.swift" -exec perl -nle '
    # 匹配普通 func 定义，排除 @objc, override, public, open
    if (/^\s*(?:private\s+|fileprivate\s+|internal\s+)?func\s+([a-zA-Z0-9_]+)\s*\(/) {
        my $method = $1;
        # 过滤掉常见的系统回调和协议方法
        unless ($method =~ /^(init|deinit|viewDidLoad|viewWillAppear|viewDidAppear|viewWillDisappear|viewDidDisappear|application|scene|tableView|collectionView|scrollView|webView|userContentController|_evaluateJavascript|evaluateJavascript|request|productsRequest|paymentQueue|userNotificationCenter|messaging|URLSession|observeValue|touches|layoutSubviews|awakeFromNib|prepare|didSelect|numberOf|cellFor|sizeFor|viewFor|didDeselect|should|can|will|did|jsEvent)/) {
            print $method;
        }
    }
' {} + | sort | uniq | grep -v "^\s*$")

if [ -z "$METHOD_LIST" ]; then
    echo "⚠️ 没有找到安全可混淆的方法名"
    exit 0
fi

# 2. 为每个方法生成一个新的混淆名，并全局替换
echo "📝 准备混淆以下方法："
declare -a OLD_METHODS
declare -a NEW_METHODS
INDEX=0

for method in $METHOD_LIST; do
    if [ ${#method} -gt 3 ]; then
        OLD_METHODS[$INDEX]=$method
        
        # 生成两个随机小写字母作为前缀
        letters=(a b c d e f g h i j k l m n o p q r s t u v w x y z)
        c1=${letters[$RANDOM % 26]}
        c2=${letters[$RANDOM % 26]}
        
        # 生成 随机双字母 + _ + 4 位随机十六进制方法名 (例如: xj_a3f8)
        NEW_METHODS[$INDEX]=$(printf "%s%s_%04x" "$c1" "$c2" $((RANDOM % 65536)))
        
        echo "   - $method  →  ${NEW_METHODS[$INDEX]}"
        INDEX=$((INDEX + 1))
    fi
done

# 3. 执行全局替换
# 注意：这会替换整个项目里的单词，为了安全，我们在替换时使用单词边界 \b
echo ""
echo "🔄 正在替换文件中..."

for (( i=0; i<${#OLD_METHODS[@]}; i++ )); do
    old="${OLD_METHODS[$i]}"
    new="${NEW_METHODS[$i]}"
    
    # 使用 perl 进行单词边界替换，防止把 `myFunction` 替换成了一部分
    find "$TARGET_DIR" -name "*.swift" -exec perl -pi -e "s/\b${old}\b/${new}/g" {} +
done

echo ""
echo "🎉 方法级混淆完成！"

# ---------- 4. 字符串混淆 (仅混淆域名) ----------
echo ""
echo "🔠 开始混淆域名字符串 ReplaceUrlDomain ..."

# 这里默认把 codegalx 变成 hex 数组
# 用户如果需要可以改动这个预设
DOMAIN="codegalx"

str_to_hex_array() {
  local str="$1"
  local result=""
  for (( i=0; i<${#str}; i++ )); do
    local char="${str:$i:1}"
    local hex=$(printf '%02x' "'$char")
    result+="0x${hex}, "
  done
  echo "${result%, }"
}

HEX_BYTES=$(str_to_hex_array "$DOMAIN")

# 生成闭包替换文本 (注意使用 printf 保证换行符被正确处理)
_AZ_DOMAIN_OBF=$(printf 'let ReplaceUrlDomain: String = {\n    let b: [UInt8] = [%s]\n    return String(bytes: b, encoding: .utf8) ?? ""\n}()' "$HEX_BYTES")
export _AZ_DOMAIN_OBF

# 查找所有定义 let ReplaceUrlDomain = "xxx" 的地方进行替换
# 匹配 let ReplaceUrlDomain = "..." 或者 let ReplaceUrlDomain: String = "..."
find "$TARGET_DIR" -name "*.swift" -exec perl -i -0pe 's/let\s+ReplaceUrlDomain(\s*:\s*String)?\s*=\s*"[^"]*"/\n$ENV{_AZ_DOMAIN_OBF}\n/g' {} +

echo "   ✓ 域名 $DOMAIN 已转为 UInt8 字节数组"

echo ""
echo "🎉 所有混淆已完成！请重新编译项目测试业务是否正常。"

#!/bin/bash
# =============================================================================
# B面混淆脚本 v2 - 每次运行生成不同随机名称
# 用法: bash obfuscate_b_side.sh <目标目录> [域名] [包ID]
# 示例: bash obfuscate_b_side.sh ./tego/er codegalx 2020
# =============================================================================

set -e

TARGET_DIR="${1:?请传入目标目录 Usage: $0 <dir> [domain] [pkg_id]}"
DOMAIN="${2:-}"
PKG_ID="${3:-}"
TARGET_DIR="${TARGET_DIR%/}"

if [ ! -d "$TARGET_DIR" ]; then
  echo "❌ 目录不存在: $TARGET_DIR"; exit 1
fi

# ---------- 备份 ----------
BACKUP_DIR="${TARGET_DIR}_backup_$(date +%Y%m%d_%H%M%S)"
cp -r "$TARGET_DIR" "$BACKUP_DIR"
echo "✅ 已备份到: $BACKUP_DIR"

# ---------- 随机名生成工具 ----------

# 生成随机字母前缀（2-3位大写字母，每次运行不同）
random_prefix() {
  local len=$((RANDOM % 2 + 2))   # 2 或 3 位
  local chars=( A B C D E F G H J K L M N P Q R S T V W X Y Z )
  local result=""
  for (( i=0; i<len; i++ )); do
    result+="${chars[$((RANDOM % ${#chars[@]}))]}"
  done
  echo "$result"
}

# 生成随机类名后缀（5-8位字母数字混合）
random_suffix() {
  local len=$((RANDOM % 4 + 5))   # 5-8位
  local chars=( a b c d e f g h j k m n p q r s t v w x y z 0 1 2 3 4 5 6 7 8 9 )
  local result=""
  for (( i=0; i<len; i++ )); do
    result+="${chars[$((RANDOM % ${#chars[@]}))]}"
  done
  # 首字母大写
  echo "$(tr '[:lower:]' '[:upper:]' <<< ${result:0:1})${result:1}"
}

# 生成随机方法名（p_ + 8位十六进制）
random_method() {
  printf "p_%08x" $((RANDOM * RANDOM % 4294967296))
}

# 字符串转 UInt8 十六进制数组
str_to_hex_array() {
  local str="$1"
  local result=""
  for (( i=0; i<${#str}; i++ )); do
    local hex=$(printf '%02x' "'${str:$i:1}")
    result+="0x${hex}, "
  done
  echo "${result%, }"
}

# ---------- 生成本次运行的随机前缀和类名 ----------
PFX=$(random_prefix)
echo ""
echo "🎲 本次随机前缀: ${PFX}"

# 生成随机类名映射（每次都不同）
declare -A CLASS_MAP=(
  ["AppWebViewScriptDelegateHandler"]="${PFX}$(random_suffix)"
  ["AppWebViewController"]="${PFX}$(random_suffix)"
  ["AppleIAPManager"]="${PFX}$(random_suffix)"
  ["IAPcompletionHandle"]="${PFX}$(random_suffix)"
  ["ApplePayType"]="${PFX}$(random_suffix)"
  ["AppleIAPStatus"]="${PFX}$(random_suffix)"
  ["AppAdjustManager"]="${PFX}$(random_suffix)"
  ["AppRequestTool"]="${PFX}$(random_suffix)"
  ["AppRequestModel"]="${PFX}$(random_suffix)"
  ["AppBaseResponse"]="${PFX}$(random_suffix)"
  ["AppErrorResponse"]="${PFX}$(random_suffix)"
  ["FinishBlock"]="${PFX}$(random_suffix)"
  ["AppPermissionTool"]="${PFX}$(random_suffix)"
  ["AppConfig"]="${PFX}$(random_suffix)"
  ["LocalPushScheduler"]="${PFX}$(random_suffix)"
  ["WaitViewController"]="${PFX}$(random_suffix)"
  ["ProgressHUD"]="${PFX}$(random_suffix)"
  ["kProgressHUD_W"]="${PFX}$(random_suffix)"
  ["kProgressHUD_cornerRadius"]="${PFX}$(random_suffix)"
  ["kProgressHUD_alpha"]="${PFX}$(random_suffix)"
  ["JSMessageModel"]="${PFX}$(random_suffix)"
  ["UserInfoModel"]="${PFX}$(random_suffix)"
)

# 生成随机 Bridge/Cache 标识符（字符串字面量）
BRIDGE_HANDLER="az$(random_suffix | tr '[:upper:]' '[:lower:]')"
PUSH_PREFIX="lp$(printf '%04x' $((RANDOM % 65536)))_"
CACHE_PAY="cp$(printf '%04x' $((RANDOM % 65536)))"
CACHE_SUB="cs$(printf '%04x' $((RANDOM % 65536)))"

# 保存本次映射日志（方便调试）
LOG_FILE="${TARGET_DIR}_obfuscation_map_$(date +%Y%m%d_%H%M%S).txt"
{
  echo "# 混淆映射记录 - $(date)"
  echo "# 前缀: ${PFX}"
  echo ""
  echo "## 类名映射"
  for old in "${!CLASS_MAP[@]}"; do echo "  ${old} → ${CLASS_MAP[$old]}"; done
  echo ""
  echo "## 字符串标识符"
  echo "  syncAppInfo → ${BRIDGE_HANDLER}"
  echo "  offmarket_loop_ → ${PUSH_PREFIX}"
  echo "  OrderTransactionInfo_Cache → ${CACHE_PAY}"
  echo "  OrderTransactionInfo_Subscribe_Cache → ${CACHE_SUB}"
} > "$LOG_FILE"
echo "📋 映射记录保存到: $(basename "$LOG_FILE")"

# =====================================================
# Step 1: 清理模板注释
# =====================================================
echo ""
echo "🧹 Step 1: 清理模板注释..."
for name in "OverseaH5" "AbroadTalking" "OverseaCommunity" "OverseasH5" "BaseH5"; do
  LC_ALL=C find "$TARGET_DIR" -name "*.swift" -exec sed -i '' "s|//  ${name}||g" {} +
  LC_ALL=C find "$TARGET_DIR" -name "*.swift" -exec sed -i '' "s|// ${name}||g" {} +
done
echo "   ✓ 完成"

# =====================================================
# Step 2: 类名随机重命名
# =====================================================
echo ""
echo "🔤 Step 2: 类名随机混淆..."
for old in "${!CLASS_MAP[@]}"; do
  new="${CLASS_MAP[$old]}"
  LC_ALL=C find "$TARGET_DIR" -name "*.swift" -exec sed -i '' "s/\b${old}\b/${new}/g" {} +
  echo "   ✓ ${old} → ${new}"
done

# =====================================================
# Step 3: 内部标识符随机混淆
# =====================================================
echo ""
echo "🔀 Step 3: 内部标识符随机混淆..."
LC_ALL=C find "$TARGET_DIR" -name "*.swift" -exec sed -i '' "s/syncAppInfo/${BRIDGE_HANDLER}/g" {} +
LC_ALL=C find "$TARGET_DIR" -name "*.swift" -exec sed -i '' "s/offmarket_loop_/${PUSH_PREFIX}/g" {} +
LC_ALL=C find "$TARGET_DIR" -name "*.swift" -exec sed -i '' "s/OrderTransactionInfo_Subscribe_Cache/${CACHE_SUB}/g" {} +
LC_ALL=C find "$TARGET_DIR" -name "*.swift" -exec sed -i '' "s/OrderTransactionInfo_Cache/${CACHE_PAY}/g" {} +
echo "   ✓ Bridge handler: syncAppInfo → ${BRIDGE_HANDLER}"
echo "   ✓ Push prefix: offmarket_loop_ → ${PUSH_PREFIX}"
echo "   ✓ Cache names: → ${CACHE_PAY} / ${CACHE_SUB}"

# =====================================================
# Step 4: Private 方法名随机混淆
# =====================================================
echo ""
echo "🎯 Step 4: Private 方法名随机混淆..."
METHOD_COUNT=0
for file in "$TARGET_DIR"/*.swift; do
  # 找所有 private/fileprivate 方法名（排除协议必须方法和 override）
  while IFS= read -r line; do
    # 提取方法名（匹配 private func xxx 或 fileprivate func xxx，非 override）
    if echo "$line" | grep -qE '^\s*(private|fileprivate)\s+func\s+[a-zA-Z]'; then
      METHOD_NAME=$(echo "$line" | sed -E 's/.*func ([a-zA-Z_][a-zA-Z0-9_]*).*/\1/')
      # 跳过协议相关名称（以 _ 开头的通常是 delegate 要求）
      if [[ "$METHOD_NAME" != _* ]] && [[ "$METHOD_NAME" != "init" ]] && [[ "$METHOD_NAME" != "deinit" ]]; then
        NEW_METHOD=$(random_method)
        # 全文件替换（同名方法在同一文件内用同一新名）
        LC_ALL=C sed -i '' "s/\b${METHOD_NAME}\b/${NEW_METHOD}/g" "$file"
        ((METHOD_COUNT++)) || true
      fi
    fi
  done < "$file"
done
echo "   ✓ 已混淆 ${METHOD_COUNT} 个 private/fileprivate 方法名"

# =====================================================
# Step 5: 敏感字符串 → 运行时 UInt8 数组
# =====================================================
echo ""
echo "🔐 Step 5: 敏感字符串运行时组装..."

if [ -n "$DOMAIN" ]; then
  HEX=$(str_to_hex_array "$DOMAIN")
  REPLACEMENT="let ReplaceUrlDomain: String = { let b: [UInt8] = [${HEX}]; return String(bytes: b, encoding: .utf8) ?? \"\" }()"
  find "$TARGET_DIR" -name "*.swift" | while read -r f; do
    perl -i -pe "s|let ReplaceUrlDomain = \"[^\"]*\"|${REPLACEMENT}|g" "$f"
  done
  echo "   ✓ 域名 '${DOMAIN}' → UInt8[]"
fi

if [ -n "$PKG_ID" ]; then
  HEX=$(str_to_hex_array "$PKG_ID")
  REPLACEMENT="let PackageID: String = { let b: [UInt8] = [${HEX}]; return String(bytes: b, encoding: .utf8) ?? \"\" }()"
  find "$TARGET_DIR" -name "*.swift" | while read -r f; do
    perl -i -pe "s|let PackageID = \"[^\"]*\"|${REPLACEMENT}|g" "$f"
  done
  echo "   ✓ 包ID '${PKG_ID}' → UInt8[]"
fi

# 自动检测并混淆 AdjustKey
find "$TARGET_DIR" -name "*.swift" | while read -r f; do
  AJKEY=$(grep -oE 'let AdjustKey = "[^"]+"' "$f" 2>/dev/null | sed 's/.*= "//;s/".*//' || true)
  if [ -n "$AJKEY" ]; then
    HEX=$(str_to_hex_array "$AJKEY")
    perl -i -pe "s|let AdjustKey = \"[^\"]*\"|let AdjustKey: String = { let b: [UInt8] = [${HEX}]; return String(bytes: b, encoding: .utf8) ?? \"\" }()|g" "$f"
    echo "   ✓ AdjustKey → UInt8[]"
  fi
done

# =====================================================
# Step 6: API路径 & URL & JS 字符串分段拼接
# =====================================================
echo ""
echo "🔒 Step 6: 字符串拆分混淆..."

find "$TARGET_DIR" -name "*.swift" | while read -r f; do
  # API路径: "a/b/c" → ["a","b","c"].joined(separator:"/")
  perl -i -pe 's/reqModel\.requestPath = "([^"\/]+)\/([^"\/]+)\/([^"\/]+)"/reqModel.requestPath = ["$1","$2","$3"].joined(separator:"\/")/g' "$f"
  # URL路径片段
  perl -i -pe 's|"dist/index\.html"|["dist","index.html"].joined(separator:"/")|g' "$f"
  # JS bridge 调用
  perl -i -pe 's/"(HttpTool)(\.NativeToJs\([^"]*\))"/"\$1" + "\$2"/g' "$f"
done
echo "   ✓ API路径/URL/JS字符串拆分完成"

# =====================================================
# 完成
# =====================================================
echo ""
echo "=============================================="
echo "✅ 混淆完成！每次运行结果不同。"
echo "   目标目录  : $TARGET_DIR"
echo "   备份目录  : $BACKUP_DIR"
echo "   映射记录  : $LOG_FILE"
echo ""
echo "⚠️  注意事项:"
echo "   1. Xcode 里 Cmd+B 验证编译通过"
echo "   2. AppDelegate 类名不变（@main 要求）"
echo "   3. WKNavigationDelegate/SKPaymentTransactionObserver"
echo "      等协议方法已保留（系统要求）"
echo "   4. 映射记录文件请妥善保存，方便排查问题"
echo "=============================================="

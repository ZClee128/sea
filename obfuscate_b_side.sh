#!/bin/bash
# =============================================================================
# B面混淆脚本 - B-Side Swift Code Obfuscation Script
# 用法: bash obfuscate_b_side.sh <目标目录> [类名前缀] [域名] [包ID]
# Usage: bash obfuscate_b_side.sh <target_dir> [class_prefix] [domain] [pkg_id]
#
# 示例 / Example:
#   bash obfuscate_b_side.sh ./tego/er AZ codegalx 2020
# =============================================================================

set -e

# ---------- 参数处理 ----------
TARGET_DIR="${1:?请传入目标目录 Usage: $0 <dir> [prefix] [domain] [pkg_id]}"
PREFIX="${2:-AZ}"          # 类名前缀，默认 AZ
DOMAIN="${3:-}"            # 需要混淆的域名（如 codegalx）
PKG_ID="${4:-}"            # 需要混淆的包ID（如 2020）

TARGET_DIR="${TARGET_DIR%/}"  # 去除末尾斜杠

if [ ! -d "$TARGET_DIR" ]; then
  echo "❌ 目录不存在: $TARGET_DIR"
  exit 1
fi

# ---------- 备份 ----------
BACKUP_DIR="${TARGET_DIR}_backup_$(date +%Y%m%d_%H%M%S)"
cp -r "$TARGET_DIR" "$BACKUP_DIR"
echo "✅ 已备份到: $BACKUP_DIR"

# ---------- 工具函数 ----------

# 字符串转 UInt8 十六进制数组（用于运行时组装，防止明文扫描）
str_to_hex_array() {
  local str="$1"
  local result=""
  for (( i=0; i<${#str}; i++ )); do
    local char="${str:$i:1}"
    local hex=$(printf '%02x' "'$char")
    result+="0x${hex}, "
  done
  echo "${result%, }"   # 去除末尾逗号
}

# 生成随机混淆方法名（p_ + 4位十六进制）
random_method_name() {
  printf "p_%04x" $((RANDOM % 65536))
}

# ---------- 第一步：清理模板注释 ----------
echo ""
echo "🧹 Step 1: 清理模板注释..."

# 常见模板项目名（在文件头注释里）
TEMPLATE_NAMES=("OverseaH5" "AbroadTalking" "OverseaCommunity" "OverseasH5" "BaseH5")
for name in "${TEMPLATE_NAMES[@]}"; do
  LC_ALL=C find "$TARGET_DIR" -name "*.swift" -exec sed -i '' "s|//  ${name}||g" {} +
  LC_ALL=C find "$TARGET_DIR" -name "*.swift" -exec sed -i '' "s|// ${name}||g" {} +
done
echo "   ✓ 模板注释清理完成"

# ---------- 第二步：类名重命名 ----------
echo ""
echo "🔤 Step 2: 类名混淆（前缀: ${PREFIX}）..."

# 固定映射（App*/Apple*/Local* 等常见模板类名 → 新前缀）
# 使用两个并行数组而非 declare -A，兼容 macOS 默认的 Bash 3.2
CLASS_KEYS=(
  # WebView
  "AppWebViewScriptDelegateHandler"
  "AppWebViewController"
  # IAP
  "AppleIAPManager"
  "IAPcompletionHandle"
  "ApplePayType"
  "AppleIAPStatus"
  # Adjust
  "AppAdjustManager"
  # Network
  "AppRequestTool"
  "AppRequestModel"
  "AppBaseResponse"
  "AppErrorResponse"
  "FinishBlock"
  # Permission
  "AppPermissionTool"
  # Config
  "AppConfig"
  # Push
  "LocalPushScheduler"
  # UI
  "WaitViewController"
  "ProgressHUD"
  "kProgressHUD_W"
  "kProgressHUD_cornerRadius"
  "kProgressHUD_alpha"
  # Models
  "JSMessageModel"
  "UserInfoModel"
)
CLASS_VALS=(
  "${PREFIX}BridgeMessageProxy"
  "${PREFIX}WebHostController"
  "${PREFIX}PurchaseSession"
  "${PREFIX}PurchaseCompletion"
  "${PREFIX}PaymentType"
  "${PREFIX}PaymentStatus"
  "${PREFIX}AnalyticsCore"
  "${PREFIX}NetworkClient"
  "${PREFIX}RequestPayload"
  "${PREFIX}BaseResponse"
  "${PREFIX}ErrorResponse"
  "${PREFIX}FinishBlock"
  "${PREFIX}AccessControl"
  "${PREFIX}AppEnvironment"
  "${PREFIX}NotifyScheduler"
  "${PREFIX}SplashController"
  "${PREFIX}LoadingOverlay"
  "kAZOverlay_W"
  "kAZOverlay_cornerRadius"
  "kAZOverlay_alpha"
  "${PREFIX}BridgeMessage"
  "${PREFIX}UserProfile"
)

for (( idx=0; idx<${#CLASS_KEYS[@]}; idx++ )); do
  old="${CLASS_KEYS[$idx]}"
  new="${CLASS_VALS[$idx]}"
  LC_ALL=C find "$TARGET_DIR" -name "*.swift" -exec sed -i '' "s/${old}/${new}/g" {} +
  echo "   ✓ ${old} → ${new}"
done

# ---------- 第三步：标识符混淆（非协议方法名）----------
echo ""
echo "🔀 Step 3: 内部标识符混淆..."

# Bridge handler 名称
LC_ALL=C find "$TARGET_DIR" -name "*.swift" \
  -exec sed -i '' 's/syncAppInfo/azHandshake/g' {} +
# 推送标识符前缀
LC_ALL=C find "$TARGET_DIR" -name "*.swift" \
  -exec sed -i '' 's/offmarket_loop_/azlp_/g' {} +
# 缓存文件名
LC_ALL=C find "$TARGET_DIR" -name "*.swift" \
  -exec sed -i '' 's/OrderTransactionInfo_Subscribe_Cache/azsc_sub/g' {} +
LC_ALL=C find "$TARGET_DIR" -name "*.swift" \
  -exec sed -i '' 's/OrderTransactionInfo_Cache/azsc_pay/g' {} +
echo "   ✓ Bridge/Push/Cache 标识符混淆完成"

# ---------- 第四步：API路径字符串混淆 ----------
echo ""
echo "🔒 Step 4: API路径字符串混淆..."

# 将 "a/b/c" 格式的路径改成 ["a","b","c"].joined(separator:"/")
# 匹配 reqModel.requestPath = "xxx/yyy/zzz" 这类模式
LC_ALL=C find "$TARGET_DIR" -name "*.swift" | while read -r file; do
  # 用 perl 做多行匹配替换（sed对此较难处理）
  perl -i -pe 's/reqModel\.requestPath = "([^"\/]+)\/([^"\/]+)\/([^"]+)"/reqModel.requestPath = ["$1","$2","$3"].joined(separator: "\/")/g' "$file"
done
echo "   ✓ API路径字符串混淆完成"

# ---------- 第五步：敏感字符串 → 运行时 UInt8 数组 ----------
echo ""
echo "🔐 Step 5: 敏感字符串混淆..."

# 混淆域名
if [ -n "$DOMAIN" ]; then
  HEX_BYTES=$(str_to_hex_array "$DOMAIN")
  # 用 printf 构建真实换行；用环境变量传给 perl，彻底绕开引号嵌套问题
  _AZ_OBF=$(printf 'let ReplaceUrlDomain: String = {\n    let b: [UInt8] = [%s]\n    return String(bytes: b, encoding: .utf8) ?? ""\n}()' "$HEX_BYTES")
  export _AZ_OBF

  LC_ALL=C find "$TARGET_DIR" -name "*.swift" | while read -r file; do
    if grep -q "let ReplaceUrlDomain" "$file"; then
      # 单引号 perl 脚本 + $ENV{} 读替换值，无需任何 shell 转义
      perl -i -0pe 's/let ReplaceUrlDomain\s*=\s*"[^"]*"\s*/$ENV{_AZ_OBF}\n/g' "$file"
      echo "   ✓ 域名 '${DOMAIN}' 已混淆 → UInt8[] 运行时组装 (${file##*/})"
    fi
  done
fi

# 混淆包ID
if [ -n "$PKG_ID" ]; then
  HEX_BYTES=$(str_to_hex_array "$PKG_ID")
  _AZ_OBF=$(printf 'let PackageID: String = {\n    let b: [UInt8] = [%s]\n    return String(bytes: b, encoding: .utf8) ?? ""\n}()' "$HEX_BYTES")
  export _AZ_OBF

  LC_ALL=C find "$TARGET_DIR" -name "*.swift" | while read -r file; do
    if grep -q "let PackageID" "$file"; then
      perl -i -0pe 's/let PackageID\s*=\s*"[^"]*"\s*/$ENV{_AZ_OBF}\n/g' "$file"
      echo "   ✓ 包ID '${PKG_ID}' 已混淆 → UInt8[] 运行时组装 (${file##*/})"
    fi
  done
fi

# 混淆 Adjust Key（如果发现）
LC_ALL=C find "$TARGET_DIR" -name "*.swift" | while read -r file; do
  if grep -q "AdjustKey" "$file"; then
    AJKEY=$(grep 'let AdjustKey\s*=\s*"' "$file" | sed 's/.*=\s*"//;s/".*//')
    if [ -n "$AJKEY" ]; then
      HEX_BYTES=$(str_to_hex_array "$AJKEY")
      _AZ_OBF=$(printf 'let AdjustKey: String = { let b: [UInt8] = [%s]; return String(bytes: b, encoding: .utf8) ?? "" }()' "$HEX_BYTES")
      export _AZ_OBF
      perl -i -0pe 's/let AdjustKey\s*=\s*"[^"]*"/$ENV{_AZ_OBF}/g' "$file"
      echo "   ✓ AdjustKey 已混淆 → UInt8[] 运行时组装 (${file##*/})"
    fi
  fi
done

# ---------- 第六步：JS 字符串反拼接混淆 ----------
echo ""
echo "🔀 Step 6: JS bridge 字符串混淆..."

# HttpTool.NativeToJs 之类的 JS 调用字符串，拆成两段拼接防止直接扫出
LC_ALL=C find "$TARGET_DIR" -name "*.swift" | while read -r file; do
  # 匹配 "HttpTool.NativeToJs(...)" 模式，在点前切断
  perl -i -pe "s/\"(HttpTool)(\.NativeToJs\([^\"]*\))\"/\"\$1\" + \"\$2\"/g" "$file"
done
echo "   ✓ JS bridge 调用字符串已拆分"

# dist/index.html URL 路径拆分
LC_ALL=C find "$TARGET_DIR" -name "*.swift" | while read -r file; do
  perl -i -pe 's|"dist/index\.html"|["dist","index.html"].joined(separator:"/")|g' "$file"
done
echo "   ✓ URL路径字符串已拆分"

# ---------- 完成 ----------
echo ""
echo "=============================================="
echo "✅ 混淆完成！"
echo "   目标目录: $TARGET_DIR"
echo "   备份目录: $BACKUP_DIR"
echo ""
echo "⚠️  注意事项:"
echo "   1. 编译前在 Xcode 中确认无报错（文件名不影响，类名已改）"
echo "   2. AppDelegate 类名保持不变（系统要求 @main）"
echo "   3. 所有 WKNavigationDelegate / SKPaymentTransactionObserver 等"
echo "      协议方法名不可混淆（已保留）"
echo "   4. 如需混淆 private 方法名，建议用 Xcode Refactor → Rename"
echo "=============================================="

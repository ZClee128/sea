#!/bin/bash
# =============================================================================
# 轻量级方法混淆脚本 - Lightweight Method Obfuscation Script
# 专门针对 min/ 目录，**只混淆方法名**，不碰类名、变量和字符串，保证业务和 SDK 正常运行。
# 用法: bash obfuscate_methods_only.sh <目标目录> [--dry-run]
# =============================================================================

set -e

TARGET_DIR=""
DRY_RUN=0

for arg in "$@"; do
  if [ "$arg" = "--dry-run" ]; then
    DRY_RUN=1
  elif [ -z "$TARGET_DIR" ]; then
    TARGET_DIR="$arg"
  else
    echo "❌ 参数错误: $arg"
    echo "Usage: $0 <dir> [--dry-run]"
    exit 1
  fi
done

if [ -z "$TARGET_DIR" ]; then
  echo "❌ 请传入目标目录"
  echo "Usage: $0 <dir> [--dry-run]"
  exit 1
fi

TARGET_DIR="${TARGET_DIR%/}"

if [ ! -d "$TARGET_DIR" ]; then
  echo "❌ 目录不存在: $TARGET_DIR"
  exit 1
fi

# ---------- 提取并重命名方法 ----------
echo ""
echo "🔍 开始扫描可混淆的方法..."

# 1. 扫描出所有 private / fileprivate 自定义方法（默认不处理 internal，避免跨文件调用风险）
# 排除系统方法、协议方法、重写方法和明显的 ObjC 交互入口。
METHOD_LIST=$(find "$TARGET_DIR" -name "*.swift" -exec perl -nle '
    if (/^\s*(private|fileprivate)\s+(?:final\s+|static\s+|class\s+)*func\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(/) {
        my $method = $2;
        unless ($method =~ /^(init|deinit|viewDidLoad|viewWillAppear|viewDidAppear|viewWillDisappear|viewDidDisappear|application|scene|tableView|collectionView|scrollView|webView|userContentController|_evaluateJavascript|evaluateJavascript|request|productsRequest|paymentQueue|userNotificationCenter|messaging|URLSession|observeValue|touches|layoutSubviews|awakeFromNib|prepare|didSelect|numberOf|cellFor|sizeFor|viewFor|didDeselect|should|can|will|did|jsEvent|closeWeb|evaluateJavaScript)/) {
            print $method;
        }
    }
' {} + | sort | uniq | grep -v "^[[:space:]]*$")

if [ -z "$METHOD_LIST" ]; then
    echo "⚠️ 没有找到安全可混淆的方法名"
    exit 0
fi

# 2. 为每个方法生成一个新的混淆名，并全局替换
echo "📝 生成候选混淆映射："
declare -a OLD_METHODS
declare -a NEW_METHODS
declare -a MATCH_COUNTS
INDEX=0
USED_NEW_NAMES=""

count_method_matches() {
    local method_name="$1"
    find "$TARGET_DIR" -name "*.swift" -exec perl -nle '
        my $old = $ARGV[0];
        my $line = $_;
        my $c = 0;
        $c += () = ($line =~ /(\bfunc\s+)\Q$old\E(\s*\()/g);
        $c += () = ($line =~ /\b\Q$old\E(\s*\()/g);
        print $c if $c > 0;
    ' "$method_name" {} + | awk '{sum+=$1} END {print sum+0}'
}

is_new_name_used() {
    local candidate="$1"
    if grep -qx "$candidate" <<< "$METHOD_LIST"; then
        return 0
    fi
    if grep -qx "$candidate" <<< "$USED_NEW_NAMES"; then
        return 0
    fi
    return 1
}

for method in $METHOD_LIST; do
    if [ ${#method} -gt 3 ]; then
        OLD_METHODS[$INDEX]=$method
        
        # 生成 随机双字母 + _ + 4 位随机十六进制方法名 (例如: xj_a3f8)
        # 并确保不与已有方法或之前生成的名字冲突。
        while true; do
            letters=(a b c d e f g h i j k l m n o p q r s t u v w x y z)
            c1=${letters[$RANDOM % 26]}
            c2=${letters[$RANDOM % 26]}
            candidate=$(printf "%s%s_%04x" "$c1" "$c2" $((RANDOM % 65536)))

            if ! is_new_name_used "$candidate"; then
                NEW_METHODS[$INDEX]="$candidate"
                USED_NEW_NAMES="${USED_NEW_NAMES}"$'\n'"$candidate"
                break
            fi
        done

        MATCH_COUNTS[$INDEX]="$(count_method_matches "$method")"
        echo "   - [$INDEX] $method  →  ${NEW_METHODS[$INDEX]}   (预计替换: ${MATCH_COUNTS[$INDEX]} 处)"
        INDEX=$((INDEX + 1))
    fi
done

# 3. 交互式选择要混淆的方法
echo ""
echo "🎯 请选择要混淆的方法："
echo "   输入 y/回车 = 混淆当前，n = 跳过，a = 当前及后续全部混淆，q = 退出"

declare -a SELECTED_OLD
declare -a SELECTED_NEW
SELECTED_COUNT=0
AUTO_ALL=0

for (( i=0; i<${#OLD_METHODS[@]}; i++ )); do
    old="${OLD_METHODS[$i]}"
    new="${NEW_METHODS[$i]}"
    count="${MATCH_COUNTS[$i]}"

    if [ "$AUTO_ALL" -eq 1 ]; then
        SELECTED_OLD[$SELECTED_COUNT]="$old"
        SELECTED_NEW[$SELECTED_COUNT]="$new"
        SELECTED_COUNT=$((SELECTED_COUNT + 1))
        continue
    fi

    while true; do
        read -r -p "   混淆 $old -> $new (预计 $count 处)? [Y/n/a/q] " choice
        choice="${choice:-y}"
        case "$choice" in
            y|Y)
                SELECTED_OLD[$SELECTED_COUNT]="$old"
                SELECTED_NEW[$SELECTED_COUNT]="$new"
                SELECTED_COUNT=$((SELECTED_COUNT + 1))
                break
                ;;
            n|N)
                break
                ;;
            a|A)
                SELECTED_OLD[$SELECTED_COUNT]="$old"
                SELECTED_NEW[$SELECTED_COUNT]="$new"
                SELECTED_COUNT=$((SELECTED_COUNT + 1))
                AUTO_ALL=1
                break
                ;;
            q|Q)
                echo "⏹️ 已取消。未执行任何混淆。"
                exit 0
                ;;
            *)
                echo "   请输入 y / n / a / q"
                ;;
        esac
    done
done

if [ "$SELECTED_COUNT" -eq 0 ]; then
    echo "⚠️ 你没有选择任何方法，未执行混淆。"
    exit 0
fi

echo ""
echo "✅ 已选择 $SELECTED_COUNT 个方法进行混淆。"
for (( i=0; i<SELECTED_COUNT; i++ )); do
    echo "   - ${SELECTED_OLD[$i]}  →  ${SELECTED_NEW[$i]}"
done

# 4. 执行替换
# 为避免误伤变量名/字符串，仅替换：
# - 方法声明: func oldName(
# - 调用/引用: oldName(   （保留后续参数部分）
echo ""
if [ "$DRY_RUN" -eq 1 ]; then
  echo "🧪 Dry-run 模式：仅按你的选择预览，不写入文件，不创建备份。"
else
  BACKUP_DIR="${TARGET_DIR}_backup_methods_$(date +%Y%m%d_%H%M%S)"
  cp -r "$TARGET_DIR" "$BACKUP_DIR"
  echo "✅ 已备份到: $BACKUP_DIR"
  echo "🔄 正在替换文件中..."
fi

for (( i=0; i<SELECTED_COUNT; i++ )); do
    old="${SELECTED_OLD[$i]}"
    new="${SELECTED_NEW[$i]}"

    if [ "$DRY_RUN" -eq 1 ]; then
        count=$(count_method_matches "$old")
        echo "   - [dry-run] $old  →  $new   (预计替换: $count 处)"
    else
        # 只改方法声明与调用形态，避免把同名变量、字符串内容改坏
        find "$TARGET_DIR" -name "*.swift" -exec perl -pi -e "s/(\\bfunc\\s+)${old}(\\s*\\()/\${1}${new}\${2}/g; s/\\b${old}(\\s*\\()/${new}\${1}/g" {} +
    fi
done

echo ""
if [ "$DRY_RUN" -eq 1 ]; then
  echo "🧪 方法级混淆预览完成（未写入）"
else
  echo "🎉 方法级混淆完成！"
fi

# ---------- 5. 字符串混淆 (仅混淆域名) ----------
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
if [ "$DRY_RUN" -eq 0 ]; then
  find "$TARGET_DIR" -name "*.swift" -exec perl -i -0pe 's/let\s+ReplaceUrlDomain(\s*:\s*String)?\s*=\s*"[^"]*"/\n$ENV{_AZ_DOMAIN_OBF}\n/g' {} +
else
  domain_count=$(find "$TARGET_DIR" -name "*.swift" -exec perl -nle '
      my $c = () = ($_ =~ /let\s+ReplaceUrlDomain(\s*:\s*String)?\s*=\s*"[^"]*"/g);
      print $c if $c > 0;
  ' {} + | awk '{sum+=$1} END {print sum+0}')
  echo "   - [dry-run] ReplaceUrlDomain 预计替换: $domain_count 处"
fi

echo "   ✓ 域名 $DOMAIN 已转为 UInt8 字节数组"

echo ""
if [ "$DRY_RUN" -eq 1 ]; then
  echo "🧪 Dry-run 结束：未修改任何文件。确认无误后去掉 --dry-run 再执行。"
else
  echo "🎉 所有混淆已完成！请重新编译项目测试业务是否正常。"
fi

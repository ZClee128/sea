#!/bin/bash
# =============================================================================
# 轻量级方法混淆脚本 - Lightweight Method Obfuscation Script
# 专门针对 manager/ 目录，混淆：
#   1. private/fileprivate 方法名 → 自然英文词汇组合风格
#   2. requestPath = "..." 明文字符串 → fileprivate 拆分 + 随机噪音拼接
# 用法:
#   bash obfuscate_methods_only.sh <目标目录> [--dry-run]   # 混淆
#   bash obfuscate_methods_only.sh <目标目录> --verify       # 验证地址正确性
# =============================================================================

set -e

TARGET_DIR=""
DRY_RUN=0
VERIFY=0

for arg in "$@"; do
  if [ "$arg" = "--dry-run" ]; then
    DRY_RUN=1
  elif [ "$arg" = "--verify" ]; then
    VERIFY=1
  elif [ -z "$TARGET_DIR" ]; then
    TARGET_DIR="$arg"
  else
    echo "❌ 参数错误: $arg"
    echo "Usage: $0 <dir> [--dry-run|--verify]"
    exit 1
  fi
done

if [ -z "$TARGET_DIR" ]; then
  echo "❌ 请传入目标目录"
  echo "Usage: $0 <dir> [--dry-run|--verify]"
  exit 1
fi

TARGET_DIR="${TARGET_DIR%/}"
if [ ! -d "$TARGET_DIR" ]; then
  echo "❌ 目录不存在: $TARGET_DIR"
  exit 1
fi

# ========== --verify 模式：扫描已混淆的文件，还原并打印真实地址 ==========
if [ "$VERIFY" -eq 1 ]; then
  echo ""
  echo "🔍 验证模式：扫描混淆后的 requestPath 变量，还原真实地址..."
  echo ""
  found=0
  while IFS= read -r line; do
    # 匹配格式：fileprivate let VAR: String = PART1.replacingOccurrences(of: "NOISE", with: "") + PART2
    if [[ "$line" =~ fileprivate[[:space:]]+let[[:space:]]+([A-Za-z0-9_]+):[[:space:]]+String[[:space:]]+=[[:space:]]+([A-Za-z0-9_]+)\.replacingOccurrences\(of:[[:space:]]*\"(.+)\",.*\)[[:space:]]*\+[[:space:]]*([A-Za-z0-9_]+) ]]; then
      final_var="${BASH_REMATCH[1]}"
      part1_var="${BASH_REMATCH[2]}"
      noise="${BASH_REMATCH[3]}"
      part2_var="${BASH_REMATCH[4]}"

      # 在同一文件中找 part1_var 和 part2_var 的值
      file_content=$(cat "$current_file")
      part1_noisy=$(echo "$file_content" | perl -nle '
          if (/fileprivate\s+let\s+'"$part1_var"'\s*:\s*String\s*=\s*"([^"]+)"/) { print $1; last }
      ')
      part2=$(echo "$file_content" | perl -nle '
          if (/fileprivate\s+let\s+'"$part2_var"'\s*:\s*String\s*=\s*"([^"]+)"/) { print $1; last }
      ')

      if [ -n "$part1_noisy" ] && [ -n "$part2" ]; then
        # 移除噪音字符，还原 part1
        part1_clean="${part1_noisy//$noise/}"
        reconstructed="${part1_clean}${part2}"
        echo "   变量: $final_var"
        echo "   还原地址: \"$reconstructed\""
        echo ""
        found=$((found+1))
      fi
    fi
  done < <(find "$TARGET_DIR" -name "*.swift" -exec grep -H 'replacingOccurrences' {} \; | while IFS=: read -r f rest; do current_file="$f"; echo "$rest"; done)

  if [ "$found" -eq 0 ]; then
    echo "   ⚠️ 未找到混淆的 requestPath 变量（可能尚未混淆）"
  else
    echo "✅ 共验证 $found 个混淆变量"
  fi
  exit 0
fi

TARGET_DIR="${TARGET_DIR%/}"
if [ ! -d "$TARGET_DIR" ]; then
  echo "❌ 目录不存在: $TARGET_DIR"
  exit 1
fi

# ========== 工具函数 ==========

# 自然词汇池（生成不规则方法名用）
PREFIX_WORDS=(load fetch save update reset clear check handle process build setup apply refresh send receive get set run start stop open close read write bind link sync push pull merge sort filter map reduce calc draw render display hide show lock unlock add remove insert delete find search match parse encode decode format wrap)
SUFFIX_WORDS=(Data View Info Cache Result State Flag Mode List Index Map Key Value Token Item Node Task Flow Pipe Source Target Type Group Path Link Tag Form Step Stage Layer Event Queue Buffer Pool Entry Record Block Frame Mark)

random_natural_name() {
    local p=${PREFIX_WORDS[$((RANDOM % ${#PREFIX_WORDS[@]}))]}
    local s=${SUFFIX_WORDS[$((RANDOM % ${#SUFFIX_WORDS[@]}))]}
    local n=$((RANDOM % 900 + 10))
    local fmt=$((RANDOM % 3))
    if   [ "$fmt" -eq 0 ]; then echo "${p}${s}"
    elif [ "$fmt" -eq 1 ]; then echo "${p}${s}${n}"
    else
        local lp="$(echo "${p:0:1}" | tr '[:upper:]' '[:lower:]')${p:1}"
        echo "${lp}${s}${n}"
    fi
}

# 噪音字符池 - 使用 URL 字符串中不会出现、但在 Swift 字符串中合法的字符
# 不使用 < > ; | 等 HTML/Shell 敏感字符
NOISE_CHARS=("~" "!" "%" "^" "*" "+" "-" "@" "#" "&")

# 将噪音池打乱，确保每次运行顺序不同，且每条路径取到不同的字符
SHUFFLED_NOISE=()
_tmp_pool=("${NOISE_CHARS[@]}")
while [ ${#_tmp_pool[@]} -gt 0 ]; do
    _pick=$(( RANDOM % ${#_tmp_pool[@]} ))
    SHUFFLED_NOISE+=("${_tmp_pool[$_pick]}")
    _tmp_pool=("${_tmp_pool[@]:0:$_pick}" "${_tmp_pool[@]:$((_pick+1))}")
done
NOISE_INDEX=0

# 从已打乱的池中依次取噪音字符（循环使用保证不越界）
next_noise_char() {
    echo "${SHUFFLED_NOISE[$NOISE_INDEX % ${#SHUFFLED_NOISE[@]}]}"
    NOISE_INDEX=$(( NOISE_INDEX + 1 ))
}

# 噪音插入位置：避免插在 / 之前（避免产生 // 或 /<noise> 等视觉怪异的片段）
safe_noise_pos() {
    local str="$1"
    local len=${#str}
    local pos
    local attempts=0
    while true; do
        pos=$(( RANDOM % (len - 1) + 1 ))  # 1 到 len-1
        local next_char="${str:$pos:1}"
        local prev_char="${str:$(( pos - 1 )):1}"
        # 避免噪音落在 / 的前后位置
        if [ "$next_char" != "/" ] && [ "$prev_char" != "/" ]; then
            echo "$pos"
            return
        fi
        attempts=$(( attempts + 1 ))
        # 超过 10 次找不到合适位置就随便选
        if [ "$attempts" -gt 10 ]; then
            echo "$pos"
            return
        fi
    done
}

count_method_matches() {
    local method_name="$1"
    find "$TARGET_DIR" -name "*.swift" -exec perl -nle '
        my $old = $ARGV[0];
        my $c = 0;
        $c += () = ($_ =~ /(\bfunc\s+)\Q$old\E(\s*\()/g);
        $c += () = ($_ =~ /\b\Q$old\E(\s*\()/g);
        print $c if $c > 0;
    ' "$method_name" {} + | awk '{sum+=$1} END {print sum+0}'
}

USED_NEW_NAMES=""
is_new_name_used() {
    local candidate="$1"
    grep -qx "$candidate" <<< "$USED_NEW_NAMES" 2>/dev/null && return 0
    grep -qx "$candidate" <<< "$METHOD_LIST"    2>/dev/null && return 0
    return 1
}

# ========== STEP 1: 方法名混淆 ==========
echo ""
echo "🔍 STEP 1: 扫描可混淆的方法名..."

METHOD_LIST=$(find "$TARGET_DIR" -name "*.swift" -exec perl -nle '
    if (/^\s*(private|fileprivate)\s+(?:final\s+|static\s+|class\s+)*func\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(/) {
        my $m = $2;
        unless ($m =~ /^(init|deinit|copy|mutableCopy|viewDidLoad|viewWillAppear|viewDidAppear|viewWillDisappear|viewDidDisappear|application|scene|tableView|collectionView|scrollView|webView|userContentController|request|productsRequest|requestDidFinish|paymentQueue|userNotificationCenter|messaging|URLSession|observeValue|touches|layoutSubviews|awakeFromNib|prepare|didSelect|numberOf|cellFor|sizeFor|viewFor|didDeselect|should|can|will|did|jsEvent|closeWeb|appWillTerminate)/) {
            print $m;
        }
    }
' {} + | sort | uniq | grep -v "^[[:space:]]*$")

declare -a OLD_METHODS NEW_METHODS MATCH_COUNTS
INDEX=0

for method in $METHOD_LIST; do
    [ ${#method} -gt 3 ] || continue
    OLD_METHODS[$INDEX]=$method
    while true; do
        candidate=$(random_natural_name)
        is_new_name_used "$candidate" || { NEW_METHODS[$INDEX]="$candidate"; USED_NEW_NAMES+=$'\n'"$candidate"; break; }
    done
    MATCH_COUNTS[$INDEX]=$(count_method_matches "$method")
    echo "   [$INDEX] $method  →  ${NEW_METHODS[$INDEX]}   (${MATCH_COUNTS[$INDEX]} 处)"
    INDEX=$((INDEX + 1))
done

echo ""
echo "🎯 请选择要混淆的方法 (y/回车=混淆, n=跳过, a=全部, q=退出)："
declare -a SEL_OLD SEL_NEW
SEL_COUNT=0 AUTO_ALL=0

for (( i=0; i<${#OLD_METHODS[@]}; i++ )); do
    old="${OLD_METHODS[$i]}"; new="${NEW_METHODS[$i]}"; cnt="${MATCH_COUNTS[$i]}"
    if [ "$AUTO_ALL" -eq 1 ]; then
        SEL_OLD[$SEL_COUNT]="$old"; SEL_NEW[$SEL_COUNT]="$new"; SEL_COUNT=$((SEL_COUNT+1)); continue
    fi
    while true; do
        read -r -p "   $old → $new ($cnt 处)? [Y/n/a/q] " ch; ch="${ch:-y}"
        case "$ch" in
            y|Y) SEL_OLD[$SEL_COUNT]="$old"; SEL_NEW[$SEL_COUNT]="$new"; SEL_COUNT=$((SEL_COUNT+1)); break ;;
            n|N) break ;;
            a|A) SEL_OLD[$SEL_COUNT]="$old"; SEL_NEW[$SEL_COUNT]="$new"; SEL_COUNT=$((SEL_COUNT+1)); AUTO_ALL=1; break ;;
            q|Q) echo "⏹️ 已取消"; exit 0 ;;
            *) echo "   请输入 y/n/a/q" ;;
        esac
    done
done

if [ "$DRY_RUN" -eq 0 ] && [ "$SEL_COUNT" -gt 0 ]; then
    BACKUP_DIR="${TARGET_DIR}_backup_$(date +%Y%m%d_%H%M%S)"
    cp -r "$TARGET_DIR" "$BACKUP_DIR"
    echo "✅ 已备份到: $BACKUP_DIR"
    for (( i=0; i<SEL_COUNT; i++ )); do
        find "$TARGET_DIR" -name "*.swift" -exec perl -pi -e \
            "s/(\\bfunc\\s+)${SEL_OLD[$i]}(\\s*\\()/\${1}${SEL_NEW[$i]}\${2}/g; s/\\b${SEL_OLD[$i]}(\\s*\\()/${SEL_NEW[$i]}\${1}/g" {} +
        echo "   ✓ ${SEL_OLD[$i]} → ${SEL_NEW[$i]}"
    done
    echo "🎉 方法名混淆完成！"
elif [ "$DRY_RUN" -eq 1 ]; then
    for (( i=0; i<SEL_COUNT; i++ )); do
        echo "   [dry-run] ${SEL_OLD[$i]} → ${SEL_NEW[$i]}"
    done
fi

# ========== STEP 2: requestPath 字符串混淆 ==========
echo ""
echo "🔠 STEP 2: 扫描 requestPath 明文字符串..."

# 扫描所有 requestPath = "..." 的字符串值
REQ_PATHS=$(find "$TARGET_DIR" -name "*.swift" -exec perl -nle '
    if (/requestPath\s*=\s*"([^"]+)"/) { print "$1\t" . $ARGV }
' {} + | sort | uniq)

if [ -z "$REQ_PATHS" ]; then
    echo "   ⚠️ 未找到明文 requestPath 字符串，跳过。"
else
    echo "   找到以下路径字符串："
    while IFS=$'\t' read -r path_val file_path; do
        echo "   → \"$path_val\"  in $(basename "$file_path")"
    done <<< "$REQ_PATHS"

    echo ""
    echo "🔄 开始混淆 requestPath 字符串..."

    while IFS=$'\t' read -r path_val file_path; do
        [ -z "$path_val" ] && continue

        # --- 生成随机混淆 ---
        # 分三段：前半、后半、噪音注入在前半的随机位置
        local_len=${#path_val}
        mid=$(( local_len / 2 ))
        part1="${path_val:0:$mid}"
        part2="${path_val:$mid}"

        noise=$(next_noise_char)
        noise_pos=$(safe_noise_pos "$part1")
        # 在 part1 的 noise_pos 处插入噪音字符
        part1_noisy="${part1:0:$noise_pos}${noise}${part1:$noise_pos}"

        # 生成三个随机变量名（自然风格）
        while true; do v1=$(random_natural_name); is_new_name_used "$v1" || { USED_NEW_NAMES+=$'\n'"$v1"; break; }; done
        while true; do v2=$(random_natural_name); is_new_name_used "$v2" || { USED_NEW_NAMES+=$'\n'"$v2"; break; }; done
        while true; do vfinal=$(random_natural_name); is_new_name_used "$vfinal" || { USED_NEW_NAMES+=$'\n'"$vfinal"; break; }; done

        # 使用 printf 生成真实换行符的 obf_block（bash 双引号字符串中 \n 是字面量，不是换行）
        obf_block=$(printf 'fileprivate let %s: String = "%s"\nfileprivate let %s: String = "%s"\nfileprivate let %s: String = %s.replacingOccurrences(of: "%s", with: "") + %s' \
            "$v1" "$part1_noisy" \
            "$v2" "$part2" \
            "$vfinal" "$v1" "$noise" "$v2")

        echo "   路径: \"$path_val\""
        echo "   变量: $vfinal (噪音='$noise', 注入位置=$noise_pos)"
        echo "   代码: $(echo -e "$obf_block" | head -1) ..."

        if [ "$DRY_RUN" -eq 0 ]; then
            # 1. 在文件顶部 import 块之后插入混淆声明
            # 先检查是否已混淆（避免重复处理）
            if grep -qF "\"$path_val\"" "$file_path"; then
                # 转义路径中的特殊字符用于 perl 正则
                escaped_path="${path_val//\//\\/}"

                # obf_block 已经包含真实换行符（由 printf 生成），可以安全 export
                export OBF_INSERT="$obf_block"

                # 将混淆声明插入到最后一个 import 行的后面
                # 注意：不使用 unless 守卫，因为外层 grep 已确保只在需要时执行
                perl -i -0pe '
                    my $ins = $ENV{OBF_INSERT};
                    s/((?:import\s+\S+[ \t]*\n)+)/$1\n$ins\n/;
                ' "$file_path"

                # 2. 将 requestPath = "path_val" 替换为 requestPath = vfinal
                perl -i -pe "s|requestPath\s*=\s*\"${escaped_path}\"|requestPath = ${vfinal}|g" "$file_path"
                echo "   ✓ 已写入 $(basename "$file_path")"
            else
                echo "   ⚠️ \"$path_val\" 在 $(basename "$file_path") 中未找到（可能已混淆），跳过"
            fi
        else
            echo "   [dry-run] 将在 $(basename "$file_path") 中插入混淆代码块"
        fi
        echo ""
    done <<< "$REQ_PATHS"
fi

# ========== STEP 3: 域名混淆 ==========
echo ""
echo "🔠 STEP 3: 混淆 ReplaceUrlDomain ..."

str_to_hex_array() {
    local str="$1" result=""
    for (( i=0; i<${#str}; i++ )); do
        result+="0x$(printf '%02x' "'${str:$i:1}'), "
    done
    echo "${result%, }"
}

# 从 AppConfig.swift 中读取当前域名值
DOMAIN_FILE=$(find "$TARGET_DIR" -name "AppConfig.swift" | head -1)
if [ -n "$DOMAIN_FILE" ]; then
    # 尝试从现有定义中提取域名（明文或之前的 UInt8 数组形式）
    RAW_DOMAIN=$(perl -nle '
        if (/let\s+ReplaceUrlDomain\s*(?::\s*String)?\s*=\s*"([^"]+)"/) { print $1; exit }
        if (/let\s+ReplaceUrlDomain\s*(?::\s*String)?\s*=\s*\{/ .. /\}/) {
            if (/\[([0-9a-fx,\s]+)\]/) {
                my @bytes = grep { /^0x/ } split /,\s*/, $1;
                print join("", map { chr(hex($_)) } @bytes); exit;
            }
        }
    ' "$DOMAIN_FILE" 2>/dev/null)

    if [ -n "$RAW_DOMAIN" ]; then
        HEX_BYTES=$(str_to_hex_array "$RAW_DOMAIN")
        export _AZ_DOMAIN_OBF
        _AZ_DOMAIN_OBF=$(printf 'let ReplaceUrlDomain: String = {\n    let b: [UInt8] = [%s]\n    return String(bytes: b, encoding: .utf8) ?? ""\n}()' "$HEX_BYTES")

        if [ "$DRY_RUN" -eq 0 ]; then
            perl -i -0pe 's/(?:fileprivate\s+let\s+\w+[^\n]*\n)*?let\s+ReplaceUrlDomain(?:\s*:\s*String)?\s*=[^\n]*/\n$ENV{_AZ_DOMAIN_OBF}/g' "$DOMAIN_FILE"
            echo "   ✓ 域名 \"$RAW_DOMAIN\" 已转为 UInt8 字节数组"
        else
            echo "   [dry-run] 域名 \"$RAW_DOMAIN\" 将被替换为 UInt8 字节数组"
        fi
    else
        echo "   ⚠️ 无法提取域名值，跳过"
    fi
else
    echo "   ⚠️ 未找到 AppConfig.swift，跳过域名混淆"
fi

echo ""
if [ "$DRY_RUN" -eq 1 ]; then
  echo "🧪 Dry-run 结束：未修改任何文件。"
else
  echo "🎉 所有混淆已完成！请重新编译项目验证。"
fi

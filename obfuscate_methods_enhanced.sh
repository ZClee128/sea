#!/bin/bash
# =============================================================================
# Enhanced Method Obfuscation Script v2
# 相比 v1 的改进：
#   1. 安全方法混淆：默认只处理 private/fileprivate 方法，并且只在定义所在文件内替换
#      （自动跳过 @objc / override / 协议必需方法，避免影响业务调用边界）
#   2. 命名策略多样化：4 种随机策略混用，消除 VerbNoun 模式指纹
#   3. 字符串混淆多策略：3 种策略随机选择，不再千篇一律
#   4. 修复 \b 边界替换导致的误伤问题
#   5. 扩展词库，降低可预测性
# 用法:
#   bash obfuscate_methods_enhanced.sh <目标目录> [--dry-run]   # 混淆
#   bash obfuscate_methods_enhanced.sh <目标目录> --verify       # 验证
# =============================================================================

if [ -z "${BASH_VERSION:-}" ] || [ -n "${POSIXLY_CORRECT:-}" ]; then
  exec /bin/bash "$0" "$@"
fi

set -e

TARGET_DIR=""
DRY_RUN=0
VERIFY=0

for arg in "$@"; do
  if [ "$arg" = "--dry-run" ]; then DRY_RUN=1
  elif [ "$arg" = "--verify" ]; then VERIFY=1
  elif [ -z "$TARGET_DIR" ]; then TARGET_DIR="$arg"
  else echo "参数错误: $arg"; echo "Usage: $0 <dir> [--dry-run|--verify]"; exit 1; fi
done

if [ -z "$TARGET_DIR" ]; then echo "请传入目标目录"; echo "Usage: $0 <dir> [--dry-run|--verify]"; exit 1; fi
TARGET_DIR="${TARGET_DIR%/}"
[ -d "$TARGET_DIR" ] || { echo "目录不存在: $TARGET_DIR"; exit 1; }
TARGET_DIR="$(cd "$TARGET_DIR" && pwd -P)"

find_swift_files() {
  find "$TARGET_DIR" \
    \( -path "*/Pods/*" -o -path "*/Carthage/*" -o -path "*/DerivedData/*" -o -path "*_backup*" \) -prune \
    -o -type f -name "*.swift" -print
}

SWIFT_FILE_COUNT=$(find_swift_files | wc -l | tr -d ' ')
echo "目标目录: $TARGET_DIR"
echo "Swift 文件数: $SWIFT_FILE_COUNT"
echo "安全模式: 仅混淆 private/fileprivate 方法，且只在定义所在文件内替换"
echo "提示: 请传 B 面源码目录完整路径，例如 /Users/lizhicong/Desktop/sea/2041/Trilo/源码/trilo/trilo/agen，不要传工程根目录。"

# ========== --verify 模式 ==========
if [ "$VERIFY" -eq 1 ]; then
  echo ""; echo "验证模式：还原混淆后的 requestPath 真实地址..."; echo ""
  found=0
  while IFS= read -r swift_file; do
    result=$(perl -0777 -ne '
      while (/(?:fileprivate|private|internal)?\s*(?:static\s+)?let\s+(\w+)\s*:\s*String\s*=\s*(\w+)\.replacingOccurrences\s*\(\s*of\s*:\s*"([^"]+)"\s*,\s*with\s*:\s*""\s*\)\s*\+\s*(\w+)/g) {
        my ($final, $v1, $noise, $v2) = ($1, $2, $3, $4);
        my ($noisy, $part2) = ("", "");
        if (/(?:fileprivate|private|internal)?\s*(?:static\s+)?let\s+\Q$v1\E\s*:\s*String\s*=\s*"([^"]+)"/) { $noisy = $1; }
        if (/(?:fileprivate|private|internal)?\s*(?:static\s+)?let\s+\Q$v2\E\s*:\s*String\s*=\s*"([^"]+)"/) { $part2 = $1; }
        if ($noisy && $part2) {
          (my $clean = $noisy) =~ s/\Q$noise\E//g;
          print "   变量: $final\n   还原地址: \"" . $clean . $part2 . "\"\n\n";
        }
      }
      # Also detect XOR array-based obfuscation
      while (/(?:fileprivate|private|internal)?\s*(?:static\s+)?let\s+(\w+)\s*:\s*String\s*=\s*\{\s*let\s+b\s*:\s*\[UInt8\]\s*=\s*\[([^\]]+)\]\s*.*?String\s*\(bytes:\s+b.*?\.utf8\)/gs) {
        my ($var, $bytes) = ($1, $2);
        my @vals = ($bytes =~ /0x([0-9a-fA-F]{2})/g);
        my $decoded = join("", map { chr(hex($_)) } @vals);
        print "   变量: $var (XOR/Byte Array)\n   还原地址: \"$decoded\"\n\n";
      }
    ' "$swift_file")
    if [ -n "$result" ]; then
      echo "--- $(basename "$swift_file") ---"; echo "$result"
      _c=$(echo "$result" | grep -c "还原地址" || true); found=$(( found + _c ))
    fi
  done < <(find_swift_files)
  [ "$found" -eq 0 ] && echo "  未找到混淆的 requestPath 变量" || echo "共验证 $found 个混淆变量"
  exit 0
fi

# ========== 扩展词库 ==========

VERB_POOL=(
  load fetch save update reset clear check handle process build setup apply
  refresh send receive configure initialize finalize execute validate compute
  generate transform resolve transfer inspect notify dispatch schedule monitor
  register unregister activate deactivate suspend resume prepare release
  allocate aggregate normalize sanitize serialize deserialize encrypt decrypt
  compress decompress import export migrate rollback commit discard
  attach detach toggle enable disable flush prefetch evict
  acquire release recycle populate depopulate join leave
  probe ping benchmark throttle
)

NOUN_POOL=(
  Data View Info Cache Result State Flag Mode List Index Map Key Value Token
  Item Node Task Flow Pipe Source Target Type Group Path Link Tag Form Step
  Stage Layer Event Queue Buffer Pool Entry Record Block Frame Mark
  Context Session Channel Stream Payload Metadata Config Schema Filter
  Template Fragment Segment Chunk Shard Snapshot Checkpoint
  Counter Gauge Timer Tracer Metric Profile
  Gateway Adapter Bridge Proxy Wrapper Facade
  Factory Builder Observer Visitor Strategy Command
  Handler Provider Resolver Locator Registry
  Router Pipeline Assembly Container
)

ADJ_POOL=(
  Core Main Base Primary Secondary Global Local Shared Remote
  Active Passive Pending Idle Ready Running Stopped
  Internal External Public Private Common Custom Native
  Async Sync Online Offline Hot Cold Warm Fresh Stale
)

# ========== 命名策略（4种混用） ==========

random_hex() { printf '%x' $((RANDOM % 4096 + 256)); }

scheme_verb_noun() {
  local v=${VERB_POOL[$((RANDOM % ${#VERB_POOL[@]}))]}
  local n=${NOUN_POOL[$((RANDOM % ${#NOUN_POOL[@]}))]}
  local h=$(random_hex)
  local fmt=$((RANDOM % 3))
  case $fmt in
    0) echo "${v}${n}${h}" ;;
    1) echo "${v}_${n}${h}" ;;
    2) echo "$(echo "${v:0:1}" | tr '[:upper:]' '[:lower:]')${v:1}${n}${h}" ;;
  esac
}

scheme_adj_noun() {
  local a=${ADJ_POOL[$((RANDOM % ${#ADJ_POOL[@]}))]}
  local n=${NOUN_POOL[$((RANDOM % ${#NOUN_POOL[@]}))]}
  local h=$(random_hex)
  echo "${a}${n}${h}"
}

scheme_random_abbrev() {
  local consonants=(b c d f g h j k l m n p q r s t v w x y z)
  local vowels=(a e i o u)
  local result=""
  local len=$((RANDOM % 5 + 4))
  for ((i=0; i<len; i++)); do
    if [ $((RANDOM % 2)) -eq 0 ]; then
      result+=${consonants[$((RANDOM % ${#consonants[@]}))]}
    else
      result+=${vowels[$((RANDOM % ${#vowels[@]}))]}
    fi
  done
  echo "${result}$(random_hex)"
}

scheme_hash_like() {
  local prefix=$((RANDOM % 2))
  if [ "$prefix" -eq 0 ]; then
    echo "fn$(random_hex)$(random_hex)"
  else
    echo "m$(random_hex)_$(random_hex)"
  fi
}

random_method_name() {
  local s=$((RANDOM % 4))
  case $s in
    0) scheme_verb_noun ;;
    1) scheme_adj_noun ;;
    2) scheme_random_abbrev ;;
    3) scheme_hash_like ;;
  esac
}

# ========== 工具函数 ==========

# 方法调用匹配计数
count_method_matches() {
  local file_path="$1"
  local method_name="$2"
  METHOD_NAME="$method_name" perl -nle '
    my $m = $ENV{METHOD_NAME};
    my $c = 0;
    my $line = $_;
    $c += () = ($line =~ /(?<![A-Za-z0-9_])func\s+\Q$m\E\s*\(/g);
    $line =~ s/(?<![A-Za-z0-9_])func\s+\Q$m\E\s*\(/func (/g;
    $c += () = ($line =~ /(?<![A-Za-z0-9_\.])\Q$m\E\s*\(/g);
    print $c if $c > 0;
  ' "$file_path" | awk '{sum+=$1} END {print sum+0}'
}

method_has_dot_call() {
  local file_path="$1"
  local method_name="$2"
  METHOD_NAME="$method_name" perl -ne '
    BEGIN { $m = $ENV{METHOD_NAME}; $found = 0; }
    $found = 1 if /\.\s*\Q$m\E\s*\(/;
    END { exit($found ? 0 : 1); }
  ' "$file_path"
}

USED_NAMES=""
is_name_used() {
  grep -qxF "$1" <<< "$USED_NAMES" 2>/dev/null && return 0
  grep -qxF "$1" <<< "$FOUND_METHODS" 2>/dev/null && return 0
  return 1
}

# 噪音字符池（大幅扩展）
NOISE_CHARS=('~' '!' '%' '^' '*' '+' '-' '@' '#' '&' '=' '?' ':' ';' ',' '.' '_' '|')
SHUFFLED_NOISE=()
_tmp=("${NOISE_CHARS[@]}")
while [ ${#_tmp[@]} -gt 0 ]; do
  _pick=$((RANDOM % ${#_tmp[@]}))
  SHUFFLED_NOISE+=("${_tmp[$_pick]}")
  _tmp=("${_tmp[@]:0:$_pick}" "${_tmp[@]:$((_pick+1))}")
done
NOISE_IDX=0

next_noise() { echo "${SHUFFLED_NOISE[$((NOISE_IDX++ % ${#SHUFFLED_NOISE[@]}))]}"; }

STRATEGY_COUNTER=0
next_string_strategy() {
  local s=$((STRATEGY_COUNTER % 3))
  STRATEGY_COUNTER=$((STRATEGY_COUNTER + 1))
  echo "$s"
}

# ========== STEP 1: 方法扫描 ==========
echo ""
echo "STEP 1: 扫描所有非生命周期方法..."

# 关键策略：只匹配 private/fileprivate 方法，避免改坏对业务侧暴露的接口
FOUND_METHODS=$(find_swift_files | while IFS= read -r swift_file; do
  SWIFT_FILE="$swift_file" perl -nle '
  if (/^\s*\@(?:objc|IBAction|IBSegueAction|available|nonobjc)\b/ || /\@(?:objc|IBAction|IBSegueAction|available|nonobjc)\b/) {
    $skip_annotated_func = 1;
    next;
  }

  if (/^\s*(?:(?:private|fileprivate|internal|public|open)\s+)?(?:final\s+)?(?:static\s+)?(?:class\s+)?override\s+func\s+/) {
    $skip_annotated_func = 0;
    next;
  }

  if (/^\s*(?:private|fileprivate)\s+(?:final\s+)?(?:(?:static|class)\s+)?func\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(/) {
    my $name = $1;
    if ($skip_annotated_func) {
      $skip_annotated_func = 0;
      next;
    }
    next if $name =~ /^(?:init|deinit|copy|mutableCopy
      |viewDidLoad|viewWillAppear|viewDidAppear|viewWillDisappear|viewDidDisappear
      |viewWillLayoutSubviews|viewDidLayoutSubviews
      |application|scene
      |tableView|collectionView|scrollView|webView
      |userContentController|request|productsRequest|requestDidFinish|paymentQueue
      |userNotificationCenter|messaging|URLSession|observeValue
      |touches|layoutSubviews|awakeFromNib|prepare|didSelect
      |numberOf|cellFor|sizeFor|viewFor|didDeselect
      |should|can|will|did
      |jsEvent|closeWeb|appWillTerminate
      |willTransition|didTransition|traitCollectionDidChange
      |preferredStatusBarStyle|supportedInterfaceOrientations
      |present|dismiss|performSegue
      |encode|decode|hash|isEqual|description|debugDescription
      )$/x;
    print $ENV{SWIFT_FILE} . "\t" . $name . "\n";
    $skip_annotated_func = 0;
  }
' "$swift_file"
done | sort | uniq | grep -v "^[[:space:]]*$")

declare -a OLD_FILES OLD_METHODS NEW_METHODS MATCH_COUNTS
INDEX=0

echo "正在筛选安全候选..."

while IFS=$'\t' read -r file_path method; do
  [ -n "$file_path" ] || continue
  [ -n "$method" ] || continue
  [ ${#method} -gt 2 ] || continue
  method_has_dot_call "$file_path" "$method" && continue
  match_count=$(count_method_matches "$file_path" "$method")
  [ "$match_count" -ge 2 ] || continue
  OLD_FILES[$INDEX]=$file_path
  OLD_METHODS[$INDEX]=$method
  while true; do
    candidate=$(random_method_name)
    is_name_used "$candidate" || { NEW_METHODS[$INDEX]="$candidate"; USED_NAMES+=$'\n'"$candidate"; break; }
  done
  MATCH_COUNTS[$INDEX]=$match_count
  INDEX=$((INDEX + 1))
done <<< "$FOUND_METHODS"

echo "找到 $INDEX 个可混淆方法："
echo ""
for (( i=0; i<${#OLD_METHODS[@]}; i++ )); do
  echo "  [$i] $(basename "${OLD_FILES[$i]}")::${OLD_METHODS[$i]}  ->  ${NEW_METHODS[$i]}   (${MATCH_COUNTS[$i]} 处)"
done

echo ""
echo "选择要混淆的方法 (y/回车=混淆, n=跳过, a=全部, q=退出)："
declare -a SEL_FILES SEL_OLD SEL_NEW
SEL_COUNT=0 AUTO_ALL=0

for (( i=0; i<${#OLD_METHODS[@]}; i++ )); do
  file="${OLD_FILES[$i]}"; old="${OLD_METHODS[$i]}"; new="${NEW_METHODS[$i]}"; cnt="${MATCH_COUNTS[$i]}"
  [ "$AUTO_ALL" -eq 1 ] && { SEL_FILES[$SEL_COUNT]="$file"; SEL_OLD[$SEL_COUNT]="$old"; SEL_NEW[$SEL_COUNT]="$new"; SEL_COUNT=$((SEL_COUNT+1)); continue; }
  while true; do
    read -r -p "  $(basename "$file")::$old -> $new ($cnt 处)? [Y/n/a/q] " ch; ch="${ch:-y}"
    case "$ch" in
      y|Y) SEL_FILES[$SEL_COUNT]="$file"; SEL_OLD[$SEL_COUNT]="$old"; SEL_NEW[$SEL_COUNT]="$new"; SEL_COUNT=$((SEL_COUNT+1)); break ;;
      n|N) break ;;
      a|A) SEL_FILES[$SEL_COUNT]="$file"; SEL_OLD[$SEL_COUNT]="$old"; SEL_NEW[$SEL_COUNT]="$new"; SEL_COUNT=$((SEL_COUNT+1)); AUTO_ALL=1; break ;;
      q|Q) echo "已取消"; exit 0 ;;
      *) echo "  请输入 y/n/a/q" ;;
    esac
  done
done

if [ "$DRY_RUN" -eq 0 ] && [ "$SEL_COUNT" -gt 0 ]; then
  BACKUP_DIR="${TARGET_DIR}_backup_$(date +%Y%m%d_%H%M%S)"
  cp -r "$TARGET_DIR" "$BACKUP_DIR"
  echo "已备份到: $BACKUP_DIR"
  for (( i=0; i<SEL_COUNT; i++ )); do
    file="${SEL_FILES[$i]}"; old="${SEL_OLD[$i]}"; new="${SEL_NEW[$i]}"
    # 关键修复：不使用 \b，改用负向先行断言确保不误伤复合名称
    # 1. 替换方法定义: func oldName( -> func newName(
    perl -pi -e \
      "s/(?<![A-Za-z0-9_])func\s+\Q${old}\E(\s*\()/func ${new}\${1}/g; s/(?<![A-Za-z0-9_\.])\Q${old}\E(\s*\()/${new}\${1}/g" "$file"
    echo "  done: $(basename "$file")::$old -> $new"
  done
  echo "方法名混淆完成！"
elif [ "$DRY_RUN" -eq 1 ]; then
  for (( i=0; i<SEL_COUNT; i++ )); do echo "  [dry-run] $(basename "${SEL_FILES[$i]}")::${SEL_OLD[$i]} -> ${SEL_NEW[$i]}"; done
fi

# ========== STEP 2: requestPath 字符串混淆（多策略） ==========
echo ""
echo "STEP 2: 扫描并混淆 requestPath 字符串..."

REQ_ENTRIES=$(find_swift_files | while IFS= read -r swift_file; do
  perl -nle '
  if (/requestPath\s*=\s*"([^"]+)"/) { print "$1\t" . $ARGV }
  ' "$swift_file"
done | sort | uniq)

if [ -z "$REQ_ENTRIES" ]; then
  echo "  未找到明文 requestPath，跳过。"
else
  echo "  找到以下路径字符串："
  while IFS=$'\t' read -r path_val file_path; do
    echo "  -> \"$path_val\"  in $(basename "$file_path")"
  done <<< "$REQ_ENTRIES"

  echo ""
  echo "开始混淆（每条路径随机选择策略）..."

  # 工具：字符串转 XOR 字节数组
  str_to_xor() {
    local str="$1" out=""
    local key=$((RANDOM % 200 + 55))
    for ((i=0; i<${#str}; i++)); do
      local c="${str:$i:1}"; local ord=$(printf '%d' "'$c")
      out+="0x$(printf '%02x' $((ord ^ key))), "
    done
    echo "${key}|${out%, }"
  }

  while IFS=$'\t' read -r path_val file_path; do
    [ -z "$path_val" ] && continue
    local_len=${#path_val}

    strategy=$(next_string_strategy)
    # 生成三个变量名
    while true; do v1=$(random_method_name); is_name_used "$v1" || { USED_NAMES+=$'\n'"$v1"; break; }; done
    while true; do v2=$(random_method_name); is_name_used "$v2" || { USED_NAMES+=$'\n'"$v2"; break; }; done
    while true; do vfinal=$(random_method_name); is_name_used "$vfinal" || { USED_NAMES+=$'\n'"$vfinal"; break; }; done

    case $strategy in
      0)
        # 策略 A：双段拆分 + 噪音 + replacingOccurrences
        mid=$((local_len / 2 + RANDOM % (local_len / 4) - local_len / 8))
        [ "$mid" -lt 2 ] && mid=2
        [ "$mid" -gt $((local_len - 2)) ] && mid=$((local_len - 2))
        part1="${path_val:0:$mid}"
        part2="${path_val:$mid}"
        noise=$(next_noise)
        noise_pos=$((RANDOM % (${#part1} - 1) + 1))
        part1_noisy="${part1:0:$noise_pos}${noise}${part1:$noise_pos}"
        obf_block=$(printf 'fileprivate let %s: String = "%s"\nfileprivate let %s: String = "%s"\nfileprivate let %s: String = %s.replacingOccurrences(of: "%s", with: "") + %s' \
          "$v1" "$part1_noisy" "$v2" "$part2" "$vfinal" "$v1" "$noise" "$v2")
        echo "  path: \"$path_val\" -> $vfinal (策略: split2+noise)"
        ;;

      1)
        # 策略 B：三段拆分 + 随机拼接顺序
        s1=$((local_len / 3))
        s2=$((local_len * 2 / 3))
        p1="${path_val:0:$s1}"; p2="${path_val:$s1:$((s2-s1))}"; p3="${path_val:$s2}"
        while true; do v3=$(random_method_name); is_name_used "$v3" || { USED_NAMES+=$'\n'"$v3"; break; }; done
        obf_block=$(printf 'fileprivate let %s: String = "%s"\nfileprivate let %s: String = "%s"\nfileprivate let %s: String = "%s"\nfileprivate let %s: String = %s + %s + %s' \
          "$v1" "$p1" "$v2" "$p2" "$v3" "$p3" "$vfinal" "$v1" "$v2" "$v3")
        echo "  path: \"$path_val\" -> $vfinal (策略: split3)"
        ;;

      2)
        # 策略 C：XOR 字节数组 + 运行时解码
        xor_result=$(str_to_xor "$path_val")
        xor_key=$(echo "$xor_result" | cut -d'|' -f1)
        xor_bytes=$(echo "$xor_result" | cut -d'|' -f2)
        obf_block=$(printf 'fileprivate let %s: [UInt8] = [%s]\nfileprivate let %s: String = {\n    let k: UInt8 = %s\n    return String(bytes: %s.map { $0 ^ k }, encoding: .utf8) ?? ""\n}()' \
          "$v1" "$xor_bytes" "$vfinal" "$xor_key" "$v1")
        echo "  path: \"$path_val\" -> $vfinal (策略: XOR)"
        ;;
    esac

    if [ "$DRY_RUN" -eq 0 ]; then
      if grep -qF "\"$path_val\"" "$file_path"; then
        escaped_path="${path_val//\//\\/}"
        export OBF_INSERT="$obf_block"
        perl -i -0pe '
          my $ins = $ENV{OBF_INSERT};
          s/((?:import\s+\S+[ \t]*\n)+)/$1\n$ins\n/;
        ' "$file_path"
        perl -i -pe "s|requestPath\s*=\s*\"${escaped_path}\"|requestPath = ${vfinal}|g" "$file_path"
        echo "  done: $(basename "$file_path")"
      else
        echo "  skip: \"$path_val\" 未找到（可能已混淆）"
      fi
    else
      echo "  [dry-run] $(basename "$file_path")"
    fi
    echo ""
  done <<< "$REQ_ENTRIES"
fi

# ========== STEP 3: 域名混淆（增强） ==========
echo ""
echo "STEP 3: 混淆 ReplaceUrlDomain..."

str_to_hex_array() {
  local str="$1" result=""
  for ((i=0; i<${#str}; i++)); do
    result+="0x$(printf '%02x' "'${str:$i:1}"), "
  done
  echo "${result%, }"
}

DOMAIN_FILE=$(find_swift_files | grep -E '/([^/]*(AppConfig|Config|Domain)[^/]*)\.swift$' | head -1)
if [ -z "$DOMAIN_FILE" ]; then
  DOMAIN_FILE=$(find_swift_files | while IFS= read -r swift_file; do
    grep -l 'ReplaceUrlDomain' "$swift_file" || true
  done | head -1)
fi

if [ -n "$DOMAIN_FILE" ]; then
  RAW_DOMAIN=$(perl -nle '
    if (/let\s+ReplaceUrlDomain\s*(?::\s*String)?\s*=\s*"([^"]+)"/) { print $1; exit }
    if (/let\s+ReplaceUrlDomain\s*(?::\s*String)?\s*=\s*\{/ .. /\}/) {
      if (/\[([^\]]+)\]/) {
        my @bytes = grep { /^0x/ } split /,\s*/, $1;
        print join("", map { chr(hex($_)) } @bytes); exit;
      }
    }
  ' "$DOMAIN_FILE" 2>/dev/null)

  if [ -n "$RAW_DOMAIN" ]; then
    # 随机选择编码策略
    DOMAIN_STRATEGY=$((RANDOM % 2))
    if [ "$DOMAIN_STRATEGY" -eq 0 ]; then
      HEX_BYTES=$(str_to_hex_array "$RAW_DOMAIN")
      export _AZ_DOMAIN_OBF
      _AZ_DOMAIN_OBF=$(printf 'let ReplaceUrlDomain: String = {\n    let b: [UInt8] = [%s]\n    return String(bytes: b, encoding: .utf8) ?? ""\n}()' "$HEX_BYTES")
      echo "  策略: 直接 UInt8 字节数组"
    else
      domain_key=$((RANDOM % 200 + 55))
      domain_bytes=""
      for ((i=0; i<${#RAW_DOMAIN}; i++)); do
        domain_char="${RAW_DOMAIN:$i:1}"
        domain_ord=$(printf '%d' "'$domain_char")
        domain_bytes+="0x$(printf '%02x' $((domain_ord ^ domain_key))), "
      done
      domain_bytes="${domain_bytes%, }"
      export _AZ_DOMAIN_OBF
      _AZ_DOMAIN_OBF=$(printf 'let ReplaceUrlDomain: String = {\n    let b: [UInt8] = [%s]\n    let k: UInt8 = %s\n    return String(bytes: b.map { $0 ^ k }, encoding: .utf8) ?? ""\n}()' "$domain_bytes" "$domain_key")
      echo "  策略: XOR + UInt8 字节数组"
    fi

    if [ "$DRY_RUN" -eq 0 ]; then
      perl -i -0pe 's/(?:fileprivate\s+let\s+\w+[^\n]*\n)*?let\s+ReplaceUrlDomain(?:\s*:\s*String)?\s*=[^\n]*/\n$ENV{_AZ_DOMAIN_OBF}/g' "$DOMAIN_FILE"
      echo "  done: \"$RAW_DOMAIN\" -> $(basename "$DOMAIN_FILE")"
    else
      echo "  [dry-run] \"$RAW_DOMAIN\" 将被混淆"
    fi
  else
    echo "  无法提取域名值，跳过"
  fi
else
  echo "  未找到 ReplaceUrlDomain 声明或含该变量的 swift 文件，跳过"
fi

# ========== 完成 ==========
echo ""
if [ "$DRY_RUN" -eq 1 ]; then
  echo "Dry-run 结束：未修改任何文件。"
else
  echo "所有混淆已完成！请重新编译并验证。"
  if [ "$SEL_COUNT" -gt 0 ]; then
    echo "建议: 先在模拟器上跑一遍完整流程，确认业务逻辑正常后再提审。"
  fi
fi

#!/bin/bash
# =============================================================================
# B-side Safe Obfuscation Report v3
# 仅生成 B 面代码保护清单，不修改源码。
# =============================================================================

if [ -z "${BASH_VERSION:-}" ] || [ -n "${POSIXLY_CORRECT:-}" ]; then
  exec /bin/bash "$0" "$@"
fi

set -e

TARGET_DIR=""

usage() {
  echo "Usage: $0 <B面源码完整路径>"
  echo "Example: $0 /Users/lizhicong/Desktop/sea/2041/Trilo/源码/trilo/trilo/agen"
}

if [ $# -lt 1 ]; then
  usage
  exit 1
fi

TARGET_DIR="$1"
TARGET_DIR="${TARGET_DIR%/}"
[ -d "$TARGET_DIR" ] || { echo "目录不存在: $TARGET_DIR"; exit 1; }
TARGET_DIR="$(cd "$TARGET_DIR" && pwd -P)"

find_swift_files() {
  find "$TARGET_DIR" \
    \( -path "*/Pods/*" -o -path "*/Carthage/*" -o -path "*/DerivedData/*" -o -path "*_backup*" \) -prune \
    -o -type f -name "*.swift" -print
}

stable_name() {
  local prefix="$1"
  local seed="$2"
  local checksum
  checksum=$(printf '%s' "$seed" | cksum | awk '{print $1}')
  printf '%s%x' "$prefix" "$checksum"
}

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

is_reserved_method() {
  local name="$1"
  case "$name" in
    init|deinit|copy|mutableCopy|viewDidLoad|viewWillAppear|viewDidAppear|viewWillDisappear|viewDidDisappear|viewWillLayoutSubviews|viewDidLayoutSubviews|application|scene|tableView|collectionView|scrollView|webView|userContentController|request|productsRequest|requestDidFinish|paymentQueue|userNotificationCenter|messaging|URLSession|observeValue|touches|layoutSubviews|awakeFromNib|prepare|didSelect|numberOf|cellFor|sizeFor|viewFor|didDeselect|should|can|will|did|jsEvent|closeWeb|appWillTerminate|willTransition|didTransition|traitCollectionDidChange|preferredStatusBarStyle|supportedInterfaceOrientations|present|dismiss|performSegue|encode|decode|hash|isEqual|description|debugDescription)
      return 0
      ;;
  esac
  return 1
}

swift_count=$(find_swift_files | wc -l | tr -d ' ')

echo "目标目录: $TARGET_DIR"
echo "Swift 文件数: $swift_count"
echo "模式: v3 清单扫描，不修改源码"
echo ""

echo "一、不可改边界符号"
echo "这些通常是业务/协议/系统/JS bridge 边界，改名容易导致 has no member 或运行时断桥。"
boundary_count=0
while IFS= read -r swift_file; do
  while IFS=$'\t' read -r name reason; do
    [ -n "$name" ] || continue
    boundary_count=$((boundary_count + 1))
    echo "  - $(basename "$swift_file")::$name  [$reason]"
  done < <(SWIFT_FILE="$swift_file" perl -nle '
    if (/^\s*\@(?:objc|IBAction|IBSegueAction|available|nonobjc)\b/) {
      $annotated = 1;
      next;
    }
    if (/^\s*(?:(?:private|fileprivate|internal|public|open)\s+)?(?:final\s+)?(?:(?:static|class)\s+)?override\s+func\s+([A-Za-z_][A-Za-z0-9_]*)/) {
      print "$1\toverride";
      $annotated = 0;
      next;
    }
    if (/^\s*(?:(?:internal|public|open)\s+)?(?:final\s+)?(?:(?:static|class)\s+)?func\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(/ ||
        /^\s*(?:(?:internal|public|open)\s+)?(?:final\s+)?(?:(?:static|class)\s+)?class\s+func\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(/ ||
        /^\s*(?:(?:internal|public|open)\s+)?(?:final\s+)?(?:(?:static|class)\s+)?static\s+func\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(/) {
      my $name = $1;
      if ($annotated) {
        print "$name\tannotation";
      } else {
        print "$name\texternal-or-internal-api";
      }
      $annotated = 0;
      next;
    }
  ' "$swift_file" | sort -u)
done < <(find_swift_files)
[ "$boundary_count" -eq 0 ] && echo "  - 未发现"
echo ""

echo "二、可安全改名候选"
echo "条件: private/fileprivate、同文件内闭环、至少定义+调用 2 处、没有 .method() 点调用冲突。"
safe_count=0
while IFS= read -r swift_file; do
  while IFS= read -r method_name; do
    [ -n "$method_name" ] || continue
    is_reserved_method "$method_name" && continue
    method_has_dot_call "$swift_file" "$method_name" && continue
    match_count=$(count_method_matches "$swift_file" "$method_name")
    [ "$match_count" -ge 2 ] || continue
    safe_count=$((safe_count + 1))
    new_name=$(stable_name "m" "$swift_file::$method_name")
    echo "  - $(basename "$swift_file")::$method_name -> $new_name  (${match_count}处)"
  done < <(perl -nle '
    if (/^\s*\@(?:objc|IBAction|IBSegueAction|available|nonobjc)\b/ || /\@(?:objc|IBAction|IBSegueAction|available|nonobjc)\b/) {
      $skip = 1;
      next;
    }
    if (/^\s*(?:private|fileprivate)\s+(?:final\s+)?(?:(?:static|class)\s+)?func\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(/) {
      if ($skip) {
        $skip = 0;
        next;
      }
      print $1;
    }
  ' "$swift_file")
done < <(find_swift_files)
[ "$safe_count" -eq 0 ] && echo "  - 未发现"
echo ""

echo "三、字符串保护候选"
string_count=0
while IFS= read -r swift_file; do
  while IFS= read -r item; do
    [ -n "$item" ] || continue
    string_count=$((string_count + 1))
    echo "  - $(basename "$swift_file")::$item"
  done < <(perl -nle '
    if (/requestPath\s*=\s*"([^"]+)"/) { print "requestPath = \"" . $1 . "\""; }
    if (/let\s+ReplaceUrlDomain\s*(?::\s*String)?\s*=\s*"([^"]+)"/) { print "ReplaceUrlDomain = \"" . $1 . "\""; }
  ' "$swift_file")
done < <(find_swift_files)
[ "$string_count" -eq 0 ] && echo "  - 未发现明文 requestPath/ReplaceUrlDomain"
echo ""

echo "四、目录风险提示"
case "$TARGET_DIR" in
  *backup*|*Backup*)
    echo "  - 当前目标目录名称包含 backup，不建议对备份目录执行混淆。"
    ;;
  *)
    echo "  - 当前目标目录不是备份目录。"
    ;;
esac
if [ "$swift_count" -gt 40 ]; then
  echo "  - Swift 文件数较多，请确认没有传到工程根目录。"
else
  echo "  - Swift 文件数较少，像是具体 B 面目录。"
fi
echo ""

echo "汇总: 不可改边界 $boundary_count 个，可安全改名 $safe_count 个，字符串候选 $string_count 个。"

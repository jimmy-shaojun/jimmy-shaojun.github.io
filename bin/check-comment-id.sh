#!/usr/bin/env bash
#
# Lint: 确保 _posts/ 下每篇文章的 front matter 都包含 comment_id，
#       且所有 comment_id 全局唯一（防止两篇文章评论串台）。
# 任一条件不满足即以非零退出码失败（供 CI 使用）。
#
# 用法：bash bin/check-comment-id.sh
#
set -uo pipefail

fail=0
shopt -s nullglob

ids_file=$(mktemp)
trap 'rm -f "$ids_file"' EXIT

# 从一篇文章的 front matter 中提取 comment_id 的值（去引号、去首尾空白）。
extract_id() {
  awk -v sq="'" -v dq='"' '
    NR==1 && $0 ~ /^---[[:space:]]*$/ { infm=1; next }
    infm && $0 ~ /^---[[:space:]]*$/  { exit }
    infm && $0 ~ /^comment_id[[:space:]]*:/ {
      v=$0
      sub(/^comment_id[[:space:]]*:[[:space:]]*/, "", v)
      sub(/[[:space:]]+$/, "", v)
      first=substr(v,1,1); last=substr(v,length(v),1)
      if ((first==dq || first==sq) && first==last) v=substr(v,2,length(v)-2)
      print v
      exit
    }
  ' "$1"
}

# 1) 每篇必须有非空 comment_id
for f in _posts/*.md _posts/*.markdown; do
  id=$(extract_id "$f")
  if [ -z "$id" ]; then
    echo "::error file=${f}::缺少 comment_id（front matter 必须包含非空的 comment_id）"
    echo "MISSING comment_id: ${f}"
    fail=1
    continue
  fi
  printf '%s\t%s\n' "$id" "$f" >> "$ids_file"
done

# 2) comment_id 必须全局唯一
dups=$(cut -f1 "$ids_file" | LC_ALL=C sort | uniq -d)
if [ -n "$dups" ]; then
  fail=1
  while IFS= read -r dup; do
    [ -z "$dup" ] && continue
    echo "❌ 重复的 comment_id: \"${dup}\" 出现在以下文章："
    while IFS=$'\t' read -r id file; do
      if [ "$id" = "$dup" ]; then
        echo "::error file=${file}::comment_id 与其他文章重复：\"${dup}\""
        echo "    - ${file}"
      fi
    done < "$ids_file"
  done <<< "$dups"
fi

if [ "$fail" -ne 0 ]; then
  echo "❌ Lint 失败：comment_id 缺失或不唯一（详见上方）。"
  echo "   每篇文章的 front matter 必须有一行：comment_id: \"<稳定且全局唯一的 id>\""
  exit 1
fi

echo "✅ 所有文章都包含 comment_id，且全部唯一。"

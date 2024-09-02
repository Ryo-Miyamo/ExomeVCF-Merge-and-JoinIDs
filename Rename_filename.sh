#! /bin/bash

# Rename_filename
# specify the directory
cd path-to-directory

# ファイルのリストを配列に格納
files=(*)

# 配列の長さを取得
no_files=${#files[@]}

# ループで各ファイルを処理
# specify the filename (old_name to new_name)
for (( i=0; i<$no_files; i++ ))
do
  old_name="${files[$i]}"
  new_name=$(echo "$old_name" | sed -e 's/TUHA/TUH-A-/')

  # ファイル名が異なる場合のみリネーム
  if [[ "$old_name" != "$new_name" ]]; then
    mv "$old_name" "$new_name"
  fi
done


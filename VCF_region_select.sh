#!/bin/bash

# bcftools view -Rの時間がかかり、かつ、bcftoolsはthreadingに対応していないため、vcfファイルを250個ずつに分けて、それぞれInput_DirとOutput_Dirを分けて並行で処理した。250個の処理に約1.5h要した。

# Specify the location of "picard.jar"
Region_bed=
Input_Dir=
Output_Dir=

cd "$Input_Dir" || { echo "Failed to change directory to $Input_Dir"; exit 1; }

# ファイルのリストを配列に格納
files=(*)

# 配列の長さを取得
no_files=${#files[@]}

# ループで各ファイルを処理
for (( i=0; i<$no_files; i++ ))
do
  input_file="${files[$i]}"
  
  # 圧縮ファイルのパス
  compressed_file="${input_file}.gz"
  output_file="${Output_Dir}/${input_file}.gz"
  
  # VCFファイルがすでに圧縮されているか確認
  if [[ ! -f "$compressed_file" ]]; then
    echo "Compressing $input_file"
    if bgzip -c "$input_file" > "$compressed_file"; then
      echo "Successfully compressed $input_file to $compressed_file"
    else
      echo "Error compressing $input_file" >&2
      continue
    fi
  else
    echo "$compressed_file already exists and is compressed."
  fi

  # インデックスの作成
  if bcftools index "$compressed_file"; then
    echo "Indexing of $compressed_file completed successfully"
  else
    echo "Error indexing $compressed_file" >&2
    continue
  fi

  # VCFファイルのフィルタリングと圧縮
  if bcftools view -R "$Region_bed" "$compressed_file" | bgzip -c > "$output_file"; then
    echo "Successfully filtered and compressed $compressed_file to $output_file"
  else
    echo "Error processing $compressed_file" >&2
    continue
  fi

  # フィルタリング結果のインデックス作成
  if bcftools index "$output_file"; then
    echo "Indexing of $output_file completed successfully"
  else
    echo "Error indexing $output_file" >&2
  fi
  
  echo "$input_file has been filtered against the bed file"
  
  # 元の未圧縮ファイルと圧縮ファイル、およびインデックスファイルを削除
  rm -f "$input_file" "${input_file}.gz" "${input_file}.gz.csi"

  echo "$input_file and related files have been deleted"

done


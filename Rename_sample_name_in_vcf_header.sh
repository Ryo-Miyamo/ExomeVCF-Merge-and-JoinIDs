#! /bin/bash

# By picard "RenameSampleInVcf"
# java -jar picard.jar RenameSampleInVcf \
# INPUT=input_variants.vcf \
# OUTPUT=output_variants.vcf \
# NEW_SAMPLE_NAME=sample

# Specify the location of "picard.jar"
Picard_Dir=
Input_Dir=
Output_Dir=

cd "$Input_Dir"

# ファイルのリストを配列に格納
files=(*)

# 配列の長さを取得
no_files=${#files[@]}

# ループで各ファイルを処理
for (( i=0; i<$no_files; i++ ))
do
  input_file="${files[$i]}"
  new_sample_name=$(echo "$input_file" | sed -e 's/_.*//')

  # picardでの処理
  java -jar "${Picard_Dir}/picard.jar" RenameSampleInVcf \
    INPUT="$input_file" \
    OUTPUT="${Output_Dir}/${input_file}" \
    NEW_SAMPLE_NAME="$new_sample_name"
    
echo VCF sample name in header has been changed to "$new_sample_name"

done




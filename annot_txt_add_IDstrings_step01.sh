#!/bin/bash

# このスクリプトでは、GTフィールドの0/1などを(het)などに変換する（input 19Gで約11分）

# 作業ディレクトリに移動
cd path-to-directory || { echo "Directory not found"; exit 1; } # specify the location

# ファイルパスの設定
input_file="merged_files_mnone_all.vcf.hg38_multianno.txt"  # ファイルの名前
temp_data_file="temp_data.txt"  # 一時データファイル名
output_file="merged_files_mnone_all.vcf.hg38_multianno_transformed.txt"  # 最終的な出力ファイル名

# Genotypeの変換処理（ファイル3の228列目以降の変換）
awk -F'\t' -v OFS='\t' '
NR == 1 {
    print
    next
}
{
    for (i = 228; i <= NF; i++) {
        if ($i ~ /^\.\//) {
            $i = "."
        } else {
            n = split($i, fields, ":")
            if (fields[1] == ".") {
                $i = "."
            } else {
                split(fields[1], alleles, "/")
                if (alleles[1] == alleles[2]) {
                    $i = "(hom)"
                } else {
                    $i = "(het)"
                }
            }
        }
    }
    print
}
' "$input_file" > "$output_file"

echo "Genotype transformation complete. Check $output_file"


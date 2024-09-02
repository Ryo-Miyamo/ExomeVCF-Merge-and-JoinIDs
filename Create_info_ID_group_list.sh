#!/bin/bash

# ANNOVARでのannotation後に、annot.txtとannot.vcfが作られる。
# annot.txtのヘッダーではサンプル名は"Otherinfo[number]"となっている。今回はOtherinfo13を含めてそれ以降がサンプル名を示すものとなる。annot.vcfのヘッダーにはサンプルIDがそのまま記載されている。
# otherinfo13を含めてそれ以降を取り出し、verticalに変換。また.vcfのヘッダーからサンプルIDを取り出してverticalに変換し、それをpasteする。つまり、
# [STEP1] cat '/merged_files_mnone_all.vcf.hg38_multianno.vcf' | grep ^# | tail -n 1 | cut -f 10- | sed -e 's/\t/\n/g' > annot_sampleID_vertical.txt
# [STEP2] cat 'merged_files_mnone_all.vcf.hg38_multianno.txt' | head -n 1 | cut -f 228- | sed -e 's/\t/\n/g' > annot_sampleOtherinfo_vertical.txt
# [STEP3] paste annot_sampleID_vertical.txt annot_sampleOtherinfo_vertical.txt > Otherinfo_sampleID.txt
# 以下の作業で、1列目"Otherinfo[number]"、2列目"sampleID"、3列目"[Group名]sampleID"のファイルが作られる。

file1="Otherinfo_sampleID.txt"
file2="ExomeSamples_DiagnosisUL_list_20240902" # extract from exome sample database: cat exome_samples_..._updating_1.0.csv | cut -f 5,12 | sed -e 's/\"//g' > ExomeSamples_DiagnosisUL_list_20240902

cd path-to-directory # specify the location

# Create the group map
awk -F'\t' '{print $1 "\t" $2}' "$file2" > group_map.txt

# Add the group information to file1 and create the new column
awk -F'\t' 'FNR==NR {groups[$1]=$2; next} {print $0 "\t" "[" groups[$2] "]" $2}' group_map.txt "$file1" > Otherinfo_sampleID_group.txt

# Clean up temporary file
rm group_map.txt

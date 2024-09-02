#!/bin/bash

Input_Dir=path-to-inputdir
Output_Dir=path-to-outputdir

cd "$Input_Dir" || { echo "Failed to change directory to $Input_Dir"; exit 1; }

# ls  *.vcf.gz > list_of_file.txt
# listはこのコマンドで作成して、listのはじめにTUH-...が来るように並べ替えて使用した。
# 1000sample以上（1024以上？）をmergeしようとするとエラーが出るため、listを約600検体でsplitして、2つのリストに分ける。それぞれのmerged.files_*.vcf.gzにindexをつけ直して、それらをさらにmergeする。
# それぞれのbcftools mergeに要する時間は4分程度で早い。
# bcftools mergeには-m none　オプションをつけることができる。このオプションをつけた場合、同じlocusにmultiallelic variantsがまとめあげられることはなくなる。ただし、単一サンプルからのvcfファイルでもALTのカラムにmultipleにvariantが存在する場合がある（今回のKAPA exome regionに限定したexome vcfで約500個/サンプル）。今回は-m noneオプションをつける。
# なお、ANNOVARのconvert2annovar.plでavinputファイルを作成すると、multiallelic variantsは異なる行にふり分けられる。例えばREF=A, ALT=T(sample01),G(sample02),C(sample03)で、それらがvcfの時点で一旦一行になっていた場合、ANNOVARの結果ファイル（annot.txtなど）ではA/T,A/G/,A/Cが別の行になり、それらの行全てにsample01,sample02,sample03のGT情報が記載されることになる。

# STEP1

bcftools merge --threads 12 -m none --file-list 01_list_of_file.txt -Oz -o ${Output_Dir}merged_files_mnone_01.vcf.gz
bcftools index ${Output_Dir}merged_files_mnone_01.vcf.gz

# STEP2

bcftools merge --threads 12 -m none --file-list 02_list_of_file.txt -Oz -o ${Output_Dir}merged_files_mnone_02.vcf.gz
bcftools index ${Output_Dir}merged_files_mnone_02.vcf.gz

# STEP3

bcftools merge --threads 12 -m none ${Output_Dir}merged_files_mnone_01.vcf.gz ${Output_Dir}merged_files_mnone_02.vcf.gz -Oz -o ${Output_Dir}merged_files_mnone_all.vcf.gz


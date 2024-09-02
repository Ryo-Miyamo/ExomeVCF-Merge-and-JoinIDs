import csv

# このスクリプトでは、Otherinfo13列以降について、
# [STEP1] ヘッダーを[group]sampleIDに変更し、
# [STEP2] カラムの中身を[group]sampleID(het)などに変更し、
# [STEP3] カラムの中身の.は削除、それ以外を:で結合してstringにして、そのカラム名をSamplesにする。

# ファイルパスの設定
input_file = 'merged_files_mnone_all.vcf.hg38_multianno_transformed.txt'
info_ID_group_list = 'Otherinfo_sampleID_group.txt'
output_file = 'merged_files_mnone_all.vcf.hg38_multianno_transformed.txt_final_transformed.txt'

# ファイル4の内容を辞書として読み込み
header_map = {}
with open(info_ID_group_list, mode='r') as f4:
    reader = csv.reader(f4, delimiter='\t')
    for row in reader:
        if len(row) >= 3:
            header_map[row[0]] = row[2]

# 入力ファイルのヘッダーを置換し、228列目以降のデータカラムに対して処理を行う
with open(input_file, mode='r') as infile, open(output_file, mode='w', newline='') as outfile:
    reader = csv.reader(infile, delimiter='\t')
    writer = csv.writer(outfile, delimiter='\t')
    
    # ヘッダー行を処理
    headers = next(reader)
    
    # ヘッダーの置換処理
    headers = [header_map.get(header, header) for header in headers]
    
    # 228列目以降のヘッダーを取得
    prefix_headers = headers[227:]
    
    # ヘッダー行を書き込む
    writer.writerow(headers[:227] + ['Samples'])
    
    def add_prefix(value, prefix):
        if value == '.' or value == '(het)' or value == '(hom)':
            return f"{prefix}{value}" if value != '.' else ''
        return value
    
    # データ行を処理
    for row in reader:
        # 228列目以降のカラムに対してプレフィックスを追加
        transformed_values = [add_prefix(row[i], prefix_headers[i - 227]) for i in range(227, len(row))]
        # 空でない値だけを結合
        combined_value = ':'.join(filter(None, transformed_values))
        # 新しい行を生成
        new_row = row[:227] + [combined_value]
        writer.writerow(new_row)

print(f"Processing complete. Check {output_file}")


awk -F '\:' '{printf("chr%s\t%d\t%d\n",$1,int($2)-1,int($2));}' < input.txt |\
./a.out |\
awk '{printf("select name,chromStart+1 from snp137 where chrom=\"%s\" and bin in(%s) and NOT(chromEnd<=%s or chromStart>%s);\n",$1,$4,$2,$2);}' |\
mysql -h genome-mysql.cse.ucsc.edu -u genome -A -D hg19 -N

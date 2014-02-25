import sys
vcf_dir_file=sys.argv[1]
 
data=open(vcf_dir_file)
data=data.readlines()
 
out=open(vcf_dir_file.strip(".vcf")+".txt", "w")
print >> out, "Chrom	Pos	Id	Minor	Major	MAF"
 
for i in range(len(data)):
	if data[i][0]!="#":
		col=data[i].strip().split()
		genos=[]
		for j in range(9,len(col)):
			geno=col[j].split(":")[0]
			if geno=="0/0" or geno=="0|0":
				genos.append(0)
			elif geno=="0/1" or geno=="0|1" or geno=="1/0" or geno=="1|0":
				genos.append(1)
			elif geno=="1/1" or geno=="1|1":
				genos.append(2)
		maf=sum(genos)/(2.0*len(genos))
		if maf<0.5:
			print >> out, col[0]+"\t"+col[1]+"\t"+col[2]+"\t"+col[3]+"\t"+col[4]+"\t"+str(maf)
		else:
			print >> out, col[0]+"\t"+col[1]+"\t"+col[2]+"\t"+col[4]+"\t"+col[3]+"\t"+str(1-maf)
 
out.close()

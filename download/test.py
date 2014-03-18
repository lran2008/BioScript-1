import sys
import os
from time import time

# location on the web:
# ftp://ftp-trace.ncbi.nih.gov/1000genomes/ftp/release/20100804/ALL.2of4intersection.20100804.genotypes.vcf.gz

tabix = "/BiO/hmkim87/BioTools/tabix/0.2.6/tabix"
if(len(sys.argv) <> 2):
    print "usage: python get-1000g.py vcffilename.vcf" # vcffilename.vcf is your VCF file listing the sites you care about
infilepath = sys.argv[1]
infileprefix = infilepath.split(".")[0]

infile = open(infilepath,"r")
outfilepath = "1000g_" + infileprefix + ".vcf"
kgvcfpath = "~/1000g/ALL.2of4intersection.20100804.genotypes.vcf.gz" # 1000g vcf file

clcall = tabix + " -H " + kgvcfpath + " > " + outfilepath # -H gets just the header
print "clcall" + " " + clcall
#os.system(clcall) 

counter = 0
starttime = time()
for line in infile.readlines():
    if(line[0]=="#"):
        continue
    col = line.split("\t")
    chromosome = col[0][3:] # strip "chr" from front
    position = col[1]
    clcall = tabix + " " + kgvcfpath + " " + chromosome + ":" + position + "-" + position + " >> " + outfilepath # >> appends rather than overwriting
    print "clcall" + " " + clcall
    #os.system(clcall)
    counter += 1
    if(counter%100==0):
        rate = counter / (time() - starttime)
        print "processed " + str(counter) + " lines at an average rate of " + str(rate) + " lines per second"

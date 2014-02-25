#!/usr/bin/python
 
import cyvcf

in_vcf = "example.vcf"

vcf_reader = cyvcf.Reader(open(in_vcf, 'rb'))
for record in vcf_reader:
	print record

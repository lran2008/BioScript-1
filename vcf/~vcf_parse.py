#!/usr/bin/python

import sys
import cyvcf

if __name__ == "__main__":
	if len(sys.argv) != 2:
		print "Usage: python %s <in.vcf>" % sys.argv[0]
		sys.exit()
	invcf = sys.argv[1]
	vcf_reader = cyvcf.Reader(open(invcf, 'rb'))

	for record in vcf_reader:
		print record

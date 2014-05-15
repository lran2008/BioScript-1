from Bio import SeqIO
import sys
if len(sys.argv)!=3:
	print "usage : %s <in.fasta> <out.fasta>"%(sys.argv[0])
	sys.exit()
[in_fasta_filename, out_fasta_filename]=sys.argv[1:2]

SeqIO.convert(in_fasta_filename, "fasta", out_fasta_filename, "fasta")

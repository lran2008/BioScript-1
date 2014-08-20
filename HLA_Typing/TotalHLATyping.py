import sys, os

def makeDirectory(file):
	if not os.path.exists(file):
		os.system("mkdir -p %s" % file)

if len(sys.argv) != 4 :
	print "Usage : python %s <first.fastq> <second.fastq> <outdir>" % sys.argv[0]
	sys.exit()

HLALIST = ['A','B','C','DMA','DMB','DOA','DOB','DPA1','DQA1','DQB1','DRA','DRB1','DRB2','DRB3','DRB4','DRB5','DRB6','DRB7','DRB8','DRB9','E','F','G','H','J','K','L','MICA','MICB','P','TAP1','TAP2','V']
BEDS = "/BiOfs/sgpark/BioTools/ATHLATES/Athlates_07082013/db/bed"
MSFS = "/BiOfs/sgpark/BioTools/ATHLATES/Athlates_07082013/db/msa"
#HLATYPING = "/BiOfs/sgpark/BioTools/ATHLATES/Athlates_07082013/bin/typing"
HLATYPING = "/BiO/hmkim87/BioTools/Athlates_11012013/bin/typing"
REFERENCE = "/BiOfs/sgpark/BioTools/ATHLATES/Athlates_07082013/db/ref/Ref.nix"
FIRSTFQ = sys.argv[1]
SECONDFQ = sys.argv[2]
OUTDIR = sys.argv[3]

makeDirectory(OUTDIR)
os.system("python /BiO/sgpark/Project/CBU_Exome_HLA_Typing/Script/novoalign.py %s %s %s %s/FirstBam.bam" % (REFERENCE, FIRSTFQ, SECONDFQ, OUTDIR))

os.system("/BiOfs/sgpark/BioTools/samtools-0.1.19/samtools sort %s/FirstBam.bam %s/FirstBam.sort" % (OUTDIR,OUTDIR))

for HLA in HLALIST :
	os.system("/BiOfs/sgpark/BioTools/samtools-0.1.19/samtools view -b -L %s/hla.%s.bed %s/FirstBam.sort.bam > %s/Second.%s.exon.bam" % (BEDS, HLA, OUTDIR, OUTDIR, HLA))
	os.system("/BiOfs/sgpark/BioTools/samtools-0.1.19/samtools view -b -L %s/hla.non-%s.bed %s/FirstBam.sort.bam > %s/Second.%s.nonexon.bam" % (BEDS, HLA, OUTDIR, OUTDIR, HLA))

	os.system("/BiOfs/sgpark/BioTools/samtools-0.1.19/samtools view -h -o %s/Second.%s.exon.sam %s/Second.%s.exon.bam" % (OUTDIR, HLA, OUTDIR, HLA))
	os.system("/BiOfs/sgpark/BioTools/samtools-0.1.19/samtools view -h -o %s/Second.%s.nonexon.sam %s/Second.%s.nonexon.bam" % (OUTDIR, HLA, OUTDIR, HLA))

	os.system("python /BiO/sgpark/Project/CBU_Exome_HLA_Typing/Script/Samsorted.py %s/Second.%s.exon.sam %s/Second.%s.exon.sort.sam" % (OUTDIR, HLA, OUTDIR, HLA))
	os.system("python /BiO/sgpark/Project/CBU_Exome_HLA_Typing/Script/Samsorted.py %s/Second.%s.nonexon.sam %s/Second.%s.nonexon.sort.sam" % (OUTDIR, HLA, OUTDIR, HLA))

	os.system("/BiOfs/sgpark/BioTools/samtools-0.1.19/samtools view -bS %s/Second.%s.exon.sort.sam > %s/Second.%s.exon.sort.bam" % (OUTDIR, HLA, OUTDIR, HLA))
	os.system("/BiOfs/sgpark/BioTools/samtools-0.1.19/samtools view -bS %s/Second.%s.nonexon.sort.sam > %s/Second.%s.nonexon.sort.bam" % (OUTDIR, HLA, OUTDIR, HLA))
	
	outputdir = "%s/%s" % (OUTDIR, HLA)
	makeDirectory(outputdir)

	if os.path.exists("%s/%s_nuc.txt" % (MSFS, HLA)) :
		os.system("%s -bam %s/Second.%s.exon.sort.bam -exlbam %s/Second.%s.nonexon.sort.bam -msa %s/%s_nuc.txt -o %s/%s" % (HLATYPING, OUTDIR, HLA, OUTDIR, HLA, MSFS, HLA, outputdir, HLA))
	elif HLA[:3] == 'DRB' :
		os.system("%s -bam %s/Second.%s.exon.sort.bam -exlbam %s/Second.%s.nonexon.sort.bam -msa %s/%s_nuc.txt -o %s/%s" % (HLATYPING, OUTDIR, HLA, OUTDIR, HLA, MSFS, HLA[:3], outputdir, HLA))
		


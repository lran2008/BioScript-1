#!/bin/bash

java -jar /gg/bio/tools/GenomeAnalysisTK-2.7-4-g6f46d11/GenomeAnalysisTK.jar \
-T VariantAnnotator \
-R /gg/reference/human/hs37d5ss/chrAll.fa \
-A SnpEff \
--variant /gg/data/vcf/all.filtered.sorted.vcf \
--snpEffFile /gg/bio/script/snpeff/out_snpeff.sorted.vcf \
-L /gg/data/vcf/all.filtered.sorted.vcf \
-o /gg/bio/script/gatk/option_1.VA.vcf

java -jar /gg/bio/tools/GenomeAnalysisTK-2.7-4-g6f46d11/GenomeAnalysisTK.jar \
-T VariantAnnotator \
-R /gg/reference/human/hs37d5ss/chrAll.fa \
-E resource.EFF \
--variant /gg/data/vcf/all.filtered.sorted.vcf \
--resource /gg/bio/script/snpeff/out_snpeff.sorted.vcf \
-L /gg/data/vcf/all.filtered.sorted.vcf \
-o /gg/bio/script/gatk/option_2.VA.vcf

#!/bin/sh
/BiOfs/shsong/BioTools/samtools-0.1.19/samtools view -h /BiO/hmkim87/OTG-snpcaller/Data/SampleBAM/OTG/temp_AJ/AJ.bam.chrM.bam | awk '{if($3 == "chrM" || $0 ~ "^@")print}'| /BiOfs/shsong/BioTools/samtools-0.1.19/samtools view -bS - -o /BiO/hmkim87/OTG-snpcaller/Result/OTG_ResultBAM/AJ.chrM.bam

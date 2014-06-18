#!/bin/bash

FILE=$1
OUTPUT_FILE=$2

echo $FILE
echo $OUTPUT_FILE

/BiOfs/BioTools/R-3.0.2/bin/R --vanilla << EOD

#library(ggplot2)
source("qqman.new.r")

a <- read.table("$FILE", head=T)

png("$OUTPUT_FILE", width=10, height=4, res=700, units="in")
manhattan(a)
dev.off()

EOD

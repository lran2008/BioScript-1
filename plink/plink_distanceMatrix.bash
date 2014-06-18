#!/bin/bash

if [ $# -lt 3 ]; then
    echo "/bin/bash $0 <input_file_prefix> <input.fam file> <output_prefix>"
    echo "/bin/bash $0 <plink format> <input.fam file> <output_prefix>"
    exit 0
fi

mydata=$1
fam_file=$2
output_file=$3
output_png=$output_file".png"
output_mdist=$output_file".mds.txt"

########################################################################
Program_path="/BiOfs/hmkim87/BioTools/plink/"
plink=$Program_path"/1.07/plink"
########################################################################

$plink \
    --noweb \
    --bfile $mydata \
    --cluster \
    --distance-matrix \
    --out $output_file

distance_file=$output_file".mdist"

R --vanilla <<EOD
library(ggplot2)
library(RColorBrewer)
cols = brewer.pal(9, 'Set1')

mdist<-read.table('$distance_file', head=F)
fit<-cmdscale(mdist, eig=TRUE, k=4)
x<-fit\$points[,1]
y<-fit\$points[,2]

fam<-read.table('$fam_file', head=F)

group=fam[,1]
group_name<-as.factor(group)

Total<-cbind(x,y)
Total<-cbind(Total,fam[,1:2])
names(Total)<-c("x", "y", "group", "ID")
write.table(Total, "$output_mdist", quote=F, col.names=F, row.names=F, sep="\t")

png("$output_png", width=6+2/3, height=6+2/3, units="in", res=300)
ggplot(Total, aes(x=x, y=y))+geom_point(aes(colour = group), size=2)
dev.off()
EOD


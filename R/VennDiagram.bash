#!/bin/bash

INPUT=$1
OUTPUT=$2

R --vanilla << EEE

library(VennDiagram)
a<-read.table("$INPUT", head=T, sep='\t')
Total<-a[,7]

Muscle<-a[which(a[,5]!=0),4]
Heart<-a[which(a[,6]!=0),4]
Cerebrum<-a[which(a[,7]!=0),4]
Lung<-a[which(a[,8]!=0),4]

venn.diagram(
x=list(
Muscle = Muscle,
Heart = Heart,
Cerebrum = Cerebrum,
Lung = Lung
),
filename="$OUTPUT",
col = "black",
lty = "dotted",
lwd = 1.2,
fill = c("cornflowerblue", "green", "yellow", "darkorchid1"),
alpha = 0.40,
label.col = c("darkorchid4", "darkorchid4", "darkorchid4", "darkorchid4", "darkorchid4", "darkorchid4", "darkorchid4", "darkorchid4", "darkorchid4", "darkorchid4", "darkorchid4", "darkorchid4", "darkorchid4", "darkgreen", "darkorchid4"),
cex = 1,
fontfamily = "serif",
fontface = "bold",
cat.col = c("darkblue", "darkgreen", "orange", "darkorchid4"),
cat.cex = 1,
cat.fontfamily = "serif",
cat.pos = c(-0.05, 0.05, 0, 0),
cat.dist = c(0.20, 0.20, 0.08, 0.08)
)
EEE

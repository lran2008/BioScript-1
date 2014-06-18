#!/bin/bash

INPUT_FILE=$1
OUTPUT_FILE=$2

R --vanilla <<EOD
library(ggplot2)
library(RColorBrewer)
cols = brewer.pal(9, 'Set1')

stat<-read.table("$INPUT_FILE", head=T)

sample_cnt = dim(stat)[1]

raw<-stat[,c(dim(stat)[2], 1, 2)]
raw<-cbind(raw, rep("raw reads", sample_cnt))
names(raw)[3]<-"read_cnt"
names(raw)[4]<-"read_type"

clean<-stat[,c(dim(stat)[2], 1, 3)]
clean<-cbind(clean, rep("clean reads", sample_cnt))
names(clean)[3]<-"read_cnt"
names(clean)[4]<-"read_type"

dedup<-stat[,c(dim(stat)[2], 1, 5)]
dedup<-cbind(dedup, rep("de-dup reads", sample_cnt))
names(dedup)[3]<-"read_cnt"
names(dedup)[4]<-"read_type"

ontarget<-stat[,c(dim(stat)[2], 1, 7)]
ontarget<-cbind(ontarget, rep("on-target reads", sample_cnt))
names(ontarget)[3]<-"read_cnt"
names(ontarget)[4]<-"read_type"

total<-rbind(raw, clean)
total<-rbind(total, dedup)
total<-rbind(total, ontarget)

png("$OUTPUT_FILE")
ggplot(total, aes(x=read_type, y=read_cnt/(10^7), color=read_type))+ geom_boxplot(width=0.3)+ geom_point(position=position_jitter(width=0.3), alpha=0.3)+ scale_color_manual(values=cols) + scale_y_continuous("Number of reads (Gb)", limit=c(0,16))
dev.off()
EOD

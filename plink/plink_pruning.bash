#!/bin/bash

#if [ $# -lt 5 ]; then
#    echo ""
#    echo ""
#    echo "##################################################################"
#    echo "# 1. vcf file ( Non exist charater : 'chr' or 'Chr'              #"
#    echo "#               Only integer : 1, 2, 3, ....                     #"
#    echo "#                                                                #"
#    echo "# 2. Otuput Path :    ex) /data1/Project/Result/                 #"
#    echo "#                                                                #"
#    echo "# 3. Output prefix :  ex) Gongju.RICE.result                     #"
#    echo "#                                                                #" 
#    echo "# 4. Plink.fam format file                                       #" 
#    echo "#                                                                #" 
#    echo "# 5. Structure K value                                           #"
#    echo "#                                                                #"
#    echo "##################################################################"
#    exit 0
#fi

Input_prefix=$1
Output_prefix=$2

Program_path="/BiOfs/hmkim87/BioTools/plink/"
plink=$Program_path"/1.07/plink"

########################################
#      plink pruning
########################################
Input_file=$Input_prefix
Prune_file=$Output_prefix

#$plink \
#    --noweb \
#    --bfile $Input_file \
#    --indep-pairwise 50 5 0.2 \
#    --allow-no-sex \
#    --out $Prune_file

########################################
#      plink pruning extract
########################################
Input_file=$Input_prefix
Prune_file=$Output_prefix".prune.in"
Output_file=$Output_prefix".prune"

$plink \
    --noweb \
    --bfile $Input_file \
    --extract $Prune_file \
    --recode \
    --out $Output_file


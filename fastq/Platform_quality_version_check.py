#!/usr/bin/python
import sys, gzip, subprocess, getopt, os, commands


#variables
BUFFER_SIZE = 10000
PROPER_N_MIN_RATE = 10.0
PROPER_AVERAGE_SCORE = 20.0
PROPER_QUALITY_2_DOWN_RATE = 5.0
PLATFORM_ZERO_DIC = {"Sanger" : -33, "Solexa" : -64, "Illumina 1.3+" : -64, "Illumina 1.5+" : -64, "Illumina 1.8+" : -33}
SEED_LENGTH = 90

FIRST_IN_FASTQ = None
SECOND_IN_FASTQ = None

def init(read1, read2):
    global FIRST_IN_FASTQ, SECOND_IN_FASTQ 
    FIRST_IN_FASTQ = read1
    SECOND_IN_FASTQ = read2
    
def checkFlatform():
    # quality #
    qualityIdcDic = {}
    if FIRST_IN_FASTQ.rfind("gz") != -1:
        firReadFile = gzip.open(FIRST_IN_FASTQ, "rb")
    else:
        firReadFile = open(FIRST_IN_FASTQ, "r")
    lineIdx = -1
    for line in firReadFile :
        lineIdx += 1
        if lineIdx == 100000 : break
        if lineIdx % 4 != 3 : continue
        for idc in line.strip() : qualityIdcDic[idc] = None
    firReadFile.close()

    if SECOND_IN_FASTQ.rfind("gz") != -1:
        secReadFile = gzip.open(SECOND_IN_FASTQ, "rb")
    else:
        secReadFile = open(SECOND_IN_FASTQ, "r")
    lineIdx = -1
    for line in secReadFile :
        lineIdx += 1
        if lineIdx == 100000 : break
        if lineIdx % 4 != 3 : continue
        for idc in line.strip() : qualityIdcDic[idc] = None
    secReadFile.close()
    
    platform = None
    qualityIdcDicKeys = qualityIdcDic.keys()
    minQualityIdc = min(qualityIdcDicKeys)
    maxQualityIdc = max(qualityIdcDicKeys)
    if minQualityIdc == ";" and maxQualityIdc == "h" :
        platform = "sanger"
    elif minQualityIdc == "@" and maxQualityIdc == "h" :
        platform = "illumina 1.3+"
    elif minQualityIdc == 'B' and maxQualityIdc == "h" :
        platform = "illumina 1.5+"
    elif minQualityIdc == "!" and maxQualityIdc == "J" :
        platform = "sanger"
    else :
        if   minQualityIdc < ";" :
            platform = "sanger"
        elif minQualityIdc < "@" :
            platform = "sanger"
        elif minQualityIdc < "B" :
            platform = "Illumina 1.3+"
        else :
            platform = "Illumina 1.5+"
    return platform

def main(read1, read2):
    init(read1, read2)
    flatform = checkFlatform()
    print flatform
    return flatform
if __name__ == "__main__":
    main()

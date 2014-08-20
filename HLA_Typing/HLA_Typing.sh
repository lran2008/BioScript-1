#$ -S /bin/sh
date
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/BiOfs/BioTools/bamtools/lib/
python /BiO/hmkim87/PAPGI/HLA_Typing/TotalHLATyping.py /BiO/hmkim87/PAPGI/Exome/RawData/T1303D1399/T1303D1399_1.fastq /BiO/hmkim87/PAPGI/Exome/RawData/T1303D1399/T1303D1399_2.fastq /BiO/hmkim87/PAPGI/HLA_Test_Output/
date

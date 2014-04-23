= Compiling overlap =

Install Objective Caml:

    http://caml.inria.fr/

Run make to produce the overlap binary:

    make

Copy the binary to your /usr/bin

    sudo cp overlap /usr/bin

= Feedback =

Please report any bug to sarahqd@gmail.com  

= Making the binaries =

The 64 bit version can be done on phobos, and the 32 bit version on xinxan.

= Usage =

                     ********************************************
                     *   overlap - version v3.3 2011/06/16      *
                     *      Sarah Djebali, Sylvain Foissac      *
                     ********************************************

Usage: overlap file1 file2 [options] 

For each file1 feature, reports some information about the file2 features overlapping it.

** file1 and file2 must be provided in gff format.
** [options] can be:
   -f flag:       labelling flag for file2 features in the result file.
                  -> default is "feat2".

   -m mode:       mode defines the kind of overlap information one wants to retrieve about file2 features overlapping file1 features.
                   * mode=0: boolean overlap: 1 or 0 whether a given file1 feature is overlapped by a file2 feature.
                   * mode=1: number of file2 features overlapping a given file1 feature. 
                             Note: file2 features with identical {chr,start,stop} from N lines will always be counted N times. 
                   * mode=n where n<0: list and number of file2 features coordinates (in the form of chr_start_stop_strand) 
                             corresponding to file2 features overlapping a given file1 feature. 
                             Note: identical {chr,start,stop} from N lines will be provided N times, unless the -nr option is used.
                   * mode=n where n>=10 and n is even: list and number of values from the nth field of file2 corresponding 
                             to file2 features overlapping a given file1 feature.
                             Note: identical nth field values from N lines will be provided N times, unless the -nr option is used.
                   * mode=n1,n2,...,np where for each i, ni>=10 and ni is even: for each i, provides the list and the number of values 
                             from the nith field of file2 corresponding to file2 features overlapping a given file1 feature.
                             Note: identical nith field values from N lines will be provided N times, unless the -nr option is used.
                   -> default is 0 (faster).

   -nr:           outputs non redundant information about file2 features overlapping a given file1 feature. 
                  Is useful in combination with the three last -m modes (see -m option for more details). 
                  -> default is unset.

   -inter:        when negative mode is used, outputs intersection segments rather than file2 feature segments. 
                      
   -o outfile:    outfile is the name of the gff file the user wants the output to be provided in. 
                  Note: This file is file1 with some additional fields representing the overlap information one wants to retrieve.
                  -> default is file1_over[flag].gff.

   -v:            provides the output result in the standard output rather than in an output file.
                  -> default is unset.

   -st strmode:   defines whether and how strand is taken into account when computing overlap between two features:
                   * strmode=0: strand is not taken into account, only positions are
                   * strmode>0: only features on the same strand can overlap
                   * strmode<0: only features on different strands can overlap
                  Note: in case a non null strmode is used, unstranded features will not be overlapped by anything.
                   -> default is 0.
   
   -i incltype:   this option enables the users to retrieve inclusion information rather than general overlap information
                  (note that inclusion is a particular example of overlap).
                  There are two types of inclusion:
                   * incltype=2: file2 features included in file1 features.
                   * incltype=1: file2 features including file1 features.
                   -> default is 0 (general overlap).

   -ucsc:         format the output file in a way that complies with the ucsc browser 
		  (in order to directly load the file in the ucsc browser)
		  (namely adds two double quotes and one semi-colon to each value of a (key,value) pair).
                  -> default is unset.

   -s nbseq:      nbseq is an upper bound for the number of sequences you have in your input gff files.
                  -> default is 50.

   -so:           overlap does not require any sorting of any file, however this option enables to skip
                  the file1 sorting in case this file is already sorted according to chromosome, start, end. 
                  Note: this sorting could be performed outside overlap using the unix sort command: 
                  sort -k1,1 -k4,4n -k5,5n file1 > sortedfile1

** Please report any bug to sarahqd@gmail.com        

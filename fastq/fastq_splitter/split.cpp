#include <stdio.h>
#include <stdlib.h>

int main(int argc, const char **argv){
	if(argc!=3){
		printf("usage : %s <number> <out_prefix>\n", argv[0]);
		return 0;
	}
	long number=atol(argv[1]);
	const char *out_prefix=argv[2];
	char out_filename[1024], out_filename2[1024], buffer[65536], buffer2[65536];
	long line_i=0, out_filename_i=0, buffer2_i=0;
	sprintf(out_filename, "%s_%ld.fastq.ing", out_prefix, out_filename_i);
	sprintf(out_filename2, "%s_%ld.fastq", out_prefix, out_filename_i++);
	FILE *out_file=fopen(out_filename, "w");
	while(size_t max_i=fread(buffer, 1, 65536, stdin)){
		for(size_t i=0;i<max_i;i++){
			buffer2[buffer2_i++]=buffer[i];
			if(buffer2_i==65536){
				fwrite(buffer2, 1, 65536, out_file);
				buffer2_i=0;
			}
			if(buffer[i]=='\n'){
				line_i++;
				if(line_i%number==0){
					fwrite(buffer2, 1, buffer2_i, out_file);
					buffer2_i=0;
					fclose(out_file);
					rename(out_filename, out_filename2);
					sprintf(out_filename, "%s_%ld.fastq.ing", out_prefix, out_filename_i);
					sprintf(out_filename2, "%s_%ld.fastq", out_prefix, out_filename_i++);
					out_file=fopen(out_filename, "w");
				}
			}
		}
	}
	fwrite(buffer2, 1, buffer2_i, out_file);
	fclose(out_file);
	rename(out_filename, out_filename2);
	return 0;
}

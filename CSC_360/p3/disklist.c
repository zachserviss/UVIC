/*
    CSC 360 Assignment 2
	By: Zach Serviss
	V00950002
*/
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <time.h>
#include <string.h>
#include "functions.h"


void *list(char *p){
	char *fileName = malloc(sizeof(char*));
  	char *fileExtension = malloc(sizeof(char*));
  	int i;
  	char fileType;
	while(p[0] != 0){
        if((p[26] != 0x00) && (p[26] != 0x01) && (p[11] != 0x0F) && ((p[11] & 0x08) != 0x08)){
        	if ((p[11] & 0x10) == 0x10) {
		    	fileType = 'D';
		    }else {
		    	fileType = 'F';
		    }


		    for (i = 0; i < 8; i++) {
	      		if (p[i] == ' ') {
	      			break;
	      		}
      			fileName[i] = p[i];
	      	}
        	fileName[i] = '\0';
		    for (i = 0; i < 3; i++) {
		    	fileExtension[i] = p[i + 8];
		    }
		   	fileExtension[i] = '\0';
		    if (fileType == 'F'){
		    	strncat(fileName, ".", 1);
		    }
		    strncat(fileName, fileExtension, 3);


            int fileSize = (p[28] & 0xFF) + ((p[29] & 0xFF) << 8) +((p[30] & 0xFF) << 16) + ((p[31] & 0xFF) << 24);

      		int year = (((p[17] & 0b11111110)) >> 1) + 1980;
      		int month = ((p[16] & 0b11100000) >> 5) + (((p[17] & 0b00000001)) << 3);
      		int day = (p[16] & 0b00011111);
      		int hour = (p[15] & 0b11111000) >> 3;
      		int minute = ((p[14] & 0b11100000) >> 5) + ((p[15] & 0b00000111) << 3);


      		if ((p[11] & 0x02) == 0 && (p[11] & 0x08) == 0) {
	            printf("%c %10u %20s %d-%d-%d %02d:%02d\n", fileType, fileSize, fileName, year, month, day, hour, minute);
      		}


            if ((p[11] & 0x10) == 0x10){
            	printf("\n");
 		        for (i = 0; i < 8; i++) {
 		        	printf("%c", p[i]);
 		        }
 		        printf("\n==================\n");
 		        list(p + 32);
            }
        }
        p += 32;
    }
    return 0;
}



int main(int argc, char* argv[]){
	if (argc < 2) {
		printf("Error: use as follows ./disklist <.IMA file>\n");
		exit(1);
	}

	int fd = open(argv[1], O_RDWR);
	struct stat sb;
	fstat(fd, &sb);

	char* p = mmap(NULL, sb.st_size, PROT_READ, MAP_SHARED, fd, 0);
	if (p == MAP_FAILED) {
		printf("Error: failed to map memory\n");
		exit(1);
	}


	list(p + SECTOR_SIZE * 19);

	// Clean up
	munmap(p, sb.st_size);
	close(fd);

	return 0;
}
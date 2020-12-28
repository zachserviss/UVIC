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

int getNumberOfRootFiles(char* p) {
    int count = 0;
    while(p[0] != 0){
        if((p[26] != 0x00) && (p[26] != 0x01) && (p[11] != 0x0F) && ((p[11] & 0x08) != 0x08)){
        	if ((p[11] & 0x10) != 0x10){
            	count ++;
            }
            if ((p[11] & 0x10) == 0x10){
            	count += getNumberOfRootFiles(p+32);
            }
        }
        p += 32;
    }
    return count;


}

int main(int argc, char *argv[]){
	if (argc < 2) {
		printf("Error: use as follows ./diskinfo <.IMA file>\n");
		exit(1);
	}

	int fd = open(argv[1], O_RDWR);
	struct stat sb;
	fstat(fd, &sb);

	char * p = mmap(NULL, sb.st_size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0); 
	if (p == MAP_FAILED) {
		printf("Error: failed to map memory\n");
		exit(1);
	}
	
	printf("OS Name:%s\n", p+3);
    printf("Label of the disk: %s\n",getVolumeLabel(p));
    printf("Total size of the disk: %lld bytes\n", sb.st_size);
    printf("Free size of the disk: %d bytes\n", getFreeSize(sb.st_size, p));
    printf("\n==============\n");
    printf("The number of files in the root directory (including all files in the root directory and files in all subdirectories): %d\n", getNumberOfRootFiles(p+SECTOR_SIZE * 19));
    printf("Number of FAT copies: %d\n", p[16]);
    printf("Sectors per FAT : %d\n", p[22] + (p[23]<<8));

	munmap(p, sb.st_size); 
	close(fd);
	return 0;
}
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

void getFile(char* p, char* file, int size, char* name) {
     int start = firstSector(name, p + SECTOR_SIZE*19);
     int n = start;
     int remainingBytes = size;
     int addr;

     do {
          if (remainingBytes != size){
          	n = getFatEntry(n, p);
          }

          addr = SECTOR_SIZE * (31 + n);

          for (int i = 0; i < SECTOR_SIZE; i++) {
               if (remainingBytes == 0) break;
               file[size - remainingBytes] = p[i + addr];
               remainingBytes --;
          }
     } while (remainingBytes != 0);

}

int main(int argc, char *argv[]){
	if (argc < 3) {
		printf("Error: use as follows ./diskget <.IMA file> <file in root of .IMA>\n");
		exit(1);
	}

	int fd = open(argv[1], O_RDWR);
	if (fd < 0) {
		printf("Image not found.\n");
		close(fd);
		exit(1);
	}
	struct stat sb;
	fstat(fd, &sb);


	char * p = mmap(NULL, sb.st_size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0); 
	if (p == MAP_FAILED) {
		printf("Error: failed to map memory\n");
		exit(1);
	}

	int size = fileSize(argv[2], p + SECTOR_SIZE * 19);
	if (size > 0){
		int copyFile = open(argv[2], O_RDWR | O_CREAT, 0644);

		//write "" to end of copy file
		lseek(copyFile, size - 1, SEEK_SET);
		write(copyFile, "\0", 1);

		char* p2 = mmap(0, size, PROT_WRITE, MAP_SHARED, copyFile, 0);
		getFile(p, p2, size, argv[2]);
		munmap(p2, size);
		close(copyFile);
	}else{
		printf("File not found.\n");
	}
	
	munmap(p, sb.st_size);
	close(fd);
	return 0;
}
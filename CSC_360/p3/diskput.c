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

void update(char* fileName, int size, int firstLogicalSector, char* p) {
	p += SECTOR_SIZE * 19;
	while (p[0] != 0x00) {
		p += 32;
	}

	//create name
	int i,j = -1;
	for (i = 0; i < 8; i++) {
		if (fileName[i] == '.') {
			j = i;
		}
		if (j == -1){
			p[i] = fileName[i];
		}else{
			p[i] = ' ';
		}
	}
	for (i = 0; i < 3; i++) {
		p[i+8] = fileName[i+j+1];
	}


	p[11] = 0x00;
	// Set create date/time
	time_t t = time(NULL);
	struct tm *now = localtime(&t);
	int year = now->tm_year + 1900;
	int month = now->tm_mon + 1;
	int day = now->tm_mday;
	int hour = now->tm_hour;
	int minute = now->tm_min;
	
	p[14] = 0;
	p[15] = 0;
	p[16] = 0;
	p[17] = 0;
	p[17] |= (year - 1980) << 1;
	p[17] |= (month - ((p[16] & 0b11100000) >> 5)) >> 3;
	p[16] |= (month - (((p[17] & 0b00000001)) << 3)) << 5;
	p[16] |= (day & 0b00011111);
	p[15] |= (hour << 3) & 0b11111000;
	p[15] |= (minute - ((p[14] & 0b11100000) >> 5)) >> 3;
	p[14] |= (minute - ((p[15] & 0b00000111) << 3)) << 5;

	// Set first logical cluster
	p[26] = (firstLogicalSector - (p[27] << 8)) & 0xFF;
	p[27] = (firstLogicalSector - p[26]) >> 8;

	// Set size
	p[28] = (size & 0x000000FF);
	p[29] = (size & 0x0000FF00) >> 8;
	p[30] = (size & 0x00FF0000) >> 16;
	p[31] = (size & 0xFF000000) >> 24;
}


void putFile(char* p, char* p2, char* fileName, int size) {
	int bytesRemaining = size;
	int current = getNextFatFree(p);
	update(fileName, size, current, p);

	while (bytesRemaining > 0) {
		int physicalAddress = SECTOR_SIZE * (31 + current);
		
		for (int i = 0; i < SECTOR_SIZE; i++) {
			if (bytesRemaining == 0) {
				setFatEntry(current, 0xFFF, p);
				return;
			}
			p[i + physicalAddress] = p2[size - bytesRemaining];
			bytesRemaining--;
		}
		setFatEntry(current, 0x69, p);
		int next = getNextFatFree(p);
		setFatEntry(current, next, p);
		current = next;
	}
}

int main(int argc, char* argv[]) {
	if (argc < 3) {
		printf("Error: use as follows ./diskput <.IMA file> <file in root of current directory>\n");
		exit(1);
	}

	// Open disk image and map memory
	int fd = open(argv[1], O_RDWR);
	if (fd < 0) {
		printf("Image not found.\n");
		close(fd);
		exit(1);
	}
	struct stat sb;
	fstat(fd, &sb);
	char* p = mmap(NULL, sb.st_size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
	if (p == MAP_FAILED) {
		printf("Error: failed to map disk memory\n");
		close(fd);
		exit(1);
	}


	int fd2 = open(argv[2], O_RDWR);
	if (fd2 < 0) {
		printf("File not found.\n");
		close(fd);
		exit(1);
	}
	struct stat sb2;
	fstat(fd2, &sb2);
	char* p2 = mmap(NULL, sb2.st_size, PROT_READ, MAP_SHARED, fd2, 0);
	if (p2 == MAP_FAILED) {
		printf("Error: failed to map file memory\n");
		exit(1);
	}

	int freeDiskSize = getFreeSize(sb.st_size, p);
	if (freeDiskSize >= sb2.st_size) {
		putFile(p, p2, argv[2], sb2.st_size);
	} else {
		printf("%d %lld\n", freeDiskSize, sb2.st_size);
		printf("Not enough free space in the disk image.\n");
	}

	munmap(p, sb.st_size);
	munmap(p2, sb2.st_size);
	close(fd);
	close(fd2);

	return 0;
}
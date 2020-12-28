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

//retireve label of disk
char *getVolumeLabel(char* p) {
    int bytesPerSector = p[11] + (p[12]<<8);
    int root = bytesPerSector * 19;
     while(p[root] != 0){
        if(p[root + 8 + 3] == 8)
            return p + root;
        p += 32;
    }
    return "Could not find volume label";
}

//get free space avalible on disk
int getFreeSize(int diskSize, char* p){
    int freeSize = 0;
    int fatVal = 0x001;
    for(int i = 0; i < (p[19] + (p[20]<<8)); i++){
        fatVal = getFatEntry(i,p);
        if(fatVal == 0x00) freeSize++;
    }
    return freeSize * 512;
}

//return fat entry
int getFatEntry(int n, char* p) {
    int left, right;

    left = p[(SECTOR_SIZE + (3 * n / 2))];
    right = p[(SECTOR_SIZE + (1 + 3 * n / 2))];

    if (n%2 == 0){
        return ((left) + ((right & 0x0f)<< 8));
    }else{
        return (((left & 0xf0) >> 4)) + (right << 4);
    }
}

//set fat entry in put
void setFatEntry(int n, int value, char* p){
	p += SECTOR_SIZE;

    n = (3 * value / 2);

    if (value % 2 == 0) {
        p[SECTOR_SIZE + n + 1] = (value >> 8) & 0x0F;
        p[SECTOR_SIZE + n] = value & 0xFF;
    } else {
        p[SECTOR_SIZE + n] = (value << 4) & 0xF0;
        p[SECTOR_SIZE + n + 1] = (value >> 4) & 0xFF;
    }
}

//return free space 
int getNextFatFree(char *p){
	p += SECTOR_SIZE;

	int n = 2;
	while(getFatEntry(n,p)){
		n++;
	}
	return n;
}

//get file size for file in root only
int fileSize(char* name, char* p) {
    while (p[0] != 0x00) {
        if ((p[11] & 0x02) == 0x00 && (p[11] & 0x08) == 0) {
            int i;

            char* fileName = malloc(sizeof(char));
            char* fileExtension = malloc(sizeof(char));
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
		    strncat(fileName, ".", 1);
		    strncat(fileName, fileExtension, 3);

            if (strncmp(name, fileName, 24) == 0) {
                int size = p[28] & 0xFF;
                size += (p[29] & 0xFF) << 8;
                size += (p[30] & 0xFF << 16);
                size += (p[31] & 0xFF) << 24;
                return size;
            }

        }
        p += 32;
    }
    return 0;
}

//return firt logical sector
int firstSector(char* name, char* p) {
    while (p[0] != 0x00) {
        if ((p[11] & 0x02) == 0x00 && (p[11] & 0x08) == 0) {
            int i;

            char* fileName = malloc(sizeof(char));
            char* fileExtension = malloc(sizeof(char));

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
		    strncat(fileName, ".", 1);
		    strncat(fileName, fileExtension, 3);

            if (strncmp(name, fileName, 24) == 0){
            	return p[26] + (p[27] << 8);
            }

        }
        p += 32;
    }
    return -1;
}
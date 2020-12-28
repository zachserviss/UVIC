/*
    CSC 360 Assignment 2
	By: Zach Serviss
	V00950002
*/
#define SECTOR_SIZE 512

int getFreeSize(int diskSize, char* p);
int getFatEntry(int n, char* p);
char *getVolumeLabel(char* p);
void setFatEntry(int n, int value, char* p);
int getNextFatFree(char *p);
int fileSize(char* name, char* p);
int firstSector(char* name, char* p);
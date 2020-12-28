#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>

/*
Concordance program to read in two files.

Created by Zach Serviss

Feb 12th 2020
*/

/*
Some code has made use of examples used in
lecture by Michael Zastre SENG 265
*/



#define MAX_IN_DOC_LINES 100
#define MAX_IN_LINE_LENGTH 80
#define MAX_WORD_LENGTH 20
#define MAX_IN_DOC_WORDS 500
#define MAX_EXCEPT 100

char cpy_buffer[MAX_IN_DOC_LINES][MAX_IN_LINE_LENGTH];
char lines[MAX_IN_DOC_LINES][MAX_IN_LINE_LENGTH];
char words[MAX_IN_DOC_WORDS][MAX_WORD_LENGTH];
char excluded_chars[MAX_IN_LINE_LENGTH][MAX_IN_DOC_WORDS];
char unique_words[MAX_IN_DOC_WORDS][MAX_WORD_LENGTH];

int num_words =0;
int num_lines =0;

int  strcmp_wrapper(const void *, const void *);
void tokenize_line(char *);
int longest_word(char str[][20],int n);
int isdelimiter(char ch);
void input_2d(FILE *input);
int exclude_2d(FILE *exclude);
int unique();



int main(int argc, char *argv[]){

	FILE *exclude;
	FILE *input;
	int exclude_tot = 0;

  for (int i = 1; i < argc; i++) {
      if (strcmp(argv[i], "-e") == 0) {
          exclude = fopen(argv[i+1],"r");
          i++;
      }else{
				input = fopen(argv[i],"r");
			}
  }
	fseek(input, 0L, SEEK_END);
	long int res = ftell(input);
	fseek(input, 0L, SEEK_SET);
	if (res==0) {
		return 0;
	}


	if(input!= NULL){
		input_2d(input);
	}
	if(exclude!=NULL){
		exclude_tot = exclude_2d(exclude);
	}else{
		exclude_tot=0;
	}

	int unique_index = unique(exclude_tot);
	int longest = longest_word(unique_words,unique_index);

	for (size_t i = 0; i < unique_index; i++) {
		int j=0;
		for (j=0;j < num_lines+1;j++) {
			int total = 0;
			char *pch = cpy_buffer[j];
			size_t len = strlen(unique_words[i]);
			while ((pch=strstr(pch, unique_words[i]))!= NULL){
				if (isdelimiter(pch[-1]) && isdelimiter(pch[len])){
					pch += len;
					total++;
				}else{
					pch++;
				}
			}
			if (total > 0) {
				/*upper case all words*/
			  char *s = unique_words[i];
			  while (*s) {
			    *s = toupper((unsigned char) *s);
			    s++;
			  }
				int formatting_length = ((longest-strlen(unique_words[i]))+2);
				if (total > 1) {
					printf("%s", unique_words[i]);
					printf("%*s%s ", formatting_length, "",cpy_buffer[j]);
					printf("(%d*)\n", j);
				}else{
					printf("%s", unique_words[i]);
					printf("%*s%s ", formatting_length, "",cpy_buffer[j]);
					printf("(%d)\n", j);
				}
					/*format back to lower*/
					s = unique_words[i];
					while (*s) {
				    *s = tolower((unsigned char) *s);
				    s++;
				  }
			}
		}
	}
  return 0;
}


int exclude_2d(FILE *exclude){
	int exclude_tot;
	int i = 0;
	while(fgets(excluded_chars[i], MAX_IN_LINE_LENGTH, exclude)){
		excluded_chars[i][strlen(excluded_chars[i])-1] = '\0';
    i++;
  }
	exclude_tot = i;

	fclose(exclude);
	return exclude_tot;
}

int unique(int exclude_tot){
	int unique_index = 0;
	int ret;
	for (size_t i = 0; i < num_words; i++) {
		int matches = 0;
		for (size_t j = 0; j < exclude_tot; j++) {
			ret = strncmp(words[i],excluded_chars[j],MAX_WORD_LENGTH);
			if (ret == 0) {
				matches++;
			}
		}if(matches == 0){
			strncpy(unique_words[unique_index], words[i], MAX_WORD_LENGTH);
			unique_index++;
		}
	}
	/*delete duplicates of unique words*/
	for (int i = 0; i < unique_index; i ++){
	    int j = i + 1;
	    while (j < unique_index){
	        if (strcmp(unique_words[i], unique_words[j]) == 0){
	            memmove(unique_words + j, unique_words + (unique_index - 1), sizeof(unique_words[0]));
	            -- unique_index;
	        }
	        else
	            ++ j;
	    }
	}
	qsort(unique_words, unique_index, MAX_WORD_LENGTH*sizeof(char),strcmp_wrapper);
	return unique_index;
}

void input_2d(FILE *input){
	char buffer[MAX_IN_LINE_LENGTH];
	char lines[MAX_IN_DOC_LINES][MAX_IN_LINE_LENGTH];


	while(fgets(buffer, sizeof(buffer)+1, input)){
		if (buffer[strlen(buffer)-1] =='\n') {
			buffer[strlen(buffer)-1] ='\0';
		}
		num_lines++;
		strncpy(cpy_buffer[num_lines],buffer,MAX_IN_LINE_LENGTH);
  }
	for (size_t i = 0; i < num_lines; i++) {
		strncpy(lines[i], cpy_buffer[i+1], MAX_IN_LINE_LENGTH);
		tokenize_line(lines[i]);
	}
	fclose(input);
	return;
}

int strcmp_wrapper(const void *a, const void *b) {
    char *sa = (char *)a;
    char *sb = (char *)b;

    return(strcmp(sa, sb));
}
void tokenize_line(char *input_line){
		char *t;
		t = strtok(input_line, " ");
		while (t && num_words < MAX_IN_DOC_WORDS) {
			strncpy(words[num_words],t,MAX_WORD_LENGTH);
			num_words++;
			t=strtok(NULL, " ");
		}
		return;
}
int longest_word(char str[MAX_IN_DOC_WORDS][MAX_WORD_LENGTH],int n){
		int i,Max,len1,c;
		Max=strlen(str[0]);
		for(i=1;i<n;i++)
		{
		len1=strlen(str[i]);
		if(len1>Max)
		{
			c=i;
			Max=len1;
		}
	}
	return strlen(str[c]);
}

int isdelimiter(char ch) {
  return (ch == ' ') || (ch == '\0');
}

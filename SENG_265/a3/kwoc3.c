/*
 * kwoc3.c
 *
 * Starter file provided to students for Assignment #3, SENG 265,
 * Spring 2020
 *
 */

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "emalloc.h"
#include "listy.h"
#include <stddef.h>
#include <sys/types.h>

#define MAX_WORD_LENGTH 40
#define MAX_LINE_LENGTH 100

node_t* input_to_line(char *);
node_t* tokenize_words(node_t *lines);
node_t* unique_word_finder(node_t *include, node_t *exclude);
int compare(node_t* a, node_t* b);
void swap(node_t *a, node_t *b);
int longest_word(node_t* list);
void print_concordance(node_t *unique_words, node_t *cpy_include_line, int longest, int total, int line_num);
int isdelimiter(char ch);
node_t* delete_duplicates(node_t* unique_words);
node_t* sort(node_t* unique_words);
void pre_printing_process(node_t *unique_words, node_t *include_line, int longest);

int main(int argc, char *argv[]){
    char *exception_file = NULL;
    char *input_file = NULL;
    node_t *include_line = NULL;
    node_t *include_words = NULL;
    node_t *exclude_line = NULL;
    node_t *exclude_words = NULL;
    node_t *unique_words = NULL;
    int longest = 0;

    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "-e") == 0) {
            exception_file = argv[i+1];
            i++;
        }else{
          input_file = argv[i];
        }
    }

    if (input_file!=NULL) {
       include_line = input_to_line(input_file);
       include_words = tokenize_words(include_line);
    }else{
       return -1;
    }
    if (exception_file != NULL) {
      exclude_line = input_to_line(exception_file);
      exclude_words = tokenize_words(exclude_line);
    }
    unique_words = unique_word_finder(include_words, exclude_words);
    longest = longest_word(unique_words);
    pre_printing_process(unique_words, include_line, longest);
    free(exclude_line);
    free(exclude_words);
    free(include_line);
    free(include_words);
    free(unique_words);
    return 0;
}

node_t* input_to_line(char *input_file){
  node_t *temp_node = NULL;
  node_t *input_line = NULL;
  FILE *fp;
  char *line = NULL;
  size_t len = 0;
  ssize_t read;
  fp = fopen(input_file, "r");
  if (fp == NULL) {
    exit(1);
  }
  fseek(fp, 0L, SEEK_END);
	long int res = ftell(fp);
	fseek(fp, 0L, SEEK_SET);
	if (res==0) {
		exit(1);
	}
  while ((read = getline(&line, &len, fp)) != -1) {
    if (line[strlen(line)-1] =='\n') {
	line[strlen(line)-1] ='\0';
    }
    temp_node = new_node(line);
    input_line = add_end(input_line, temp_node);
  }
  if (line) {
    free(line);
  }
  fclose(fp);
  return input_line;
}

node_t* tokenize_words(node_t *lines){
  node_t* temp_node = NULL;
  node_t* temp_word_node = NULL;
  node_t* input_word = NULL;
  temp_node = copy(lines);

  while(temp_node){
    char *t;
    t = strtok(temp_node->text, " ");
    while (t) {
      int i = 0;
      while(t[i]){
        t[i] = tolower(t[i]);
        i++;
      }
      temp_word_node = new_node(t);
      input_word = add_end(input_word,temp_word_node);
      t=strtok(NULL, " ");
    }
     temp_node = temp_node->next;
   }
  free(temp_node);
  return input_word;
}

node_t* unique_word_finder(node_t *include, node_t *exclude){
  node_t* unique_words = NULL;
  node_t* temp_node = NULL;
  node_t* include_copy = copy(include);
  int compare_num;
  while (include_copy){
    int matches = 0;
    node_t *exclude_copy = copy(exclude);
    while (exclude_copy != NULL) {
      compare_num = compare(exclude_copy,include_copy);
      if (compare_num == 0) {
        matches++;
      }
      exclude_copy = exclude_copy->next;
    }
    if (matches == 0) {
      temp_node = new_node(include_copy->text);
      unique_words = add_end(unique_words,temp_node);
    }
    free(exclude_copy);
    include_copy = include_copy->next;
  }

  unique_words = delete_duplicates(unique_words);
  unique_words = sort(unique_words);
  free(include_copy);
  return unique_words;
}

node_t* delete_duplicates(node_t* unique_words){
  node_t *current = unique_words;
  node_t *index = NULL;
  node_t *temp = NULL;
/*https://www.javatpoint.com/program-to-remove-duplicate-elements-from-a-singly-linked-list*/
  while(current != NULL){
    temp = current;
    index = current->next;

    while(index) {
      if(compare(current,index)==0){
        temp->next = index->next;
      }else{
        temp = index;
      }
      index = index->next;
    }
    current = current->next;
  }
  return(unique_words);
}

node_t* sort(node_t* unique_words){
  /*https://www.geeksforgeeks.org/c-program-bubble-sort-linked-list/*/
  node_t* swapping_unique = NULL;
  node_t* next_node= NULL;
  int swapped;
  do{
    swapped = 0;
    swapping_unique = unique_words;
    while (swapping_unique->next != next_node){
        int r = compare(swapping_unique,swapping_unique->next);
        if(r > 0){
            swap(swapping_unique, swapping_unique->next);
            swapped = 1;
        }
        swapping_unique = swapping_unique->next;
    }
    next_node = swapping_unique;
  }while(swapped);
  return unique_words;
}

int compare(node_t* a, node_t* b){
  return strncmp(a->text, b->text,MAX_WORD_LENGTH);
}
void swap(node_t *a, node_t *b){
    node_t* temp = new_node(a->text);
    strncpy(a->text,b->text,MAX_WORD_LENGTH);
    strncpy(b->text,temp->text,MAX_WORD_LENGTH);
}

int longest_word(node_t* list){
  int max, len;
  max = strlen(list->text);
  list = list->next;
  while(list){
    len = strlen(list->text);
    if (len>max) {
      max = len;
    }
    list = list->next;
  }
  return max;
}

int isdelimiter(char ch) {
  return (ch == ' ') || (ch == '\0');
}

void pre_printing_process(node_t *unique_words, node_t *include_line, int longest){
  while(unique_words){
    int line_num = 1;
    node_t *cpy_include_line = copy(include_line);
    while (cpy_include_line) {
      int total = 0;
      char entire_line[MAX_LINE_LENGTH];
      int len = strlen(unique_words->text);
      strncpy(entire_line,cpy_include_line->text,MAX_LINE_LENGTH);
      int i = 0;
      while(entire_line[i]){
        entire_line[i] = tolower(entire_line[i]);
        i++;
      }
      char *searchable_line = entire_line;
      while((searchable_line = strstr(searchable_line, unique_words->text))!= NULL){
        if (isdelimiter(searchable_line[-1]) && isdelimiter(searchable_line[len])){
					searchable_line += len;
					total++;
				}else{
					searchable_line++;
				}
      }
      print_concordance(unique_words, cpy_include_line, longest, total, line_num);
      line_num++;
      cpy_include_line = cpy_include_line->next;
    }
    free(cpy_include_line);
    unique_words = unique_words->next;
  }
}

void print_concordance(node_t *unique_words, node_t *cpy_include_line, int longest, int total, int line_num){
  if (total > 0){
    char *s = unique_words->text;
    while (*s){
      *s = toupper((unsigned char) *s);
      s++;
    }
    int formatting_length = ((longest-strlen(unique_words->text))+2);
    if (total > 1) {
      printf("%s", unique_words->text);
			printf("%*s%s ", formatting_length, "",cpy_include_line->text);
			printf("(%d*)\n", line_num);
    }else{
      printf("%s", unique_words->text);
			printf("%*s%s ", formatting_length, "",cpy_include_line->text);
			printf("(%d)\n", line_num);
    }
    s = unique_words->text;
    while (*s) {
      *s = tolower((unsigned char) *s);
      s++;
    }
  }
}

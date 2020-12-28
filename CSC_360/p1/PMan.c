/*
    CSC 360 Assignment 1
	By: Zach Serviss
	V00950002
*/


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>

//node functions
//https://www.tutorialspoint.com/data_structures_algorithms/linked_list_program_in_c.htm
struct node {
    int processID;
    char *name;
    struct node *next;
};

struct node *head = NULL;

void printList() {
    struct node *cur = head;
	char cwd[1024];
    //get current working directory to show full program path
    getcwd(cwd, sizeof(cwd));
    while(cur != NULL) {
        printf("%d: %s/%.*s\n", cur->processID,cwd, 1024,cur->name + 2);
        cur = cur->next;
    }
}

void insertProcess(int processID, char *name) {
    struct node *newNode = (struct node*) malloc(sizeof(struct node));
    newNode->processID = processID;
    newNode->name = malloc(sizeof(name));
    newNode->name = name;
    newNode->next = head;
    head = newNode;
}

struct node* delete(int processID) {
    struct node* cur = head;
    struct node* prev = NULL;  
    if(head == NULL) {
        return NULL;
    }
    while(cur->processID != processID) {
        if(cur->next == NULL) {
            return NULL;
        } else {
            prev = cur;
            cur = cur->next;
        }
    }
    if(cur == head) {
        head = head->next;
    } else {
        prev->next = cur->next;
    }
    return cur;
}

int numProcesses(){
	struct node* cur = head;
	int size = 0;
	while(cur!=NULL){
		size++;
		cur = cur->next;
	}
	return size;
}

//bg processes 
int bg(char *input[]) {
    pid_t pid = fork();                                 
    int processID = pid;
    if (pid == 0) {
        //pass variables after "bg" (bg is input[0])                                                             
        execvp(input[1], &input[1]);
        printf("Error: Failed to start process.\n");    
        exit(1);
    } else if (pid > 0) {                              
        insertProcess(processID, input[1]);
        return 1;                                       
    } else {
        printf("Error: Failed to fork process.\n");
        return 0;
    }
}

void bglist(){
    printList();
    printf("Total background processes: %d\n", numProcesses());
}

void bgkill(int processID){
    if(kill(processID, SIGKILL) != 0) {
        printf("Error: Failed to kill process %d\n", processID);  
    }
    delete(processID);
}

void bgstop(int processID){
    if(kill(processID, SIGSTOP) != 0) {
		printf("Error: Failed to stop process %d\n", processID);                            
    }    
}

void bgstart(int processID){
    if(kill(processID, SIGCONT) != 0) {    
		printf("Error: Failed to start process %d\n", processID);                            
    }
}

void pstat(int processID){
    //make space for variables
    char *line = malloc(1024);
    char *statPath = malloc(64);
    char *statusPath = malloc(64);
    //concatinate to get correct file path
    sprintf(statPath, "/proc/%d/stat", processID);    
    sprintf(statusPath, "/proc/%d/status", processID);
    //open file paths
    FILE* stat = fopen(statPath, "r");                   
    FILE* status = fopen(statusPath, "r");

    if (stat && status) {                      
        fgets(line, 1024, stat);                       
        int i = 1;
        //tokenize line to get each value from stat
        //indexes of each wanted value in stat spec pdf                               
        char *tok = strtok(line, " ");
        while (tok != NULL) {                         
            if (i == 2) {
            	printf("comm: %s\n", tok); 
            }else if (i == 3) {
            	printf("state: %s\n", tok);    
            }else if (i == 14) {
            	printf("utime: %ld\n", atoi(tok)/sysconf(_SC_CLK_TCK));
            }else if (i == 15) {
            	printf("stime: %ld\n", atoi(tok)/sysconf(_SC_CLK_TCK));
            }else if (i == 24) {
                printf("rss: %s\n", tok);
                break;
            }
            tok = strtok(NULL, " ");
            i++;
        }
        i=0;
        while(fgets(line, 1024, status)) {       
            //non and voluntary ctxt switches on line 35 and 36
            if(i==35) {    
                printf("%s", line);
            } else if(i==36) {
                printf("%s", line);
            }
            i++;
        }
        //close files
        fclose(stat);                                 
        fclose(status);
    } else {
        printf("Error: Process %d does not exist\n", processID); 
    }
    free(line);
    free(statPath);
    free(statusPath);
}
//check for zombie processes 
//taken from examples in tutorial
void checkZombieProcess() {
    int status;
	int retVal = 0;
	
	while(1) {
		usleep(1000);
		if(head == NULL){
			return ;
		}
		retVal = waitpid(-1, &status, WNOHANG);
		if(retVal > 0) {
			delete(retVal);
		}
		else if(retVal == 0){
			break;
		}
		else{
			perror("waitpid failed");
			exit(EXIT_FAILURE);
		}
	}
	return ;

}

void inputError() {  
    printf("\tCommand not found, please enter:\n\tbg [program] (run program)\n\tbglist (list all background processes)\n\tbgkill [pid] (end program)\n\tbgstop [pid] (pause program)\n\tbgstart [pid] (restart program)\n\tpstat [pid] (more details on a running program)\n");
}

int main(int argc, char* argv[]) {
    while (1) {
        printf("PMan: >");                              
        //create space for input variables 
        char *userInput = malloc(512);                  
        char *input[1024];
        //store user input in variable
        fgets(userInput, 4096, stdin);
        //strtok to break up user input
        char *tok = strtok(userInput, " \n");
        if (tok !=NULL){
            int i = 0;
            while(tok != NULL) {
                input[i] = tok;
                tok = strtok(NULL, " \n");
                i++;
            }
            //check first word input to go to correct function
            if (strncmp(input[0], "bg",3) == 0){ 
                bg(input);
            //exit if user wants to exit
            }else if(strncmp(input[0], "exit", 5) == 0){
                exit(1);
            }else if (strncmp(input[0], "bglist", 7) == 0) {
                //check for zombies before printing
                checkZombieProcess();                           
                bglist();
            }else if (strncmp(input[0], "bgkill", 7) == 0){
                bgkill(atoi(input[1]));
            }else if (strncmp(input[0], "bgstop", 7) == 0){
                bgstop(atoi(input[1]));
            }else if (strncmp(input[0], "bgstart", 8) == 0){
                bgstart(atoi(input[1]));
            }else if (strncmp(input[0], "pstat", 6) == 0){
                pstat(atoi(input[1]));
            }else {
                inputError();
            }
            checkZombieProcess(); 
        }else{
            inputError();
        }                       
    }
    return 0;
}
/*
    CSC 360 Assignment 2
	By: Zach Serviss
	V00950002
*/

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <pthread.h>
#include <sys/time.h>

//number of clerks can be changed here if needed
#define CLERKS 6

//customer def
typedef struct customer{ 
    int userID;
	int classType; 
	int serviceTime;
	int arrivalTime;
	int index; 
	int clerk; 
	float waitStart;	
	float waitEnd;			
}customer;

//clerk def
typedef struct clerk{		
	int clerkID;					
	int busy;			
}clerk;

//globals 

//total customers
customer* customers;
//queues (0 = econ, 1 = business)		
customer* queue[2];
//total clerks			
clerk clerks[CLERKS];
//queue lengths (0 = econ, 1 = business)			
int queueLength[2] = {0,0};
//wait times (0 = econ, 1 = business)	
float waitTime[2] = {0,0};
//total line lengths (0 = econ, 1 = business, 2 = total customers)	
int lineLength[3] = {0,0,0};
struct timeval programStart;

//mutex & convars
pthread_mutex_t mutex[CLERKS+1];
//0= queue
//1= clerk 1
//etc.
pthread_cond_t convar[CLERKS+2];
//0= econ
//1= buiness
//2= clerk 1
//3= clerk 2
//4= clerk 3
//5= clerk 4

//insert customer into queue(buiness or econ)
void insertQueue(customer* p, int k){
	queue[k][queueLength[k]] = *p;
	queueLength[k]++;
}

//pop customer from queue(buiness or econ)
int popQueue(int k){
	int customerIndex = queue[k][0].index;
	for(int i = 0; i < queueLength[k]-1; i++){
		queue[k][i] = queue[k][i+1];
	}
	queueLength[k]--;
	return customerIndex;
}

//get current machine time
float getTime(){
	struct timeval programNow;
	gettimeofday(&programNow, NULL);
	return (programNow.tv_sec - programStart.tv_sec) + (programNow.tv_usec - programStart.tv_usec)/1000000.0f;
}

// function entry for customer threads
void * customer_entry(void * cus_info){
	struct customer* p = (customer*) cus_info;
	usleep(p->arrivalTime * 100000);
	printf("A customer arrives: customer ID %2d.\n", p->userID);
	//lock queue
	pthread_mutex_lock(&mutex[0]);
	//insert customer to correct queue
	insertQueue(p, p->classType);
	printf("A customer enters a queue: the queue ID %1d, and length of the queue %2d.\n", p->classType, queueLength[p->classType]);
	p->waitStart = getTime();
	//wait until customer can be pickup by clerk
	while(p->clerk == -1){
		//wait for clerk to broadcast to buisness first, then econ
		pthread_cond_wait(&convar[p->classType], &mutex[0]);
	}
	p->waitEnd = getTime();
	waitTime[p->classType] += p->waitEnd - p->waitStart;
	printf("A clerk starts serving a customer: start time %.2f, the customer ID %2d, the clerk ID %1d.\n", p->waitEnd, p->userID, p->clerk);
	//customer has been picked up by clerk, unlock queue
	pthread_mutex_unlock(&mutex[0]);
	usleep(p->serviceTime * 100000);
	printf("A clerk finishes serving a customer: end time %.2f, the customer ID %2d, the clerk ID %1d.\n", getTime(), p->userID, p->clerk);
	//signal to clerk customer is done
	int clerk = p->clerk;
	clerks[clerk-1].busy = 0;
	pthread_cond_signal(&convar[clerk+1]);
	pthread_exit(NULL);
	return NULL;
}

// function entry for clerk threads
void *clerk_entry(void * clerkNum){
	clerk* p =  (clerk*) clerkNum;
	while(1){
		//lock the queue
		pthread_mutex_lock(&mutex[0]);
		int queueIndex = 1;
		if(queueLength[queueIndex] <= 0){
			queueIndex = 0;
		}
		if(queueLength[queueIndex] > 0){
			//grab first customer in queue (business first)
			int customerIndex = popQueue(queueIndex);
			customers[customerIndex].clerk = p->clerkID;
			clerks[p->clerkID-1].busy = 1;
			//broadcast to business/econ queue
			pthread_cond_broadcast(&convar[queueIndex]);
			pthread_mutex_unlock(&mutex[0]);
		}else{
			//unlock queue
			pthread_mutex_unlock(&mutex[0]);
			usleep(100);
		}
		pthread_mutex_lock(&mutex[p->clerkID]);
		//wait for clerk to finish up
		if(clerks[p->clerkID-1].busy){
			pthread_cond_wait(&convar[p->clerkID+1], &mutex[p->clerkID]);
		}
		pthread_mutex_unlock(&mutex[p->clerkID]);
	}
	pthread_exit(NULL);
	return NULL;
}

//get customers from input file
void getCustomers(char* file){
	FILE* f = fopen(file, "r");
	//check for errors in txt file
	if(f == NULL || fscanf(f, "%d", &lineLength[2]) < 1){
		printf("Error: failed to read file\n");
		exit(1);
	}
	if(lineLength[2] < 1){
		printf("Error: no customers.\n");
		exit(1);
	}
	//allocate enough space for queues and customer lists
	queue[0] = (customer*) malloc(lineLength[2] * sizeof(customer));
	queue[1] = (customer*) malloc(lineLength[2] * sizeof(customer));
	customers = (customer*) malloc(lineLength[2] * sizeof(customer));
	//n is the real count of customers incase of bad customer info
	int i;
	int n = 0;
	customer p;
	for(i = 0; i < lineLength[2]; i++){
		if(fscanf(f, "%d:%d,%d,%d", &p.userID, &p.classType, &p.arrivalTime, &p.serviceTime) != 4){
			printf("Error: missing customer values. (skipping cusotmer)\n");
			continue;
		}
		if(p.userID < 0 || p.classType < 0 || p.classType > 1 || p.arrivalTime < 0 || p.serviceTime < 0){
			printf("Error: wrong customer values. (skipping customer)\n");
			continue;
		}
		p.index = n;
		p.clerk = -1;
		customers[n] = p;
		n++;
		lineLength[p.classType]++;
	}
	//set total number of customers to correct value
	lineLength[2] = n;
	fclose(f);
}

int main(int argc, char* argv[]) {
	if(argc != 2){
		printf("Error: invalid number of arguments, only accecpts: ./ACS 'file name'.txt\n");
		exit(1);
	}
	getCustomers(argv[1]);
	//start time after grabbing customer data
	gettimeofday(&programStart, NULL);
	
	int i;
	//set clerks and init mutexs and convars
	for(i = 0; i < CLERKS+2; i++){
		if(i < CLERKS){
			clerks[i].clerkID = i+1;
			clerks[i].busy = 0;
		}
		if(i < CLERKS+1){
			pthread_mutex_init(&mutex[i], NULL);
		}
		pthread_cond_init(&convar[i], NULL);
	}
	//create clerk threads
	pthread_t clerkThread;
	for(i = 0; i < CLERKS; i++){
		pthread_create(&clerkThread, NULL, clerk_entry,&clerks[i]);
	}
	//create customer threads
	pthread_t customerThread[lineLength[2]];
	for(i = 0; i < lineLength[2]; i++){
		pthread_create(&customerThread[i], NULL, customer_entry,&customers[i]);
	}
	//join threads to start the processing 
	for(i = 0; i < lineLength[2]; i++){
		pthread_join(customerThread[i], NULL);
	}
	//destroy mutex and convars
	for(i = 0; i < CLERKS+2; i++){
		if(i < CLERKS+1){
			pthread_mutex_destroy(&mutex[i]);
		}
		pthread_cond_destroy(&convar[i]);
	}
	printf("The average waiting time for all customers in the system is: %.2f seconds.\n", (waitTime[0]+waitTime[1])/lineLength[2]);
	printf("The average waiting time for all business-class customers is: %.2f seconds.\n", waitTime[1]/lineLength[1]);
	printf("The average waiting time for all economy-class customers is: %.2f seocnds.\n", waitTime[0]/lineLength[0]);
	free(customers);
	free(queue[0]);
	free(queue[1]);
	return 0;
}

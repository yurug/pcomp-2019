#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int count(char c, char* word){
	int i,count=0;
	for (i = 0; i < strlen(word); i++){
		if(c==word[i])
			count++;
	}
	return count;
}
int compareWords(char* w1, char* w2){
	int i;
	for(i = 0; i < strlen(w1); i++){
		if(count(w1[i],w1)!=count(w1[i],w2)) 
			return 0;
	}
	return 1;
}
void findWord(char* word, FILE * f){
	char * line = NULL;
    size_t len = 0;
    ssize_t read;
	while((read = getline(&line, &len, f)) != -1){
		if(strlen(word)==strlen(line)-1 && compareWords(word,line)==1) 
			printf("%s\n",line);
	}
}

int main(int size, char * args[]){
	FILE * f = fopen(args[1], "r");
	int i;
	for(i=2; i<size; i++){
		printf("%s:\n",args[i]);
		findWord(args[i], f);
		fseek(f,0, SEEK_SET); 
	}

}
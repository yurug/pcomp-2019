#include <stdio.h>
#include <pthread.h> 
  
#define MAX 16 
#define THREAD_MAX 4

/** Code d'exemple trouvé sur
    https://www.geeksforgeeks.org/linear-search-using-multi-threading/
    Le traduire en Rust.
**/
 
int a[MAX] = { 1, 5, 7, 10, 12, 14, 15, 
               18, 20, 22, 25, 27, 30, 
               64, 110, 202 }; 
int key = 202; 
  
int found = 0; 
  
int current_thread = 0 ;

pthread_mutex_t m1 = PTHREAD_MUTEX_INITIALIZER ;
pthread_mutex_t m2 = PTHREAD_MUTEX_INITIALIZER ;
  
void* thread_search(void* args) {
  pthread_mutex_lock(&m1) ;
  int num = current_thread++ ;
  pthread_mutex_unlock(&m1) ;
  
  for (int i = num * (MAX / 4); i < ((num + 1) * (MAX / 4)); i++) { 
    if (a[i] == key) {
      pthread_mutex_lock(&m2) ;
      found = 1;
      pthread_mutex_unlock(&m2) ;
    }
  } 
} 
  
int main() { 
  pthread_t thread[THREAD_MAX]; 
  
  for (int i = 0; i < THREAD_MAX; i++) { 
    pthread_create(&thread[i], NULL, thread_search, NULL); 
  } 
  
  for (int i = 0; i < THREAD_MAX; i++) { 
    pthread_join(thread[i], NULL); 
  } 
  
  if (found == 1) 
    printf("Key element found\n") ;
  else
    printf("Key not present\n") ;

  return 0; 
} 

#include <stdlib.h>
#include <string.h>

int main(int argc, char** argv)
{
  char cmd[1024];

  strcpy(cmd, "scala Anagram");

  for(int i = 1; i < argc; i++) {
    strcat(cmd, " ");
    strcat(cmd, argv[i]);
  }

  system(cmd);
  
  return EXIT_SUCCESS;
}

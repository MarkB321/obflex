
#include "scan.h"
#include <stdio.h>

FILE * g_f_objc;
char g_objc_name[520];

int main(void) {
int pair_count=0;
   printf("hello\n");
   while (
         (pair_count < 50)
          &&
         (1 == get_next_file(&g_f_objc, g_objc_name))
         )
     {
     fprintf(stderr, "TEST[%d]%s\n", pair_count, g_objc_name);
     pair_count++;
     }
}


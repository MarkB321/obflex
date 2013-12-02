
#include <unistd.h>
#include <stdio.h>
#include <dirent.h>
#include <string.h>
#include <sys/stat.h>

static char g_path[2048] = "";
static int g_length = 0;

void printdir(char *dir, int depth, int lenadded)
{
    DIR *dp;
    struct dirent *entry;
    struct stat statbuf;
    int spaces = depth*2;

    strcat(g_path, dir);
    strcat(g_path, "/");
    g_length += lenadded + 1;

printf("G_PATH %s\n", g_path);

    if((dp = opendir(dir)) == NULL) {
        fprintf(stderr,"cannot open directory: %s\n", dir);
        return;
    }
    chdir(dir);
    while((entry = readdir(dp)) != NULL) {
        lstat(entry->d_name,&statbuf);
        if(S_ISDIR(statbuf.st_mode)) {
            /* Found a directory, but ignore . and .. */
            if(strcmp(".",entry->d_name) == 0 || 
                strcmp("..",entry->d_name) == 0)
                continue;
            printf("DIR %*s%s/\n",spaces,"",entry->d_name);
            /* Recurse at a new indent level */
            printdir(entry->d_name,depth+1, strlen(entry->d_name));
        }
        else {
            printf("FILE %s\n",entry->d_name);
            printf("FILE2 %s%s\n",g_path,entry->d_name);
        }
    }
    chdir("..");
    closedir(dp);
    g_length -= (lenadded + 1);
    g_path[g_length] = '\0';
}

/*  Now we move onto the main function.  */

int main(int argc, char* argv[])
{
    char *topdir;
    if (argc != 2)
        topdir = ".";
    else
        topdir = argv[1];

    printf("Directory scan of %s\n",topdir);
    printdir(topdir,0, strlen(topdir));
    return 0;
}


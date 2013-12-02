
#include <stddef.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <dirent.h>
#include <stdlib.h>
#include <string.h>
#include "scan.h"

#define DNO 150
#define FNO 4096

#define RDT_C 0
#define RDT_PC 1

static char g_path[2048] = "";
static int g_length = 0;

static char g_repo[500];
static char g_filelist[FNO][160];
static char g_objc_name[FNO][160];
static g_num_files;

void parse_dir(char *dir, int depth, int lenadded);

int getrepo()
{
char* repo;
int ret;
  repo = getenv("REPO");
  ret = 0;
  if (NULL != repo)
    {
    strcpy(g_repo, repo);
    ret = 1;
    }
  return(ret);
}

int init_scan_top_level (void)
{
  DIR *dir_ptr;
  struct dirent *entry_pointer;
  int len;

  if (getrepo())
    {
    parse_dir(g_repo, 0, strlen(g_repo));
    }
  else
    {
    perror ("could not determine DCS env var setting");
    }
  return 0;
}

int get_next_file(FILE** objc_file, char* rdt_name)
{
static file_count = 0;
static first_time = 1;
int ret;
  if (1 == first_time)
    {
    g_num_files = 0;
    init_scan_top_level();
    first_time = 0;
    }
  ret = 0;
  if (*objc_file != NULL)
    {
    fclose(*objc_file);
    }
  if (file_count < g_num_files)
    {
    strcpy(rdt_name,
           &g_objc_name[file_count][0]);
    *objc_file = fopen(rdt_name,
                  "r");
    file_count++;
    ret = 1;
    }
  return(ret);
}

void parse_dir(char *dir, int depth, int lenadded)
{
    int len;
    DIR *dp;
    struct dirent *entry;
    struct stat statbuf;
    int spaces = depth*2;

    strcat(g_path, dir);
    strcat(g_path, "/");
    g_length += lenadded + 1;

/******************
printf("G_PATH %s\n", g_path);
*******************/

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
/********************
            printf("DIR %*s%s/\n",spaces,"",entry->d_name);
*******************/
            /* Recurse at a new indent level */
            parse_dir(entry->d_name,depth+1, strlen(entry->d_name));
        }
        else {
/********************
            printf("FILE %s\n",entry->d_name);
*******************/
/********************
            printf("FILE2 %s%s\n",g_path,entry->d_name);
*******************/

            len = strlen(entry->d_name);

            if ( ( (entry->d_name[len-2] == '.') && (entry->d_name[len-1] == 'm'))) {
              strcpy(
                 &g_objc_name[g_num_files][0],
                 g_path
                  );
              strcat(
                 &g_objc_name[g_num_files][0],
                 entry->d_name
                  );
              g_num_files++;
           }
        }
    }
    chdir("..");
    closedir(dp);
    g_length -= (lenadded + 1);
    g_path[g_length] = '\0';
}


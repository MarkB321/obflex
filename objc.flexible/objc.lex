
%{
/*****************
#include "hash/hashtbl.h"
*****************/

FILE * g_f_objc_in;
FILE * g_f_objc_out;
char g_objc_name[520];

int g_round_brackets = 0;
int g_cond_arr[100];
int g_condition_count = 0;
int g_instrument = 0;

#define PUSH 1
#define POP 2
%}

WHITE_CHAR [ \t\n]
VARNAME    [0-9a-zA-Z_]
GENERAL    [^ \t\n]

/*
Exclusive start condition identifiers ....
*/
%x c_comment round_brackets cpp_comment hat_hash double_quotes ifkeyword elsekeyword

/*
If you see "push_condition_and_print_with_font" then we can climb out of that condition into another one
(so for example - we don't push from a cpp or c style comment).
*/
%%

"{" {
  fprintf(stdout,  "%s", yytext);
  fprintf(stdout,  "\nNSLog(@\"INSTRUMENT \%d \");", g_instrument);
  fprintf(g_f_objc_out,  "%s", yytext);
  fprintf(g_f_objc_out,  "\nNSLog(@\"INSTRUMENT \%d \");", g_instrument++);
}

"(" {
  g_round_brackets++;
  push_condition_and_print_with_font(round_brackets, 1, 1);
}
"/*" {
  push_condition_and_print_with_font(c_comment, 1, 1);
}
"//" {
  push_condition_and_print_with_font(cpp_comment, 1, 1);
}
^"#" {
  push_condition_and_print_with_font(hat_hash, 1, 1);
}
\" {
  push_condition_and_print_with_font(double_quotes, 1, 1);
}

<c_comment>[^*\n]* {
         fprintf(stdout,  "%s", yytext);
         fprintf(g_f_objc_out,  "%s", yytext);
         }
<c_comment>"*"+[^*/\n]* {
         fprintf(stdout,  "%s", yytext);
         fprintf(g_f_objc_out,  "%s", yytext);
         }
<c_comment>"*"+"/" {
         pop_condition(1, 1);
         }

<cpp_comment>"*"+[^*/\n]* {
         fprintf(stdout,  "%s", yytext);
         fprintf(g_f_objc_out,  "%s", yytext);
         }
<cpp_comment>"\n" {
         pop_condition(1, 1);
         }
<cpp_comment>[^*\n]* {
         fprintf(stdout,  "%s", yytext);
         fprintf(g_f_objc_out,  "%s", yytext);
         }

<hat_hash>"*"+[^*/\n]* {
         fprintf(stdout,  "%s", yytext);
         fprintf(g_f_objc_out,  "%s", yytext);
         }
<hat_hash>"\n" {
         pop_condition(1, 1);
         }
<hat_hash>[^*\n]* {
         fprintf(stdout,  "%s", yytext);
         fprintf(g_f_objc_out,  "%s", yytext);
         }

<round_brackets>"(" {
  g_round_brackets++;
  fprintf(stdout,  "%s", yytext);
  fprintf(g_f_objc_out,  "%s", yytext);
}
<round_brackets>")" {
  g_round_brackets--;
  if (0 == g_round_brackets) {
    pop_condition(1, 1);
  }
  else {
    fprintf(stdout,  "%s", yytext);
    fprintf(g_f_objc_out,  "%s", yytext);
  }
}
<round_brackets>"/*" {
  push_condition_and_print_with_font(c_comment, 1, 1);
}
<round_brackets>"//" {
  push_condition_and_print_with_font(cpp_comment, 1, 1);
}
<round_brackets>\" {
  push_condition_and_print_with_font(double_quotes, 1, 1);
}
<round_brackets>^"#" {
  push_condition_and_print_with_font(hat_hash, 1, 1);
}
<INITIAL,round_brackets>{VARNAME}* {
  if ( ! strcmp(yytext,"if") ) {
    push_condition_and_print_with_font(ifkeyword, 1, 1);
  } else if ( ! strcmp(yytext,"else") ) {
    push_condition_and_print_with_font(elsekeyword, 1, 1);
  } else {
    fprintf(stdout,  "%s", yytext);
    fprintf(g_f_objc_out,  "%s", yytext);
  }
}

<double_quotes>\" {
  pop_condition(1, 1);
}
<ifkeyword,elsekeyword>{WHITE_CHAR}* {
  if (
      (g_cond_arr[g_condition_count-1] == ifkeyword)
       ||
      (g_cond_arr[g_condition_count-1] == elsekeyword)
     ) {
    pop_condition(1, 1);
  }
}
%%

int font_colour(int condition)
{
  switch(condition)
  {
  case round_brackets:
      fprintf(stdout, "<font color=\"red\">");
  break;
  case c_comment:
    fprintf(stdout, "<font color=\"yellow\">");
  break;
  case cpp_comment:
    fprintf(stdout, "<font color=\"yellow\">");
  break;
  case hat_hash:
    fprintf(stdout, "<font color=\"purple\">");
  break;
  case double_quotes:
    fprintf(stdout, "<font color=\"green\">");
  break;
  case ifkeyword:
    fprintf(stdout, "<font color=\"blue\">");
  break;
  case elsekeyword:
    fprintf(stdout, "<font color=\"orange\">");
  break;
  default:
  break;
  }
}

int font_end()
{
  fprintf(stdout, "</font>");
}

int pop_condition(int print, int withFont)
{
  if (print) {
    fprintf(stdout,  "%s", yytext);
    fprintf(g_f_objc_out,  "%s", yytext);
  }

  if (withFont) {
    font_end();
  }

  if (g_condition_count > 0)
  {
    g_condition_count--;
  }

  if (g_condition_count > 0) {
    BEGIN(g_cond_arr[g_condition_count-1]);
  }
  else {
    BEGIN(0);
  }
}

int push_condition_and_print_with_font(int condition, int doPrint, int withFont)
{
  g_cond_arr[g_condition_count] = condition;
  g_condition_count++;

  if (withFont) {
    font_colour(g_cond_arr[g_condition_count-1]);
  }
  BEGIN(g_cond_arr[g_condition_count-1]);
  if (doPrint) {
    fprintf(stdout,  "%s", yytext);
    fprintf(g_f_objc_out,  "%s", yytext);
  }
}

main( argc, argv )
int argc;
char **argv;
{
int objc_count=0;
  ++argv, --argc;  /* skip over program name */
  g_f_objc_in = NULL;

   while (
         (objc_count < 100)
          &&
         (1 == get_next_file(&g_f_objc_in, &g_f_objc_out, g_objc_name))
         )
     {
     fprintf(stderr, "FLEX [%d]%s\n", objc_count, g_objc_name);
     /*
     Let the dog see the rabbit
     */
     yyin = g_f_objc_in;

     fprintf(stdout, "<pre>\n");
     yylex();
     fprintf(stdout, "</pre>\n");

     objc_count++;
     }
}




%option noyywrap nodefault yylineno
%{

#define TABLE_SIZE 65536
typedef struct stack{
  char value[50];
  int top;
} stack;

stack * initstack(){
  stack *s = (stack *)malloc(sizeof(stack));
  s->top = 0;
  s->value[0] = '\0';
  return s;
}

char pop(stack *s){
  char temp = s->value[s->top];
  s->top--;
  return temp;
}

void push(stack *s,char a){
  s->top++;
  s->value[s->top] = a;
}

void print_stack(stack *s){
  int i;
  for ( i=1;i<=s->top;i++)
    printf("%d ",s->value[i]);
  printf("\n");
}

int token[65535];
int nowtoken=0;


typedef struct information{//词的信息
  int id;//token号
  char *filename;//所在文件
  int lineno;//所在行号
  char *original;//原型
} information;


typedef struct node{//结点定义
  int key;
  information * value;
} node;


typedef struct information_table{
  node bucket[TABLE_SIZE];
} information_table;

void init_information_table(information_table *t){
  int i;
  for ( i=0;i<TABLE_SIZE;i++){
    t->bucket[i].key = 0;
    t->bucket[i].value = NULL;
  }
}

int keyToIndex(int key,int i){
  int index,h1,h2;
  h1 = key%TABLE_SIZE;
  h2 = 1+(key%(TABLE_SIZE-1));
  return (h1+h2*i)%TABLE_SIZE;
}

int insert_information_table(information_table *t,int key,information * value){
  if ( t==NULL )
    return -1;
  int i=0,j;
  while ( i<TABLE_SIZE ){
    j = keyToIndex(key,i);
    if ( t->bucket[j].key == 0){
      t->bucket[j].key = key;
      t->bucket[j].value = value;
      return j;
    }
    i++;
  }
  printf("lexical error:the information_table is overflow\n");
  return -1;
}

information * search_information_table(information_table *t,int key){
  if ( t==NULL )
    return NULL;
  int i=0,j;
  while ( i<TABLE_SIZE ){
    j = keyToIndex(key,i);
    if ( t->bucket[j].key == key ){
      return t->bucket[j].value;
    }
    if ( t->bucket[j].key==0 )
      return NULL;
    i++;
  }
  return NULL;
}

int addinformation(int *date,int local_number, int id,char * file_name,int linenumber,char *text,information_table *t){
  date[local_number] = id;
  int i;
  int length = strlen(text);
  information *p = (information *)malloc(sizeof(information));
  if ( p==NULL ) {
    printf("lexical error:RAN malloc error when insert information\n");
    return 0;
  }
  p->original = (char *)malloc(sizeof(char)*(length+1));
  for ( i=0;i<length;i++)
    p->original[i] = text[i];
  p->original[i] = '\0';

  p->id = id;
  p->filename = file_name;
  p->lineno = linenumber;
  int flag;
  flag = insert_information_table(t,local_number,p);
  if ( flag==-1 ){
    printf("lexical error:can not insert information \n");
    return 0;
  }
  else
    return 1;
}

int nowlocal=0;
char *curfilename;
stack *indentstack;
stack *stackrecord;

information_table *t;
char indentation[50];
%}
%%
def                         {
                              nowlocal++;
                              addinformation(token,nowlocal,2,curfilename,yylineno,yytext,t);
                            }
for                         {
                              nowlocal++;
                              addinformation(token,nowlocal,3,curfilename,yylineno,yytext,t);
                            }
while                       {
                              nowlocal++;
                              addinformation(token,nowlocal,4,curfilename,yylineno,yytext,t);
                            }
if                          {
                              nowlocal++;
                              addinformation(token,nowlocal,5,curfilename,yylineno,yytext,t);
                            }
return                      {
                              nowlocal++;
                              addinformation(token,nowlocal,6,curfilename,yylineno,yytext,t);
                            }
break                       {
                              nowlocal++;
                              addinformation(token,nowlocal,7,curfilename,yylineno,yytext,t);
                            }
continue                    {
                              nowlocal++;
                              addinformation(token,nowlocal,8,curfilename,yylineno,yytext,t);
                            }
and                         {
                              nowlocal++;
                              addinformation(token,nowlocal,9,curfilename,yylineno,yytext,t);
                            }
not                         {
                              nowlocal++;
                              addinformation(token,nowlocal,10,curfilename,yylineno,yytext,t);
                            }
or                          {
                              nowlocal++;
                              addinformation(token,nowlocal,11,curfilename,yylineno,yytext,t);
                            }
in                          {
                              nowlocal++;
                              addinformation(token,nowlocal,12,curfilename,yylineno,yytext,t);
                            }
elseif                      {
                              nowlocal++;
                              addinformation(token,nowlocal,13,curfilename,yylineno,yytext,t);
                            }
else                        {
                              nowlocal++;
                              addinformation(token,nowlocal,14,curfilename,yylineno,yytext,t);
                            }
[_a-zA-Z][_a-zA-Z0-9]{0,63} {
                              nowlocal++;
                              addinformation(token,nowlocal,1,curfilename,yylineno,yytext,t);
                              }
"+"                           {nowlocal++;token[nowlocal]=20;}
"-"                           {nowlocal++;token[nowlocal]=21;}
"*"                           {nowlocal++;token[nowlocal]=22;}
"/"                           {nowlocal++;token[nowlocal]=23;}
"%"                           {nowlocal++;token[nowlocal]=24;}
"**"                          {nowlocal++;token[nowlocal]=25;}
"&"                           {nowlocal++;token[nowlocal]=26;}
"|"                           {nowlocal++;token[nowlocal]=27;}
"~"                           {nowlocal++;token[nowlocal]=28;}
"^"                           {nowlocal++;token[nowlocal]=29;}
"("                           {nowlocal++;token[nowlocal]=30;}
")"                           {nowlocal++;token[nowlocal]=31;}
"["                           {nowlocal++;token[nowlocal]=32;}
"]"                           {nowlocal++;token[nowlocal]=33;}
">"                           {nowlocal++;token[nowlocal]=36;}
">="                          {nowlocal++;token[nowlocal]=37;}
"<"                           {nowlocal++;token[nowlocal]=38;}
"<="                          {nowlocal++;token[nowlocal]=39;}
"=="                          {nowlocal++;token[nowlocal]=40;}
"!="                          {nowlocal++;token[nowlocal]=41;}
"<<"                          {nowlocal++;token[nowlocal]=42;}
">>"                          {nowlocal++;token[nowlocal]=43;}
"++"                          {nowlocal++;token[nowlocal]=44;}
"--"                          {nowlocal++;token[nowlocal]=45;}
"="                           {nowlocal++;token[nowlocal]=46;}
"*="                          {nowlocal++;token[nowlocal]=47;}
"/="                          {nowlocal++;token[nowlocal]=48;}
"%="                          {nowlocal++;token[nowlocal]=49;}
"**="                         {nowlocal++;token[nowlocal]=50;}
"+="                          {nowlocal++;token[nowlocal]=51;}
"-="                          {nowlocal++;token[nowlocal]=52;}
"<<="                         {nowlocal++;token[nowlocal]=53;}
">>="                         {nowlocal++;token[nowlocal]=54;}
"&="                          {nowlocal++;token[nowlocal]=55;}
"^="                          {nowlocal++;token[nowlocal]=56;}
"|="                          {nowlocal++;token[nowlocal]=57;}
":"                           {nowlocal++;token[nowlocal]=58;}

\"([^\"\\]|\\['"?\\abfnrtv])*\" {
                              nowlocal++;
                              addinformation(token,nowlocal,80,curfilename,yylineno,yytext,t);
                            }

\'([^\'\\]|\\['"?\\abfnrtv])*\' {
                              nowlocal++;
                              addinformation(token,nowlocal,81,curfilename,yylineno,yytext,t);
                            }
[0-9]|[1-9][0-9]*           {
                              nowlocal++;
                              addinformation(token,nowlocal,85,curfilename,yylineno,yytext,t);
                            }
[0-9]+\.?[0-9]*|[0-9]+\.[0-9]* {
                              nowlocal++;
                              addinformation(token,nowlocal,86,curfilename,yylineno,yytext,t);
                            }
\n                          {//处理缩进，有多种情况，连续\n,\n后加空白字符后继续\n(此情况应该忽略这一行)
                              char c2=*(yy_c_buf_p+1);//\n后面一个字符
                              int s_i=2;
                              int i_=0,k;
                              //while ( c2=='\n' )//此处需要改进，等最后调试时改
                              //  c2 = input();
                              //此时c2肯定不是\n，处理第一种情况
                              while (1){
                                if ( c2=='\t' || c2==' '){
                                  indentation[i_] = c2;
                                  i_++;
                                }
                                else if ( c2=='\n'){
                                  i_=0;//放弃记录的缩进字符
                                }
                                else{
                                  break;//遇见非缩进字符，退出循环
                                }
                                c2 = *(yy_c_buf_p+s_i);
                                s_i++;
                              }

                              for ( k=0;k<i_ && k<indentstack->top;k++){
                                if ( indentation[k] != indentstack->value[k+1] ){
                                  printf("lexical error:indentation error on %d",yylineno);
                                  break;
                                }
                              }

                              while ( i_!= indentstack->top ){
                                if ( i_>indentstack->top ){//高于上一层次,左层次一行最多添加一个，右层次符一行无上限
                                  nowlocal++;
                                  token[nowlocal] = 34;
                                  //将所有剩余字符入栈
                                  push(stackrecord,(char)(i_-k));
                                  for ( ; k<i_ ; k++){
                                    push(indentstack,indentation[k]);
                                  }
                                }
                                else if ( i_<indentstack->top ){//低于上一层次
                                  nowlocal++;
                                  token[nowlocal] = 35;
                                  int sssss=pop(stackrecord);
                                  for ( k=0;k<sssss;k++)
                                    pop(indentstack);
                                }
                              }
                            }
[ \t]                       {;}
.                           {
                              printf("lexical error:found illegality character %s\n",yytext);
                            }
<<EOF>>                     return 0;
%%
int main(int argc,char ** argv)
{
  indentstack = initstack();
  stackrecord = initstack();
  t = (information_table *)malloc(sizeof(information_table));
  if ( t==NULL ) {
    printf("lexical error:information table can't malloc RAN\n");
    return 1;
  }
  init_information_table(t);
  memset (token,0,sizeof(int)*65535);

  if (argc<2)
    return 1;
  curfilename = argv[1];
  yylineno = 1;
  FILE *f = fopen(argv[1],"r");
  yyrestart(f);
  yylex();
  fclose(f);
  int i;
  printf("\nnowlocal:%d\n",nowlocal);

  for ( i=1;i<=nowlocal;i++){
    printf("token[%d]:%d \n",i,token[i]);
    information *p;
    p = search_information_table(t,i);
    if ( p!=NULL ){
      printf("\t%d\t%d\t%s\t%s\n",p->id,p->lineno,p->filename,p->original);
    }
  }
  return 0;
}

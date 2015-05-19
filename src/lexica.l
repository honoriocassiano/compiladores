%{
#include <string>
#include <sstream>

using namespace std;

%}

ESPACO [ \t]
DIGITO [0-9]
LETRA [A-Za-z_]


DELIM {ESPACO}+
NUM {DIGITO}+
REAL {NUM}+("."{NUM}+)?
CHAR \'({LETRA}|{NUM})\'
ID {LETRA}({LETRA}|{NUM})*

%%

"\n"		{
				nlinha++;
			}

"="			{
				yylval.label = yytext;
				return TK_ATR;
			}

{DELIM} 	{}

"main"		{return TK_MAIN;}

"int"		{
				yylval.label = yytext;
				return TK_TIPO_INT;
			}

[(){}[\];,]	{ return *yytext; }

[+\-*/]		{ return *yytext; }

{NUM}		{	
				yylval.traducao = yytext;
				yylval.label = yytext;
				return TK_NUM;
			}

{ID}		{ yylval.label = yytext; return TK_ID; }
.			{ *yytext; }

%%


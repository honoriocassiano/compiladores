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

"begin"		{
				yylval.traducao = yytext;
				yylval.label = yytext;

				return TK_BEGIN;
			}

"end"		{
				yylval.traducao = yytext;
				yylval.label = yytext;

				return TK_END;
			}

{DELIM} 	{}

"main"		{return TK_MAIN;}

"int"		{
				yylval.label = yytext;
				return TK_TIPO_INT;
			}

[(){}[\];,]	{ return *yytext; }

"+"			{
				yylval.traducao = yytext;
				yylval.label = yytext;
				return TK_SOMA;
			}

"-"			{
				yylval.traducao = yytext;
				yylval.label = yytext;
				return TK_SUB;
			}

"*"			{
				yylval.traducao = yytext;
				yylval.label = yytext;
				return TK_MUL;
			}

"/"			{
				yylval.traducao = yytext;
				yylval.label = yytext;
				return TK_DIV;
			}

{NUM}		{	
				yylval.traducao = yytext;
				yylval.label = yytext;
				return TK_NUM;
			}

{ID}		{ yylval.label = yytext; return TK_ID; }
.			{ *yytext; }

%%


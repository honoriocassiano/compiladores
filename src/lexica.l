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

"main"		{
				return TK_MAIN;
			}

"int"		{
				yylval.label = yytext;
				yylval.traducao = "int";
				return TK_TIPO_INT;
			}

"float"		{
				yylval.label = yytext;
				yylval.traducao = "float";
				return TK_TIPO_FLOAT;
			}

"boolean"	{
				yylval.traducao = "int";
				yylval.label = yytext;
				return TK_TIPO_BOOL;
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

"%"			{
				yylval.traducao = yytext;
				yylval.label = yytext;
				return TK_RESTO;
			}

"<"			{
				yylval.traducao = yytext;
				yylval.label = yytext;
				return TK_MENOR;
			}

">"			{
				yylval.traducao = yytext;
				yylval.label = yytext;
				return TK_MAIOR;
			}

"<="		{
				yylval.traducao = yytext;
				yylval.label = yytext;
				return TK_MENOR_IGUAL;
			}

">="		{
				yylval.traducao = yytext;
				yylval.label = yytext;
				return TK_MAIOR_IGUAL;
			}

"=="		{
				yylval.traducao = yytext;
				yylval.label = yytext;
				return TK_IGUAL;
			}

"!="		{
				yylval.traducao = yytext;
				yylval.label = yytext;
				return TK_DIFERENTE;
			}

"and"		{	
				yylval.traducao = "&&";
				yylval.label = yytext;
				return TK_AND;
			}

"or"		{	
				yylval.traducao = "||";
				yylval.label = yytext;
				return TK_OR;
			}

"true"		{	
				yylval.traducao = "1";
				yylval.label = yytext;
				yylval.tipo = "boolean";
				return TK_LOGICO;
			}

"false"		{	
				yylval.traducao = "0";
				yylval.label = yytext;
				yylval.tipo = "boolean";
				return TK_LOGICO;
			}

{NUM}		{	
				yylval.traducao = yytext;
				yylval.label = yytext;
				yylval.tipo = "int";
				return TK_NUM;
			}
{REAL}		{
				yylval.traducao = yytext;
				yylval.label = yytext;
				yylval.tipo = "float";
				return TK_FLOAT;

			}	

{ID}		{ yylval.label = yytext; return TK_ID; }
.			{ *yytext; }

%%


%{
#include <iostream>
#include <string>
#include <fstream>
#include <sstream>
#include <map>

#define YYSTYPE _atributos

using namespace std;

int nlinha = 1;

typedef struct
{
	string label;
	string traducao;
} _atributos;

bool erro = false;

int yylex(void);
void yyerror(string);

typedef struct _info_variavel
{
	string tipo;
	string nome_temp;
	int valor;

} info_variavel;

map<string, info_variavel> mapa_variavel = map<string, info_variavel>();

string geraVariavel();

%}

%token TK_NUM
%token TK_MAIN TK_ID TK_TIPO_INT
%token TK_ATR
%token TK_FIM TK_ERROR

%start S

%left '+' '-'
%left '*' '/'

%%

S 			: TK_TIPO_INT TK_MAIN '(' ')' BLOCO
			{
				//ofstream myfile;
				//myfile.open ("example.c");
				//myfile << "Writing this to a file.\n";
				  //printf(\"Resultado: %d\", " << tipo[contador] << ");\n\t 
				//cout << "$5.traducao";
				//cout << contador << "\n";

				//cout << $5.traducao << "\n\n";

				if(!erro) {
					cout << "/*Compilador FOCA*/\n" << "#include <iostream>\n#include<string.h>\n#include<stdio.h>\nint main(void)\n{\n" << $5.traducao << "\n\treturn 0;\n}" << endl; 
				} 
				//myfile.close();
			}
			;

BLOCO		: '{' COMANDOS '}'
			{
				$$.traducao = $2.traducao;
			}
			;

COMANDOS	: COMANDO ';' COMANDOS {
				$$.traducao = $1.traducao + $3.traducao;
			}
			|
			{
				$$.traducao = "";
				$$.label = "";
			}
			;

COMANDO 	: DECLARACAO
			{
				$$.label = $1.label;
				$$.traducao = $1.traducao;
			}
			;

COMANDO 	: E
			{
				$$.label = $1.label;
				$$.traducao = $1.traducao;
			}
			;

DECLARACAO	: TK_TIPO_INT TK_ID TK_ATR E
			{
				info_variavel atributos = { $1.label, $2.label, atoi($4.label.c_str()) };

				if(mapa_variavel.find($2.label) == mapa_variavel.end()) {
					mapa_variavel[$2.label] = atributos;

					$$.label = atributos.nome_temp;
					$$.traducao = "\t" + $1.label + " " + $2.label + " = " + $4.traducao + ";\n";
				} else {
					cout << "Erro na linha " << nlinha <<": Você já declarou a variável \"" << $2.label << "\", animal!\n\n";

					erro = true;
					//exit(1);
				}
			}
			| TK_TIPO_INT TK_ID
			{
				info_variavel atributos = { $1.label, $2.label, 0 };

				if(mapa_variavel.find($2.label) == mapa_variavel.end()) {
					mapa_variavel[$2.label] = atributos;

					$$.label = atributos.nome_temp;
					$$.traducao = "\t" + $1.label + " " + $2.label + " = " + "0" + ";\n";
				} else {
					cout << "Erro na linha " << nlinha <<": Você já declarou a variável \"" << $2.label << "\", animal!\n\n";

					erro = true;
					//exit(1);
				}
			}
			;

E 			: E '+' E
			{
				$$.traducao = $1.traducao + "+" + $3.traducao;
			}
			| E '-' E
			{
				$$.traducao = $1.traducao + "-" + $3.traducao;
			}
			| E '*' E
			{
				$$.traducao = $1.traducao + "*" + $3.traducao;
			}
			| E '/' E
			{
				$$.traducao = $1.traducao + "/" + $3.traducao;
			}
			| TK_NUM
			{
				$$.label = $1.label;
				$$.traducao = $1.traducao;
			}
			| TK_ID
			{
				if(mapa_variavel.find($1.label) == mapa_variavel.end()) {
					cout << "Erro na linha " << nlinha <<": Que porra de variável \"" << $1.label << "\" é essa?\n\n";

					erro = true;
				}

				$$.label = $1.label;
				$$.traducao = $1.label;
			}
			;

%%

#include "lex.yy.c"

int yyparse();

int contador = 0;

string geraVariavel() {

	stringstream nome;

	nome << "temp" << contador;

	contador++;

	return nome.str();
}

int main( int argc, char* argv[] )
{
	yyparse();

	return 0;
}

void yyerror( string MSG )
{
	cout << MSG << endl;
	exit (0);
}				

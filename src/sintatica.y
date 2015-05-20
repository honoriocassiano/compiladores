%{
#include <iostream>
#include <string>
//#include <fstream>
#include <sstream>
#include <map>

#define YYSTYPE _atributos

using namespace std;

int nlinha = 1;

// Estrutura dos atributos de um token

typedef struct
{
	string label;
	string traducao;
} _atributos;

// Variável que indica se ocorreram erros ao compilar o programa

bool erro = false;

int yylex(void);
void yyerror(string);

// Estrutura de informações de uma variável

typedef struct _info_variavel
{
	string tipo;
	string nome_temp;
	int valor;

} info_variavel;

// Mapa de variáveis

stringstream cabecalho;

map<string, info_variavel> mapa_variavel = map<string, info_variavel>();

// Função para gerar nomes temporários para as variáveis

string gera_variavel_temporaria(string tipo, string nome="");

void adiciona_biblioteca_cabecalho(string nome_biblioteca);

%}

%token TK_NUM
%token TK_MAIN TK_ID TK_TIPO_INT
%token TK_ATR
%token TK_SOMA TK_SUB 
%token TK_MUL TK_DIV
%token TK_BEGIN TK_END
%token TK_FIM TK_ERROR

%start S

%left TK_SOMA TK_SUB
%left TK_MUL TK_DIV

%%

S 			: TK_TIPO_INT TK_MAIN '(' ')' BLOCO_NO_B
			{
				//ofstream myfile;
				//myfile.open ("example.c");
				//myfile << "Writing this to a file.\n";
				//printf(\"Resultado: %d\", " << tipo[contador] << ");\n\t 
				//cout << "$5.traducao";
				//cout << contador << "\n";

				//cout << $5.traducao << "\n\n";

				adiciona_biblioteca_cabecalho("stdio.h");

				if(!erro) {
					//cout << "/*Compilador FOCA*/\n" << "#include <iostream>\n#include<string.h>\n#include<stdio.h>\nint main(void)\n{\n" << $5.traducao << "\n\treturn 0;\n}" << endl; 
					cout << cabecalho.str() << "\nint main(void)\n{\n" << $5.traducao << "\n\n\treturn 0;\n}" << endl; 
				} 
				//myfile.close();
			}
			;

BLOCO_NO_B	: COMANDOS TK_END
			{
				$$.traducao = $1.traducao;
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
				info_variavel atributos = { $1.label, gera_variavel_temporaria($1.label, $2.label), atoi($4.label.c_str()) };

				if(mapa_variavel.find($2.label) == mapa_variavel.end()) {
					mapa_variavel[$2.label] = atributos;

					$$.label = atributos.nome_temp;
					$$.traducao = "\t" + $4.traducao + "\n\t" + $1.label + " " + atributos.nome_temp + " = " + $4.label + ";";
					
				} else {
					cout << "Erro na linha " << nlinha <<": Você já declarou a variável \"" << $2.label << "\", animal!" << endl << endl;

					erro = true;
				}
			}
			| TK_TIPO_INT TK_ID
			{
				info_variavel atributos = { $1.label, gera_variavel_temporaria($1.label, $2.label), 0 };

				if(mapa_variavel.find($2.label) == mapa_variavel.end()) {
					mapa_variavel[$2.label] = atributos;

					$$.label = atributos.nome_temp;
					$$.traducao = "\t" + $1.label + " " + atributos.nome_temp + " = " + "0" + ";\n";
					
				} else {
					cout << "Erro na linha " << nlinha <<": Você já declarou a variável \"" << $2.label << "\", animal!" << endl << endl;

					erro = true;
				}
			}
			;

E 			: E TK_ARIT_OP_S E_TEMP
			{
				string nome_variavel_temporaria = gera_variavel_temporaria("int");

				$$.label = nome_variavel_temporaria;

				$$.traducao = $3.traducao + "\t" + $1.traducao + "\n\t" + "int " + nome_variavel_temporaria + " = " + $1.label + " " + $2.label + " " + $3.label + ";";

			}
			| E_TEMP
			{
				$$.label = $1.label;
				$$.traducao = $1.traducao;
			}
			;

E_TEMP		: E_TEMP TK_ARIT_OP_M VAL
			{
				string nome_variavel_temporaria = gera_variavel_temporaria("int");

				$$.label = nome_variavel_temporaria;

				$$.traducao = $1.traducao + "\n\t" + "int " + nome_variavel_temporaria + " = " + $1.label + " " + $2.label + " " + $3.label + ";";
			}
			| VAL
			{
				$$.label = $1.label;
				$$.traducao = $1.traducao;
			};

VAL			: TK_NUM
			{
				$$.label = $1.label;
				$$.traducao = "";
			}
			| TK_ID
			{
				if(mapa_variavel.find($1.label) == mapa_variavel.end()) {
					cout << "Erro na linha " << nlinha <<": Que porra de variável \"" << $1.label << "\" é essa?" << endl << endl;

					erro = true;
				}

				$$.label = mapa_variavel[$1.label].nome_temp;
				$$.traducao = $$.label;
			}
			;

TK_ARIT_OP_S: TK_SOMA
			{
				$$.traducao = $1.traducao;
				$$.label = $1.label;
			}
			| TK_SUB
			{
				$$.traducao = $1.traducao;
				$$.label = $1.label;
			};

TK_ARIT_OP_M: TK_MUL
			{
				$$.traducao = $1.traducao;
				$$.label = $1.label;
			}
			| TK_DIV
			{
				$$.traducao = $1.traducao;
				$$.label = $1.label;
			}
			;

%%

#include "lex.yy.c"

int yyparse();

int contador = 0;

string gera_variavel_temporaria(string tipo, string nome) {

	stringstream nome_temporario;

	nome_temporario << "temp_" << tipo << "_";

	if (!nome.empty()) {
		nome_temporario << nome << "_";
	}

	nome_temporario << contador;

	contador++;

	return nome_temporario.str();
}

void adiciona_biblioteca_cabecalho(string nome_biblioteca) {
	cabecalho << "#include <" << nome_biblioteca << ">" << endl;
}

int main( int argc, char* argv[] )
{
	yyparse();

	return 0;
}

void yyerror( string MSG )
{
	cout << MSG << " on line " << nlinha << endl;
	exit (0);
}				

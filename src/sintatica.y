%{
#include <iostream>
#include <string>
#include <cstdio>
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
	string tipo;
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

// Estrutura que guarda informações sobre o cast a se fazer

typedef struct _tipo_cast
{
	string resultado;
	int operando_cast;
} tipo_cast;

// Variável para o cabeçalho
stringstream cabecalho;

// Mapa de variáveis
map<string, info_variavel> mapa_variavel;

// Mapa de casts
map<string, tipo_cast> mapa_cast;

/****************************************
	Início da declaração de funções
****************************************/

// Função para geração do mapa de cast

void gera_mapa_cast();
string gera_chave(string operador1, string operador2, string operacao);

// Função para gerar nomes temporários para as variáveis

string gera_variavel_temporaria(string tipo, string nome="");

void adiciona_biblioteca_cabecalho(string nome_biblioteca);

%}

%token TK_NUM
%token TK_MAIN TK_ID
%token TK_TIPO_INT TK_TIPO_FLOAT TK_TIPO_BOOL
%token TK_ATR
%token TK_SOMA TK_SUB 
%token TK_MUL TK_DIV TK_RESTO
%token TK_BEGIN TK_END
%token TK_FIM TK_ERROR
%token TK_FLOAT

%token TK_LOGICO

%token TK_MENOR
%token TK_MAIOR
%token TK_MENOR_IGUAL
%token TK_MAIOR_IGUAL
%token TK_IGUAL
%token TK_DIFERENTE

%token TK_AND TK_OR

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
					cout << cabecalho.str() << "\nint main(void)\n{" << $5.traducao << "\n\n\treturn 0;\n}" << endl; 
				} 
				//myfile.close();
			};

BLOCO_NO_B	: COMANDOS TK_END
			{
				$$.traducao = $1.traducao;
			};

COMANDOS	: COMANDO ';' COMANDOS {
				$$.traducao = $1.traducao + $3.traducao;
			}
			|
			{
				$$.traducao = "";
				$$.label = "";
			};

COMANDO 	: DECLARACAO
			{
				$$.label = $1.label;
				$$.traducao = $1.traducao;
			}
			| ATRIBUICAO
			{
				$$.label = $1.label;
				$$.traducao = $1.traducao;
			};

ATRIBUICAO 	: TK_ID TK_ATR E_OP_OR
			{
				//cout << $1.tipo << " " << $3.tipo << endl << endl;

				if(mapa_variavel.find($1.label) != mapa_variavel.end()) {

					info_variavel variavel = mapa_variavel[$1.label];

					string chave = gera_chave(variavel.tipo, $3.tipo, $2.label);

					$$.tipo = variavel.tipo;

					if(variavel.tipo == $3.tipo) {

						//cout << $1.tipo << " " << $3.tipo << endl << endl;

						$$.traducao = "\t" + $3.traducao + "\n\t" + variavel.nome_temp + " " + $2.label + " " + $3.label + ";";

					} else if(mapa_cast.find(chave) != mapa_cast.end()) {

						tipo_cast cast = mapa_cast[chave];

						if(cast.operando_cast == 2) {
							$$.traducao = "\t" + $3.traducao + "\n\t" + variavel.nome_temp + " " + $2.label + " " + "(" + cast.resultado + ") " + $3.label + ";";
						} else {
							cout << "Erro na linha " << nlinha <<": Não é possível atribuir um valor do tipo " << $3.tipo
							<< " a uma variável do tipo " << $1.tipo << endl << endl;
							erro = true;
						}
					} else {

						//cout << chave << endl << endl;

						//cout << "Erro na linha b" << nlinha <<": Verifique os tipos, idiota!" << endl << endl;

						cout << "Erro na linha " << nlinha <<": Não é possível atribuir um valor do tipo " << $3.tipo
							<< " a uma variável do tipo " << $1.tipo << endl << endl;
						erro = true;
					}

				} else {
					//cout << "Erro na linha " << nlinha <<": Você já declarou a variável \"" << $2.label << "\", animal!" << endl << endl;
					cout << "Erro na linha " << nlinha <<": Que porra de variável \"" << $1.label << "\" é essa?" << endl << endl;

					erro = true;
				}
			};

COMANDO 	: E_OP_OR
			{
				$$.label = $1.label;
				$$.traducao = $1.traducao;
			};

DECLARACAO	: TIPO TK_ID TK_ATR E_OP_OR
			{
				//cout << "200: " << $2.label << " " << $2.tipo << " " << $4.tipo << endl << endl;

				info_variavel atributos = { $1.label, gera_variavel_temporaria($1.label, $2.label), atoi($4.label.c_str()) };

				if(mapa_variavel.find($2.label) == mapa_variavel.end()) {

					mapa_variavel[$2.label] = atributos;

					string chave = gera_chave(atributos.tipo, $4.tipo, $3.label);

					$$.label = atributos.nome_temp;
					//$$.traducao = "\t" + $4.traducao + "\n\t" + $1.label + " " + atributos.nome_temp + " = " + $4.label + ";\n\t";
					$$.tipo = $1.label;

					if(atributos.tipo == $4.tipo) {

						//cout << "213: "<< $2.tipo << " " << $4.tipo << endl << endl;
						$$.traducao = "\t" + $4.traducao + "\n\t" + $1.traducao +" " + atributos.nome_temp + " " + $3.label + " " + $4.label + ";";
						//cout << "217: "<< $$.traducao << endl << endl;

					} else if(mapa_cast.find(chave) != mapa_cast.end()) {

						tipo_cast cast = mapa_cast[chave];

						if(cast.operando_cast == 2) {
							$$.traducao = "\t" + $4.traducao + "\n\t" + atributos.nome_temp + " " + $3.label + " " + "(" + cast.resultado + ") " + $4.label + ";";
						} else {
							cout << "Erro na linha " << nlinha <<": Não é possível atribuir um valor do tipo " << $4.tipo
								<< " a uma variável do tipo " << atributos.tipo << endl << endl;
							erro = true;
						}
					} else {
						cout << "Erro na linha " << nlinha <<": Não é possível atribuir um valor do tipo " << $4.tipo
							<< " a uma variável do tipo " << atributos.tipo << endl << endl;
						erro = true;
					}
				} else {
					cout << "Erro na linha " << nlinha <<": Não é possível atribuir um valor do tipo " << $4.tipo
						<< " a uma variável do tipo " << atributos.tipo << endl << endl;
					erro = true;
				}

				//cout << $1.label << endl << endl;
			}
			| TIPO TK_ID
			{
				info_variavel atributos = { $1.label, gera_variavel_temporaria($1.label, $2.label), 0 };

				if(mapa_variavel.find($2.label) == mapa_variavel.end()) {
					mapa_variavel[$2.label] = atributos;

					$$.label = atributos.nome_temp;
					$$.traducao = "\t" + $1.label + " " + atributos.nome_temp + " = " + "0" + ";\n";
					$$.tipo = $1.label;
					
				} else {
					cout << "Erro na linha " << nlinha <<": Você já declarou a variável \"" << $2.label << "\", animal!" << endl << endl;

					erro = true;
				}
			};

E_OP_OR		: E_OP_OR TK_OR E_OP_AND
			{
				string nome_variavel_temporaria;

				string chave = gera_chave($1.tipo, $3.tipo, $2.label);

				/*if (mapa_cast.find(chave) != mapa_cast.end()) {
					tipo_cast cast = mapa_cast[chave];

					nome_variavel_temporaria = gera_variavel_temporaria(cast.resultado);

					if(cast.operando_cast == 1) {
						$$.traducao = $3.traducao + "\t" + $1.traducao + "\n\t" + "int" + " " + nome_variavel_temporaria + " = " + "(" + $3.tipo + ") " + $1.label + " " + $2.label + " " + $3.label + ";";
					} else {
						$$.traducao = $3.traducao + "\t" + $1.traducao + "\n\t" + "int" + " " + nome_variavel_temporaria + " = " + $1.label + " " + $2.label + " " + "(" + $1.tipo + ") " + $3.label + ";";
					}

					$$.tipo = cast.resultado;

				} else*/
				if( ($1.tipo == "boolean") && ($1.tipo == $3.tipo)) {

					nome_variavel_temporaria = gera_variavel_temporaria($1.tipo);

					$$.traducao = $3.traducao + "\t" + $1.traducao + "\n\t" + "int" + " " + nome_variavel_temporaria + " = " + $1.label + " " + $2.traducao + " " + $3.label + ";";

					$$.tipo = "boolean";

				} else {
					cout << "Erro na linha " << nlinha <<": Não é possível comparar um valor do tipo " << $1.tipo
						<< " com um do tipo " << $3.tipo << endl << endl;

					erro = true;
				}

				$$.label = nome_variavel_temporaria;
			}
			| E_OP_AND
			{
				$$.label = $1.label;
				$$.traducao = $1.traducao;
				$$.tipo = $1.tipo;
			};

E_OP_AND	: E_OP_AND TK_AND E_REL
			{
				string nome_variavel_temporaria;

				string chave = gera_chave($1.tipo, $3.tipo, $2.label);

				/*if (mapa_cast.find(chave) != mapa_cast.end()) {
					tipo_cast cast = mapa_cast[chave];

					nome_variavel_temporaria = gera_variavel_temporaria(cast.resultado);

					if(cast.operando_cast == 1) {
						$$.traducao = $3.traducao + "\t" + $1.traducao + "\n\t" + "int" + " " + nome_variavel_temporaria + " = " + "(" + $3.tipo + ") " + $1.label + " " + $2.label + " " + $3.label + ";";
					} else {
						$$.traducao = $3.traducao + "\t" + $1.traducao + "\n\t" + "int" + " " + nome_variavel_temporaria + " = " + $1.label + " " + $2.label + " " + "(" + $1.tipo + ") " + $3.label + ";";
					}

					$$.tipo = cast.resultado;

				} else*/
				if( ($1.tipo == "boolean") && ($1.tipo == $3.tipo)) {

					nome_variavel_temporaria = gera_variavel_temporaria($1.tipo);

					$$.traducao = $3.traducao + "\t" + $1.traducao + "\n\t" + "int" + " " + nome_variavel_temporaria + " = " + $1.label + " " + $2.traducao + " " + $3.label + ";";

					$$.tipo = "boolean";

				} else {
					cout << "Erro na linha " << nlinha <<": Não é possível comparar um valor do tipo " << $1.tipo
						<< " com um do tipo " << $3.tipo << endl << endl;

					erro = true;
				}

				$$.label = nome_variavel_temporaria;
			}
			| E_REL
			{
				$$.label = $1.label;
				$$.traducao = $1.traducao;
				$$.tipo = $1.tipo;
			};

E_REL		: E TK_REL_OP E
			{
				string nome_variavel_temporaria;

				string chave = gera_chave($1.tipo, $3.tipo, $2.label);

				if (mapa_cast.find(chave) != mapa_cast.end()) {
					tipo_cast cast = mapa_cast[chave];

					nome_variavel_temporaria = gera_variavel_temporaria(cast.resultado);

					if(cast.operando_cast == 1) {
						$$.traducao = $3.traducao + "\t" + $1.traducao + "\n\t" + "int" + " " + nome_variavel_temporaria + " = " + "(" + $3.tipo + ") " + $1.label + " " + $2.label + " " + $3.label + ";";
					} else {
						$$.traducao = $3.traducao + "\t" + $1.traducao + "\n\t" + "int" + " " + nome_variavel_temporaria + " = " + $1.label + " " + $2.label + " " + "(" + $1.tipo + ") " + $3.label + ";";
					}

					$$.tipo = cast.resultado;

				} else if($1.tipo == $3.tipo) {

					nome_variavel_temporaria = gera_variavel_temporaria($1.tipo);

					$$.traducao = $3.traducao + "\t" + $1.traducao + "\n\t" + "int" + " " + nome_variavel_temporaria + " = " + $1.label + " " + $2.label + " " + $3.label + ";";

					$$.tipo = "boolean";

				} else {
					cout << "Erro na linha " << nlinha <<": Não é possível comparar um valor do tipo " << $1.tipo
						<< " com um do tipo " << $3.tipo << endl << endl;

					erro = true;
				}

				$$.label = nome_variavel_temporaria;
			}
			| E
			{
				$$.label = $1.label;
				$$.traducao = $1.traducao;
				$$.tipo = $1.tipo;
			};

E 			: E TK_ARIT_OP_S E_TEMP
			{
				string nome_variavel_temporaria;

				string chave = gera_chave($1.tipo, $3.tipo, $2.label);

				if (mapa_cast.find(chave) != mapa_cast.end()) {
					tipo_cast cast = mapa_cast[chave];

					nome_variavel_temporaria = gera_variavel_temporaria(cast.resultado);

					switch(cast.operando_cast) {
						case 1:
							$$.traducao = $3.traducao + "\t" + $1.traducao + "\n\t" + cast.resultado + " " + nome_variavel_temporaria + " = " + "(" + cast.resultado + ") " + $1.label + " " + $2.label + " " + $3.label + ";";
							break;
						case 2:
							$$.traducao = $3.traducao + "\t" + $1.traducao + "\n\t" + cast.resultado + " " + nome_variavel_temporaria + " = " + $1.label + " " + $2.label + " " + "(" + cast.resultado + ") " + $3.label + ";";
							break;
						default:
							cout << "Erro na linha " << nlinha <<": Verifique os tipos, idiota!" << endl << endl;
							erro = true;
					}

					$$.tipo = cast.resultado;

				} else if($1.tipo == $3.tipo) {

					nome_variavel_temporaria = gera_variavel_temporaria($1.tipo);

					$$.traducao = $3.traducao + "\t" + $1.traducao + "\n\t" + $1.tipo + " " + nome_variavel_temporaria + " = " + $1.label + " " + $2.label + " " + $3.label + ";";

					$$.tipo = $1.tipo;

				} else {
					cout << "Erro na linha " << nlinha <<": Verifique os tipos, idiota!" << endl << endl;
					erro = true;

					//cout << "359: aa " << $1.tipo << " " << $2.label << " " << $3.tipo << endl;	
				}

				$$.label = nome_variavel_temporaria;

				//cout << "362: " << $$.traducao << endl;
				//$$.traducao = $3.traducao + "\t" + $1.traducao + "\n\t" + "int " + nome_variavel_temporaria + " = " + $1.label + " " + $2.label + " " + $3.label + ";";
			}
			| E_TEMP
			{
				$$.label = $1.label;
				$$.traducao = $1.traducao;
				$$.tipo = $1.tipo;
			};

E_TEMP		: E_TEMP TK_ARIT_OP_M VAL
			{
				string nome_variavel_temporaria;

				string chave = gera_chave($1.tipo, $3.tipo, $2.label);

				if (mapa_cast.find(chave) != mapa_cast.end()) {
					tipo_cast cast = mapa_cast[chave];

					nome_variavel_temporaria = gera_variavel_temporaria(cast.resultado);

					switch(cast.operando_cast) {
						case 1:
							$$.traducao = $3.traducao + "\t" + $1.traducao + "\n\t" + cast.resultado + " " + nome_variavel_temporaria + " = " + "(" + cast.resultado + ") " + $1.label + " " + $2.label + " " + $3.label + ";";
							break;
						case 2:
							$$.traducao = $3.traducao + "\t" + $1.traducao + "\n\t" + cast.resultado + " " + nome_variavel_temporaria + " = " + $1.label + " " + $2.label + " " + "(" + cast.resultado + ") " + $3.label + ";";
							break;
						default:
							cout << "Erro na linha " << nlinha <<": Verifique os tipos, idiota!" << endl << endl;
							erro = true;
					}

					$$.tipo = cast.resultado;

					//cout << cast.resultado << endl << endl;

				} else if($1.tipo == $3.tipo) {

					nome_variavel_temporaria = gera_variavel_temporaria($1.tipo);

					$$.tipo = $1.tipo;
					$$.traducao = $3.traducao + "\t" + $1.traducao + "\n\t" + $1.tipo + " " + nome_variavel_temporaria + " = " + $1.label + " " + $2.label + " " + $3.label + ";";

				} else {

					cout << "Erro na linha " << nlinha <<": Verifique os tipos, idiota!" << endl << endl;
					erro = true;
				}

				$$.label = nome_variavel_temporaria;

				// $$.traducao = $1.traducao + "\n\t" + "int " + nome_variavel_temporaria + " = " + $1.label + " " + $2.label + " " + $3.label + ";";
			}
			| VAL
			{
				$$.label = $1.label;
				$$.traducao = $1.traducao;
				$$.tipo = $1.tipo;
				// cout << "tipo " << $$.label << ": " << $1.tipo << endl << endl;
			};

VAL			: '(' E_OP_OR ')'
			{
				$$.label = $2.label;
				$$.traducao = $2.traducao;
				$$.tipo = $2.tipo;
			}
			| TK_LOGICO
			{
				$$.label = $1.traducao;
				$$.traducao = "";
				$$.tipo = $1.tipo;
			}
			| TK_NUM
			{
				$$.label = $1.label;
				$$.traducao = "";
				$$.tipo = $1.tipo;
			}
			| TK_ID
			{
				if(mapa_variavel.find($1.label) == mapa_variavel.end()) {
					cout << "Erro na linha " << nlinha <<": Que porra de variável \"" << $1.label << "\" é essa?" << endl << endl;

					erro = true;
				}

				$$.label = mapa_variavel[$1.label].nome_temp;
				$$.traducao = $$.label;
				$$.tipo = mapa_variavel[$1.label].tipo;
			}
			| TK_FLOAT
			{
				$$.label = $1.label;
				$$.traducao = "";
				$$.tipo = $1.tipo;	
			};

TK_REL_OP	: TK_MENOR
			{
				$$.traducao = $1.traducao;
				$$.label = $1.label;
			}
			| TK_MAIOR
			{
				$$.traducao = $1.traducao;
				$$.label = $1.label;
			}
			| TK_MENOR_IGUAL
			{
				$$.traducao = $1.traducao;
				$$.label = $1.label;
			}
			| TK_MAIOR_IGUAL
			{
				$$.traducao = $1.traducao;
				$$.label = $1.label;
			}
			| TK_IGUAL
			{
				$$.traducao = $1.traducao;
				$$.label = $1.label;
			}
			| TK_DIFERENTE
			{
				$$.traducao = $1.traducao;
				$$.label = $1.label;
			};

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
			| TK_RESTO
			{
				$$.traducao = $1.traducao;
				$$.label = $1.label;
			};

TIPO 		: TK_TIPO_INT
			{
				$$.label = $1.label;
				//$$.traducao = "";
				$$.traducao = $1.traducao;

			}
			| TK_TIPO_FLOAT
			{
				$$.label = $1.label;
				//$$.traducao = "";
				$$.traducao = $1.traducao;
			}
			| TK_TIPO_BOOL
			{
				$$.label = $1.label;
				$$.traducao = $1.traducao;
			};

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

string gera_chave(string operador1, string operador2, string operacao) {

	return operador1 + "_" + operacao + "_" + operador2;
}

void gera_mapa_cast() {

	FILE* file2 = fopen("./src/mapa.txt", "r");
	
	char operador1[20] = "";
	char operador2[20] = "";
	char operacao[3] = "";
	
	char resultado[20] = "";
	int operando_cast;
	
	while(fscanf(file2, "%s\t%s\t%s\t%s\t%d\n", operador1, operacao, operador2, resultado, &operando_cast)) {
		
		tipo_cast cast = {resultado, operando_cast};

		mapa_cast[gera_chave(operador1, operador2, operacao)] = cast;

		//cout << operador1 << " " << operador2 << " " << operacao;
		
		if(feof(file2)) {
			break;
		}
	}
	
	fclose(file2);
}

void adiciona_biblioteca_cabecalho(string nome_biblioteca) {
	cabecalho << "#include <" << nome_biblioteca << ">" << endl;
}

int main( int argc, char* argv[] )
{

	gera_mapa_cast();

	yyparse();

	return 0;
}

void yyerror( string MSG )
{
	cout << MSG << " on line " << nlinha << endl;
	exit (0);
}				
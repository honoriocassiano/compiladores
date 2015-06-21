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
	string tipo_traducao;
	int tamanho;
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
	int tamanho;
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

// Mapa de traduções de tipo
map<string, string> mapa_traducao_tipo;

// Mapa de traduções de tipo
map<string, string> mapa_valor_padrao;

/****************************************
	Início da declaração de funções
****************************************/

// Função para geração do mapa de cast

void gera_mapa_cast();

// Função para gerar o mapa de traduções de tipo
void gera_mapa_traducao_tipo();

// Função para gerar o mapa de traduções de tipo
void gera_mapa_valor_padrao();

string gera_chave(string operador1, string operador2, string operacao);

// Função para gerar nomes temporários para as variáveis
string gera_variavel_temporaria(string tipo, int tamanho, string nome="");

void adiciona_biblioteca_cabecalho(string nome_biblioteca);

%}

%token TK_MAIN TK_ID
%token TK_TIPO_INT TK_TIPO_FLOAT TK_TIPO_BOOL TK_TIPO_DOUBLE TK_TIPO_LONG TK_TIPO_STRING
%token TK_ATR
%token TK_SOMA TK_SUB 
%token TK_MUL TK_DIV TK_RESTO
%token TK_BEGIN TK_END
%token TK_FIM TK_ERROR
%token TK_NUM TK_FLOAT TK_LONG TK_DOUBLE TK_STRING

%token TK_LOGICO TK_NOT

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
					cout << cabecalho.str() << "\nint main(void)\n" << $5.traducao << "\n\n\treturn 0;\n}" << endl; 
				} 
				//myfile.close();
			};

BLOCO_NO_B	: COMANDOS TK_END
			{
				stringstream variaveis;

				for (std::map<string, info_variavel>::iterator it=mapa_variavel.begin(); it!=mapa_variavel.end(); ++it) {
    				variaveis << "\t" << mapa_traducao_tipo[it->second.tipo] << " " << it->second.nome_temp;

    				if(it->second.tipo == "string") {
    					variaveis << "[" << (it->second.tamanho + 1) << "]";
    				}

    				variaveis << ";\n";
    			}
				$$.traducao = "{\n" + variaveis.str() + $1.traducao;

				//traducao << $4.traducao << "\n\t" << atributos.nome_temp << "[" << (atributos.tamanho+1) << "]" << ";";
			};

COMANDOS	: COMANDO ';' COMANDOS
			{
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
				if(mapa_variavel.find($1.label) != mapa_variavel.end()) {

					info_variavel variavel = mapa_variavel[$1.label];

					string chave = gera_chave(variavel.tipo, $3.tipo, $2.label);

					$$.tipo = variavel.tipo;

					if(mapa_cast.find(chave) != mapa_cast.end()) {

						tipo_cast cast = mapa_cast[chave];

						switch(cast.operando_cast) {
							case 0:
								$$.traducao = "\t" + $3.traducao + "\n\t" + variavel.nome_temp + " " + $2.label + " " + $3.label + ";";
								break;
							case 2:
								$$.traducao = "\t" + $3.traducao + "\n\t" + variavel.nome_temp + " " + $2.label + " " + "(" + cast.resultado + ") " + $3.label + ";";
								break;
							default:
								cout << "Erro na linha " << nlinha <<": Não é possível atribuir um valor do tipo " << $3.tipo
									<< " a uma variável do tipo " << $1.tipo << endl << endl;
									erro = true;
								break;
						}
					} else {

						cout << "Erro na linha " << nlinha <<": Não é possível atribuir um valor do tipo " << $3.tipo
							<< " a uma variável do tipo " << $1.tipo << endl << endl;
						erro = true;
					}

					/*
					if(variavel.tipo == $3.tipo) {

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

						cout << "Erro na linha " << nlinha <<": Não é possível atribuir um valor do tipo " << $3.tipo
							<< " a uma variável do tipo " << $1.tipo << endl << endl;
						erro = true;
					}
					*/

				} else {
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
				string nome_temp = gera_variavel_temporaria($1.label, $4.tamanho, $2.label);

				info_variavel atributos = mapa_variavel[$2.label];

				string chave = gera_chave(atributos.tipo, $4.tipo, $3.label);

				$$.label = atributos.nome_temp;
				$$.tipo = $1.label;

				/*
				if(atributos.tipo == $4.tipo) {
					
					if($1.label == "string") {
						
						stringstream traducao;
						
						traducao << $4.traducao << "\n\tstrcpy(" << atributos.nome_temp << ", " << $4.label << ");";
						
						$$.traducao = traducao.str();
						
						adiciona_biblioteca_cabecalho("string.h");
						
					} else {
						$$.traducao = "\t" + $4.traducao + "\n\t" + atributos.nome_temp + " " + $3.label + " " + $4.label + ";";
					}

				} else */
				if(mapa_cast.find(chave) != mapa_cast.end()) {

					tipo_cast cast = mapa_cast[chave];

					switch(cast.operando_cast) {
						case 0:
							if($1.label == "string") {
						
								stringstream traducao;
								
								traducao << $4.traducao << "\n\tstrcpy(" << atributos.nome_temp << ", " << $4.label << ");";
								
								$$.traducao = traducao.str();
								
								adiciona_biblioteca_cabecalho("string.h");
								
							} else {
								$$.traducao = "\t" + $4.traducao + "\n\t" + atributos.nome_temp + " " + $3.label + " " + $4.label + ";";
							}
							break;
						case 2:
							$$.traducao = "\t" + $4.traducao + "\n\t" + atributos.nome_temp + " " + $3.label + " " + "(" + cast.resultado + ") " + $4.label + ";";
							break;
						default:
							cout << "Erro na linha " << nlinha <<": Não é possível atribuir um valor do tipo " << $4.tipo
								<< " a uma variável do tipo " << atributos.tipo << endl << endl;
							erro = true;
							break;
					}

					$$.tipo = "boolean";
				} else {
					cout << "Erro na linha " << nlinha <<": Não é possível atribuir um valor do tipo " << $4.tipo
						<< " a uma variável do tipo " << atributos.tipo << endl << endl;

					erro = true;
				}

				/*
				if(atributos.tipo == $4.tipo) {
					
					if($1.label == "string") {
						
						stringstream traducao;
						
						traducao << $4.traducao << "\n\tstrcpy(" << atributos.nome_temp << ", " << $4.label << ");";
						
						$$.traducao = traducao.str();
						
						adiciona_biblioteca_cabecalho("string.h");
						
					} else {
						$$.traducao = "\t" + $4.traducao + "\n\t" + atributos.nome_temp + " " + $3.label + " " + $4.label + ";";
					}

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
				*/
			}
			| TIPO TK_ID
			{
				string nome_temp = gera_variavel_temporaria($1.label, 0, $2.label);

				info_variavel atributos = mapa_variavel[$2.label];

				$$.label = atributos.nome_temp;
				
				if($1.label == "string") {
					$$.traducao = "\n\tstrcpy(" + atributos.nome_temp + ", " + mapa_valor_padrao[$1.label] + ");";
					
					adiciona_biblioteca_cabecalho("string.h");
				} else {
					$$.traducao = "\n\t" + atributos.nome_temp + " = " + mapa_valor_padrao[$1.label] + ";";
				}
				
				$$.tipo = $1.label;
				$$.tamanho = $2.tamanho;
			}

E_OP_OR		: E_OP_OR TK_OR E_OP_AND
			{
				string nome_variavel_temporaria;

				string chave = gera_chave($1.tipo, $3.tipo, $2.label);

				if(mapa_cast.find(chave) != mapa_cast.end()) {

					tipo_cast cast = mapa_cast[chave];

					nome_variavel_temporaria = gera_variavel_temporaria($1.tipo, $1.tamanho);

					switch(cast.operando_cast) {
						case 0:
							$$.traducao = $3.traducao + "\t" + $1.traducao + "\n\t" + nome_variavel_temporaria + " = " + $1.label + " " + $2.traducao + " " + $3.label + ";";

							break;
						case 1:
							$$.traducao = "\t" + $3.traducao + "\n\t" + "(" + cast.resultado + ") " +  nome_variavel_temporaria + " " + $2.label + " " + $3.label + ";";
							break;
						case 2:
							$$.traducao = "\t" + $3.traducao + "\n\t" + nome_variavel_temporaria + " " + $2.label + " " + "(" + cast.resultado + ") " + $3.label + ";";
							break;
						default:
							cout << "Erro na linha " << nlinha <<": Não é possível comparar um valor do tipo " << $1.tipo
							<< " com um do tipo " << $3.tipo << endl << endl;

							erro = true;
							break;
					}

				} else {
					cout << "Erro na linha " << nlinha <<": Não é possível comparar um valor do tipo " << $1.tipo
						<< " com um do tipo " << $3.tipo << endl << endl;

					erro = true;
				}

				/*
				if( ($1.tipo == "boolean") && ($1.tipo == $3.tipo)) {

					nome_variavel_temporaria = gera_variavel_temporaria($1.tipo, $1.tamanho);

					$$.traducao = $3.traducao + "\t" + $1.traducao + "\n\t" + nome_variavel_temporaria + " = " + $1.label + " " + $2.traducao + " " + $3.label + ";";

					$$.tipo = "boolean";

				} else {
					cout << "Erro na linha " << nlinha <<": Não é possível comparar um valor do tipo " << $1.tipo
						<< " com um do tipo " << $3.tipo << endl << endl;

					erro = true;
				}
				*/

				$$.label = nome_variavel_temporaria;
			}
			| E_OP_AND
			{
				$$.label = $1.label;
				$$.traducao = $1.traducao;
				$$.tipo = $1.tipo;
				$$.tamanho = $1.tamanho;
			};

E_OP_AND	: E_OP_AND TK_AND E_REL
			{
				string nome_variavel_temporaria;

				string chave = gera_chave($1.tipo, $3.tipo, $2.label);

				if(mapa_cast.find(chave) != mapa_cast.end()) {

					tipo_cast cast = mapa_cast[chave];

					nome_variavel_temporaria = gera_variavel_temporaria($1.tipo, $1.tamanho);

					switch(cast.operando_cast) {
						case 0:
							$$.traducao = $3.traducao + "\t" + $1.traducao + "\n\t" + nome_variavel_temporaria + " = " + $1.label + " " + $2.traducao + " " + $3.label + ";";

							break;
						case 1:
							$$.traducao = "\t" + $3.traducao + "\n\t" + "(" + cast.resultado + ") " +  nome_variavel_temporaria + " " + $2.label + " " + $3.label + ";";
							break;
						case 2:
							$$.traducao = "\t" + $3.traducao + "\n\t" + nome_variavel_temporaria + " " + $2.label + " " + "(" + cast.resultado + ") " + $3.label + ";";
							break;
						default:
							cout << "Erro na linha " << nlinha <<": Não é possível comparar um valor do tipo " << $1.tipo
							<< " com um do tipo " << $3.tipo << endl << endl;

							erro = true;
							break;
					}

				} else {
					cout << "Erro na linha " << nlinha <<": Não é possível comparar um valor do tipo " << $1.tipo
						<< " com um do tipo " << $3.tipo << endl << endl;

					erro = true;
				}
				/*
				if( ($1.tipo == "boolean") && ($1.tipo == $3.tipo)) {

					nome_variavel_temporaria = gera_variavel_temporaria($1.tipo, $1.tamanho);

					$$.traducao = $3.traducao + "\t" + $1.traducao + "\n\t" + nome_variavel_temporaria + " = " + $1.label + " " + $2.traducao + " " + $3.label + ";";

					$$.tipo = "boolean";

				} else {
					cout << "Erro na linha " << nlinha <<": Não é possível comparar um valor do tipo " << $1.tipo
						<< " com um do tipo " << $3.tipo << endl << endl;

					erro = true;
				}
				*/

				$$.label = nome_variavel_temporaria;
			}
			| E_REL
			{
				$$.label = $1.label;
				$$.traducao = $1.traducao;
				$$.tipo = $1.tipo;
				$$.tamanho = $1.tamanho;
			};

E_REL		: E TK_REL_OP E
			{
				string nome_variavel_temporaria;

				string chave = gera_chave($1.tipo, $3.tipo, $2.label);

				if (mapa_cast.find(chave) != mapa_cast.end()) {
					tipo_cast cast = mapa_cast[chave];

					//TODO verificar se o tamanho está certo
					nome_variavel_temporaria = gera_variavel_temporaria(cast.resultado, 0);

					switch(cast.operando_cast) {
						case 0:
							$$.traducao = $3.traducao + "\t" + $1.traducao + "\n\t" + nome_variavel_temporaria + " = " + $1.label + " " + $2.label + " " + $3.label + ";";
							break;
						case 1:
							$$.traducao = $3.traducao + "\t" + $1.traducao + "\n\t" + nome_variavel_temporaria + " = " + "(" + $3.tipo + ") " + $1.label + " " + $2.label + " " + $3.label + ";";
							break;
						case 2:
							$$.traducao = $3.traducao + "\t" + $1.traducao + "\n\t" + nome_variavel_temporaria + " = " + $1.label + " " + $2.label + " " + "(" + $1.tipo + ") " + $3.label + ";";
							break;
						default:
							cout << "Erro na linha " << nlinha <<": Não é possível comparar um valor do tipo " << $1.tipo << " com um do tipo " << $3.tipo << endl << endl;

							erro = true;
							break;
					}

					$$.tipo = "boolean";

				} else {
					cout << "Erro na linha " << nlinha <<": Não é possível comparar um valor do tipo " << $1.tipo
						<< " com um do tipo " << $3.tipo << endl << endl;

					erro = true;
				}
				/*
				if (mapa_cast.find(chave) != mapa_cast.end()) {
					tipo_cast cast = mapa_cast[chave];

					//TODO verificar se o tamanho está certo
					
					nome_variavel_temporaria = gera_variavel_temporaria(cast.resultado, 0);

					if(cast.operando_cast == 1) {
						$$.traducao = $3.traducao + "\t" + $1.traducao + "\n\t" + nome_variavel_temporaria + " = " + "(" + $3.tipo + ") " + $1.label + " " + $2.label + " " + $3.label + ";";
					} else {
						$$.traducao = $3.traducao + "\t" + $1.traducao + "\n\t" + nome_variavel_temporaria + " = " + $1.label + " " + $2.label + " " + "(" + $1.tipo + ") " + $3.label + ";";
					}

					$$.tipo = cast.resultado;

				} else if($1.tipo == $3.tipo) {

					//TODO verificar se o tamanho está certo
					
					nome_variavel_temporaria = gera_variavel_temporaria($1.tipo, 0);

					$$.traducao = $3.traducao + "\t" + $1.traducao + "\n\t" + nome_variavel_temporaria + " = " + $1.label + " " + $2.label + " " + $3.label + ";";

					$$.tipo = "boolean";

				} else {
					cout << "Erro na linha " << nlinha <<": Não é possível comparar um valor do tipo " << $1.tipo
						<< " com um do tipo " << $3.tipo << endl << endl;

					erro = true;
				}
				*/

				$$.label = nome_variavel_temporaria;
			}
			| E
			{
				$$.label = $1.label;
				$$.traducao = $1.traducao;
				$$.tipo = $1.tipo;
				$$.tamanho = $1.tamanho;
			};

E 			: E TK_ARIT_OP_S E_TEMP
			{
				string nome_variavel_temporaria;

				string chave = gera_chave($1.tipo, $3.tipo, $2.label);

				if (mapa_cast.find(chave) != mapa_cast.end()) {
					tipo_cast cast = mapa_cast[chave];

					//TODO verificar se o tamanho está certo
					nome_variavel_temporaria = gera_variavel_temporaria(cast.resultado, 0);

					switch(cast.operando_cast) {
						case 0:
							$$.traducao = $3.traducao + "\t" + $1.traducao + "\n\t" + nome_variavel_temporaria + " = " + $1.label + " " + $2.label + " " + $3.label + ";";
							break;
						case 1:
							$$.traducao = $3.traducao + "\t" + $1.traducao + "\n\t" + nome_variavel_temporaria + " = " + "(" + cast.resultado + ") " + $1.label + " " + $2.label + " " + $3.label + ";";
							break;
						case 2:
							$$.traducao = $3.traducao + "\t" + $1.traducao + "\n\t" + nome_variavel_temporaria + " = " + $1.label + " " + $2.label + " " + "(" + cast.resultado + ") " + $3.label + ";";
							break;
						default:
							cout << "Erro na linha " << nlinha <<": Verifique os tipos, idiota!" << endl << endl;
							erro = true;
					}

					$$.tipo = cast.resultado;

				} else {
					cout << "Erro na linha " << nlinha <<": Verifique os tipos, idiota!" << endl << endl;
					erro = true;
				}
				/*
				if (mapa_cast.find(chave) != mapa_cast.end()) {
					tipo_cast cast = mapa_cast[chave];

					//TODO verificar se o tamanho está certo
					nome_variavel_temporaria = gera_variavel_temporaria(cast.resultado, 0);

					switch(cast.operando_cast) {
						case 1:
							$$.traducao = $3.traducao + "\t" + $1.traducao + "\n\t" + nome_variavel_temporaria + " = " + "(" + cast.resultado + ") " + $1.label + " " + $2.label + " " + $3.label + ";";
							break;
						case 2:
							$$.traducao = $3.traducao + "\t" + $1.traducao + "\n\t" + nome_variavel_temporaria + " = " + $1.label + " " + $2.label + " " + "(" + cast.resultado + ") " + $3.label + ";";
							break;
						default:
							cout << "Erro na linha " << nlinha <<": Verifique os tipos, idiota!" << endl << endl;
							erro = true;
					}

					$$.tipo = cast.resultado;

				} else if($1.tipo == $3.tipo) {

					nome_variavel_temporaria = gera_variavel_temporaria($1.tipo, 0);
					
					$$.traducao = $3.traducao + "\t" + $1.traducao + "\n\t" + nome_variavel_temporaria + " = " + $1.label + " " + $2.label + " " + $3.label + ";";

					$$.tipo = $1.tipo;

				} else {
					cout << "Erro na linha " << nlinha <<": Verifique os tipos, idiota!" << endl << endl;
					erro = true;
				}
				*/

				$$.label = nome_variavel_temporaria;
			}
			| E_TEMP
			{
				$$.label = $1.label;
				$$.traducao = $1.traducao;
				$$.tipo = $1.tipo;
				$$.tamanho = $1.tamanho;
			};

E_TEMP		: E_TEMP TK_ARIT_OP_M VAL
			{
				string nome_variavel_temporaria;

				string chave = gera_chave($1.tipo, $3.tipo, $2.label);

				if (mapa_cast.find(chave) != mapa_cast.end()) {
					tipo_cast cast = mapa_cast[chave];

					nome_variavel_temporaria = gera_variavel_temporaria(cast.resultado, 0);

					switch(cast.operando_cast) {
						case 0:
							$$.traducao = $3.traducao + "\t" + $1.traducao + "\n\t" + nome_variavel_temporaria + " = " + $1.label + " " + $2.label + " " + $3.label + ";";
							break;
						case 1:
							$$.traducao = $3.traducao + "\t" + $1.traducao + "\n\t" + nome_variavel_temporaria + " = " + "(" + cast.resultado + ") " + $1.label + " " + $2.label + " " + $3.label + ";";
							break;
						case 2:
							$$.traducao = $3.traducao + "\t" + $1.traducao + "\n\t" + nome_variavel_temporaria + " = " + $1.label + " " + $2.label + " " + "(" + cast.resultado + ") " + $3.label + ";";
							break;
						default:
							cout << "Erro na linha " << nlinha <<": Verifique os tipos, idiota!" << endl << endl;
							erro = true;
							break;
					}

					$$.tipo = cast.resultado;

				} else {

					cout << "Erro na linha " << nlinha <<": Verifique os tipos, idiota!" << endl << endl;
					erro = true;
				}
				/*
				if (mapa_cast.find(chave) != mapa_cast.end()) {
					tipo_cast cast = mapa_cast[chave];

					nome_variavel_temporaria = gera_variavel_temporaria(cast.resultado, 0);

					switch(cast.operando_cast) {
						case 1:
							$$.traducao = $3.traducao + "\t" + $1.traducao + "\n\t" + nome_variavel_temporaria + " = " + "(" + cast.resultado + ") " + $1.label + " " + $2.label + " " + $3.label + ";";
							break;
						case 2:
							$$.traducao = $3.traducao + "\t" + $1.traducao + "\n\t" + nome_variavel_temporaria + " = " + $1.label + " " + $2.label + " " + "(" + cast.resultado + ") " + $3.label + ";";
							break;
						default:
							cout << "Erro na linha " << nlinha <<": Verifique os tipos, idiota!" << endl << endl;
							erro = true;
					}

					$$.tipo = cast.resultado;

				} else if($1.tipo == $3.tipo) {

					nome_variavel_temporaria = gera_variavel_temporaria($1.tipo, 0);
					
					$$.tipo = $1.tipo;
					
					$$.traducao = $3.traducao + "\t" + $1.traducao + "\n\t" + nome_variavel_temporaria + " = " + $1.label + " " + $2.label + " " + $3.label + ";";

				} else {

					cout << "Erro na linha " << nlinha <<": Verifique os tipos, idiota!" << endl << endl;
					erro = true;
				}
				*/

				$$.label = nome_variavel_temporaria;
			}
			| E_NOT
			{
				$$.label = $1.label;
				$$.traducao = $1.traducao;
				$$.tipo = $1.tipo;
				$$.tamanho = $1.tamanho;
			};

E_NOT		: TK_NOT E_NOT
			{
				string nome_variavel_temporaria;

				if ($2.tipo == "boolean") {

					nome_variavel_temporaria = gera_variavel_temporaria($2.tipo, 0);

					$$.traducao = $2.traducao + "\n\t" + nome_variavel_temporaria + " = " + $1.traducao + $2.label + ";";
					
				}else {
					cout << "Erro na linha " << nlinha <<": Verifique os tipos, idiota!" << endl << endl;
					erro = true;
				}

				$$.tipo = $2.tipo;
				$$.label = nome_variavel_temporaria;
			}
			| VAL
			{
				$$.label = $1.label;
				$$.traducao = $1.traducao;
				$$.tipo = $1.tipo;
				$$.tamanho = $1.tamanho;
			};

VAL			: '(' E_OP_OR ')'
			{
				$$.label = $2.label;
				$$.traducao = $2.traducao;
				$$.tipo = $2.tipo;
			}
			| TK_LOGICO
			{
				string nome_variavel_temporaria = gera_variavel_temporaria($1.tipo, $1.tamanho);

				//TODO Verificar se essa atribuição está certa
				$$.label = nome_variavel_temporaria;
				$$.traducao = "\n\t" + nome_variavel_temporaria + " = " + $1.traducao + ";";
				$$.tipo = $1.tipo;
			}
			| TK_NUM
			{
				string nome_variavel_temporaria = gera_variavel_temporaria($1.tipo, $1.tamanho);

				$$.label = nome_variavel_temporaria;
				$$.traducao = "\n\t" + nome_variavel_temporaria + " = " + $1.traducao + ";";
				$$.tipo = $1.tipo;
			}
			| TK_ID
			{
				if(mapa_variavel.find($1.label) == mapa_variavel.end()) {
					cout << "Erro na linha " << nlinha <<": Que porra de variável \"" << $1.label << "\" é essa?" << endl << endl;

					erro = true;
				}

				$$.label = mapa_variavel[$1.label].nome_temp;
				$$.traducao = "";
				$$.tipo = mapa_variavel[$1.label].tipo;
			}
			| TK_FLOAT
			{
				string nome_variavel_temporaria = gera_variavel_temporaria($1.tipo, $1.tamanho);

				$$.label = nome_variavel_temporaria;
				$$.traducao = "\n\t" + nome_variavel_temporaria + " = " + $1.traducao + ";";
				$$.tipo = $1.tipo;
			}
			| TK_LONG
			{
				string nome_variavel_temporaria = gera_variavel_temporaria($1.tipo, $1.tamanho);

				$$.label = nome_variavel_temporaria;
				$$.traducao = "\n\t" + nome_variavel_temporaria + " = " + $1.traducao + ";";
				$$.tipo = $1.tipo;	
			}
			| TK_DOUBLE
			{
				string nome_variavel_temporaria = gera_variavel_temporaria($1.tipo, $1.tamanho);

				$$.label = nome_variavel_temporaria;
				$$.traducao = "\n\t" + nome_variavel_temporaria + " = " + $1.traducao + ";";
				$$.tipo = $1.tipo;	
			}
			| TK_STRING
			{
				stringstream traducao;
				string nome_variavel_temporaria = gera_variavel_temporaria($1.tipo, $1.tamanho);
							
				traducao << "\n\tstrcpy(" << nome_variavel_temporaria << ", \"" << $1.label << "\");";
				
				$$.traducao = traducao.str();
				$$.label = nome_variavel_temporaria;
				$$.tipo = $1.tipo;
				$$.tamanho = $1.tamanho;
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
			}
			| TK_TIPO_LONG
			{
				$$.label = $1.label;
				$$.traducao = $1.traducao;
			}
			| TK_TIPO_DOUBLE
			{
				$$.label = $1.label;
				$$.traducao = $1.traducao;
			}
			| TK_TIPO_STRING
			{
				$$.label = $1.label;
				$$.traducao = $1.traducao;
			};

%%

#include "lex.yy.c"

int yyparse();

int contador = 0;

string gera_variavel_temporaria(string tipo, int tamanho, string nome) {

	stringstream nome_temporario;
	string nome_mapa;

	nome_temporario << "temp_" << tipo << "_";

	if (!nome.empty()) {
		nome_temporario << nome << "_" << contador;
		nome_mapa = nome;
	} else {
		nome_temporario << "exp_" << contador;
		nome_mapa = nome_temporario.str();
	}

	contador++;

	info_variavel atributos = {tipo, nome_temporario.str(), tamanho};
	if(mapa_variavel.find(nome_mapa) == mapa_variavel.end()) {
		mapa_variavel[nome_mapa] = atributos;

	} else {
		cout << "Erro na linha " << nlinha <<": Você já declarou a variável \"" << nome << "\"." << endl << endl;
		erro = true;
	}

	return nome_temporario.str();
}

string gera_chave(string operador1, string operador2, string operacao) {

	return operador1 + "_" + operacao + "_" + operador2;
}

void gera_mapa_cast() {

	FILE* file2 = fopen("./src/mapa_cast.txt", "r");

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

void gera_mapa_traducao_tipo() {

	mapa_traducao_tipo["string"] = "char";
	mapa_traducao_tipo["int"] = "int";
	mapa_traducao_tipo["float"] = "float";
	mapa_traducao_tipo["double"] = "double";
	mapa_traducao_tipo["long"] = "long";
	mapa_traducao_tipo["boolean"] = "int";
	mapa_traducao_tipo["char"] = "char";
}

void gera_mapa_valor_padrao() {

	mapa_valor_padrao["string"] = "\"\"";
	mapa_valor_padrao["int"] = "0";
	mapa_valor_padrao["float"] = "0.0";
	mapa_valor_padrao["double"] = "0.0D";
	mapa_valor_padrao["long"] = "0L";
	mapa_valor_padrao["boolean"] = "0";
	mapa_valor_padrao["char"] = "\'\0\'";
}

void adiciona_biblioteca_cabecalho(string nome_biblioteca) {
	cabecalho << "#include <" << nome_biblioteca << ">" << endl;
}

int main( int argc, char* argv[] )
{

	gera_mapa_cast();
	gera_mapa_traducao_tipo();
	gera_mapa_valor_padrao();

	yyparse();

	return 0;
}

void yyerror( string MSG )
{
	cout << MSG << " on line " << nlinha << endl;
	exit (0);
}				
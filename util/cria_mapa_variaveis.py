#-*- coding: utf8 -*-

def verifica_cast():

	tipos_numericos = ("int", "float", "long", "double")
	tipos_boleanos = ("boolean",)
	tipos_caracteres = ("string",)

	tipos = tipos_numericos + tipos_boleanos + tipos_caracteres

	operacoes_numericas = ("+", "-", "*", "/", "%")
	operacoes_atribuicao = ("=",)
	operacoes_relacionais = ("<", ">", "<=", ">=", "==", "!=")
	operacoes_logicas = ("and", "or", "not")

	operacoes = operacoes_numericas + operacoes_atribuicao + operacoes_relacionais + operacoes_logicas

	tipos_reais = ["float", "double"]

	for i in tipos:
		for j in operacoes:
			for k in tipos:

				# Operações entre tipos numéricos
				if i in tipos_numericos and k in tipos_numericos:
					
					if j in operacoes_atribuicao:
						if i == k:
							yield (i, j, k, i, 0)
						# Faz cast na atribuição independentemente dos tipos numéricos
						else:
							yield (i, j, k, i, 2)

					# Verifica se as operações podem ser feitas com números
					elif j in operacoes_numericas or j in operacoes_relacionais:

						# O resto é o único que tem restrições para tipos numéricos
						if j == "%":

							# Caso um dos valores não seja int ou long
							if i in tipos_reais or k in tipos_reais:
								#yield (i, j, k, "null", -1)
								continue

							# Não precisa de cast
							elif i == k:
								yield (i, j, k, i, 0)

							elif i == "long":
								yield (i, j, k, k, 2)

							else:
								yield (i, j, k, i, 1)

						# Não precisa de cast
						elif i == k:
							yield (i, j, k, i, 0)

						# Sempre é feito cast no int a menos que seja operado com um int também
						elif i == "int":
							yield (i, j, k, k, 1)

						elif k == "int":
							yield (i, j, k, i, 2)

						# Qualquer outro tipo vira um double
						elif i == "double":
							yield (i, j, k, i, 2)

						elif k == "double":
							yield (i, j, k, k, 1)

						# Qualquer valor não real é alterado para double
						elif i == "float":
							yield (i, j, k, i, 2)

						elif k == "float":
							yield (i, j, k, k, 1)

					# Outras operações não suportadas pelos tipos numéricos
					else:
						#yield (i, j, k, "null", -1)
						continue

				# Operações entre tipos boolean
				elif i in tipos_boleanos and k in tipos_boleanos:

					if j in operacoes_atribuicao:
						if i == k:
							yield (i, j, k, i, 0)
					# Boolean só faz operações lógicas com boolean
					elif j in operacoes_logicas:
						yield (i, j, k, i, 0)

					# Nenhuma outra operação é permitida
					else:
						#yield (i, j, k, "null", -1)
						continue

				# Operações entre string
				elif i in tipos_caracteres and k in tipos_caracteres:

					if j in operacoes_relacionais:
						yield (i, j, k, i, 0)
					elif j == "=":
						yield (i, j, k, i, 0)
					elif j == "+":
						yield (i, j, k, i, 0)
					else:
						#yield (i, j, k, "null", -1)
						continue

				# Qualquer outra combinação de operações com tipos não é permitida
				else:
					#yield (i, j, k, "null", -1)
					continue

def main():
	mapa = open("../src/mapa_cast.txt", "w")

	"""
		Ainda não estão definidas operações com char
	"""

	"""
		Imprime algo no formato:

		tipo 1, operacao, tipo 2, tipo resultado, operando a fazer cast

		Exemplo:

		string	+	float	null	-1
		float	+	double	double	1

		Legenda do operando a fazer cast:

		-1	- Erro
		0	- Nenhum
		1	- Primeiro operando
		2	- Segundo operando

	"""

	formato = "%s\t%s\t%s\t%s\t%d\n"

	for cast in verifica_cast():

		linha = formato % cast
		mapa.write(linha)

	mapa.close()

main()

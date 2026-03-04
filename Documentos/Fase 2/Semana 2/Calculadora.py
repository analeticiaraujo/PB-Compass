### CALCULADORA BASICA ###
import pytest

valorfinal = float

class Calculadora():
    def soma(self, numero1, numero2):
        valorfinal = numero1 + numero2
        return valorfinal
    def subtracao(self, numero1, numero2):
        valorfinal = numero1 - numero2
        return valorfinal
    def multiplicacao(self, numero1, numero2):
        valorfinal = numero1 * numero2
        return valorfinal
    def divisao(self, numero1, numero2):
        if numero2 == 0:
            raise ZeroDivisionError("Não é possível dividir por 0")
        else:
            valorfinal = numero1 / numero2
            return valorfinal
    def exponencial(self, numero1, numero2):
        valorfinal = numero1 ** numero2
        return valorfinal
    def divisaoresto(self, numero1, numero2):
        if numero2 == 0:
            raise ZeroDivisionError("Não é possível dividir por 0")
        else:
            valorfinal = numero1 - (int(numero1 / numero2) * numero2)
            return valorfinal


if __name__ == "__main__":
    calculadora = Calculadora()
    operador = {
    1: calculadora.soma,
    2: calculadora.subtracao,
    3: calculadora.multiplicacao,
    4: calculadora.divisao,
    5: calculadora.exponencial,
    6: calculadora.divisaoresto
}

    operacao = ""

    while operacao != 7:
        print('''   [1] - somar 
        [2] - subtrair 
        [3] - multiplicar 
        [4] - dividir 
        [5] - exponencial
        [6] - Sobra divisão
        [7] - sair''')
        operacao = int(input('Qual a operação desejada?'))
        if operacao == 7:
            print("Fim da operação")
            break

        if operacao in operador:
            numero1 = float(input("Coloque o primeiro número: "))
            numero2 = float(input("Coloque o segundo número: "))
            
            operacaoescolhida = operador[operacao]
            valorfinal = operacaoescolhida(numero1, numero2)
            print(f'O valor final é {valorfinal}')
        else:
            print("Operação não suportada pela calculadora")
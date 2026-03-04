from calculadora import Calculadora
import pytest
import sys

c = Calculadora()
sys.set_int_max_str_digits(15000)

@pytest.mark.parametrize("numero1, numero2, valorfinal", [
    (4, 9, 13),
    (7, 0, 7),
    (28, 8372, 8400)
])

def test_soma(numero1, numero2, valorfinal):
    assert c.soma(numero1, numero2) == valorfinal

@pytest.mark.parametrize("numero1, numero2, valorfinal", [
    (4, 9, -5),
    (7, 0, 7),
    (28, 8372, -8344)
])

def test_subtracao(numero1, numero2, valorfinal):
    assert c.subtracao(numero1, numero2) == valorfinal

@pytest.mark.parametrize("numero1, numero2, valorfinal", [
    (4, 9, 36),
    (7, 0, 0),
    (28, 8372, 234416)
])

def test_multiplicacao(numero1, numero2, valorfinal):
    assert c.multiplicacao(numero1, numero2) == valorfinal

@pytest.mark.parametrize("numero1, numero2, valorfinal", [
    (4, 9, 4/9),
    (28, 8372, (28/8372))
])

def test_divisao(numero1, numero2, valorfinal):
    assert c.divisao(numero1, numero2) == valorfinal

def test_divisao_zero():
    with pytest.raises(ZeroDivisionError) as exec_info:
        c.divisao(7, 0)
    assert "Não é possível dividir por 0" in str(exec_info)

@pytest.mark.parametrize("numero1, numero2, valorfinal", [
    (4, 9, 262144),
    (7, 0, 1),
    (28, 8372, 28**8372)
])

def test_exponencial(numero1, numero2, valorfinal):
    assert c.exponencial(numero1, numero2) == valorfinal

@pytest.mark.parametrize("numero1, numero2, valorfinal", [
    (4, 9, 4),
    (28, 8372, 28)
])

def test_divisao_resto(numero1, numero2, valorfinal):
    assert c.divisaoresto(numero1, numero2) == valorfinal

def test_divisao_resto_zero():
    with pytest.raises(ZeroDivisionError) as exec_info:
        c.divisaoresto(7, 0)
    assert "Não é possível dividir por 0" in str(exec_info)
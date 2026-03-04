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
    assert c.soma(27, 8) == 35

@pytest.mark.parametrize("numero1, numero2, valorfinal", [
    (4, 9, -5),
    (7, 0, 7),
    (28, 8372, -8344)
])
def test_subtracao(numero1, numero2, valorfinal):
    assert c.subtracao(27, 8) == 19

@pytest.mark.parametrize("numero1, numero2, valorfinal", [
    (4, 9, 36),
    (7, 0, 0),
    (28, 8372, 234416)
])
def test_multiplicacao(numero1, numero2, valorfinal):
    assert c.multiplicacao(27, 8) == 216

@pytest.mark.parametrize("numero1, numero2, valorfinal", [
    (4, 9, 4/9),
    (7, 0, "erro"),
    (28, 8372, 28/8372)
])
def test_divisao(numero1, numero2, valorfinal):
    assert c.divisao(27, 8) == 3.375

@pytest.mark.parametrize("numero1, numero2, valorfinal", [
    (4, 9, 262144),
    (7, 0, 1),
    (28, 8372, 28**8372)
])
def test_exponencial(numero1, numero2, valorfinal):
    assert c.exponencial(27, 8) == 282429536481

@pytest.mark.parametrize("numero1, numero2, valorfinal", [
    (4, 9, 4),
    (7, 0, "erro"),
    (28, 8372, 28)
])
def test_divisaoresto(numero1, numero2, valorfinal):
    assert c.divisaoresto(27, 8) == 3
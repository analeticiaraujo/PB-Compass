from calculadora import Calculadora

def test_soma():
    calc = Calculadora()
    assert calc.soma(3, 4) == 7
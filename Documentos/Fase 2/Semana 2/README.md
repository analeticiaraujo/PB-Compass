**Projeto: Calculadora com Testes Automatizados**
Como parte integrante dos desafios práticos, foi desenvolvida uma calculadora em Python que exercita a lógica de programação e a cultura de Quality Assurance (QA).

**O projeto foi construído utilizando as seguintes referências educacionais:**

Lógica e Menu Interativo: Inspirado na didática do Prof. Gustavo Guanabara (Curso em Vídeo), focando em usabilidade via terminal e controle de fluxo.

Suíte de Testes (Pytest): Baseado no curso "Domine Pytest: Testes de Software com Python" de Fernando Amaral (Udemy), aplicando técnicas de parametrização e tratamento de exceções.

Assistência de IA (Gemini): Utilizado como ferramenta de consulta dinâmica para otimização de tempo em substituição ao StackOverflow, auxiliando na resolução de bugs de conversão de tipos.

**Estrutura de Testes**

Para garantir a confiabilidade das operações (Soma, Subtração, Multiplicação, Divisão e Resto), foram implementados testes unitários que cobrem:

Cenários de sucesso com múltiplos valores (@pytest.mark.parametrize).

Tratamento de erros críticos, como a divisão por zero (ZeroDivisionError).

**Como Executar os Testes**
Certifique-se de ter o pytest instalado e, na raiz do projeto da calculadora, execute:

Bash pytest -v

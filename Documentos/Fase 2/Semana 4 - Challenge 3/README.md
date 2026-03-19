# Challenge 3: Automação de API com Robot Framework (ServeRest)

Este projeto contém a automação de testes para a API **ServeRest**, focada na validação de operações de CRUD e regras de negócio para o gerenciamento de usuários.

---

## Objetivo do Projeto
O objetivo principal é garantir a confiabilidade da API ServeRest, validando:
* Fluxos de sucesso (Happy Path).
* Tratamento de erros e mensagens (Negative Path).
* Validação de estrutura de dados (Contrato).
* Identificação de inconsistências lógicas (Bugs).

---

## Tecnologias e Dependências
* **Linguagem:** Python 3.x
* **Framework:** [Robot Framework](https://robotframework.org/)
* **Bibliotecas:**
    * `RequestsLibrary`: Comunicação HTTP/REST.
    * `String`: Geração de dados aleatórios.
* **API Alvo:** [ServeRest](https://compassuol.serverest.dev)

### Como instalar as dependências
1.  Certifique-se de ter o Python instalado.
2.  Execute o comando:
    ```bash
    pip install robotframework robotframework-requests
    ```

---

## Cenários de Teste (Capa de Testes)
A suíte automatizada cobre os seguintes casos:

| ID | Cenário | Tipo | Validação Principal |
| :--- | :--- | :---: | :--- |
| **01** | Cadastrar novo usuário | Positivo | Status 201 e geração de `_id`. |
| **02** | Cadastrar e-mail já existente | Negativo | Status 400 e mensagem de erro impeditiva. |
| **03** | Buscar usuário por ID | Contrato | Presença dos campos `nome`, `email` e `_id`. |
| **04** | Modificar dados do usuário | Positivo | Sucesso na alteração via método PUT. |
| **05** | Deletar usuário | Positivo | Remoção física do registro no banco. |
| **06** | Validar persistência do Delete | Negativo | Garantia de que o ID excluído retorna 400. |
| **07** | Validar e-mail inválido | Bug Check | Bloqueio de caracteres especiais ($) no e-mail. |
| **08** | Validar nome com números | Bug Check | Bloqueio de numerais no campo de nome. |

---

## Como Executar
Para rodar todos os testes e gerar os relatórios na pasta de evidências:

```bash
robot -d ./results tests/CompassServerest.robot
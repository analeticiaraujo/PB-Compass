*** Settings ***
Resource  ../resources/CompassServerest.resource

*** Test Cases ***
Cenário 01: Cadastrar um novo usuário com sucesso na ServeRest
    Criar um novo usuário
    Criar Sessão na ServeRest
    Cadastrar o usuário criado na ServeRest

Cenário 02: Cadastrar um usuário já existente
    Cadastrar um usuário já existente

Cenário 03: Encontra um usuário baseando-se na ID
    Procurar um usuário baseando-se na ID

Cenário 04: Modifica os dados do usuário já existente
    Modificar os dados do usuário

Cenário 05: Deletar usuário
    Deletar o usuário já existente

Cenário 06: Validar que o usuário excluído não existe mais
    Verificar se o DELETE funcionou

Cenário 07: Verificar se tem regras de adição de usuário
    Adicionar usuário com e-mail inválido

Cenário 08: Adiciona um usuário com números no nome
    Adicionar usuário com números no nome

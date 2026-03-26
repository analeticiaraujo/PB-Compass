*** Settings ***
Resource          ./resources/keywords.resource
Suite Setup       Criar Sessão na ServeRest
Suite Teardown    Deleta usuário caso exista

*** Test Cases ***
Cenário 01: Cadastrar um novo usuário com sucesso na ServeRest
    [Tags]    usuarios    smoke    crud
    Criar um novo usuário
    Cadastrar o usuário criado na ServeRest

Cenário 02: Cadastrar um usuário já existente
    [Tags]    usuarios    negativo
    Cadastrar um usuário já existente

Cenário 03: Encontra um usuário baseando-se na ID
    [Tags]    usuarios    smoke    crud
    Procurar um usuário baseando-se na ID

Cenário 04: Modifica os dados do usuário já existente
    [Tags]    usuarios    crud
    Modificar os dados do usuário

Cenário 05: Deletar usuário
    [Tags]    usuarios    crud
    Deletar o usuário já existente

Cenário 06: Validar que o usuário excluído não existe mais
    [Tags]    usuarios    crud
    Verificar se o DELETE funcionou

Cenário 07: Verificar se tem regras de adição de usuário
    [Tags]    usuarios    negativo    bug
    Adicionar usuário com e-mail inválido

Cenário 08: Adiciona um usuário com números no nome
    [Tags]    usuarios    negativo    bug
    Adicionar usuário com números no nome

Cenário 09: Listar todos os usuários cadastrados
    [Tags]    usuarios    smoke
    Listar todos os usuários

Cenário 10: Criar usuário via PUT em ID inexistente (upsert)
    [Tags]    usuarios    crud
    Criar usuário via PUT (upsert)

Cenário 11: Deletar usuário com ID inexistente
    [Tags]    usuarios    negativo
    Deletar usuário com ID inexistente

Cenário 12: Cadastrar usuário sem campo nome
    [Tags]    usuarios    negativo    validacao
    Cadastrar usuário sem campo nome

Cenário 13: Cadastrar usuário sem campo password
    [Tags]    usuarios    negativo    validacao
    Cadastrar usuário sem campo password

Cenário 14: Cadastrar usuário sem campo administrador
    [Tags]    usuarios    negativo    validacao
    Cadastrar usuário sem campo administrador

Cenário 15: Cadastrar usuário não administrador com sucesso
    [Tags]    usuarios    smoke
    Cadastrar usuário não administrador

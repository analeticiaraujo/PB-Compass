*** Settings ***
Documentation     Testes CRUD do endpoint /usuarios — ServeRest
Resource          ../../resources/usuarios_keywords.resource
Suite Setup       Criar Sessão na ServeRest
Suite Teardown    Deleta usuário caso exista

*** Test Cases ***
Cenário 01: Cadastrar um novo usuário com sucesso na ServeRest
    [Documentation]  Cria um novo usuário no ServeRest
    [Tags]    usuarios    smoke    crud
    Criar um novo usuário
    Cadastrar o usuário criado na ServeRest

Cenário 02: Cadastrar um usuário já existente
    [Documentation]  Tenta criar novamente o mesmo usuário criado anteriormente
    [Tags]    usuarios    negativo
    Cadastrar um usuário já existente

Cenário 03: Encontra um usuário baseando-se na ID
    [Documentation]  Encontra um usuário baseando-se na ID coletada
    [Tags]    usuarios    smoke    crud
    Procurar um usuário baseando-se na ID

Cenário 04: Modifica os dados do usuário já existente
    [Documentation]  Modifica usuário existente
    [Tags]    usuarios    crud
    Modificar os dados do usuário

Cenário 05: Deletar usuário
    [Documentation]  Remove usuário existente da ServeRest
    [Tags]    usuarios    crud
    Deletar o usuário já existente

Cenário 06: Validar que o usuário excluído não existe mais
    [Documentation]  Confirma que a deleção foi bem sucedida
    [Tags]    usuarios    crud
    Verificar se o DELETE funcionou

Cenário 07: Verificar se tem regras de adição de usuário
    [Documentation]  Verifica se é possível adicionar um e-mail com caracteres especiais
    [Tags]    usuarios    negativo    bug
    Adicionar usuário com e-mail inválido

Cenário 08: Adiciona um usuário com números no nome
    [Documentation]  Verifica se é possível adicionar um nome com números no lugar de letras
    [Tags]    usuarios    negativo    bug
    Adicionar usuário com números no nome

Cenário 09: Listar todos os usuários cadastrados
    [Documentation]  Lista quais usuários foram cadastrados
    [Tags]    usuarios    smoke
    Listar todos os usuários

Cenário 10: Criar usuário via PUT em ID inexistente (upsert)
    [Documentation]  Tenta criar um usuário com ID inexistente via PUT
    [Tags]    usuarios    crud
    Criar usuário via PUT (upsert)

Cenário 11: Deletar usuário com ID inexistente
    [Documentation]  Deleta usuário com ID inexistente
    [Tags]    usuarios    negativo
    Deletar usuário com ID inexistente

Cenário 12: Cadastrar usuário sem campo nome
    [Documentation]  Não coloca campo nome na hora de cadastrar usuário
    [Tags]    usuarios    negativo    validacao
    Cadastrar usuário sem campo nome

Cenário 13: Cadastrar usuário sem campo password
    [Documentation]  Não coloca campo password na hora de cadastrar usuário
    [Tags]    usuarios    negativo    validacao
    Cadastrar usuário sem campo password

Cenário 14: Cadastrar usuário sem campo administrador
    [Documentation]  Não coloca campo administrador na hora de cadastrar usuário
    [Tags]    usuarios    negativo    validacao
    Cadastrar usuário sem campo administrador

Cenário 15: Cadastrar usuário não administrador com sucesso
    [Documentation]  Não coloca administrador=true na hora de cadastrar usuário
    [Tags]    usuarios    smoke
    Cadastrar usuário não administrador

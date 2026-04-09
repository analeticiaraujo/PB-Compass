*** Settings ***
Documentation     Testes CRUD do endpoint /usuarios — ServeRest
Resource          ../../resources/usuarios_keywords.resource
Suite Setup       Criar Sessão na ServeRest
Suite Teardown    Limpar Usuario Criado

*** Test Cases ***
Cenário 01: Cadastrar um novo usuário com sucesso na ServeRest
    [Documentation]    POST /usuarios com dados válidos deve retornar 201 e persistir o ID.
    [Tags]    usuarios    smoke    crud
    Criar E Cadastrar Usuario
    Validar Usuario Cadastrado Com Sucesso

Cenário 02: Cadastrar um usuário já existente
    [Documentation]    POST com e-mail já cadastrado deve retornar 400 com mensagem de conflito.
    [Tags]    usuarios    negativo
    Cadastrar Usuario Duplicado E Validar Conflito

Cenário 03: Buscar usuário pelo ID
    [Documentation]    GET /usuarios/{id} deve retornar 200 com e-mail e _id corretos no corpo.
    [Tags]    usuarios    smoke    crud
    Buscar Usuario Por ID E Validar Dados

Cenário 04: Atualizar dados do usuário existente
    [Documentation]    PUT /usuarios/{id} com novos dados deve retornar 200 com confirmação.
    [Tags]    usuarios    crud
    Atualizar Dados Do Usuario E Validar Confirmacao

Cenário 05: Deletar usuário existente
    [Documentation]    DELETE /usuarios/{id} deve retornar 200 com mensagem de exclusão.
    [Tags]    usuarios    crud
    Deletar Usuario Existente E Validar Confirmacao

Cenário 06: Confirmar que usuário deletado não existe mais
    [Documentation]    GET no ID deletado deve retornar 400 com 'Usuário não encontrado'.
    [Tags]    usuarios    crud
    Confirmar Que Usuario Deletado Retorna Nao Encontrado

Cenário 07: API deve rejeitar e-mail com caractere especial inválido
    [Documentation]    POST com e-mail contendo $$ deve ser rejeitado com 400 (BUG se aceitar).
    [Tags]    usuarios    negativo    bug
    Validar Rejeicao De Email Invalido

Cenário 08: API deve rejeitar nome contendo números
    [Documentation]    POST com nome numérico deve ser rejeitado com 400 (BUG se aceitar).
    [Tags]    usuarios    negativo    bug
    Validar Rejeicao De Nome Com Numeros

Cenário 09: Listar todos os usuários cadastrados
    [Documentation]    GET /usuarios deve retornar 200 com campos 'quantidade' e 'usuarios'.
    [Tags]    usuarios    smoke
    Listar Usuarios E Validar Estrutura Da Resposta

Cenário 10: Criar usuário via PUT em ID inexistente (upsert)
    [Documentation]    PUT em ID inexistente deve criar o usuário com status 201.
    [Tags]    usuarios    crud
    [Teardown]    Run Keyword And Ignore Error    Deletar Usuario Por ID    ${id_upsert}
    ${id_upsert}    Criar Usuario Via Upsert E Validar Criacao

Cenário 11: Deletar usuário com ID inexistente
    [Documentation]    DELETE em ID inexistente deve retornar 200 com 'Nenhum registro excluído'.
    [Tags]    usuarios    negativo
    Deletar Usuario Com ID Inexistente E Validar Mensagem

Cenário 12: Cadastrar usuário sem campo nome
    [Documentation]    POST sem 'nome' deve retornar 400 com mensagem de campo obrigatório.
    [Tags]    usuarios    negativo    validacao
    Cadastrar Usuario Com Campo Ausente E Validar Erro    nome    nome é obrigatório

Cenário 13: Cadastrar usuário sem campo password
    [Documentation]    POST sem 'password' deve retornar 400 com mensagem de campo obrigatório.
    [Tags]    usuarios    negativo    validacao
    Cadastrar Usuario Com Campo Ausente E Validar Erro    password    password é obrigatório

Cenário 14: Cadastrar usuário sem campo administrador
    [Documentation]    POST sem 'administrador' deve retornar 400 com mensagem de campo obrigatório.
    [Tags]    usuarios    negativo    validacao
    Cadastrar Usuario Com Campo Ausente E Validar Erro    administrador    administrador é obrigatório

Cenário 15: Cadastrar usuário não administrador com sucesso
    [Documentation]    POST com administrador=false deve retornar 201 com mensagem de sucesso.
    [Tags]    usuarios    smoke
    [Teardown]    Run Keyword And Ignore Error    Deletar Usuario Por ID    ${id_nao_admin}
    ${id_nao_admin}    Cadastrar Usuario Nao Administrador E Validar Criacao

Cenário 16: Cadastrar usuário sem campo email
    [Documentation]    POST sem 'email' deve retornar 400 com mensagem de campo obrigatório.
    [Tags]    usuarios    negativo    validacao
    Cadastrar Usuario Com Campo Ausente E Validar Erro    email    email é obrigatório

*** Settings ***
Documentation     Testes CRUD do endpoint /usuarios — ServeRest
Resource          ../../resources/keywords/usuarios/usuarios_keywords.resource
Suite Setup       Criar Sessão na ServeRest
Suite Teardown    Limpar Usuario Criado

*** Test Cases ***
CT01: Cadastrar um novo usuário com sucesso na ServeRest
    [Documentation]    POST /usuarios com dados válidos deve retornar 201 e persistir o ID.
    [Tags]    usuarios    smoke    crud    ct01
    Criar E Cadastrar Usuario
    Validar Usuario Cadastrado Com Sucesso

CT02: Cadastrar um usuário já existente
    [Documentation]    POST com e-mail já cadastrado deve retornar 400 com mensagem de conflito.
    [Tags]    usuarios    negativo    ct02
    Cadastrar Usuario Duplicado E Validar Conflito

CT03: Buscar usuário pelo ID
    [Documentation]    GET /usuarios/{id} deve retornar 200 com e-mail e _id corretos no corpo.
    [Tags]    usuarios    smoke    crud    ct03
    Buscar Usuario Por ID E Validar Dados

CT04: Atualizar dados do usuário existente
    [Documentation]    PUT /usuarios/{id} com novos dados deve retornar 200 com confirmação.
    [Tags]    usuarios    crud    ct04
    Atualizar Dados Do Usuario E Validar Confirmacao

CT05: Deletar usuário existente
    [Documentation]    DELETE /usuarios/{id} deve retornar 200 com mensagem de exclusão.
    [Tags]    usuarios    crud    ct05
    Deletar Usuario Existente E Validar Confirmacao

CT06: Confirmar que usuário deletado não existe mais
    [Documentation]    GET no ID deletado deve retornar 400 com 'Usuário não encontrado'.
    [Tags]    usuarios    crud    ct06
    Confirmar Que Usuario Deletado Retorna Nao Encontrado

CT07: API deve rejeitar e-mail com caractere especial inválido
    [Documentation]    POST com e-mail contendo $$ deve ser rejeitado com 400 (BUG se aceitar).
    [Tags]    usuarios    negativo    bug    ct07
    Validar Rejeicao De Email Invalido

CT08: API deve rejeitar nome contendo números
    [Documentation]    POST com nome numérico deve ser rejeitado com 400 (BUG se aceitar).
    [Tags]    usuarios    negativo    bug    ct08
    Validar Rejeicao De Nome Com Numeros

CT09: Listar todos os usuários cadastrados
    [Documentation]    GET /usuarios deve retornar 200 com campos 'quantidade' e 'usuarios'.
    [Tags]    usuarios    smoke    ct09
    Listar Usuarios E Validar Estrutura Da Resposta

CT10: Criar usuário via PUT em ID inexistente (upsert)
    [Documentation]    PUT em ID inexistente deve criar o usuário com status 201.
    [Tags]    usuarios    crud    ct10
    [Teardown]    Run Keyword And Ignore Error    Deletar Usuario Por ID    ${id_upsert}
    ${id_upsert}    Criar Usuario Via Upsert E Validar Criacao

CT11: Deletar usuário com ID inexistente
    [Documentation]    DELETE em ID inexistente deve retornar 200 com 'Nenhum registro excluído'.
    [Tags]    usuarios    negativo    ct11
    Deletar Usuario Com ID Inexistente E Validar Mensagem

CT12: Cadastrar usuário sem campo nome
    [Documentation]    POST sem 'nome' deve retornar 400 com mensagem de campo obrigatório.
    [Tags]    usuarios    negativo    validacao    ct12
    Cadastrar Usuario Com Campo Ausente E Validar Erro    nome    nome é obrigatório

CT13: Cadastrar usuário sem campo password
    [Documentation]    POST sem 'password' deve retornar 400 com mensagem de campo obrigatório.
    [Tags]    usuarios    negativo    validacao    ct13
    Cadastrar Usuario Com Campo Ausente E Validar Erro    password    password é obrigatório

CT14: Cadastrar usuário sem campo administrador
    [Documentation]    POST sem 'administrador' deve retornar 400 com mensagem de campo obrigatório.
    [Tags]    usuarios    negativo    validacao    ct14
    Cadastrar Usuario Com Campo Ausente E Validar Erro    administrador    administrador é obrigatório

CT15: Cadastrar usuário não administrador com sucesso
    [Documentation]    POST com administrador=false deve retornar 201 com mensagem de sucesso.
    [Tags]    usuarios    smoke    ct15
    [Teardown]    Run Keyword And Ignore Error    Deletar Usuario Por ID    ${id_nao_admin}
    ${id_nao_admin}    Cadastrar Usuario Nao Administrador E Validar Criacao

CT16: Cadastrar usuário sem campo email
    [Documentation]    POST sem 'email' deve retornar 400 com mensagem de campo obrigatório.
    [Tags]    usuarios    negativo    validacao    ct16
    Cadastrar Usuario Com Campo Ausente E Validar Erro    email    email é obrigatório

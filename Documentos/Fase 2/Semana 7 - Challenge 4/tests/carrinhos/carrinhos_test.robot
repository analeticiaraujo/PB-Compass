*** Settings ***
Documentation     Testes do endpoint /carrinhos — ServeRest
Resource          ../../resources/usuarios_keywords.resource
Resource          ../../resources/carrinhos_keywords.resource
Suite Setup       Criar Sessão na ServeRest

*** Test Cases ***
Cenário 01: Listar todos os carrinhos
    [Documentation]    GET /carrinhos deve retornar 200 com campos 'quantidade' e 'carrinhos'.
    [Tags]    carrinhos    smoke
    Listar Carrinhos E Validar Estrutura Da Resposta

*** Settings ***
Resource  ../resources/CompassServerest.resource

*** Variables ***


*** Test Cases ***
Cenário 01: Cadastrar um novo usuário com sucesso na ServeRest
    Criar um novo usuário
    Criar Sessão na ServeRest
    Cadastrar o usuário criado na ServeRest
    # Conferir se o usuário foi cadastrado corretamente

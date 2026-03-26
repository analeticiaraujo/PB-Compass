*** Settings ***
Library    RequestsLibrary
Library    String

*** Variables ***
${BASE_URL}           https://compassuol.serverest.dev
${ALIAS}              ServeRest
${NOME_PADRAO}        Fulano da Silva
${SENHA_PADRAO}       1234
${DOMINIO_EMAIL}      @emailtest.com
${EMAIL_TEST}         ${EMPTY}
${ID_USUARIO_CRIADO}  ${NONE}

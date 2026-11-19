# LeafEat Mobile

Aplicativo multiplataforma do **LeafEat**, desenvolvido em Flutter, para consulta de estabelecimentos e pratos, acompanhamento nutricional e avaliação de experiências presenciais.

O aplicativo possui experiências específicas para três perfis:

- **visitante:** consulta pública de estabelecimentos, pratos e informações nutricionais;
- **cliente:** favoritos, preferências alimentares, visitas, avaliações e acompanhamento nutricional;
- **restaurante:** painel, cardápio, receitas, catálogo nutricional, visitas e avaliações recebidas.

O Mobile consome a [LeafEat API](https://github.com/MarchonGa/LeafEat-API). A branch de desenvolvimento atual é `refactor/initial-architecture`.

---

## Estado atual

O projeto está funcional como MVP integrado à API local.

Validação mais recente:

- `flutter analyze` sem problemas;
- **44 testes automatizados aprovados**;
- execução web validada no Chrome;
- autenticação e persistência de sessão integradas à API;
- fluxo de visita, confirmação e avaliação integrado de ponta a ponta.

As funcionalidades de mapa real, QR Code e auditoria nutricional foram deliberadamente deixadas para etapas posteriores.

---

## Tecnologias

- Flutter;
- Dart;
- Material Design;
- `http` para comunicação REST;
- `shared_preferences` para persistência local da sessão;
- Flutter Test para testes unitários e de widgets;
- suporte atual para Web e estrutura compatível com Android.

Versões declaradas no projeto:

- Dart SDK: `^3.13.1`;
- aplicação: `1.0.0+1`.

---

## Pré-requisitos

- Flutter instalado e configurado;
- Chrome para execução web;
- Git;
- LeafEat API executando em `http://localhost:5000`;
- PostgreSQL disponível para a API.

Verifique o ambiente:

```powershell
flutter doctor
flutter devices
```

---

## Executar o projeto

### 1. Iniciar a API

Em outro terminal:

```powershell
cd C:\Users\31976\develop\LeafEat-API
dotnet run --project src\LeafEat.Api
```

A API deverá responder em `http://localhost:5000`.

### 2. Atualizar, validar e executar o Mobile

```powershell
cd C:\Users\31976\develop\LeafEat-Mobile
git pull --ff-only origin refactor/initial-architecture
flutter pub get
flutter analyze
flutter test
flutter run -d chrome --web-port 5173
```

O aplicativo será aberto em `http://localhost:5173`.

### Encerrar

No terminal do Flutter ou da API:

```text
Ctrl + C
```

Durante a execução do Flutter:

- `r`: hot reload;
- `R`: hot restart;
- `q`: encerrar a execução.

---

## Configuração da API

O endereço padrão é definido em `lib/core/config/api_config.dart`:

```text
http://localhost:5000
```

Para usar outro endereço:

```powershell
flutter run -d chrome --web-port 5173 --dart-define=API_BASE_URL=http://SEU_ENDERECO:5000
```

### Android

No emulador Android, o computador normalmente é acessado por:

```text
http://10.0.2.2:5000
```

Em celular físico, use o IP do computador na rede local e configure a API para aceitar conexões nesse endereço.

---

## Arquitetura

O projeto utiliza organização **feature-first**, separando o código por funcionalidade.

```text
lib/
├── app/
│   ├── app.dart
│   ├── navigation/
│   └── session/
├── core/
│   ├── config/
│   ├── input/
│   ├── network/
│   └── theme/
├── features/
│   ├── auth/
│   ├── customer/
│   ├── establishments/
│   ├── explore/
│   ├── map/
│   ├── profile/
│   ├── restaurant/
│   ├── review/
│   └── welcome/
└── main.dart
```

Cada feature pode conter:

- `data`: repositórios, DTOs e integração com a API;
- `domain`: modelos e regras da funcionalidade;
- `presentation`: páginas, widgets e estado de interface.

### Componentes centrais

- `AppSession`: controla token, usuário, perfil ativo e persistência da sessão;
- `ApiClient`: centraliza requisições GET, POST, PUT e DELETE;
- `ApiException`: padroniza erros retornados pela API;
- `MainNavigation`: alterna a navegação conforme o perfil;
- `AppTheme` e `AppColors`: centralizam a identidade visual.

---

## Perfis e navegação

### Visitante

O visitante pode:

- acessar a tela inicial;
- consultar estabelecimentos;
- pesquisar e filtrar locais;
- visualizar cardápios;
- abrir detalhes dos pratos;
- consultar valores nutricionais;
- visualizar selos;
- visualizar notas e avaliações públicas dos pratos;
- consultar respostas públicas dos restaurantes.

Recursos privados permanecem bloqueados e direcionam o usuário para login ou cadastro.

### Cliente

A navegação inferior do cliente contém:

- **Mapa**;
- **Explorar**;
- **Avaliar**;
- **Perfil**.

### Restaurante

A navegação inferior do restaurante contém:

- **Início**;
- **Cardápio**;
- **Avaliações**;
- **Perfil**.

A API impede que uma conta autenticada utilize permissões de outro perfil apenas por alternar a visualização.

---

## Funcionalidades implementadas

### Autenticação e sessão

- cadastro de cliente;
- cadastro de restaurante;
- login;
- confirmação de senha;
- validação dos requisitos de senha;
- sessão JWT;
- restauração automática da sessão;
- logout;
- distinção entre cliente e restaurante;
- tratamento visual de erros da API.

### Cadastro de cliente

- nome;
- e-mail;
- senha;
- confirmação de senha;
- preferências e restrições alimentares;
- intolerância à lactose;
- alergias, como camarão e amendoim;
- edição posterior do perfil;
- alteração de senha.

### Cadastro de restaurante

- dados de acesso;
- nome do responsável/restaurante;
- CNPJ;
- CEP;
- número;
- bairro;
- descrição e categoria;
- edição posterior do perfil;
- alteração de senha.

### Exploração pública

- listagem de estabelecimentos;
- pesquisa;
- filtros;
- detalhes do estabelecimento;
- endereço e categoria;
- cardápio;
- detalhes de cada prato;
- preço;
- calorias e macronutrientes;
- identificação de opções veganas e sem lactose;
- atualização dos dados pela API;
- estados de carregamento, vazio e erro.

### Selos nutricionais

A cobertura nutricional do cardápio determina o selo:

- menos de 10%: sem selo;
- de 10% até 49,99%: Bronze;
- de 50% até 99,99%: Prata;
- 100%: Ouro.

O selo representa cobertura de informações e não auditoria ou certificação dos dados fornecidos.

### Favoritos

O cliente pode:

- favoritar estabelecimentos;
- remover favoritos;
- consultar os locais salvos;
- manter os favoritos persistidos na API.

### Visitas e confirmação presencial

Fluxo implementado:

1. o cliente abre um prato;
2. informa data e horário aproximados;
3. a API gera um código de confirmação;
4. o código fica disponível em **Minhas visitas**;
5. o restaurante visualiza a visita;
6. o restaurante confirma com o código ou marca ausência;
7. após a confirmação, a avaliação é liberada;
8. cada visita permite somente uma avaliação.

Também é possível cancelar uma visita ainda agendada.

### Avaliações do cliente

- avaliações pendentes separadas das realizadas;
- nota do prato;
- nota do ambiente;
- comentário;
- vínculo obrigatório com visita confirmada;
- histórico das avaliações próprias;
- visualização de resposta do restaurante;
- indicação de resposta pendente;
- contadores de útil e não útil.

### Avaliações vinculadas ao prato

As avaliações públicas são exibidas no detalhe do prato.

- a nota do prato utiliza apenas `dishRating`;
- a nota do restaurante utiliza `environmentRating`;
- cada prato possui média e quantidade próprias;
- pratos sem avaliações mostram estrela vazada e traço;
- votos de utilidade não alteram a média em estrelas;
- o autor não pode votar na própria avaliação.

### Perfil público e privacidade

O cliente pode definir como seu nome aparece publicamente:

- primeiro nome;
- nome mascarado;
- apelido;
- anônimo.

Preferências alimentares públicas só são exibidas com autorização do cliente. O e-mail não é exposto nas avaliações.

### Acompanhamento nutricional

- resumo diário;
- calorias;
- proteínas;
- carboidratos;
- gorduras;
- fibras;
- registro de refeições;
- registro de refeição externa;
- remoção de registros;
- seleção de data;
- metas nutricionais opcionais;
- edição de metas;
- cálculo calórico a partir dos macronutrientes;
- comparação entre consumo e meta.

### Preferências alimentares

Área centralizada para:

- preferência vegana;
- preferência por opções sem lactose;
- restrições alimentares;
- alergias;
- preferência por cardápios com métricas nutricionais.

### Painel do restaurante

- identificação do estabelecimento autenticado;
- total de pratos;
- quantidade de pratos com informação nutricional;
- percentual de cobertura;
- selo atual;
- quantidade de avaliações;
- média do ambiente;
- atalhos para as áreas administrativas.

### Gestão do cardápio

O restaurante pode:

- cadastrar prato;
- editar prato;
- excluir prato;
- definir nome, descrição e preço;
- informar características veganas e sem lactose;
- montar composição nutricional;
- utilizar receitas e alimentos cadastrados;
- visualizar cálculo automático de calorias e nutrientes.

### Catálogo nutricional TACO

- consulta ao catálogo da TACO;
- pesquisa sem acentos;
- paginação;
- filtro por categoria;
- filtro por preparação;
- nutrientes por 100 g;
- cálculo proporcional pela quantidade utilizada.

### Receitas e itens personalizados

O restaurante pode criar itens:

- compostos por alimentos da TACO;
- compostos por outras receitas;
- informados manualmente por rótulo nutricional;
- com quantidade e porção de referência;
- com cálculo de nutrientes totais e por 100 g.

### Gestão de visitas pelo restaurante

- listagem de clientes que informaram comparecimento;
- identificação do prato e horário;
- confirmação por código;
- registro de não comparecimento;
- atualização do histórico.

### Gestão de avaliações pelo restaurante

- avaliações recebidas;
- identificação do prato;
- nota do prato e do ambiente;
- confirmação da presença;
- totais de útil e não útil;
- perfil público do autor;
- resposta pública;
- edição da resposta;
- anotação interna privada;
- data da visita e da confirmação.

---

## Testes

Executar análise estática:

```powershell
flutter analyze
```

Executar todos os testes:

```powershell
flutter test
```

Executar um arquivo específico:

```powershell
flutter test test\visit_confirmation_test.dart
```

A suíte cobre, entre outros pontos:

- navegação;
- autenticação e formulários;
- modelos e serialização;
- selos;
- pratos e calorias;
- preferências;
- metas nutricionais;
- acompanhamento diário;
- visitas;
- confirmação de presença;
- avaliações;
- respostas e anotações;
- itens personalizados.

---

## Dados de demonstração

Mocks foram preservados para desenvolvimento visual e fallback em algumas telas. Os fluxos reais de autenticação, favoritos, cardápio, visitas, avaliações, preferências e acompanhamento nutricional utilizam a API quando há sessão e backend disponíveis.

Os mocks não substituem a validação integrada com PostgreSQL.

---

## O que ainda precisa ser feito

### Para concluir formalmente o MVP

- executar roteiro manual completo em ambiente limpo;
- validar persistência após reiniciar API e aplicativo;
- testar em diferentes tamanhos de tela;
- testar em dispositivo Android ou emulador;
- revisar textos, estados vazios e mensagens de erro;
- atualizar descrição e finalizar o PR;
- criar e revisar o PR correspondente da API;
- preparar contas e dados para demonstração.

### Planejado para etapas futuras

- mapa real com geolocalização;
- cálculo real de distância;
- confirmação de presença por QR Code;
- auditoria dos dados nutricionais;
- upload de imagens de restaurantes e pratos;
- recuperação de senha;
- verificação de e-mail;
- notificações;
- paginação para históricos extensos;
- acessibilidade ampliada;
- internacionalização;
- modo escuro;
- funcionamento offline e sincronização;
- publicação Android e iOS;
- deploy web de produção.

### Melhorias técnicas antes de produção

- testes end-to-end;
- cobertura de falhas de rede e expiração de token;
- armazenamento seguro do token em dispositivos móveis;
- telemetria e monitoramento;
- configuração de CI/CD;
- versionamento de releases;
- redução e organização do PR atual;
- revisão de desempenho e responsividade.

---

## Escopo não incluído nesta etapa

- mapa interativo real;
- QR Code;
- auditoria ou certificação nutricional;
- pagamentos;
- pedidos e entrega;
- integração com sistemas comerciais do restaurante.

---

## Repositório relacionado

Backend:

- [LeafEat API](https://github.com/MarchonGa/LeafEat-API)

---

## Observação

O LeafEat está em desenvolvimento acadêmico. Informações nutricionais cadastradas pelos restaurantes devem ser tratadas como informativas até que exista um processo de auditoria.

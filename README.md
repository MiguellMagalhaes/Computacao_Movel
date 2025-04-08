--------------------------------------------------
Explicação do Projeto Mediador de Seguros
--------------------------------------------------

O projeto Mediador de Seguros é uma aplicação Flutter que permite a interação entre clientes e um mediador de seguros. Cada tipo de utilizador possui funcionalidades específicas. A seguir, encontram-se informações sobre a organização do projeto, as suas funcionalidades e os requisitos para executá-lo.

--------------------------------------------------
1. Estrutura Geral do Projeto
--------------------------------------------------

1.1. lib/screens  
- cliente: Telas específicas para os utilizadores com o papel "cliente" (por exemplo, Pedir Orçamento, Ver Orçamentos, Apólices Ativas, etc.).  
- mediador: Telas específicas para os utilizadores com o papel "mediador" (por exemplo, Lista de Seguradoras, Responder Orçamento, Apólices Ativas, etc.).  
- settings: Telas de configurações (alterar tema, informações pessoais, etc.).  
- login: Tela de login.  
- home: Tela principal que redireciona para as funcionalidades de acordo com o papel do utilizador.  
- splash: Tela inicial para verificação de autenticação, encaminhando para Home ou Login.

1.2. lib/models  
Contém classes de modelo (por exemplo, Seguradora, PigeonUserDetails) que representam os dados manipulados pelo projeto.

1.3. lib/services  
Arquivos responsáveis pela comunicação com APIs (como OpenWeather e Car API) e com o Firebase (através do AuthService).

1.4. lib/widgets  
Widgets reutilizáveis, como o MainDrawer, que apresenta o menu lateral de configurações.

1.5. assets  
Pasta onde são armazenadas as imagens utilizadas no projeto (ícone da aplicação, logótipos, etc.).

1.6. pubspec.yaml  
Arquivo de configuração onde são definidas as dependências (Firebase, http, shared_preferences, etc.), os assets e outras configurações do projeto.

1.7. firebase_options.dart  
Arquivo gerado pela FlutterFire CLI, que contém as configurações e as chaves necessárias para a ligação ao Firebase (para Android, iOS, etc.).

1.8. main.dart  
Ponto de entrada da aplicação. Este ficheiro inicializa o Firebase, carrega as preferências de tema e configura as rotas iniciais (Splash, Login, Home, etc.).

--------------------------------------------------
2. Funcionalidades Principais
--------------------------------------------------

2.1. Login e Registo  
- Login: Tela de login (LoginScreen) para a autenticação via e-mail/senha.  
- Registo: Opções de registo para dois papéis (RegisterClientScreen e RegisterMediadorScreen).

2.2. Gestão de Temas  
- Possibilidade de alternar entre o tema claro e o escuro, com a preferência armazenada através de SharedPreferences.

2.3. Splash Screen  
- Verifica se existe um utilizador autenticado e redireciona para a HomeScreen ou para a LoginScreen.

2.4. Home Screen  
- Exibe diferentes opções consoante o papel do utilizador:
  - Mediador: Acesso à lista de seguradoras, aos pedidos de orçamento e às apólices ativas.
  - Cliente: Opções para pedir orçamentos, ver orçamentos respondidos e gerir as apólices ativas.

2.5. Funcionalidades de Cliente  
- Pedir Orçamento: Preenchimento de dados para seguros de Habitação, Vida, Automóvel ou Trabalho. Cria um documento no Firestore com o estado "pendente".  
- Ver Orçamentos: Exibição dos orçamentos com o estado "respondido".  
- Apólices Ativas: Consulta das apólices, com possibilidade de cancelar ou antecipar.

2.6. Funcionalidades de Mediador  
- Lista de Seguradoras: Criação, edição e remoção de seguradoras no Firestore.  
- Pedidos de Orçamento Pendentes: Visualização de todos os pedidos com o estado "pendente" e resposta com valores para cada seguradora.  
- Apólices Ativas: Exibição das informações de todas as apólices ativas.

2.7. Integrações Externas  
- Car API (NHTSA): Obtenção da lista de marcas/modelos para o seguro automóvel.  
- OpenWeather: Fornecimento de condições climáticas (útil para seguros de habitação).  
- Firebase Auth e Firestore: Gerem a autenticação, a base de dados de orçamentos, as apólices, as seguradoras e os dados dos utilizadores.

2.8. Configurações (Settings)  
- Opções para alterar o tema (claro/escuro) e aceder à área de Informações Pessoais, entre outras configurações.

--------------------------------------------------
3. O Que é Necessário para Rodar o Projeto
--------------------------------------------------

3.1. Flutter e Dart  
- Ter o Flutter instalado (versão >= 3.6.0) e devidamente configurado.  
- Garantir que o SDK Dart está conforme especificado no pubspec.yaml.

3.2. Firebase  
- Possuir uma conta no Firebase e configurar o projeto (conforme refletido no ficheiro firebase_options.dart).  
- Configurar os ficheiros google-services.json (Android) e GoogleService-Info.plist (iOS), se aplicável.

3.3. Dependências  
- Executar o comando "flutter pub get" para instalar as seguintes dependências:
  - firebase_core, firebase_auth, cloud_firestore
  - shared_preferences
  - http
  - provider (opcional)
  - flutter_launcher_icons (opcional, para a geração de ícones)

3.4. Configurações de Ambiente  
- Para Android: Ter o Android Studio ou o SDK do Android instalado.  
- Para iOS: Necessário ter o Xcode e um ambiente Mac.

3.5. Execução  
- Certifique-se de que existe um emulador ou dispositivo físico disponível.  
- No terminal, execute os seguintes comandos:
  
  flutter pub get  
  flutter run

Estes comandos instalam as dependências, compilam o projeto e o executam no dispositivo selecionado.

--------------------------------------------------
4. Conclusão
--------------------------------------------------

O projeto Mediador de Seguros integra funcionalidades para:

• Cliente: Solicitar orçamentos e gerir as apólices.  
• Mediador: Responder aos orçamentos e gerir as seguradoras.

Utiliza o Firebase (Auth/Firestore), integra serviços externos (Car API e OpenWeather) e suporta temas claro e escuro na aplicação Flutter.

Para executar o projeto, é necessário:
1. Ter o Flutter e o ambiente de desenvolvimento configurados.
2. Executar "flutter pub get" para instalar as dependências.
3. Executar "flutter run" para compilar e iniciar a aplicação.

As configurações de ligação ao Firebase encontram-se definidas no ficheiro firebase_options.dart; ajuste-as conforme necessário para o seu ambiente.

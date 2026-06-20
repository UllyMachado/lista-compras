# 🛒 App Lista de Compras

Um aplicativo de Lista de Compras intuitivo, moderno e financeiramente inteligente, desenvolvido em **Flutter**. O aplicativo oferece suporte a múltiplas listas, controle detalhado de orçamento, visualização de estatísticas, compartilhamento nativo e um sistema de navegação fluido.

---

## 📱 Visão Geral

O projeto une a tradicional criação de listas de supermercado com o gerenciamento do seu limite de gastos. Conforme você marca os itens no carrinho, o aplicativo calcula automaticamente em tempo real quanto dinheiro ainda resta ou se o carrinho ultrapassou o orçamento estipulado.

Adicionalmente, o app se conecta a um backend com Inteligência Artificial para converter receitas em linguagem natural em listas de compras e gerencia de forma dinâmica categorias, badges de itens e relatórios de progresso em tempo real.

---

## 🔐 Credenciais de Teste

A aplicação é pré-semeada com um usuário de demonstração padrão para testes locais:

*   **E-mail:** `admin@gmail.com`
*   **Senha:** `123456`

---

## 🛠️ Stack Tecnológico Atualizado

O projeto utiliza um conjunto de bibliotecas modernas que atendem aos padrões de engenharia de software do mercado:

1.  **Framework Base:** [Flutter](https://flutter.dev/) (para compilação multiplataforma).
2.  **Gerenciamento de Estado:** `Provider` — separa de forma reativa a sessão de autenticação (`AuthProvider`) e a lógica de compras (`ShoppingProvider`).
3.  **Roteamento:** `go_router` — navegação declarativa com segurança e tratamento automático de redirecionamentos.
4.  **Comunicação API (REST):**
    *   `Chopper` — chamadas HTTP tipadas e autogeradas com base na especificação OpenAPI do backend.
    *   `Dio` — cliente HTTP robusto e otimizado utilizado para operações de autenticação.
5.  **Persistência de Dados Local (Segurança):**
    *   `flutter_secure_storage` — armazena tokens JWT (Access e Refresh tokens) utilizando as chaves de segurança nativas do hardware (*Keystore* / *Keychain*).
6.  **Estatísticas e Gráficos:**
    *   `fl_chart` — renderiza gráficos de pizza responsivos que ilustram a proporção de itens comprados vs. pendentes.
7.  **Compartilhamento Nativo:**
    *   `share_plus` — formata a lista de compras e dispara o menu de compartilhamento nativo do dispositivo (WhatsApp, e-mail, notas, etc.).

---

## 🚀 Como Executar o Projeto Localmente

### Pré-requisitos
*   **Flutter SDK** (versão 3.24+ recomendada)
*   **Java Development Kit (JDK) 21** (para o backend)
*   Emulador ativo (Android/iOS) ou navegador de internet (Chrome/Edge) para execução do frontend.

---

### Passo 1: Executar o Backend (Spring Boot)

1.  Navegue até o diretório do backend:
    ```bash
    cd C:\Workspace\Projetos\lista-compras-backend
    ```
2.  *(Opcional)* Crie o arquivo `.env` para suporte ao Assistente de Receitas com IA:
    ```env
    AI_API_KEY=sua_chave_de_api_aqui
    AI_API_URL=https://api.groq.com/openai/v1/chat/completions
    AI_API_MODEL=llama-3.1-8b-instant
    ```
3.  Execute a aplicação via Gradle wrapper:
    ```bash
    ./gradlew bootRun
    ```
    *O backend rodará em `http://localhost:8090` e criará automaticamente as tabelas no banco PostgreSQL local (`lista_compras`).*

---

### Passo 2: Executar o Frontend (Flutter)

1.  Navegue até o diretório do frontend:
    ```bash
    cd C:\Workspace\Projetos\lista-compras
    ```
2.  Instale as dependências declaradas:
    ```bash
    flutter pub get
    ```
3.  Execute o aplicativo:
    ```bash
    flutter run
    ```
    *Dica: se estiver rodando no navegador ou emulador, garanta que o backend está ativo e acessível na mesma rede.*

---

## 📁 Estrutura de Pastas (Frontend)

*   `lib/api/` — Arquivos gerados do cliente de API Chopper (`openapi.swagger.dart`).
*   `lib/core/` — Configurações globais (`config.dart`), rotas (`router.dart`) e temas (`theme.dart`).
*   `lib/models/` — Estruturas locais de representação de dados.
*   `lib/providers/` — Regras de negócio em memória e reatividade (`auth_provider.dart`, `shopping_provider.dart`).
*   `lib/screens/` — Telas de Login, Dashboard (Carrossel Infinito), Edição de Itens e Gestão de Categorias.
*   `lib/services/` — Mecanismos de infraestrutura (TokenStorage, AuthInterceptor, AuthService).
*   `lib/widgets/` — Componentes reaproveitáveis (como Drawer lateral e a Bottom Sheet de Resumo).
*   `test/` — Suíte de testes automatizados (`shopping_list_summary_test.dart`).

# Lista de Compras App

Um aplicativo de Lista de Compras intuitivo, moderno e financeiramente inteligente, desenvolvido em [Flutter](https://flutter.dev/). O aplicativo oferece suporte a múltiplas listas, controle detalhado de orçamento e um sistema de navegação fluido, tornando o momento das compras mais organizado e livre de estresse.

## 📱 Visão Geral

O projeto foi pensado com a finalidade de unir a tradicional criação de listas de supermercado com o gerenciamento do seu limite de gastos (orçamento). Conforme você marca os itens no carrinho, o aplicativo calcula automaticamente em tempo real quanto dinheiro ainda resta ou se o carrinho ultrapassou o orçamento estipulado.

## ✨ Funcionalidades Principais

* **Autenticação:** Tela de Login inicial focada no usuário.
* **Múltiplas Listas:** É possível criar, gerenciar, renomear e excluir quantas listas forem necessárias (ex: "Compras do Mês", "Festa", "Material de Construção"). As listas são acessíveis de forma fácil e rápida.
* **Carrossel Infinito:** No dashboard principal, você pode alternar facilmente entre suas listas ativas apenas deslizando a tela (swipe). Ao fim do ciclo de listas, o sistema transiciona nativamente para a primeira e vice-versa.
* **Itens e Valores:**
  * Adicione itens na lista informando o nome, quantidade e o preço unitário. O valor total do item é atualizado automaticamente.
  * Checklist para acompanhar os itens que já foram fisicamente adicionados ao seu carrinho de compras.
* **Controle Financeiro (Orçamento e Saldo Atual):**
  * Toda lista possui um campo estipulando seu Orçamento próprio.
  * O Saldo é calculado instantaneamente descontando os **itens já checados/adicionados**. Se for além do orçamento, o saldo fica vermelho no painel!
* **Integração de Menu Avançada:** Um Drawer (menu lateral) presente em todo o fluxo ajuda o usuário a navegar entre a gestão das listas ou acessar opções da sua conta em segundos.

## 🛠️ Tecnologias Utilizadas

* **Framework Base:** [Flutter](https://flutter.dev/) (compatível com Android, iOS e Web).
* **Gestão de Estado:** `Provider` - Separado de forma reativa para isolar as lógicas do Shopping e as sessões de Autenticação (`ShoppingProvider`, `AuthProvider`).
* **Roteamento:** pacote `go_router` atuando com segurança e com redirecionamentos rápidos entre telas com validações (Redirecionamento automático de usuários não logados).
* **Estilização/Fontes:** Fonte do Google `Montserrat` com componentes visuais seguindo perfeitamente o Design System com paleta de cor pré-definida em um arquivo unificado (`core/theme.dart`).

## 🎨 Design System e UI/UX

O aplicativo trabalha em contraste majoritário com base nas seguintes cores mapeadas:
- **Primary:** `0xFFA480F2` (Lilás/Roxo Claro, muito presente nos Headers e Botões)
- **Background (Dark):** `0xFF021140` (Tons profundos p/ botões base e contrastes escuros)
- **Background secundário / Clean:** Branco (`0xFFFFFFFF`), explorado bastante na listagem global via `AppTheme.backgroundList`.
- Alertas Dinâmicos de sucesso ou erro, formatações ricas em popups e um footer sempre intuitivo focado na "criação nova" para melhorar a UX global do usuário.

## 🚀 Como Executar o Projeto Localmente

**Pré-requisitos:**
* Flutter SDK (recomendado para versões recentes 3.24+).
* Emulador Android/iOS ativo, ou navegador web se preferir compilar localmente nele.
* IDE com ferramentas instaladas (VSCode ou Android Studio).

**Passos:**
1. Clone o repositório na sua máquina:
   ```bash
   git clone https://github.com/UllyMachado/lista-compras.git
   ```
2. Entre na pasta do repositório clonado:
   ```bash
   cd lista-compras
   ```
3. Instale / Restaure os pacotes da aplicação (via flutter pub)
   ```bash
   flutter pub get
   ```
4. Execute em seu ambiente favorito (selecionando seu device no terminal/IDEs):
   ```bash
   flutter run
   ```

## 🏗️ Estrutura do Código 

* `lib/core/` - Contém a definição das rotas principais (`router.dart`) e do Design System/Temas globais (`theme.dart`).
* `lib/models/` - As definições dos moldes base do App - os Itens em si (`shopping_item.dart`) e as suas respectivas Listas (`shopping_list.dart`).
* `lib/providers/` - Concentra a inteligência das transações internas e mudanças de estado usando Provider (`shopping_provider.dart`, `auth_provider.dart`).
* `lib/screens/` - Onde cada tela separada vive, como  Login, Criação, Listagem etc.
* `lib/widgets/` - Todo o conjunto de widgets extraídos, reutilizáveis como o menu principal (app drawer).

---
*Desenvolvido focado em Usabilidade e Experiência do Usuário (UX/UI).*

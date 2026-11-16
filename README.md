# Projeto Integrador - Rede Social (PI-4DSN)

Este é um projeto de rede social full-stack desenvolvido como Projeto Integrador. O sistema inclui uma aplicação web, um backend em Java Spring Boot e um aplicativo móvel em Flutter.

## 🚀 Tecnologias Utilizadas

### Backend
- **Linguagem:** Java 17
- **Framework:** Spring Boot 4.x
- **Persistência:** Spring Data JPA / Hibernate
- **Banco de Dados:** MySQL
- **Gerenciamento de Dependências:** Maven
- **Utilitários:** Lombok

### Mobile
- **Framework:** Flutter
- **Linguagem:** Dart
- **Comunicação:** Pacote `http` para integração com API REST

### Web
- **Tecnologias:** HTML, CSS e JavaScript (módulos ES)
- **Comunicação:** API REST do backend

## 📋 Funcionalidades

- **Usuários:** Cadastro, login e perfis.
- **Aparência:** Alternância entre tema claro e escuro, com preferência salva no navegador.
- **Segurança de conta:** Sessões autenticadas, alteração de senha e opção de seguir pessoas.
- **Postagens:** Criação de posts com imagens no Cloudinary e visualização em feed.
- **Interações:** Sistema de likes/dislikes (votos), comentários e compartilhamentos.
- **Comunidades:** Criação e gestão de comunidades temáticas.
- **Eventos:** Inscrições, eventos salvos, fila de espera, agenda e notificações internas.
- **Estatísticas:** Monitoramento de uso e engajamento do usuário.
- **Posts Salvos:** Funcionalidade para favoritar e salvar postagens.

## 📁 Estrutura do Projeto

```text
.
├── java/                 # Backend Spring Boot
├── mobile_flutter/       # Aplicativo Flutter
├── web/                  # Aplicação web
└── desktop/              # Painel administrativo desktop
```

## ⚙️ Configuração e Execução

### 1. Banco de Dados
O backend utiliza MySQL. Inicie o serviço e configure a conexão em `java/src/main/resources/application.properties`. O repositório não contém um `schema.sql` para criar todo o banco; use o banco/schema fornecido para o projeto. Não publique senhas nem outras credenciais no Git.

No MySQL Workbench ou DBeaver, conecte-se ao mesmo banco configurado no backend e aplique, **uma única vez e somente se ainda não tiverem sido aplicadas**, as migrações necessárias:

| Migração | Recurso habilitado |
| --- | --- |
| `java/database/migrations/20261111_add_taxa_repassada_comprador.sql` | Opção de repasse da taxa do ingresso |
| `java/database/migrations/20261112_event_management_features.sql` | Fila de espera, agenda, notificações e lembretes internos de eventos |
| `java/database/migrations/20261112_user_follows.sql` | Seguir pessoas |
| `java/database/migrations/20261112_cloudinary_image_storage.sql` | Identificadores das imagens do Cloudinary no banco |

As migrações com `ALTER TABLE` não devem ser executadas novamente depois de aplicadas. Os lembretes de eventos são notificações internas na web; não há envio por e-mail/push nem processamento de pagamentos reais.

### 2. Backend (Java)
#### Configurar o Cloudinary

Crie uma conta no Cloudinary e obtenha o **Cloud name**, a **API Key** e a **API Secret** no painel da conta. O backend usa essas três variáveis:

- `CLOUDINARY_CLOUD_NAME`
- `CLOUDINARY_API_KEY`
- `CLOUDINARY_API_SECRET`

No Windows, abra um terminal PowerShell na raiz do repositório. Substitua os exemplos pelos valores da sua conta; execute esses comandos apenas localmente e não os salve em arquivos do projeto:

```powershell
$env:CLOUDINARY_CLOUD_NAME = "seu_cloud_name"
$env:CLOUDINARY_API_KEY = "sua_api_key"
$env:CLOUDINARY_API_SECRET = "sua_api_secret"
```

Inicie o backend **no mesmo terminal**, para que ele receba as variáveis:

```powershell
Set-Location .\java
.\mvnw.cmd spring-boot:run
```

A API estará disponível em `http://localhost:8080`. Essas variáveis duram apenas enquanto esse terminal estiver aberto; se abrir outro, configure-as novamente. Em produção, cadastre-as na área de variáveis/secrets da hospedagem, nunca no código.

Para validar a compilação e executar os testes do backend, em outro terminal configurado para usar um banco de teste isolado:

```powershell
Set-Location .\java
.\mvnw.cmd test
```

O teste de contexto do Spring Boot conecta-se ao banco definido em `application.properties`; não execute a suíte apontando para um banco de produção ou compartilhado.

O login e o cadastro retornam um token de sessão com validade de 12 horas. As operações de escrita da API exigem esse token; após reiniciar o backend ou expirar a sessão, entre novamente. As sessões ficam em memória.

Os uploads de perfil e de postagem são enviados pelo backend ao Cloudinary. O banco guarda a URL segura e o identificador usado para substituir ou remover cada imagem. Os arquivos locais existentes continuam acessíveis, mas não são migrados automaticamente. Sem as variáveis do Cloudinary, o backend inicia, mas os uploads de imagens falham com uma mensagem de configuração.

### 3. Web
Com o backend ativo, abra outro terminal na raiz do repositório e inicie o servidor da aplicação web:

```powershell
py -m http.server 5500 --directory web
```

Abra `http://localhost:5500`. Não abra `web/index.html` diretamente como arquivo: a aplicação usa módulos ES e precisa ser servida por HTTP.

Em desenvolvimento, o frontend usa `http://localhost:8080` quando aberto em `localhost` ou `127.0.0.1`. Para outro endereço, configure a meta tag `api-base-url` em `web/index.html` com a origem HTTPS da API. No backend, `APP_CORS_ALLOWED_ORIGINS` aceita uma lista de origens do frontend separadas por vírgulas; o padrão local permite `http://localhost:5500` e `http://127.0.0.1:5500`.

Para uma demonstração, prepare usuários e eventos futuros no banco antes de iniciar. Faça login e teste pelo menos um upload de perfil ou postagem; confirme que o arquivo aparece na Media Library do Cloudinary. A aplicação requer conexão com o banco e internet para enviar e carregar imagens do Cloudinary.

### 4. Mobile (Flutter)
Para rodar o aplicativo:
```powershell
Set-Location .\mobile_flutter
flutter pub get
flutter run
```
*Nota: em um emulador Android, `localhost` aponta para o próprio emulador. Se necessário, ajuste o `baseUrl` em `lib/services/api_service.dart` para o IP da máquina que executa o backend.*

## 🛠️ Endpoints Principais (API)

- `/usuarios`: Gestão de usuários e perfis.
- `/posts`: Criação e listagem de postagens.
- `/comentarios`: Interação em posts.
- `/comunidades`: Exploração e criação de grupos.
- `/votos`: Sistema de curtidas.

## ✅ Checklist para a apresentação

- [ ] Banco correto em execução e migrações necessárias aplicadas.
- [ ] Credenciais do banco e do Cloudinary configuradas sem serem publicadas no repositório.
- [ ] Backend e frontend iniciados e testados antes da banca.
- [ ] Contas de demonstração e dados necessários preparados.
- [ ] Testados login, publicação com imagem e exclusão de um post.
- [ ] Plano alternativo preparado caso haja falha de internet ou do serviço externo.

---
Desenvolvido como parte do currículo do COTIL.

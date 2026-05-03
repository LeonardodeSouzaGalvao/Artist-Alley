# Artist Alley

Projeto interdisciplinar para a faculdade de Engenharia de Software (PUC Minas). O ArtisAlley é uma plataforma distribuída que conecta artistas independentes a clientes interessados em artes personalizadas (comissões), utilizando uma arquitetura orientada a eventos.

---

## Documentação do Projeto

**Sprint 1**

*   **[Proposta de Domínio](./docs/proposta_dominio.pdf):** Descrição do problema, justificativa e perfis de usuário (Cliente e Artista).
*   **[Diagrama de Arquitetura](./docs/diagrama_arquitetura.png):** Representação visual da comunicação entre Flutter, Node.js, RabbitMQ e PostgreSQL.
*   **[Modelagem do Banco de Dados](./docs/modelagem_db.png):** Esquema das tabelas e relacionamentos via Prisma.

---

## Tecnologias Utilizadas

*   **Mobile:** Flutter (Apps distintos para Cliente e Prestador)
*   **Backend:** Node.js com Express e TypeScript
*   **Banco de Dados:** PostgreSQL
*   **Mensageria (MOM):** RabbitMQ
*   **ORM:** Prisma
*   **Storage:** Cloudinary (Imagens)
*   **Containerização:** Docker

---

## Instruções de Instalação (Docker)

Para rodar a infraestrutura necessária (Banco de Dados e Mensageria) de forma isolada, siga os passos abaixo:

### Pré-requisitos
*   Docker Desktop instalado e rodando.
*   Node.js instalado (versão 18 ou superior).

### Passo 1: Subir os Containers
Navegue até a pasta de infraestrutura e inicie os serviços:
```bash
cd infra
docker compose up -d

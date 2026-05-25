# Relatório de Integração do MOM

## Contexto

O backend do Artist Alley adota mensageria orientada a eventos para desacoplar o fluxo de pedidos do processamento assíncrono. A solução atual usa RabbitMQ com `amqplib`, inicializada no boot do servidor e mantida junto da aplicação Node.js.

## Decisões de Design

### Ferramenta escolhida

A ferramenta escolhida foi o RabbitMQ. A decisão foi guiada por três pontos: suporte nativo ao padrão pub/sub, facilidade de execução local com Docker e boa adequação a fluxos de negócio baseados em eventos de domínio. O projeto já expõe a exchange `orders_exchange` e a exchange `commission_exchange`, ambas do tipo `topic`, o que permite evoluir o roteamento sem acoplamento rígido entre produtor e consumidor.

### Padrão utilizado

O padrão adotado é publish/subscribe com exchanges do tipo `topic`.

Os produtores publicam eventos de domínio após operações do negócio, e os consumidores escutam filas vinculadas por routing keys. No fluxo de pedidos, a fila `orders_queue` recebe eventos com o padrão `order.*`; no fluxo de comissões, a fila `commission_queue` recebe eventos com `commission.*`.

### Fluxo assíncrono

A publicação ocorre em pontos distintos do domínio:

- criação do pedido, em `createOrder`
- mudança de status do pedido, em `updateOrderStatus`
- aceitação e rejeição via endpoints específicos, que reaproveitam a atualização de status e também emitem eventos próprios
- enfileiramento de pedido de comissão, durante a criação do pedido

O consumidor é iniciado junto com o servidor e processa as mensagens recebidas sem chamada REST direta entre produtor e consumidor. Hoje ele faz log e acknowledge da mensagem, servindo como prova de integração assíncrona e como base para futuras projeções ou integrações adicionais.

## Tabela de Eventos

| Evento | Produtor | Consumidor | Payload JSON de exemplo | Tópico/Fila |
|---|---|---|---|---|
| `ORDER_CREATED` | `src/services/eventService.ts` via `createOrder` | `src/lib/consumers.ts` | `{ "type": "ORDER_CREATED", "orderId": "ord_123", "clientId": "cli_1", "artistId": "art_1", "commissionSlotId": "slot_1", "description": "Retrato digital", "referenceImage": "https://...", "createdAt": "2026-05-25T12:00:00.000Z" }` | `orders_exchange` / `order.order_created` / `orders_queue` |
| `ORDER_ACCEPTED` | `src/routes/orders.ts` | `src/lib/consumers.ts` | `{ "type": "ORDER_ACCEPTED", "orderId": "ord_123", "artistId": "art_1", "acceptedAt": "2026-05-25T12:05:00.000Z" }` | `orders_exchange` / `order.order_accepted` / `orders_queue` |
| `ORDER_REJECTED` | `src/routes/orders.ts` | `src/lib/consumers.ts` | `{ "type": "ORDER_REJECTED", "orderId": "ord_123", "artistId": "art_1", "rejectedAt": "2026-05-25T12:05:00.000Z" }` | `orders_exchange` / `order.order_rejected` / `orders_queue` |
| `ORDER_STATUS_CHANGED` | `src/services/orderService.ts` via `updateOrderStatus` | `src/lib/consumers.ts` | `{ "type": "ORDER_STATUS_CHANGED", "orderId": "ord_123", "artistId": "art_1", "status": "ACCEPTED", "changedAt": "2026-05-25T12:05:00.000Z" }` | `orders_exchange` / `order.order_status_changed` / `orders_queue` |
| `COMMISSION_ORDER_QUEUED` | `src/services/eventService.ts` via `createOrder` | `src/lib/consumers.ts` | `{ "type": "COMMISSION_ORDER_QUEUED", "orderId": "ord_123", "commissionSlotId": "slot_1", "clientId": "cli_1", "artistId": "art_1", "queuePosition": 1, "totalOrders": 4, "createdAt": "2026-05-25T12:00:00.000Z" }` | `commission_exchange` / `commission.commission_order_queued` / `commission_queue` |


## Evidência de Funcionamento
![Log de eventos recebidos no consumidor](./docs/TerminalComLogsMensageria.png)
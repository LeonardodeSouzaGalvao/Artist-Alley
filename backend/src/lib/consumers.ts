import { getChannel, ORDERS_QUEUE, COMMISSION_QUEUE } from './rabbitmq';
import { CommissionEvent, OrderEvent } from '../types/events';

export async function startConsumers() {
  try {
    const channel = getChannel();

    await channel.consume(ORDERS_QUEUE, async (msg: any) => {
      if (!msg) {
        return;
      }

      try {
        const event: OrderEvent = JSON.parse(msg.content.toString());

        console.log(`!!! Evento recebido: ${event.type} !!!`);

        switch (event.type) {
          case 'ORDER_CREATED':
            console.log(`----- Nova order criada: ${event.orderId} -----`);
            console.log(`-----   Cliente: ${event.clientId} -----`);
            console.log(`-----   Artista: ${event.artistId} -----`);
            break;

          case 'ORDER_ACCEPTED':
            console.log(`----- Order aceita: ${event.orderId} -----`);
            break;

          case 'ORDER_REJECTED':
            console.log(`----- Order rejeitada: ${event.orderId} -----`);
            break;

          case 'ORDER_STATUS_CHANGED':
            console.log(`----- Status alterado: ${event.orderId} -> ${event.status} -----`);
            break;
        }

        channel.ack(msg);
      } catch (error) {
        console.error('----- Erro ao processar evento:', error, ' -----');
        channel.nack(msg, false, true);
      }
    }, { noAck: false });

    await channel.consume(COMMISSION_QUEUE, async (msg: any) => {
      if (!msg) {
        return;
      }

      try {
        const event: CommissionEvent = JSON.parse(msg.content.toString());

        console.log(`!!! Evento de comissão recebido: ${event.type} !!!`);
        console.log(`----- Comissão ${event.commissionSlotId} recebeu a order ${event.orderId} -----`);
        console.log(`----- Posição na fila: ${event.queuePosition}/${event.totalOrders} -----`);

        channel.ack(msg);
      } catch (error) {
        console.error('----- Erro ao processar evento de comissão:', error, ' -----');
        channel.nack(msg, false, true);
      }
    }, { noAck: false });

    console.log('----- Consumidores iniciados -----');
  } catch (error) {
    console.error('----- Erro ao iniciar consumidores:', error, " -----");
    throw error;
  }
}

import amqp from 'amqplib';

const RABBITMQ_URL = process.env.RABBITMQ_URL || 'amqp://guest:guest@localhost:5673';
export const ORDERS_EXCHANGE = 'orders_exchange';
export const ORDERS_QUEUE = 'orders_queue';
export const COMMISSION_EXCHANGE = 'commission_exchange';
export const COMMISSION_QUEUE = 'commission_queue';

let connection: any = null;
let channel: any = null;

export async function connectRabbitMQ() {
  try {
    connection = await amqp.connect(RABBITMQ_URL);
    channel = await connection.createChannel();

    await channel.assertExchange(ORDERS_EXCHANGE, 'topic', { durable: true });
    await channel.assertExchange(COMMISSION_EXCHANGE, 'topic', { durable: true });

    await channel.assertQueue(ORDERS_QUEUE, { durable: true });
    await channel.assertQueue(COMMISSION_QUEUE, { durable: true });

    await channel.bindQueue(ORDERS_QUEUE, ORDERS_EXCHANGE, 'order.*');
    await channel.bindQueue(COMMISSION_QUEUE, COMMISSION_EXCHANGE, 'commission.*');

    console.log('----- RabbitMQ conectado // http://localhost:15673 -----');
    return { connection, channel };
  } catch (error) {
    console.error('----- Erro ao conectar ao RabbitMQ:', error, " -----");
    throw error;
  }
}

export async function publishEvent(eventType: string, payload: any) {
  await publishDomainEvent(ORDERS_EXCHANGE, `order.${eventType.toLowerCase()}`, eventType, payload);
}

export async function publishCommissionEvent(eventType: string, payload: any) {
  await publishDomainEvent(COMMISSION_EXCHANGE, `commission.${eventType.toLowerCase()}`, eventType, payload);
}

async function publishDomainEvent(exchange: string, routingKey: string, eventType: string, payload: any) {
  if (!channel) {
    throw new Error('RabbitMQ channel não inicializado');
  }

  const message = Buffer.from(JSON.stringify({
    type: eventType,
    timestamp: new Date(),
    ...payload,
  }));

  channel.publish(exchange, routingKey, message, { persistent: true });
  console.log(`----- Evento publicado: ${eventType} -----`);
}

export function getChannel() {
  if (!channel) {
    throw new Error('RabbitMQ channel não inicializado');
  }
  return channel;
}

export async function closeRabbitMQ() {
  if (connection) {
    await connection.close?.();
    console.log('----- Conexão RabbitMQ fechada -----');
  }
}

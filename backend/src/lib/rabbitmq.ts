import amqp, { Connection, Channel } from 'amqplib';

const RABBITMQ_URL = process.env.RABBITMQ_URL || 'amqp://guest:guest@localhost:5673';
const ORDERS_EXCHANGE = 'orders_exchange';
const ORDERS_QUEUE = 'orders_queue';

let connection: Connection | null = null;
let channel: Channel | null = null;

export async function connectRabbitMQ() {
  try {
    connection = await amqp.connect(RABBITMQ_URL);
    channel = await connection.createChannel();

    await channel.assertExchange(ORDERS_EXCHANGE, 'topic', { durable: true });

    await channel.assertQueue(ORDERS_QUEUE, { durable: true });

    await channel.bindQueue(ORDERS_QUEUE, ORDERS_EXCHANGE, 'order.*');

    console.log('----- RabbitMQ conectado // http://localhost:15673 -----');
    return { connection, channel };
  } catch (error) {
    console.error('----- Erro ao conectar ao RabbitMQ:', error, " -----");
    throw error;
  }
}

export async function publishEvent(eventType: string, payload: any) {
  if (!channel) {
    throw new Error('RabbitMQ channel não inicializado');
  }

  const routingKey = `order.${eventType.toLowerCase()}`;
  const message = Buffer.from(JSON.stringify({
    type: eventType,
    timestamp: new Date(),
    ...payload,
  }));

  channel.publish(ORDERS_EXCHANGE, routingKey, message, { persistent: true });
  console.log(`----- Evento publicado: ${eventType} -----`);
}

export function getChannel(): Channel {
  if (!channel) {
    throw new Error('RabbitMQ channel não inicializado');
  }
  return channel;
}

export async function closeRabbitMQ() {
  if (connection) {
    await connection.close();
    console.log('----- Conexão RabbitMQ fechada -----');
  }
}

import { publishEvent, publishCommissionEvent } from '../lib/rabbitmq';
import { Order } from './orderService';

export async function publishOrderCreated(order: Order) {
  await publishEvent('ORDER_CREATED', {
    orderId: order.id,
    clientId: order.clientId,
    artistId: order.artistId,
    commissionSlotId: order.commissionSlotId,
    description: order.description,
    referenceImage: order.referenceImage,
    createdAt: order.createdAt,
  });
}

export async function publishOrderAccepted(orderId: string, artistId: string, clientId: string) {
  await publishEvent('ORDER_ACCEPTED', {
    orderId,
    artistId,
    clientId,
    acceptedAt: new Date(),
  });
}

export async function publishOrderRejected(orderId: string, artistId: string, clientId: string) {
  await publishEvent('ORDER_REJECTED', {
    orderId,
    artistId,
    clientId,
    rejectedAt: new Date(),
  });
}

export async function publishOrderStatusChanged(orderId: string, artistId: string, clientId: string, status: string) {
  await publishEvent('ORDER_STATUS_CHANGED', {
    orderId,
    artistId,
    clientId,
    status,
    changedAt: new Date(),
  });
}

export async function publishCommissionOrderQueued(order: Order, queuePosition: number, totalOrders: number) {
  await publishCommissionEvent('COMMISSION_ORDER_QUEUED', {
    orderId: order.id,
    commissionSlotId: order.commissionSlotId,
    clientId: order.clientId,
    artistId: order.artistId,
    queuePosition,
    totalOrders,
    createdAt: order.createdAt,
  });
}

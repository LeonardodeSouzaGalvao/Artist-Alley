import { OrderStatus, Order as PrismaOrder } from '@prisma/client';
import { prisma } from '../lib/prisma';
import * as eventService from './eventService';

export type Order = {
  id: string;
  status: OrderStatus;
  description: string;
  referenceImage: string;
  clientId: string;
  artistId: string;
  commissionSlotId: string;
  createdAt: Date;
  updatedAt: Date;
};

export type CommissionQueueItem = Order & {
  queuePosition: number;
  totalOrders: number;
};

function toOrder(order: PrismaOrder): Order {
  return {
    id: order.id,
    status: order.status,
    description: order.description ?? '',
    referenceImage: order.referenceImage ?? '',
    clientId: order.clientId,
    artistId: order.artistId,
    commissionSlotId: order.commissionSlotId,
    createdAt: order.createdAt,
    updatedAt: order.updatedAt,
  };
}

export async function createOrder(
  clientId: string,
  artistId: string,
  commissionSlotId: string,
  description?: string,
  referenceImage?: string
) {
  const order = await prisma.order.create({
    data: {
      description: description ?? '',
      referenceImage: referenceImage ?? '',
      status: 'PENDING',
      client: {
        connect: { id: clientId },
      },
      artist: {
        connect: { id: artistId },
      },
      commissionSlot: {
        connect: { id: commissionSlotId },
      },
    },
  });

  const orderData = toOrder(order);
  await eventService.publishOrderCreated(orderData);

  const queueOrders = await prisma.order.findMany({
    where: { commissionSlotId },
    orderBy: [
      { createdAt: 'asc' },
      { id: 'asc' },
    ],
  });
  const queuePosition = queueOrders.findIndex((queueOrder) => queueOrder.id === orderData.id) + 1;
  await eventService.publishCommissionOrderQueued(orderData, queuePosition, queueOrders.length);

  return orderData;
}

export async function findByArtistId(artistId: string) {
  const order = await prisma.order.findFirst({ where: { artistId } });
  return order ? toOrder(order) : null;
}

export async function findById(id: string) {
  const order = await prisma.order.findUnique({ where: { id } });
  return order ? toOrder(order) : null;
}


export async function findByClientId(clientId: string) {
  const orders = await prisma.order.findMany({ 
    where: { clientId },
    include: {
      artist: true,
      commissionSlot: true
    }
  });
  return orders;
}

export async function findByCommissionSlotId(commissionSlotId: string) {
  const orders = await prisma.order.findMany({ where: { commissionSlotId } });
  return orders.map(toOrder);
}

export async function updateOrderStatus(id: string, status: OrderStatus) {
  const order = await prisma.order.findUnique({ where: { id } });
  if (!order) {
    throw new Error('Order not found');
  }

  const updatedOrder = await prisma.order.update({
    where: { id },
    data: { status },
  });

  await eventService.publishOrderStatusChanged(id, order.artistId, status);

  return updatedOrder;
}

export async function findCommissionQueueProjectionByCommissionSlotId(commissionSlotId: string) {
  const orders = await prisma.order.findMany({
    where: { commissionSlotId },
    orderBy: [
      { createdAt: 'asc' },
      { id: 'asc' },
    ],
  });

  return orders.map((order, index, allOrders): CommissionQueueItem => ({
    ...toOrder(order),
    queuePosition: index + 1,
    totalOrders: allOrders.length,
  }));
}

export async function deleteOrder(id: string) {
  const order = await prisma.order.delete({ where: { id } });
  return toOrder(order);
}



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
  const orders = await prisma.order.findMany({ where: { clientId } });
  return orders.map(toOrder);
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

  const orderData = toOrder(order);
  
  await eventService.publishOrderStatusChanged(id, order.artistId, status);

  return await prisma.order.update({
    where: { id },
    data: { status },
  });
}

export async function deleteOrder(id: string) {
  const order = await prisma.order.delete({ where: { id } });
  return toOrder(order);
}



import {CommissionSlot as PrismaCommissionSlot } from '@prisma/client';
import { prisma } from '../lib/prisma';

export type CommissionSlot = { id: string; title: string; description: string; price: number ; imageUrl?: string; slots: number; available: boolean };

function toCommissionSlot(commissionSlot: PrismaCommissionSlot): CommissionSlot {
  return {
    id: commissionSlot.id,
    title: commissionSlot.title,
    description: commissionSlot.description ?? '',
    price: commissionSlot.price.toNumber(),
    imageUrl: commissionSlot.imageUrl ?? undefined,
    slots: commissionSlot.slots,
    available: commissionSlot.available,
  };
}

export async function createCommissionSlot(title: string, description: string, price: number, artistId: string, slots: number, imageUrl?: string) {
  const slot = await prisma.commissionSlot.create({
    data: {
        title,
        description,
        price,
        slots,
        available: true,
        imageUrl: imageUrl ?? '',
        artist: {
          connect: { id: artistId },
        },
    },
  });

  return toCommissionSlot(slot);
}

export async function findByArtistId(artistId: string) {
  const slot = await prisma.commissionSlot.findFirst({ where: { artistId } });
  return slot ? toCommissionSlot(slot) : null;
}

export async function findById(id: string) {
  const slot = await prisma.commissionSlot.findUnique({ where: { id } });
  return slot ? toCommissionSlot(slot) : null;
}

export async function findAll() {
  const slots = await prisma.commissionSlot.findMany();
  return slots.map(slot => toCommissionSlot(slot));
}

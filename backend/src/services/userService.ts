import bcrypt from 'bcryptjs';
import { Role, User as PrismaUser } from '@prisma/client';
import { prisma } from '../lib/prisma';

export type User = { id: string; username: string; email: string; role: Role };


function toUser(user: PrismaUser): User {
  return {
    id: user.id,
    username: user.name,
    email: user.email,
    role: user.role,
  };
}

export async function createUser(username: string, password: string, email: string, role: Role) {
  const passwordHash = await bcrypt.hash(password, 10);
  const user = await prisma.user.create({
    data: {
      name: username,
      email,
      password: passwordHash,
      role,
    },
  });

  return toUser(user);
}

export async function findByEmail(email: string) {
  const user = await prisma.user.findUnique({ where: { email } });
  return user ? toUser(user) : null;
}

export async function findById(id: string) {
  const user = await prisma.user.findUnique({ where: { id } });
  return user ? toUser(user) : null;
}

export async function verifyPassword(id: string, password: string) {
  const user = await prisma.user.findUnique({ where: { id } });
  if (!user) return false;
  return bcrypt.compare(password, user.password);
}

export async function turnintoArtist(id: string) {
  const user = await prisma.user.update({
    where: { id },
    data: { role: 'ARTIST' },
  });
  return toUser(user);
}

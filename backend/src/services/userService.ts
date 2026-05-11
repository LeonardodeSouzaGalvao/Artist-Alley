import bcrypt from 'bcryptjs';

export type User = { id: number; username: string; passwordHash: string };

const users: User[] = [];
let nextId = 1;

export async function createUser(username: string, password: string) {
  const passwordHash = await bcrypt.hash(password, 10);
  const user: User = { id: nextId++, username, passwordHash };
  users.push(user);
  return { id: user.id, username: user.username };
}

export async function findByUsername(username: string) {
  return users.find(u => u.username === username) || null;
}

export async function findById(id: number) {
  return users.find(u => u.id === id) || null;
}

export async function verifyPassword(id: number, password: string) {
  const user = await findById(id);
  if (!user) return false;
  return bcrypt.compare(password, user.passwordHash);
}

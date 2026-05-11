import { Router, Request, Response } from 'express';
import * as userService from '../services/userService';
import jwt from 'jsonwebtoken';

const router = Router();
const JWT_SECRET = process.env.JWT_SECRET || 'dev_secret_change_me';

router.post('/register', async (req: Request, res: Response) => {
  const { username, password } = req.body as { username?: string; password?: string };
  if (!username || !password) return res.status(400).json({ error: 'username and password required' });

  const exists = await userService.findByUsername(username);
  if (exists) return res.status(409).json({ error: 'username already taken' });

  const user = await userService.createUser(username, password);
  return res.status(201).json({ id: user.id, username: user.username });
});

router.post('/login', async (req: Request, res: Response) => {
  const { username, password } = req.body as { username?: string; password?: string };
  if (!username || !password) return res.status(400).json({ error: 'username and password required' });

  const user = await userService.findByUsername(username);
  if (!user) return res.status(401).json({ error: 'invalid credentials' });

  const valid = await userService.verifyPassword(user.id, password);
  if (!valid) return res.status(401).json({ error: 'invalid credentials' });

  const token = jwt.sign({ sub: user.id, username: user.username }, JWT_SECRET, { expiresIn: '1h' });
  return res.json({ token });
});

export default router;

import { Router, Request, Response } from 'express';
import * as userService from '../services/userService';
import jwt from 'jsonwebtoken';

const router = Router();
const JWT_SECRET = process.env.JWT_SECRET || 'dev_secret_change_me';

router.post('/register', async (req: Request, res: Response) => {
  const { username, password, email, role } = req.body as { username?: string; password?: string; email?: string; role?: 'CLIENT' | 'ARTIST';};
  if (!username || !password || !email || !role) return res.status(400).json({ error: 'username, email, password, and role required' });

  if (role !== 'CLIENT' && role !== 'ARTIST') {
    return res.status(400).json({ error: 'Invalid role type' });
  }
  const exists = await userService.findByEmail(email);
  if (exists) return res.status(409).json({ error: 'email already registered' });

  const user = await userService.createUser(username, password, email, role);
  return res.status(201).json({ id: user.id, username: user.username, email: user.email, role: user.role });
});


router.post('/login', async (req: Request, res: Response) => {
  const { email, password } = req.body as { email?: string; password?: string };
  if (!email || !password)
    return res.status(400).json({ error: 'email and password required' });

  const user = await userService.findByEmail(email);
  if (!user) return res.status(401).json({ error: 'invalid credentials' });

  const valid = await userService.verifyPassword(user.id, password);
  if (!valid) return res.status(401).json({ error: 'invalid credentials' });

  const token = jwt.sign(
    { sub: user.id, username: user.username },
    JWT_SECRET,
    { expiresIn: '1h' },
  );

  return res.json({
    token,
    user: {
      id:       user.id,
      username: user.username,
      email:    user.email,
      role:     user.role,
    },
  });
});

router.post('/turnintoArtist', async (req: Request, res: Response) => {
  const { userId } = req.body as { userId?: string };
  if (!userId) return res.status(400).json({ error: 'userId required' });
  const user = await userService.turnintoArtist(userId);
  if (!user) return res.status(404).json({ error: 'user not found' });
  return res.json({ id: user.id, username: user.username, email: user.email, role: user.role });
});

export default router;

import express from 'express';
import dotenv from 'dotenv';
import authRoutes from './routes/auth';
import commissionSlotRoutes from './routes/commissionSlots';
import orderRoutes from './routes/orders';
import sseRouter from './middleware/sse'; // ← importar o router SSE
import { authMiddleware } from './middleware/auth';

dotenv.config();

const app = express();
app.use(express.json());

app.get('/', (_req, res) => res.json({ message: 'O servidor está rodando!' }));

app.use('/auth', authRoutes);
app.use('/commission-slots', commissionSlotRoutes);
app.use('/orders', orderRoutes);
app.use('/events', sseRouter);

app.get('/me', authMiddleware, (req, res) => {
  const user = (req as any).user;
  return res.json({ id: user.sub, username: user.username });
});

export default app;

import { Router, Request, Response } from 'express';

const router = Router();

const clients = new Map<string, Response[]>();

export function notifyArtist(artistId: string, payload: object) {
  const conns = clients.get(artistId) ?? [];
  const data = `data: ${JSON.stringify(payload)}\n\n`;
  conns.forEach(res => res.write(data));
}

router.get('/stream/:userId', (req: Request, res: Response) => {
  const userId = req.params.userId as string;

  res.setHeader('Content-Type', 'text/event-stream');
  res.setHeader('Cache-Control', 'no-cache');
  res.setHeader('Connection', 'keep-alive');
  res.flushHeaders();

  const existing = clients.get(userId) ?? [];
  clients.set(userId, [...existing, res]);

  const heartbeat = setInterval(() => res.write(': ping\n\n'), 30_000);

  req.on('close', () => {
    clearInterval(heartbeat);
    const updated = (clients.get(userId) ?? []).filter(r => r !== res);
    if (updated.length === 0) clients.delete(userId);
    else clients.set(userId, updated);
  });
});

export default router;
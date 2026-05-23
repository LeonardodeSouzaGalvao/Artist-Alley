import { Router, Request, Response } from 'express';
import { OrderStatus } from '@prisma/client';
import * as OrderService from '../services/orderService';
import * as eventService from '../services/eventService';
import * as commissionSlotService from '../services/commissionSlotService';
import * as userService from '../services/userService';

const router = Router();

async function handleCreateOrder(req: Request, res: Response) {
  const { clientId, artistId, commissionSlotId, description, referenceImage } = req.body as {
    clientId?: string;
    artistId?: string;
    commissionSlotId?: string;
    description?: string;
    referenceImage?: string;
  };
  if (!clientId || !artistId || !commissionSlotId) {
    return res.status(400).json({ error: 'clientId, artistId, and commissionSlotId required' });
  }

  const client = await userService.findById(clientId);
  if (!client) {
    return res.status(404).json({ error: 'client not found' });
  }

  const artist = await userService.findById(artistId);
  if (!artist) {
    return res.status(404).json({ error: 'artist not found' });
  }

  
  const commissionSlot = await commissionSlotService.findById(commissionSlotId);
  if (!commissionSlot) {
    return res.status(404).json({ error: 'commission slot not found' });
  }

  const order = await OrderService.createOrder(clientId, artistId, commissionSlotId, description, referenceImage);
  return res.status(201).json(order);
}


router.post('/createOrder', handleCreateOrder);

router.get('/artist/:artistId', async (req: Request, res: Response) => {
  const { artistId } = req.params;

  if (typeof artistId !== 'string' || !artistId) {
    return res.status(400).json({ error: 'artistId required' });
  }

  const order = await OrderService.findByArtistId(artistId);

  if (!order) {
    return res.status(404).json({ error: 'order not found for artist' });
  }

  return res.json(order);
});

router.get('/:id', async (req: Request, res: Response) => {
  const { id } = req.params;

  if (typeof id !== 'string' || !id) {
    return res.status(400).json({ error: 'id required' });
  }

  const order = await OrderService.findById(id);

  if (!order) {
    return res.status(404).json({ error: 'order not found' });
  }

  return res.json(order);
});

router.get('/client/:clientId', async (req: Request, res: Response) => {
  const { clientId } = req.params;
  if (typeof clientId !== 'string' || !clientId) {
    return res.status(400).json({ error: 'clientId required' });
  }

  const orders = await OrderService.findByClientId(clientId);
  return res.json(orders);
});

router.get('/commissionSlot/:commissionSlotId', async (req: Request, res: Response) => {
  const { commissionSlotId } = req.params;
  if (typeof commissionSlotId !== 'string' || !commissionSlotId) {
    return res.status(400).json({ error: 'commissionSlotId required' });
  }

  const orders = await OrderService.findByCommissionSlotId(commissionSlotId);
  return res.json(orders);
});

router.put('/:id', async (req: Request, res: Response) => {
  const { id } = req.params;
  const { status } = req.body as { status?: string };

  if (typeof id !== 'string' || !id) {
    return res.status(400).json({ error: 'id required' });
  }

  if (!status || !['PENDING', 'ACCEPTED', 'IN_PROGRESS', 'WAITING_PAYMENT', 'REVISED', 'FINISHED', 'CANCELLED'].includes(status)) {

  router.get('/commissionSlot/:commissionSlotId/queue', async (req: Request, res: Response) => {
    const { commissionSlotId } = req.params;

    if (typeof commissionSlotId !== 'string' || !commissionSlotId) {
      return res.status(400).json({ error: 'commissionSlotId required' });
    }

    const queue = await OrderService.findQueueByCommissionSlotId(commissionSlotId);
    return res.json(queue);
  });
    return res.status(400).json({ error: 'valid status required' });
  }

  const order = await OrderService.findById(id);
  if (!order) {
    return res.status(404).json({ error: 'order not found' });
  }

  const updatedOrder = await OrderService.updateOrderStatus(id, status as OrderStatus);
  return res.json(updatedOrder);
});

router.delete('/:id', async (req: Request, res: Response) => {
  const { id } = req.params;

  if (typeof id !== 'string' || !id) {
    return res.status(400).json({ error: 'id required' });
  }

  const order = await OrderService.findById(id);
  if (!order) {
    return res.status(404).json({ error: 'order not found' });
  }

  const deletedOrder = await OrderService.deleteOrder(id);
  return res.json(deletedOrder);
});

router.post('/:id/accept', async (req: Request, res: Response) => {
  const { id } = req.params;
  const { artistId } = req.body as { artistId?: string };

  if (typeof id !== 'string' || !id) {
    return res.status(400).json({ error: 'id required' });
  }

  if (!artistId) {
    return res.status(400).json({ error: 'artistId required' });
  }

  const order = await OrderService.findById(id);
  if (!order) {
    return res.status(404).json({ error: 'order not found' });
  }

  if (order.status !== 'PENDING') {
    return res.status(400).json({ error: 'only pending orders can be accepted' });
  }

  if (order.artistId !== artistId) {
    return res.status(403).json({ error: 'only the artist can accept this order' });
  }

  const updatedOrder = await OrderService.updateOrderStatus(id, 'ACCEPTED');
  await eventService.publishOrderAccepted(id, artistId);

  return res.json(updatedOrder);
});

router.post('/:id/reject', async (req: Request, res: Response) => {
  const { id } = req.params;
  const { artistId } = req.body as { artistId?: string };

  if (typeof id !== 'string' || !id) {
    return res.status(400).json({ error: 'id required' });
  }

  if (!artistId) {
    return res.status(400).json({ error: 'artistId required' });
  }

  const order = await OrderService.findById(id);
  if (!order) {
    return res.status(404).json({ error: 'order not found' });
  }

  if (order.status !== 'PENDING') {
    return res.status(400).json({ error: 'only pending orders can be rejected' });
  }

  if (order.artistId !== artistId) {
    return res.status(403).json({ error: 'only the artist can reject this order' });
  }

  const updatedOrder = await OrderService.updateOrderStatus(id, 'CANCELLED');
  await eventService.publishOrderRejected(id, artistId);

  return res.json(updatedOrder);
});

export default router;

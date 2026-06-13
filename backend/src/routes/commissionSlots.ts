import { Router, Request, Response } from 'express';
import * as commissionSlotService from '../services/commissionSlotService';
import * as userService from '../services/userService';

const router = Router();

async function handleCreateCommissionSlot(req: Request, res: Response) {
  const { title, description, price, artistId, slots, imageUrl } = req.body as { title?: string; description?: string; price?: number; artistId?: string; slots?: number; imageUrl?: string };
  if (!title || !description || price === undefined || !artistId || slots === undefined) return res.status(400).json({ error: 'title, description, price, artistId, and slots required' });

  const artist = await userService.findById(artistId);
  if (!artist) {
    return res.status(404).json({ error: 'artist not found' });
  }

  const commissionSlot = await commissionSlotService.createCommissionSlot(title, description, price, artistId, slots, imageUrl);
  return res.status(201).json(commissionSlot);
}


router.post('/createCommissionSlot', handleCreateCommissionSlot);

router.get('/artist/:artistId', async (req: Request, res: Response) => {
  const { artistId } = req.params;

  if (typeof artistId !== 'string' || !artistId) {
    return res.status(400).json({ error: 'artistId required' });
  }

  const commissionSlot = await commissionSlotService.findByArtistId(artistId);

  if (!commissionSlot) {
    return res.status(404).json({ error: 'commission slot not found for artist' });
  }

  return res.json(commissionSlot);
});

router.get('/', async (_req: Request, res: Response) => {
  try {
    const commissionSlots = await commissionSlotService.findAll();
    return res.json(commissionSlots);
  } catch (error) {
    console.error('Erro ao buscar commission slots:', error);
    return res.status(500).json({ error: 'Internal server error' });
  }
});

router.get('/:id', async (req: Request, res: Response) => {
  const { id } = req.params;

  if (typeof id !== 'string' || !id) {
    return res.status(400).json({ error: 'id required' });
  }

  const commissionSlot = await commissionSlotService.findById(id);

  if (!commissionSlot) {
    return res.status(404).json({ error: 'commission slot not found' });
  }

  return res.json(commissionSlot);
});

export default router;

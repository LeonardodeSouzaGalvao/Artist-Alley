import { Router } from 'express';
import { SessionsController } from '../../modules/users/controllers/SessionsController';
import { ensureAuthenticated } from '../middlewares/ensureAuthenticated';

const routes = Router();
const sessionsController = new SessionsController();

// Rota pública (Login)
routes.post('/sessions', sessionsController.create);

// Exemplo de rota protegida (Só acessa com Token)
routes.get('/profile', ensureAuthenticated, (req, res) => {
  return res.json({ message: "Você está autenticado!", user_id: req.user.id });
});

export { routes };
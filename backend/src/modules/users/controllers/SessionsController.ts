import { Request, Response } from 'express';
import { AuthenticateUserService } from '../services/AuthenticateUserService';

class SessionsController {
  public async create(req: Request, res: Response): Promise<Response> {
    const { email, password } = req.body;

    const authenticateUser = new AuthenticateUserService();

    const { user, token } = await authenticateUser.execute({
      email,
      password,
    });

    return res.json({ user, token });
  }
}

export { SessionsController };
import { Request, Response, NextFunction } from 'express';
import { verify } from 'jsonwebtoken';
import { AppError } from '../errors/appError';

interface ITokenPayload {
  iat: number;
  exp: number;
  sub: string;
}

declare global {
  namespace Express {
    interface Request {
      user: { id: string };
    }
  }
}

export function ensureAuthenticated(
  req: Request, 
  res: Response, 
  next: NextFunction
): void {
  const authHeader = req.headers.authorization;

  if (!authHeader) {
    return next(new AppError('JWT token está faltando.', 401));
  }

  const [, token] = authHeader.split(' ');

  if (!token) {
    return next(new AppError('Token JWT inválido.', 401));
  }

  try {
    const decoded = verify(token, process.env.JWT_SECRET || '');
    const { sub } = decoded as ITokenPayload;

    req.user = { id: sub };

    return next();
  } catch (error) {
    return next(new AppError('Token JWT inválido.', 401));
  }
}
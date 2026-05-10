import { compare } from 'bcryptjs';
import { sign } from 'jsonwebtoken';
import { PrismaClient } from '@prisma/client';
import { AppError } from '../../../shared/errors/appError';

const prisma = new PrismaClient();

interface IRequest {
  email: string;
  password: string;
}

interface IResponse {
  user: {
    id: string;
    name: string;
    email: string;
    role: string;
  };
  token: string;
}

class AuthenticateUserService {
  public async execute({ email, password }: IRequest): Promise<IResponse> {
    const user = await prisma.user.findUnique({ where: { email } });

    if (!user) {
      throw new AppError('E-mail ou senha incorretos.', 401);
    }

    const passwordMatched = await compare(password, user.password);

    if (!passwordMatched) {
      throw new AppError('E-mail ou senha incorretos.', 401);
    }

    
    const jwtSecret = process.env.JWT_SECRET;

    if (!jwtSecret) {
      throw new AppError('JWT secret não configurado.', 500);
    }

    const token = sign({}, jwtSecret, {
      subject: user.id,
      expiresIn: '1d',
    });

    return {
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
      },
      token,
    };
  }
}

export { AuthenticateUserService };
import {
  ConflictException,
  Injectable,
  NotFoundException,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcryptjs';
import { randomUUID } from 'node:crypto';
import { PrismaService } from '../prisma/prisma.service';
import { LoginDto, RegisterDto } from './auth.dto';

const BCRYPT_ROUNDS = 10;
const TOKEN_TTL = '7d';

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwt: JwtService,
  ) {}

  async register(dto: RegisterDto): Promise<AuthResponse> {
    const email = dto.email.toLowerCase();
    const existing = await this.prisma.user.findUnique({ where: { email } });
    if (existing) throw new ConflictException('Email already registered');

    const passwordHash = await bcrypt.hash(dto.password, BCRYPT_ROUNDS);
    const user = await this.prisma.user.create({
      data: { id: randomUUID(), email, passwordHash },
    });
    return this.issueToken(user.id, user.email);
  }

  async login(dto: LoginDto): Promise<AuthResponse> {
    const email = dto.email.toLowerCase();
    const user = await this.prisma.user.findUnique({ where: { email } });
    // Одинаковая ошибка для неизвестного email и неверного пароля —
    // чтобы не раскрывать, какие адреса зарегистрированы.
    if (!user) throw new UnauthorizedException('Invalid email or password');

    const passwordOk = await bcrypt.compare(dto.password, user.passwordHash);
    if (!passwordOk) throw new UnauthorizedException('Invalid email or password');

    return this.issueToken(user.id, user.email);
  }

  async me(userId: string): Promise<{ id: string; email: string }> {
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!user) throw new NotFoundException('User not found');
    return { id: user.id, email: user.email };
  }

  private async issueToken(userId: string, email: string): Promise<AuthResponse> {
    const token = await this.jwt.signAsync({ sub: userId, email });
    return { token, user: { id: userId, email } };
  }
}

export type AuthResponse = {
  token: string;
  user: { id: string; email: string };
};

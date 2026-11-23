import { JwtService } from '@nestjs/jwt';
import {
  ConflictException,
  UnauthorizedException,
} from '@nestjs/common';
import * as bcrypt from 'bcryptjs';
import { PrismaService } from '../prisma/prisma.service';
import {
  createTestPrisma,
  deleteTestDatabase,
  pushTestSchema,
} from '../testing/test-db';
import { AuthService } from './auth.service';

/** Тесты реальной аутентификации: регистрация, логин, токены. */
describe('AuthService', () => {
  let prisma: PrismaService;
  let service: AuthService;
  let jwt: JwtService;

  beforeAll(() => {
    pushTestSchema('test-auth.db');
    prisma = createTestPrisma('test-auth.db') as PrismaService;
    jwt = new JwtService({ secret: 'test-secret' });
    service = new AuthService(prisma, jwt);
  });

  afterAll(async () => {
    await prisma.$disconnect();
    deleteTestDatabase('test-auth.db');
  });

  beforeEach(async () => {
    await prisma.aiUsage.deleteMany();
    await prisma.user.deleteMany();
  });

  describe('register', () => {
    it('создаёт пользователя и возвращает токен с userId', async () => {
      const res = await service.register({
        email: 'Cook@Example.com',
        password: 'super-secret-1',
      });

      expect(res.user.email).toBe('cook@example.com'); // email нормализуется
      const payload = jwt.verify(res.token) as { sub: string };
      expect(payload.sub).toBe(res.user.id);

      const dbUser = await prisma.user.findUnique({
        where: { email: 'cook@example.com' },
      });
      expect(dbUser).not.toBeNull();
      // пароль хранится хэшем, не в открытом виде
      expect(dbUser!.passwordHash).not.toBe('super-secret-1');
      expect(await bcrypt.compare('super-secret-1', dbUser!.passwordHash)).toBe(true);
    });

    it('отклоняет повторную регистрацию того же email (409)', async () => {
      await service.register({ email: 'dup@test.io', password: 'password-1' });
      await expect(
        service.register({ email: 'dup@test.io', password: 'password-2' }),
      ).rejects.toThrow(ConflictException);
    });
  });

  describe('login', () => {
    it('пускает с верным паролем и выдаёт валидный токен', async () => {
      const registered = await service.register({
        email: 'login@test.io',
        password: 'password-1',
      });
      const res = await service.login({
        email: 'login@test.io',
        password: 'password-1',
      });
      expect(res.user.id).toBe(registered.user.id);
      const payload = jwt.verify(res.token) as { sub: string };
      expect(payload.sub).toBe(registered.user.id);
    });

    it('отклоняет неверный пароль (401)', async () => {
      await service.register({ email: 'wrongpw@test.io', password: 'password-1' });
      await expect(
        service.login({ email: 'wrongpw@test.io', password: 'wrong-password' }),
      ).rejects.toThrow(UnauthorizedException);
    });

    it('отклоняет неизвестный email той же ошибкой, что и неверный пароль', async () => {
      const err = await service
        .login({ email: 'ghost@test.io', password: 'whatever-1' })
        .catch((e) => e);
      expect(err).toBeInstanceOf(UnauthorizedException);
      expect(err.message).toBe('Invalid email or password');
    });
  });

  describe('me', () => {
    it('возвращает профиль по userId из токена', async () => {
      const res = await service.register({ email: 'me@test.io', password: 'password-1' });
      await expect(service.me(res.user.id)).resolves.toEqual({
        id: res.user.id,
        email: 'me@test.io',
      });
    });

    it('бросает 404 для несуществующего пользователя', async () => {
      await expect(service.me('no-such-user')).rejects.toThrow(
        'User not found',
      );
    });
  });
});

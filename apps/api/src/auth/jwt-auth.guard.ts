import {
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { AuthGuard } from '@nestjs/passport';
import { IS_PUBLIC_KEY } from './public.decorator';

/**
 * Защита всех эндпоинтов по умолчанию.
 * Принимает Bearer JWT; для обратной совместимости с текущим Flutter-клиентом
 * пока пропускает legacy-заголовок x-user-id (MVP-переходный период).
 */
@Injectable()
export class JwtAuthGuard extends AuthGuard('jwt') {
  constructor(private reflector: Reflector) {
    super();
  }

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const isPublic = this.reflector.getAllAndOverride<boolean>(IS_PUBLIC_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);
    if (isPublic) return true;

    const request = context.switchToHttp().getRequest();
    const authHeader: string | undefined = request.headers?.authorization;
    if (authHeader?.startsWith('Bearer ')) {
      return (await super.canActivate(context)) as boolean;
    }

    // Legacy-режим: клиент ещё шлёт x-user-id. Когда клиент переедет на
    // /auth/login, этот блок убирается.
    const legacyUserId = request.headers?.['x-user-id'];
    if (typeof legacyUserId === 'string' && legacyUserId.length > 0) {
      if (legacyUserId.length > 128) {
        throw new UnauthorizedException('Invalid x-user-id header');
      }
      request.user = { userId: legacyUserId };
      return true;
    }

    throw new UnauthorizedException(
      'Provide Authorization: Bearer <token> or x-user-id',
    );
  }
}

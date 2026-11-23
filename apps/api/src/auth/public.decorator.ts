import { SetMetadata } from '@nestjs/common';

/** Помечает маршрут публичным — JwtAuthGuard его пропускает. */
export const IS_PUBLIC_KEY = 'isPublic';
export const Public = () => SetMetadata(IS_PUBLIC_KEY, true);

import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { getJwtSecret } from './auth.constants';

export type JwtPayload = { sub: string; email?: string };

/** Достаёт userId из Bearer-токена и кладёт в request.user. */
@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor() {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: getJwtSecret(),
    });
  }

  validate(payload: JwtPayload): { userId: string; email?: string } {
    if (!payload.sub) throw new UnauthorizedException('Invalid token payload');
    return { userId: payload.sub, email: payload.email };
  }
}

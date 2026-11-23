import { createParamDecorator, ExecutionContext } from '@nestjs/common';

/**
 * Достаёт текущего пользователя, положенного в request гвардом:
 * { userId } из JWT либо из legacy-заголовка x-user-id.
 */
export const CurrentUser = createParamDecorator(
  (_data: unknown, ctx: ExecutionContext) => {
    const request = ctx.switchToHttp().getRequest();
    return request.user as { userId: string } | undefined;
  },
);

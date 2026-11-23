import { Module } from '@nestjs/common';
import { APP_GUARD } from '@nestjs/core';
import { ThrottlerGuard, ThrottlerModule } from '@nestjs/throttler';
import { ConfigModule } from '@nestjs/config';
import { AiModule } from './ai/ai.module';
import { AuthModule } from './auth/auth.module';
import { JwtAuthGuard } from './auth/jwt-auth.guard';
import { HealthModule } from './health/health.module';
import { InventoryModule } from './inventory/inventory.module';
import { PrismaModule } from './prisma/prisma.module';
import { RecipesModule } from './recipes/recipes.module';
import { ShoppingModule } from './shopping/shopping.module';
import { RootController } from './root.controller';

// Глобальные лимиты запросов: защита от брутфорса и абьюза AI.
const GLOBAL_THROTTLE = { ttl: 60_000, limit: 120 };

@Module({
  imports: [
    // isGlobal: process.env доступен везде без повторного импорта
    ConfigModule.forRoot({ isGlobal: true }),
    ThrottlerModule.forRoot([{ ttl: GLOBAL_THROTTLE.ttl, limit: GLOBAL_THROTTLE.limit }]),
    PrismaModule,
    AuthModule,
    HealthModule,
    InventoryModule,
    RecipesModule,
    ShoppingModule,
    AiModule,
  ],
  controllers: [RootController],
  providers: [
    // Порядок важен: сперва rate limit, потом auth
    { provide: APP_GUARD, useClass: ThrottlerGuard },
    { provide: APP_GUARD, useClass: JwtAuthGuard },
  ],
})
export class AppModule {}

import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AiModule } from './ai/ai.module';
import { HealthModule } from './health/health.module';
import { InventoryModule } from './inventory/inventory.module';
import { RecipesModule } from './recipes/recipes.module';
import { ShoppingModule } from './shopping/shopping.module';
import { RootController } from './root.controller';

@Module({
  imports: [
    // isGlobal: process.env доступен везде без повторного импорта
    ConfigModule.forRoot({ isGlobal: true }),
    HealthModule,
    InventoryModule,
    RecipesModule,
    ShoppingModule,
    AiModule,
  ],
  controllers: [RootController],
})
export class AppModule {}

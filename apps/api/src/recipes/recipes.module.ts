import { Module } from '@nestjs/common';
import { AiModule } from '../ai/ai.module';
import { InventoryModule } from '../inventory/inventory.module';
import { RecipesController } from './recipes.controller';
import { RecipesService } from './recipes.service';

@Module({
  imports: [AiModule, InventoryModule],
  controllers: [RecipesController],
  providers: [RecipesService],
})
export class RecipesModule {}

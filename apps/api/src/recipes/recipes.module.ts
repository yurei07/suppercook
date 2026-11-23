import { Module } from '@nestjs/common';
import { AiModule } from '../ai/ai.module';
import { InventoryModule } from '../inventory/inventory.module';
import { PrismaModule } from '../prisma/prisma.module';
import { RecipesController } from './recipes.controller';
import { RecipesService } from './recipes.service';
import { SavedRecipesController } from './saved.controller';
import { SavedRecipesService } from './saved.service';

@Module({
  imports: [AiModule, InventoryModule, PrismaModule],
  controllers: [RecipesController, SavedRecipesController],
  providers: [RecipesService, SavedRecipesService],
  exports: [SavedRecipesService],
})
export class RecipesModule {}

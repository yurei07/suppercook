import { Controller, Get } from '@nestjs/common';
import { Public } from './auth/public.decorator';

/**
 * Корневой маршрут: индекс API.
 * Без него браузер на http://localhost:3000 показывает "Cannot GET /".
 */
@Controller()
@Public()
export class RootController {
  @Get()
  index(): Record<string, unknown> {
    return {
      name: 'Suppercook API',
      version: '0.1.0',
      status: 'ok',
      endpoints: {
        health: 'GET /health',
        auth: ['POST /auth/register', 'POST /auth/login', 'GET /auth/me'],
        inventory: [
          'GET /inventory',
          'POST /inventory',
          'PATCH /inventory/:id',
          'DELETE /inventory/:id',
          'POST /inventory/recognize',
        ],
        recipes: ['POST /recipes/suggest'],
        planner: [
          'GET /planner?week=YYYY-MM-DD',
          'PUT /planner/meals',
          'PUT /planner',
          'DELETE /planner/meals?week&day&slot',
        ],
        shopping: [
          'GET /shopping',
          'POST /shopping/items',
          'POST /shopping/from-recipe',
          'PATCH /shopping/items/:id',
          'DELETE /shopping/items/:id',
          'DELETE /shopping/checked',
        ],
      },
      docs: 'https://github.com/yurei07/suppercook',
    };
  }
}

import { Controller, Get } from '@nestjs/common';

/**
 * Корневой маршрут: индекс API.
 * Без него браузер на http://localhost:3000 показывает "Cannot GET /".
 */
@Controller()
export class RootController {
  @Get()
  index(): Record<string, unknown> {
    return {
      name: 'Suppercook API',
      version: '0.1.0',
      status: 'ok',
      endpoints: {
        health: 'GET /health',
        inventory: [
          'GET /inventory',
          'POST /inventory',
          'PATCH /inventory/:id',
          'DELETE /inventory/:id',
          'POST /inventory/recognize',
        ],
        recipes: ['POST /recipes/suggest'],
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

/**
 * Клиент Suppercook API.
 *
 * Для разработки: API_URL указывает на локальный сервер.
 * В проде — заменить на боевой домен (через переменную окружения).
 */
import { Platform } from 'react-native';

/** Адрес API: эмулятор Android ходит на 10.0.2.2, симулятор iOS — на localhost */
export const API_URL =
  process.env.EXPO_PUBLIC_API_URL ??
  (Platform.OS === 'android' ? 'http://10.0.2.2:3000' : 'http://localhost:3000');

/** Заглушка аутентификации: MVP идентифицирует пользователя заголовком */
export const USER_ID = 'demo-user';

export class ApiError extends Error {
  constructor(
    message: string,
    readonly status: number,
  ) {
    super(message);
  }
}

async function request<T>(path: string, options: RequestInit = {}): Promise<T> {
  const response = await fetch(`${API_URL}${path}`, {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      'x-user-id': USER_ID,
      ...options.headers,
    },
  });

  if (!response.ok) {
    let message = `Ошибка ${response.status}`;
    try {
      const body = await response.json();
      if (body?.message) message = Array.isArray(body.message) ? body.message[0] : body.message;
    } catch {
      /* тело не JSON — оставляем сообщение по умолчанию */
    }
    throw new ApiError(message, response.status);
  }

  if (response.status === 204) return undefined as T;
  return (await response.json()) as T;
}

// ===== Типы (зеркалят доменные типы API) =====

export interface InventoryItem {
  id: string;
  name: string;
  quantity: number;
  unit: 'g' | 'ml' | 'pcs';
  addedAt: string;
  source: 'manual' | 'photo';
}

export interface RecipeIngredient {
  name: string;
  quantity: number;
  unit: 'g' | 'ml';
  have?: boolean;
}

export interface Recipe {
  id: string;
  title: string;
  description: string;
  servings: number;
  timeMinutes: number;
  difficulty: 'easy' | 'medium' | 'hard';
  ingredients: RecipeIngredient[];
  steps: string[];
  nutrition: { kcal: number; protein: number; carbs: number; fat: number };
  tags: string[];
  missingIngredients: string[];
}

export interface ShoppingListItem {
  id: string;
  name: string;
  quantity: number;
  unit: 'g' | 'ml';
  recipeIds: string[];
  checked: boolean;
}

export interface RecognitionResult {
  items: Array<{ name: string; quantity: number; unit: 'g' | 'ml' | 'pcs'; confidence: number }>;
  summary: string;
}

// ===== Эндпоинты =====

export const api = {
  // Инвентарь
  getInventory: () => request<InventoryItem[]>('/inventory'),

  addInventoryItem: (data: { name: string; quantity: number; unit: string }) =>
    request<InventoryItem[]>('/inventory', { method: 'POST', body: JSON.stringify(data) }),

  updateInventoryItem: (id: string, data: Partial<{ name: string; quantity: number; unit: string }>) =>
    request<InventoryItem>(`/inventory/${id}`, { method: 'PATCH', body: JSON.stringify(data) }),

  deleteInventoryItem: (id: string) =>
    request<InventoryItem[]>(`/inventory/${id}`, { method: 'DELETE' }),

  recognizePhoto: (imageBase64: string, mimeType = 'image/jpeg') =>
    request<RecognitionResult>('/inventory/recognize', {
      method: 'POST',
      body: JSON.stringify({ imageBase64, mimeType }),
    }),

  // Рецепты
  suggestRecipes: (data: { request?: string; allergens?: string[]; preferences?: string[] }) =>
    request<Recipe[]>('/recipes/suggest', { method: 'POST', body: JSON.stringify(data) }),

  // Список покупок
  getShoppingList: () => request<ShoppingListItem[]>('/shopping'),

  addFromRecipe: (missingIngredients: string[], recipeId?: string) =>
    request<ShoppingListItem[]>('/shopping/from-recipe', {
      method: 'POST',
      body: JSON.stringify({ missingIngredients, recipeId }),
    }),

  toggleShoppingItem: (id: string, checked: boolean) =>
    request<ShoppingListItem>(`/shopping/items/${id}`, {
      method: 'PATCH',
      body: JSON.stringify({ checked }),
    }),

  removeShoppingItem: (id: string) =>
    request<ShoppingListItem[]>(`/shopping/items/${id}`, { method: 'DELETE' }),
};

/**
 * Секрет для подписи JWT. В dev-режиме без JWT_SECRET в .env
 * используется fallback — он годится только для локальной разработки.
 */
const DEV_FALLBACK_SECRET = 'dev-only-insecure-secret-change-me';

export function getJwtSecret(): string {
  return process.env.JWT_SECRET ?? DEV_FALLBACK_SECRET;
}

export function isJwtSecretConfigured(): boolean {
  return Boolean(process.env.JWT_SECRET);
}

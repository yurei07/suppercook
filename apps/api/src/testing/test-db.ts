import { execSync } from 'node:child_process';
import * as fs from 'node:fs';
import * as path from 'node:path';
import { PrismaClient } from '@prisma/client';

const PRISMA_DIR = path.join(__dirname, '../../prisma');
const API_DIR = path.join(__dirname, '../..');

/** SQLite URL для тестовой базы. Файл лежит рядом со schema.prisma. */
export function databaseUrl(dbName: string): string {
  return `file:${dbName}`;
}

/** Пересоздаёт тестовую базу из схемы. */
export function pushTestSchema(dbName: string): void {
  deleteTestDatabase(dbName);
  execSync('npx prisma db push --skip-generate --accept-data-loss', {
    cwd: API_DIR,
    env: { ...process.env, DATABASE_URL: databaseUrl(dbName) },
    stdio: 'ignore',
  });
}

export function createTestPrisma(dbName: string): PrismaClient {
  return new PrismaClient({
    datasources: { db: { url: databaseUrl(dbName) } },
  });
}

export function deleteTestDatabase(dbName: string): void {
  const base = path.join(PRISMA_DIR, dbName);
  for (const suffix of ['', '-journal', '-wal', '-shm']) {
    const file = base + suffix;
    if (fs.existsSync(file)) fs.unlinkSync(file);
  }
}

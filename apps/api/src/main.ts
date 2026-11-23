import { ValidationPipe } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { json, urlencoded } from 'express';
import helmet from 'helmet';
import { AppModule } from './app.module';
import { isJwtSecretConfigured } from './auth/auth.constants';

async function bootstrap(): Promise<void> {
  // Photo recognition sends base64 images, so the default 100 KB JSON limit
  // is not enough.
  const app = await NestFactory.create(AppModule, { bodyParser: false });
  app.use(json({ limit: '20mb' }));
  app.use(urlencoded({ extended: true, limit: '20mb' }));

  app.use(helmet());

  if (!isJwtSecretConfigured()) {
    // eslint-disable-next-line no-console
    console.warn(
      '⚠️  JWT_SECRET не задан — используется dev-секрет. ' +
        'Для продакшена скопируйте apps/api/.env.example в .env и задайте свой.',
    );
  }

  // CORS — мобильное приложение ходит с эмулятора/устройства на другой origin.
  // CORS_ORIGINS="https://app.example.com,https://web.example.com" — белый список;
  // не задано — отражаем любой origin (dev-режим).
  const origins = process.env.CORS_ORIGINS?.split(',')
    .map((s) => s.trim())
    .filter(Boolean);
  app.enableCors({ origin: origins && origins.length ? origins : true });

  // Валидация DTO: белый список + трансформация в типизированные значения
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      transform: true,
      forbidNonWhitelisted: true,
    }),
  );

  const port = Number(process.env.PORT ?? 3000);
  await app.listen(port);
  // eslint-disable-next-line no-console
  console.log(`🍲 Suppercook API ready → http://localhost:${port}`);
}

void bootstrap();

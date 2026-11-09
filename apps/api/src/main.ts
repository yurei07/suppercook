import { ValidationPipe } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { json, urlencoded } from 'express';
import { AppModule } from './app.module';

async function bootstrap(): Promise<void> {
  // Photo recognition sends base64 images, so the default 100 KB JSON limit
  // is not enough.
  const app = await NestFactory.create(AppModule, { bodyParser: false });
  app.use(json({ limit: '20mb' }));
  app.use(urlencoded({ extended: true, limit: '20mb' }));

  // CORS — мобильное приложение ходит с эмулятора/устройства на другой origin
  app.enableCors({ origin: true });

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

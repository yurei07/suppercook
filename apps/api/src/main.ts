import { ValidationPipe } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap(): Promise<void> {
  const app = await NestFactory.create(AppModule);

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

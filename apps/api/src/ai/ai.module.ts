import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma/prisma.module';
import { AiService } from './ai.service';
import { MockAiProvider } from './mock.provider';
import { OpenAiProvider } from './openai.provider';
import { QuotaService } from './quota.service';

@Module({
  imports: [PrismaModule],
  providers: [AiService, MockAiProvider, OpenAiProvider, QuotaService],
  exports: [AiService, QuotaService],
})
export class AiModule {}

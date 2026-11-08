import { Module } from '@nestjs/common';
import { AiService } from './ai.service';
import { MockAiProvider } from './mock.provider';
import { OpenAiProvider } from './openai.provider';

@Module({
  providers: [AiService, MockAiProvider, OpenAiProvider],
  exports: [AiService],
})
export class AiModule {}

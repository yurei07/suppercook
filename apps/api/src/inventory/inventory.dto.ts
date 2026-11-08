import { IsIn, IsNotEmpty, IsNumber, IsOptional, IsString, Max, Min } from 'class-validator';

const UNITS = ['g', 'ml', 'pcs'] as const;

/** POST /inventory — добавить продукт в инвентарь */
export class AddInventoryItemDto {
  @IsString()
  @IsNotEmpty()
  name!: string;

  @IsNumber()
  @Min(0.01)
  @Max(100_000)
  quantity!: number;

  @IsIn(UNITS)
  unit!: (typeof UNITS)[number];

  @IsOptional()
  @IsIn(['manual', 'photo'])
  source?: 'manual' | 'photo';
}

/** PATCH /inventory/:id — изменить количество/название */
export class UpdateInventoryItemDto {
  @IsOptional()
  @IsString()
  @IsNotEmpty()
  name?: string;

  @IsOptional()
  @IsNumber()
  @Min(0.01)
  @Max(100_000)
  quantity?: number;

  @IsOptional()
  @IsIn(UNITS)
  unit?: (typeof UNITS)[number];
}

/** POST /inventory/recognize — распознавание фото */
export class RecognizePhotoDto {
  /** base64 без префикса data: */
  @IsString()
  @IsNotEmpty()
  imageBase64!: string;

  @IsOptional()
  @IsString()
  mimeType?: string;
}

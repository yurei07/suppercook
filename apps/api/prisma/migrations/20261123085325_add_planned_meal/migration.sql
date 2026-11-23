-- CreateTable
CREATE TABLE "PlannedMeal" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "userId" TEXT NOT NULL,
    "week" TEXT NOT NULL,
    "day" INTEGER NOT NULL,
    "slot" TEXT NOT NULL,
    "recipeId" TEXT NOT NULL,
    "recipeJson" TEXT NOT NULL
);

-- CreateIndex
CREATE INDEX "PlannedMeal_userId_week_idx" ON "PlannedMeal"("userId", "week");

-- CreateIndex
CREATE UNIQUE INDEX "PlannedMeal_userId_week_day_slot_key" ON "PlannedMeal"("userId", "week", "day", "slot");

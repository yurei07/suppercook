# Dev-окружение для Suppercook на NixOS.
#
#   nix-shell            # node + prisma-движки нужной версии в env
#   npm install          # один раз, из корня
#   npm run prisma:push  # создать dev-базу (в apps/api)
#   npm run api
#
# На других дистрибутивах достаточно Node.js 20+.

{ pkgs ? import <nixpkgs> {} }:

let
  # Версия должна совпадать с @prisma/client в apps/api/package.json
  prismaEngines = pkgs.prisma-engines_6;
in
pkgs.mkShell {
  packages = [
    pkgs.nodejs_24
    prismaEngines
  ];

  # Prisma CLI и клиент подхватывают эти пути вместо скачивания движков
  # (binaries.prisma.sh не публикует сборки для nixos).
  PRISMA_SCHEMA_ENGINE_BINARY = "${prismaEngines}/bin/schema-engine";
  PRISMA_QUERY_ENGINE_LIBRARY = "${prismaEngines}/lib/libquery_engine.node";
  PRISMA_FMT_BINARY = "${prismaEngines}/bin/prisma-fmt";
}

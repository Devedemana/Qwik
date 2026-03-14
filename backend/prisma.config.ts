import { env } from './env.ts'
import { defineConfig } from "prisma/config";

export default defineConfig({
  schema: "prisma/schema.prisma",
  migrations: {
    path: "prisma/migrations",
  },
  
  datasource: {
    url: env.DATABASE_URL,
  },
});

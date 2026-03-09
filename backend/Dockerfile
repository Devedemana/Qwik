#  Build & Dev 
FROM node:24-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci

COPY prisma ./prisma/
RUN npx prisma generate

COPY . .

# Production 
FROM node:24-alpine AS production
WORKDIR /app
ENV NODE_ENV=production

# Install ONLY production
COPY package*.json ./
RUN npm ci --only=production

COPY prisma ./prisma/
RUN npx prisma generate

COPY --from=build /app/src ./src
COPY --from=build /app/tsconfig.json ./

CMD npx prisma db push && node --experimental-strip-types -r tsconfig-paths/register src/index.ts
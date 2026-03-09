# Stage 1: Development & Build
FROM node:24-alpine AS development
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
CMD ["npm", "run", "dev"]

# Stage 2: Production
FROM node:24-alpine AS production
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY --from=development /app/dist ./dist
CMD ["node", "dist/index.js"]
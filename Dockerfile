FROM node:23-alpine AS BUILD_IMAGE
WORKDIR /app
COPY package*.json web/package*.json ./
RUN npm install
RUN npm ci
COPY . .
RUN rm /app/web/.env
WORKDIR /app/web
RUN npx prisma generate
RUN npm run build

FROM node:23-alpine AS PRODUCTION_STAGE
WORKDIR /app
COPY --from=BUILD_IMAGE /app/web/package*.json ./
COPY --from=BUILD_IMAGE /app/web/.next ./.next
COPY --from=BUILD_IMAGE /app/node_modules ./node_modules

ENV NODE_ENV=production

EXPOSE 3000

CMD ["npm", "start"]
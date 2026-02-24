FROM node:24-alpine

RUN apk add --no-cache bash

WORKDIR /app

RUN npm install -g pnpm

COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

COPY . .

RUN pnpm exec prisma generate
RUN pnpm run build

EXPOSE 5000

CMD ["pnpm", "start"]

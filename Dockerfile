# --- Etapa 1: Construcción ---
FROM node:18-alpine AS builder
WORKDIR /app

# Instalar pnpm globalmente ya que el proyecto usa pnpm-lock.yaml
RUN npm install -g pnpm

# Copiar archivos de dependencias
COPY package*.json pnpm-lock.yaml* ./
RUN pnpm install --frozen-lockfile

# Copiar el resto del código y construir la app
COPY . .
RUN pnpm run build

# --- Etapa 2: Ejecución ---
FROM node:18-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production

# Instalar pnpm también en la etapa final
RUN npm install -g pnpm

# Copiar solo lo necesario desde la etapa de construcción
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/pnpm-lock.yaml* ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public

# Render asigna dinámicamente el puerto 10000
ENV PORT=10000
EXPOSE 10000

# Comando para arrancar Next.js en producción
CMD ["pnpm", "start"]
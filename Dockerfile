FROM oven/bun:1.2.2-debian AS base

FROM base AS development-dependencies-env
COPY . /app
WORKDIR /app
RUN bun install

FROM base AS production-dependencies-env
COPY ./package.json bun.lock /app/
WORKDIR /app
RUN bun install --frozen-lockfile --no-dev

FROM base AS build-env
COPY . /app/
COPY --from=development-dependencies-env /app/node_modules /app/node_modules
WORKDIR /app
RUN bun run build

FROM base
COPY ./package.json bun.lock /app/
COPY --from=production-dependencies-env /app/node_modules /app/node_modules
COPY --from=build-env /app/build /app/build
WORKDIR /app
CMD ["bun", "run", "start"]

FROM bun:latest AS development-dependencies-env
COPY . /app
WORKDIR /app
RUN bun ci

FROM bun:latest AS production-dependencies-env
COPY ./package.json bun.lock /app/
WORKDIR /app
RUN bun ci --omit=dev

FROM bun:latest AS build-env
COPY . /app/
COPY --from=development-dependencies-env /app/node_modules /app/node_modules
WORKDIR /app
RUN bun run build

FROM bun:latest
COPY ./package.json bun.lock /app/
COPY --from=production-dependencies-env /app/node_modules /app/node_modules
COPY --from=build-env /app/build /app/build
WORKDIR /app
CMD ["bun", "run", "start"]

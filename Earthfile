VERSION 0.7

deps:
  ARG ELIXIR=1.17.1
  ARG OTP=27.0-rc1
  ARG ALPINE_VERSION=3.18.6
  FROM hexpm/elixir:${ELIXIR}-erlang-${OTP}-alpine-${ALPINE_VERSION}
  RUN apk update --no-cache
  RUN apk add --no-cache build-base gcc git curl
  WORKDIR /src
  COPY mix.exs mix.lock ./
  COPY --dir config . # check .earthlyignore
  RUN mix local.rebar --force
  RUN mix local.hex --force
  RUN mix deps.get
  RUN mix deps.compile
  COPY --dir lib .
  SAVE ARTIFACT /src/deps AS LOCAL deps

ci:
  FROM +deps
  COPY .formatter.exs .
  RUN mix clean
  RUN mix compile --warning-as-errors
  RUN mix format --check-formatted
  RUN mix credo --strict

test:
  FROM +deps
  RUN apk add postgresql-client
  COPY --dir config ./
  RUN MIX_ENV=test mix deps.compile
  COPY docker-compose.ci.yml ./docker-compose.yml
  COPY mix.exs mix.lock ./
  COPY --dir lib priv test ./

  WITH DOCKER --compose docker-compose.yml
    RUN while ! pg_isready --host=localhost --port=5432 --quiet; do sleep 1; done; \
        mix test
  END

docker-prod:
  FROM DOCKERFILE .
  ARG GITHUB_REPO
  SAVE IMAGE --push ghcr.io/$GITHUB_REPO:prod

docker-dev:
  FROM +deps
  RUN apk update --no-cache
  RUN apk add --no-cache inotify-tools
  ENV MIX_ENV=dev
  COPY --dir config ./
  RUN mix deps.compile
  COPY --dir priv ./
  RUN mix compile
  CMD ["mix", "dev"]
  ARG GITHUB_REPO=zoedsoupe/jaya_test
  SAVE IMAGE --push ghcr.io/$GITHUB_REPO:dev

docker-dev-arm:
  BUILD --platform=linux/arm64/v8 +docker-dev

docker:
  BUILD +docker-dev
  BUILD +docker-prod

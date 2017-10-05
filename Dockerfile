FROM elixir:1.5.2-alpine

ADD . /app
WORKDIR /app
RUN apk update && apk add bash
RUN mix local.hex --force && mix local.rebar --force && mix deps.get && MIX_ENV=prod mix release --env=prod
CMD _build/prod/rel/coincoin/bin/coincoin console


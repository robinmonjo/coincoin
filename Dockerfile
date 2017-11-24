FROM elixir:1.5.2-alpine

RUN apk update && apk add bash make git

ADD . /app
WORKDIR /app
RUN make release
CMD _build/prod/rel/coincoin/bin/coincoin console

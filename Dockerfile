# Using the Hex.pm docker images. You have much better version control for
# Elixir, Erlang and Alpine.
#
#   - https://hub.docker.com/r/hexpm/elixir/tags
#   - Ex: hexpm/elixir:1.11.2-erlang-23.3.2-alpine-3.13.3
#
# Debugging Notes:
#
#   docker run -it --rm conta /bin/ash

###
### Fist Stage - Building the Release
###
FROM hexpm/elixir:1.11.2-erlang-23.3.2-alpine-3.13.3 AS build

# install build dependencies
RUN apk add --no-cache build-base npm

# prepare build dir
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# set build ENV as prod
ENV MIX_ENV=prod
ENV SECRET_KEY_BASE=nokey

# Copy over the mix.exs and mix.lock files to load the dependencies. If those
# files don't change, then we don't keep re-fetching and rebuilding the deps.
COPY mix.exs mix.lock ./

RUN mix deps.get --only prod && \
    mix deps.compile

COPY lib lib
COPY priv priv

# compile and build release
RUN mix do compile, release

###
### Second Stage - Setup the Runtime Environment
###

# prepare release docker image
FROM alpine:3.13.3 AS app
RUN apk add --no-cache openssl ncurses-libs

WORKDIR /app

RUN chown nobody:nobody /app

USER nobody:nobody

COPY --from=build --chown=nobody:nobody /app/_build/prod/rel/conta ./

ENV HOME=/app
ENV MIX_ENV=prod
ENV SECRET_KEY_BASE=nokey
ENV PORT=8080

CMD ["bin/conta", "start"]


FROM library/elixir:1.5-slim

EXPOSE 4810
ENV MIX_ENV=prod \
    HOST=localhost \
    PORT=4810

COPY sources.list /etc/apt/sources.list
RUN set -xe \
  && apt-get update \
  && apt-get install -y --no-install-recommends git ca-certificates


ADD . /srv/aria
VOLUME /srv/aria/config
VOLUME /srv/aria/data
WORKDIR /srv/aria


RUN HEX_MIRROR=https://hexpm.upyun.com mix local.hex --force
RUN HEX_MIRROR=https://hexpm.upyun.com mix local.rebar --force
RUN mix hex.repo add upm https://hexpm.upyun.com
RUN mix deps.get  --only prod
RUN mix compile

CMD ["mix"]

FROM ruby:2.6.3-alpine3.10
MAINTAINER Ryan Schlesinger <ryan@outstand.com>

RUN addgroup -g 1000 -S gem && \
    adduser -u 1000 -S -s /bin/ash -G gem gem && \
    apk add --no-cache \
      ca-certificates \
      tini \
      su-exec \
      build-base \
      git \
      openssh

WORKDIR /srv
RUN chown -R gem:gem /srv
USER gem

COPY --chown=gem:gem Gemfile faraday_persistent_excon.gemspec /srv/
COPY --chown=gem:gem lib/faraday_persistent_excon/version.rb /srv/lib/faraday_persistent_excon/
RUN git config --global push.default simple
COPY --chown=gem:gem . /srv/

USER root
COPY docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT ["/sbin/tini", "-g", "--", "/docker-entrypoint.sh"]
CMD ["rspec", "spec"]

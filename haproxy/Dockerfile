FROM ubuntu:18.04

ENV HAPROXY_VERSION 2.2.6
ENV HAPROXY_URL http://www.haproxy.org/download/2.2/src/haproxy-2.2.6.tar.gz
ENV HAPROXY_SHA256 be1c6754cbaceafc4837e0c6036c7f81027a3992516435cbbbc5dc749bf5a087

# see https://sources.debian.net/src/haproxy/jessie/debian/rules/ for some helpful navigation of the possible "make" arguments
RUN set -x \
  \
  && savedAptMark="$(apt-mark showmanual)" \
  && apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    gcc \
    libc6-dev \
    liblua5.3-dev \
    libpcre2-dev \
    libssl-dev \
    make \
    wget \
    zlib1g-dev \
  && rm -rf /var/lib/apt/lists/* \
  \
  && wget -O haproxy.tar.gz "$HAPROXY_URL" \
  && echo "$HAPROXY_SHA256 *haproxy.tar.gz" | sha256sum -c \
  && mkdir -p /usr/src/haproxy \
  && tar -xzf haproxy.tar.gz -C /usr/src/haproxy --strip-components=1 \
  && rm haproxy.tar.gz \
  \
  && makeOpts=' \
    TARGET=linux-glibc \
    USE_GETADDRINFO=1 \
    USE_LUA=1 LUA_INC=/usr/include/lua5.3 \
    USE_OPENSSL=1 \
    USE_PCRE2=1 USE_PCRE2_JIT=1 \
    USE_ZLIB=1 \
    \
    EXTRA_OBJS=" \
# see https://github.com/docker-library/haproxy/issues/94#issuecomment-505673353 for more details about prometheus support
      contrib/prometheus-exporter/service-prometheus.o \
    " \
  ' \
  && nproc="$(nproc)" \
  && eval "make -C /usr/src/haproxy -j '$nproc' all $makeOpts" \
  && eval "make -C /usr/src/haproxy install-bin $makeOpts" \
  \
  && mkdir -p /usr/local/etc/haproxy \
  && cp -R /usr/src/haproxy/examples/errorfiles /usr/local/etc/haproxy/errors \
  && rm -rf /usr/src/haproxy \
  \
  && apt-mark auto '.*' > /dev/null \
  && { [ -z "$savedAptMark" ] || apt-mark manual $savedAptMark; } \
  && find /usr/local -type f -executable -exec ldd '{}' ';' \
    | awk '/=>/ { print $(NF-1) }' \
    | sort -u \
    | xargs -r dpkg-query --search \
    | cut -d: -f1 \
    | sort -u \
    | xargs -r apt-mark manual \
  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false

# https://www.haproxy.org/download/1.8/doc/management.txt
# "4. Stopping and restarting HAProxy"
# "when the SIGTERM signal is sent to the haproxy process, it immediately quits and all established connections are closed"
# "graceful stop is triggered when the SIGUSR1 signal is sent to the haproxy process"
STOPSIGNAL SIGUSR1

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["haproxy", "-f", "/local/haproxy.cfg"]

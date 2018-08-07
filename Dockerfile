FROM alpine:3.8
LABEL maintainer="quentin.mcgaw@gmail.com" \
      description="Lightweight TeamSpeak 3.1.1 server (Alpine, glibc)" \
      download="11.4MB" \
      size="22.6MB" \
      ram="29MB" \
      cpu_usage="Very Low to Low" \
      github="https://github.com/qdm12/teamspeak-docker"
ENV VERSION=3.3.0 \
	SHA256=f124868f7bdb1b359f984d2b5cd16b6e0259cecb85bad32ffafdfa91576065cb
RUN apk add -q --progress --no-cache --update ca-certificates && \
    wget -q https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.27-r0/glibc-2.27-r0.apk \
            https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.27-r0/glibc-bin-2.27-r0.apk \
            https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.27-r0/glibc-i18n-2.27-r0.apk && \
    wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://raw.githubusercontent.com/sgerrand/alpine-pkg-glibc/master/sgerrand.rsa.pub && \
    apk add -q --progress --no-cache glibc-2.27-r0.apk glibc-bin-2.27-r0.apk glibc-i18n-2.27-r0.apk && \
    rm /etc/apk/keys/sgerrand.rsa.pub glibc-*.apk && \
    #/usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 C.UTF-8 || true && \
    echo "export LANG=C.UTF-8" > /etc/profile.d/locale.sh && \
    apk del -q --progress --purge glibc-i18n glibc-bin && \
    mkdir -p /teamspeak/logs && \
    cd /teamspeak && \
    wget -q -O teamspeak.tgz http://dl.4players.de/ts/releases/$VERSION/teamspeak3-server_linux_amd64-$VERSION.tar.bz2 && \
    apk del -q --progress --purge wget && \
    if [ $(sha256sum teamspeak.tgz | cut -d" " -f 0) != $SHA256 ]; then echo "Checksum of Teamspeak download failed"; exit 1; fi && \
    tar xf teamspeak.tgz --strip-components=1 && \
    touch .ts3server_license_accepted && \
    rm -rf teamspeak.tgz CHANGELOG LICENSE libts3db_mariadb.so doc redist serverquerydocs tsdns *.sh && \
    mkdir -p /data && \
    touch /data/ts3server.sqlitedb /data/query_ip_blacklist.txt /data/query_ip_whitelist.txt && \
    rm -rf /var/cache/apk/*
VOLUME /data /teamspeak/logs
RUN ln -s /data/ts3server.sqlitedb /teamspeak/ts3server.sqlitedb && \
    ln -s /data/query_ip_blacklist.txt /teamspeak/query_ip_blacklist.txt && \
    ln -s /data/query_ip_whitelist.txt /teamspeak/query_ip_whitelist.txt
ENV LD_LIBRARY_PATH=/teamspeak
EXPOSE 9987/udp 10011/tcp 30033/tcp
WORKDIR /teamspeak
ENTRYPOINT ./ts3server
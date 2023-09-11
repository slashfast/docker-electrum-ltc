FROM python:3.11-alpine

ARG ELECTRUM_LTC_VERSION

ENV ELECTRUM_LTC_VERSION $ELECTRUM_LTC_VERSION
ENV ELECTRUM_LTC_USER electrum-ltc
ENV ELECTRUM_LTC_PASSWORD electrumz		# XXX: CHANGE REQUIRED!
ENV ELECTRUM_LTC_HOME /home/$ELECTRUM_LTC_USER
ENV ELECTRUM_LTC_NETWORK mainnet

COPY contrib /contrib/
COPY docker-entrypoint.sh /usr/local/bin/

RUN adduser -D $ELECTRUM_LTC_USER && \
    mkdir -p /data ${ELECTRUM_LTC_HOME} && \
	ln -sf /data ${ELECTRUM_LTC_HOME}/.electrum-ltc && \
	chown ${ELECTRUM_LTC_USER} ${ELECTRUM_LTC_HOME}/.electrum-ltc /data && \
    apk add libsecp256k1 libressl3.7-libcrypto && \
    apk --no-cache add --virtual build-dependencies git make automake autoconf libtool gcc musl-dev libsecp256k1-dev libressl-dev gpg gpg-agent dirmngr libffi libffi-dev && \
    wget https://electrum-ltc.org/download/Electrum-LTC-${ELECTRUM_LTC_VERSION}.tar.gz && \
    wget https://electrum-ltc.org/download/Electrum-LTC-${ELECTRUM_LTC_VERSION}.tar.gz.asc && \
    gpg --keyserver keyserver.ubuntu.com --recv-keys 0x6fc4c9f7f1be8fea 0xfe3348877809386c 0x3b2a6315cd51a673 && \
    gpg --fingerprint 0x6fc4c9f7f1be8fea 0xfe3348877809386c 0x3b2a6315cd51a673 && \
    gpg --verify Electrum-LTC-${ELECTRUM_LTC_VERSION}.tar.gz.asc Electrum-LTC-${ELECTRUM_LTC_VERSION}.tar.gz && \
    echo -e "**************************\n GPG VERIFIED OK\n**************************" && \
    pip3 install cryptography scrypt Electrum-LTC-${ELECTRUM_LTC_VERSION}.tar.gz && \
    chmod +x /contrib/* && \
    ./contrib/make_libsecp256k1.sh && \
    rm -r contrib Electrum-LTC-${ELECTRUM_LTC_VERSION}.tar.gz Electrum-LTC-${ELECTRUM_LTC_VERSION}.tar.gz.asc && \
    apk del build-dependencies && \
    mkdir -p /data \
	    ${ELECTRUM_LTC_HOME}/.electrum-ltc/wallets/ \
	    ${ELECTRUM_LTC_HOME}/.electrum-ltc/testnet/wallets/ \
	    ${ELECTRUM_LTC_HOME}/.electrum-ltc/regtest/wallets/ \
	    ${ELECTRUM_LTC_HOME}/.electrum-ltc/simnet/wallets/ && \
    ln -sf ${ELECTRUM_LTC_HOME}/.electrum-ltc/ /data && \
    chown -R ${ELECTRUM_LTC_USER} ${ELECTRUM_LTC_HOME}/.electrum-ltc /data && \
    chmod +x /usr/local/bin/docker-entrypoint.sh && \
	
USER $ELECTRUM_LTC_USER
WORKDIR $ELECTRUM_LTC_HOME
VOLUME /data
EXPOSE 7000

ENTRYPOINT ["docker-entrypoint.sh"]

#!/usr/bin/env sh

set -ex

# Network switch
if [ "$ELECTRUM_LTC_NETWORK" = "mainnet" ]; then
  FLAGS=''
elif [ "$ELECTRUM_LTC_NETWORK" = "testnet" ]; then
  FLAGS='--testnet'
elif [ "$ELECTRUM_LTC_NETWORK" = "regtest" ]; then
  FLAGS='--regtest'
elif [ "$ELECTRUM_LTC_NETWORK" = "simnet" ]; then
  FLAGS='--simnet'
fi

# Graceful shutdown
trap 'pkill -TERM -P1; electrum-ltc $FLAGS daemon stop; exit 0' SIGTERM

# Set config
electrum-ltc -o $FLAGS setconfig rpcuser ${ELECTRUM_LTC_USER}
electrum-ltc -o $FLAGS setconfig rpcpassword ${ELECTRUM_LTC_PASSWORD}
electrum-ltc -o $FLAGS setconfig rpchost 0.0.0.0
electrum-ltc -o $FLAGS setconfig rpcport 7000

# XXX: Check load wallet or create

# Remove daemon file after setconfig
find $ELECTRUM_LTC_HOME/.electrum-ltc/ -name "daemon" -type f -delete


# Run application
if [ -n "$ELECTRUM_LTC_PROXY" ]; then
  electrum-ltc $FLAGS daemon -d -p "${ELECTRUM_LTC_PROXY}"
else
  electrum-ltc $FLAGS daemon -d
fi

# Wait forever
while true; do
  tail -f /dev/null & wait ${!}
done
# docker-electrum-ltc

[![License: MIT](https://img.shields.io/badge/License-MIT-black.svg)](https://opensource.org/licenses/MIT)


**Electrum-LTC client running as a daemon in docker container with JSON-RPC enabled.**

[Electrum-LTC client](https://electrum-ltc.org/) is a simple, but powerful Litecoin wallet.

### Ports

* `7000` - JSON-RPC port.

### Volumes

* `/data` - user data folder (on host it usually has a path ``/home/user/.electrum-ltc``).


## Getting started

#### docker-compose

[docker-compose.yml](https://github.com/slashfast/docker-electrum-ltc/blob/main/docker-compose.yml) to see minimal working setup. When running in production, you can use this as a guide.

```bash
git clone https://github.com/slashfast/docker-electrum-ltc.git
cd docker-electrum-ltc
docker-compose up
docker-compose exec electrum-ltc electrum-ltc getinfo
docker-compose exec electrum-ltc electrum-ltc create
docker-compose exec electrum-ltc electrum-ltc load_wallet
curl --data-binary '{"id":"1","method":"getinfo"}' http://electrum-ltc:changeme@localhost:7000
```

:exclamation:**Warning**:exclamation:

Always link electrum-ltc daemon to containers or bind to localhost directly and not expose 7000 port for security reasons.

## License

See [LICENSE](https://github.com/slashfast/docker-electrum-ltc/blob/main/LICENSE)

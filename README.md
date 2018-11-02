# kong-jwt-claims-to-headers

work in progress....
please check back later...

## Developer Prequisites

see Kong Setup section below

- install postgres and cassandra locally
- start postgres and cassandra
- configure postgres for tests

```shell
psql postgres
CREATE USER kong_tests; CREATE DATABASE kong_tests OWNER kong_tests;
```

## Source code

- Source: see kong/plugins/jwt-claims-to-headers
- Tests: see spec/jwt-claims-to-headers

## Developer Packaging and installation

### Build

```shell
luarocks make
```

### Package

```shell
luarocks pack kong-plugin-jwt-claims-to-headers 0.1.0-1
```

### Install

Install local build

```shell
luarocks install kong-plugin-jwt-claims-to-headers-0.1.0-1.all.rock
```

Install dist build

```shell
luarocks install http://github.com/cdimascio/kong-plugin-jwt-claims-to-headers/kong-plugin-jwt-claims-to-headers-0.1.0-1.all.rock
```

Manual install

```shell
# use lua package path or KONG LONG PACKAGE PATH
# e.g. lua_package_path = /</kong/plugins/jwt-claims-to-headers/?.lua;;
export KONG_LUA_PACKAGE_PATH=/kong/plugins/jwt-claims-to-headers/handler.lua?.lua;;

# edit kong.conf and modify the plugins directive to
plugins = bundled,jwt-claims-to-headers
```

Validate it loaded

```shell
# edit kong.conf and set
log_level = debug
```

You should see the following on start up:

```shell
[debug] Loading plugin jwt-clatims-to-headers
```

### Remove plugin

```shell
luarocks remove  kong-plugin-jwt-claims-to-headers
```

## Install posgres and cassandra for tests

postgres setup

```
psql postgres
CREATE USER kong_tests; CREATE DATABASE kong_tests OWNER kong_tests;
```

## Contributing

Setup Kong so we have an environment to run our tests

## Kong Setup

This is not needed, however its a good way to test that you can run tests within a Kong test environment

### Build

- Install open SSL
- git clone https://github.com/Kong/kong
- git checkout tags/0.14.1
- cd kong/
- luarocks install luasec OPENSSL_DIR=/usr/local/opt/openssl
- luarocks make

### Tests

<!-- - luarocks install busted
- luarocks install luacheck -->

- make dev
- make test
- make test-integration

don't need to run the tests below. if the above work we can run integration tests

- make test-plugins
- make test-all
- make lint

### Full instructions

https://github.com/Kong/kong/blob/master/README.md#development

<!-- - export LUA_PATH=./spec/?.lua
- Install https://github.com/openresty/resty-cli

  - pip2 install hererocks
  - hererocks lua_install --lua=5.1 -r latest
    - source lua_install/bin/activate
  - luarocks install busted
  - luarocks install luacheck

  ## Build
  - luarocks make

  busted -c -->

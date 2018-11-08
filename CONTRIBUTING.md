# Contributing: kong-jwt-claims-to-headers

# Prerequisites

To run tests locally, you will need to install Kong, PostgreSQL, and Cassandra

- [Kong 0.14.1](https://konghq.com/install/)
- [PostgreSQL](https://www.postgresql.org/download/)
- [Cassandra](http://cassandra.apache.org/download/) (or use brew on mac)

  After installing PostgreSQL, you must create a db and user for `kong` and `kong_tests`. To do so:

```shell
psql -c 'CREATE USER kong;' -U postgres
psql -c 'CREATE DATABASE kong OWNER kong;' -U postgres
psql -c 'CREATE USER kong_tests;' -U postgres
psql -c 'CREATE DATABASE kong_tests OWNER kong_tests;' -U postgres
```


- Start Cassandra `cassandra -f`
- Start Postgres `pg_ctl -D /usr/local/var/postgres start`
- Download [kong.conf](https://raw.githubusercontent.com/Kong/kong/0.14.1/kong.conf.default)
  - Uncomment and update any custom values in the cassandra and postgres sections e.g. `pg_password`. If everything is installed locally with defaults, you likely do not need to uncomment or edit.
- Start Kong `kong start -c /path/to/my/kong.conf` to verify it works
- Stop Kong

Next, run the tests to verify everything is all good!

# Test

```shell
./bin/busted
```

# Develop

Write code and submit a PR

- Source code: `kong/plugins/jwt-claims-to-headers`
- Tests: `spec/jwt-claims-to-headers`

## Build

```shell
luarocks make
```

### Package

Create the lua rock

```shell
luarocks pack kong-plugin-jwt-claims-to-headers 0.1.0-1
```

### Install

Install your newly generated rock

```shell
luarocks install kong-plugin-jwt-claims-to-headers-0.1.0-1.all.rock
```

Add the plugin’s name to the plugins list in your Kong configuration (on each Kong node):

```shell
plugins = bundled,jwt-claims-to-headers
```

# kong-jwt-claims-to-headers

![](https://travis-ci.org/cdimascio/kong-plugin-jwt-claims-to-headers.svg?branch=master)

work in progress....
please check back later...

## Install

### Install dist build

```shell
luarocks install http://github.com/cdimascio/kong-plugin-jwt-claims-to-headers/kong-plugin-jwt-claims-to-headers-0.1.0-1.all.rock
```

If you compiled it yourself you can install from the locally generated rock

```shell
luarocks install kong-plugin-jwt-claims-to-headers-0.1.0-1.all.rock
```


### Manual install

```shell
# use lua package path or KONG LONG PACKAGE PATH
# e.g. lua_package_path = /</kong/plugins/jwt-claims-to-headers/?.lua;;
export KONG_LUA_PACKAGE_PATH=/kong/plugins/jwt-claims-to-headers/handler.lua?.lua;;

# edit kong.conf and modify the plugins directive to
plugins = bundled,jwt-claims-to-headers
```

### Validate the install

To verify the plugin loaded on Kong start, edit `kong.conf` and set `log_level` to `debug`.

```shell
# edit kong.conf and set
log_level = debug
```

Look for the following output:

```shell
[debug] Loading plugin jwt-clatims-to-headers
```

### Uninstall

```shell
luarocks remove  kong-plugin-jwt-claims-to-headers
```

## [Contributing](CONTRIBUTING.md)

If you would like to contribute to `kong-plugin-jwt-claims-to-headers`, go [here](CONTRIBUTING.md). We walk you through how to set up your developent environment.


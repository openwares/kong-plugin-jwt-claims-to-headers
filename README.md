# kong-jwt-claims-to-headers

![](https://travis-ci.org/cdimascio/kong-plugin-jwt-claims-to-headers.svg?branch=master)

A Kong plugin that extracts JWT claims and adds them as HTTP request headers

## Installation

### Install the plugin

```shell
luarocks install kong-plugin-jwt-claims-to-headers
```

### Configure Kong to use the plugin

Add the plugin’s name to the plugins list in your Kong configuration (on each Kong node):

```shell
plugins = bundled,jwt-claims-to-headers
```

### Manual install

```shell
# use lua package path or KONG LONG PACKAGE PATH
# e.g. lua_package_path = /</kong/plugins/jwt-claims-to-headers/?.lua;;
export KONG_LUA_PACKAGE_PATH=/kong/plugins/jwt-claims-to-headers/handler.lua?.lua;;

# edit the Kong configuration and modify the plugins directive to
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

# kong-jwt-claims-to-headers

![](https://travis-ci.org/openwares/kong-plugin-jwt-claims-to-headers.svg?branch=master)![](https://img.shields.io/badge/license-Apache%202-blue.svg)![http://luarocks.org/modules/cdimascio/kong-plugin-jwt-claims-to-headers](https://img.shields.io/badge/luarocks-yes-orange.svg)

A [Kong](https://konghq.com/) plugin that extracts JWT claims and applies them as HTTP request headers.

<p align="center">
<img src="https://raw.githubusercontent.com/cdimascio/kong-plugin-jwt-claims-to-headers/master/assets/jwt-claims-to-headers-logo.png" width="400"/>
</p>

_requires Kong 1.0.x or greater_

## Setup

### Install the plugin

```shell
luarocks install kong-plugin-jwt-claims-to-headers
```

### Enable the plugin

Edit `kong.conf`. Add `jwt-claims-to-headers` to the `plugins` directive.

```shell
plugins = bundled,jwt-claims-to-headers
```

## Usage

_coming soon..._

## Installation

The [setup](#setup) section describes the recommended installation method. The sub-sections below describe 1. manually installing the plugin, 2. validating the that the plugin was installed properly, and 3. uninstalling the plugin

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

### Contributors

- Tova [riley2012](https://github.com/riley2012)
- Carmine [cdimascio](https://github.com/cdimascio)

## License

[Apache 2.0](LICENSE)

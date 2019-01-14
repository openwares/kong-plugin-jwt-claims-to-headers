package = "kong-plugin-jwt-claims-to-headers"

version = "0.1.0-1"               -- TODO: renumber, must match the info in the filename of this rockspec!
-- The version '0.1.0' is the source code version, the trailing '1' is the version of this rockspec.
-- whenever the source version changes, the rockspec should be reset to 1. The rockspec version is only
-- updated (incremented) when this file changes, but the source remains the same.

-- Here we extract it from the package name.
local pluginName = package:match("^kong%-plugin%-(.+)$")

supported_platforms = {"linux", "macosx"}
source = {
  url = "http://github.com/cdimascio/kong-plugin-jwt-claims-to-headers.git",
  tag = "0.1.0"
}

description = {
  summary = "Extracts specific JWT claims and adds them as headers",
  homepage = "http://github.com/cdimascio/kong-plugin-jwt-claims-to-headers",
  license = "Apache 2.0"
}

dependencies = {
}

build = {
  type = "builtin",
  modules = {
    ["kong.plugins."..pluginName..".handler"] = "kong/plugins/"..pluginName.."/handler.lua",
    ["kong.plugins."..pluginName..".schema"] = "kong/plugins/"..pluginName.."/schema.lua",
  }
}
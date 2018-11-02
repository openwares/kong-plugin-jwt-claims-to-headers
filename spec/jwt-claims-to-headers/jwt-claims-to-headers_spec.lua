local helpers = require "spec.helpers"

-- The source code to setup and teardown Kong was borrowed from the Kong project
-- spec/fixture contains fixtures directly borrowed from the Kong project
for _, strategy in helpers.each_strategy() do
  describe("Jwt-Claims-to-Headers-Plugin: (access) [#" .. strategy .. "]", function()
    local client

    setup(function()
      local bp = helpers.get_db_utils(strategy)

      local route1 = bp.routes:insert({
        hosts = { "test1.com" },
      })
      bp.plugins:insert {
        name = "jwt-claims-to-headers",
        route_id = route1.id,
        config = {},
      }

      -- start kong
      assert(helpers.start_kong({
        -- set the strategy
        database   = strategy,
        -- use the custom test template to create a local mock server
        nginx_conf = "spec/fixtures/custom_nginx.template",
        -- set the config item to make sure our plugin gets loaded
        plugins = "bundled,jwt-claims-to-headers",         -- since Kong CE 0.14
        custom_plugins = "jwt-claims-to-headers",          -- pre Kong CE 0.14
      }))
    end)

    teardown(function()
      helpers.stop_kong(nil, true)
    end)

    before_each(function()
      client = helpers.proxy_client()
    end)

    after_each(function()
      if client then client:close() end
    end)



    describe("request", function()
      it("contains the X-Jwt-ClaimX header", function()
        local r = assert(client:send {
          method = "GET",
          path = "/request",  -- makes mockbin return the entire request
          headers = {
            host = "test1.com"
          }
        })
        -- validate that the request succeeded, response status 200
        assert.response(r).has.status(200)
        -- now check the request (as echoed by mockbin) to have the header
        local header_value = assert.request(r).has.header("X-Jwt-ClaimX")
        -- validate the value of that header
        assert.equal("ClaimX value", header_value)
      end)
    end)



    describe("response", function()
      it("contains the X-Jwt-ClaimX header", function()
        local r = assert(client:send {
          method = "GET",
          path = "/request",  -- makes mockbin return the entire request
          headers = {
            host = "test1.com",
          }
        })
        -- validate that the request succeeded, response status 200
        assert.response(r).has.status(200)
        -- now check the response to have the header
        local header_value = assert.response(r).has.header("X-Jwt-ClaimX")
        -- validate the value of that header
        assert.equal("ClaimX value", header_value)
      end)
    end)

    describe("/not-a-route", function()
      it("should return not found", function()
        -- send requests through Kong
        local res = client:get("/not-a-route", {
          headers = {
            ["Host"] = "test.com"
          }
        })

        assert.res_status(404, res)
      end)
    end)

  end)
end
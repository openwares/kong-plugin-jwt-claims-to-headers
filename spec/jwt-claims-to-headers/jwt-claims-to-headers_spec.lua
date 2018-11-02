local helpers = require "spec.helpers"

for _, strategy in helpers.each_strategy() do
  describe("my plugin", function()

    local bp = helpers.get_db_utils(strategy)

    setup(function()
      local service = bp.services:insert {
        name = "test-service",
        host = "httpbin.org"
      }

      bp.routes:insert({
        hosts = { "test.com" },
        service = { id = service.id }
      })

      -- start Kong with your testing Kong configuration (defined in "spec.helpers")
      assert(helpers.start_kong( { plugins = "bundled,jwt-claims-to-headers" }))

      admin_client = helpers.admin_client()
    end)

    teardown(function()
      if admin_client then
        admin_client:close()
      end

      helpers.stop_kong()
    end)

    before_each(function()
      proxy_client = helpers.proxy_client()
    end)

    after_each(function()
      if proxy_client then
        proxy_client:close()
      end
    end)

    describe("thing", function()
      it("should do thing", function()
        -- send requests through Kong
        local res = proxy_client:get("/get", {
          headers = {
            ["Host"] = "test.com"
          }
        })

        local body = assert.res_status(200, res)

        -- body is a string containing the response
      end)
    end)
  end)
end

-- local helpers = require "spec.helpers"



-- for _, strategy in helpers.each_strategy() do
--   describe("Demo-Plugin: myplugin (access) [#" .. strategy .. "]", function()
--     local client

--     setup(function()
--       local bp = helpers.get_db_utils(strategy)

--       local route1 = bp.routes:insert({
--         hosts = { "test1.com" },
--       })
--       bp.plugins:insert {
--         name = "myplugin",
--         route_id = route1.id,
--         config = {},
--       }

--       -- start kong
--       assert(helpers.start_kong({
--         -- set the strategy
--         database   = strategy,
--         -- use the custom test template to create a local mock server
--         nginx_conf = "spec/fixtures/custom_nginx.template",
--         -- set the config item to make sure our plugin gets loaded
--         plugins = "bundled,jwt-claims-to-headers",         -- since Kong CE 0.14
--         custom_plugins = "jwt-claims-to-headers",          -- pre Kong CE 0.14
--       }))
--     end)

--     teardown(function()
--       helpers.stop_kong(nil, true)
--     end)

--     before_each(function()
--       client = helpers.proxy_client()
--     end)

--     after_each(function()
--       if client then client:close() end
--     end)



--     describe("request", function()
--       it("gets a 'hello-world' header", function()
--         local r = assert(client:send {
--           method = "GET",
--           path = "/request",  -- makes mockbin return the entire request
--           headers = {
--             host = "test1.com"
--           }
--         })
--         -- validate that the request succeeded, response status 200
--         assert.response(r).has.status(200)
--         -- now check the request (as echoed by mockbin) to have the header
--         local header_value = assert.request(r).has.header("hello-world")
--         -- validate the value of that header
--         assert.equal("this is on a request", header_value)
--       end)
--     end)



--     describe("response", function()
--       it("gets a 'bye-world' header", function()
--         local r = assert(client:send {
--           method = "GET",
--           path = "/request",  -- makes mockbin return the entire request
--           headers = {
--             host = "test1.com"
--           }
--         })
--         -- validate that the request succeeded, response status 200
--         assert.response(r).has.status(200)
--         -- now check the response to have the header
--         local header_value = assert.response(r).has.header("bye-world")
--         -- validate the value of that header
--         assert.equal("this is on the response", header_value)
--       end)
--     end)

--   end)
-- end
local function read_config(filename)
	local file = require('fio').open(filename)
	local config = require('yaml').decode(file:read())

	return config
end

local filename = 'config.yml'
local config = read_config(filename)

local function request_handler(request)
	local client = require('http.client').new()

	local host = config.proxy.bypass.host
	local port = config.proxy.bypass.port
	
	local path = request:path()
	local query = request:query()

	local url = host .. ":" .. port .. path .. '?' .. query

	local method = request:method()
	local body = request.body
	local headers = request:headers()
	local timeout = 30

	return client:request(method, url, body, { headers, timeout })
end

local function start_proxy()
	local server = require('http.server').new('localhost', config.proxy.port)

	local router = require('http.router').new()
	router:route({ path = '/' }, request_handler)
	router:route({ path = '/.*' }, request_handler)

	server:set_router(router)
	server:start()
end

start_proxy()

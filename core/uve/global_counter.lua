--
--全局计数器
-- TODO 优化该计数器，所在全局计数(如趋势通总量控制)通过该模块实现
--
module(..., package.seeall)

function new(self)
    local c = {counter={}}

    local conf = require('conf.common')
    local servers = conf.UPSTREAM.global_counter

    local index = math.random(1, #servers)
    local ip = servers[index].ip
    local port = servers[index].port
    local redis_t = require('lib.redis')
    c.redis = redis_t.conn(ip, port)
    local _start_time = ngx.req.start_time()
    c.daily_key = os.date('%Y%m%d', _start_time)
    c.hash_key = 'counter_' .. c.daily_key 
    c.hash_total_key = c.hash_key .. '_total'
    setmetatable(c, {__index = self})
    return c
end

function get_daily(self, key, default)
    default = default or 0
    if not self.counter[key] then
        local _data, flags, err = self.redis:hget(self.hash_total_key, key)
        if err then
            ngx.log(ngx.ERR, 'REDIS error: ' .. err)
        elseif _data then
            self.counter[key] = tonumber(_data) or default
        else
            self.counter[key] = default
        end
    end
    return self.counter[key]
end

function inc_daily(self, key, default)
    local count = default or 1
    local new_count, err = self.redis:hincrby(self.hash_key, key, 1)
    if err then
      ngx.log(ngx.ERR, 'REDIS error: ' .. err)
    else
        self.counter[key] = new_count
    end
    return self.counter[key]
end

function get(self, key, default)
    --TODO get
end

function inc(self, key)
end

function close(self)
    local redis_t = require('lib.redis')
    redis_t.close(self.redis)
end


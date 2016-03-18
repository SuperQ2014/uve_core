-- 
-- Meredisached wrapper
--
-- @author Tang Linhua<linhua@staff.sina.com.cn>
-- @version 20140305
module(..., package.seeall)

function conn(ip, port)
    local redis_t = require('resty.redis')
    local redis, err = redis_t:new()
    if redis then
        local ok, err = redis:connect(ip, port)
        if not ok then
            ngx.log(ngx.ERR, 'SAD#failed to conn Redis(' .. ip .. ':' .. port .. '): ' .. err)
        end
        redis:set_timeout(20)
        local times, err = redis:get_reused_times()
        if times then
            ngx.log(ngx.INFO, 'SAD#MC(' .. ip .. ':' .. port .. ') reused times: ' .. times)
        end
        return redis
    else
        ngx.log(ngx.ERR, 'MC init error: ' .. err)
    end
    return nil
end

function close(redis)
    if not redis then
        return false
    end
    local ok, err = redis:set_keepalive(10000, 100)
    if not ok then
        ngx.log(ngx.INFO, 'SAD#failed to set keepalive of Redis: ' .. err)
        return false
    end
    return true
end

function real_close(redis)
    if not redis then
        return false
    end
    local ok, err = redis:close()
    if not ok then
        ngx.log(ngx.ERR, 'SAD#failed to close Redis: ' .. err)
        return false
    end
    return true
end


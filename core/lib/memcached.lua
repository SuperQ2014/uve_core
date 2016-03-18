-- 
-- Memcached wrapper
--
-- @author Tang Linhua<linhua@staff.sina.com.cn>
-- @version 20140305
module(..., package.seeall)

MC_DEFAULT_TIMEOUT_MS=200
MC_MAX_IDLE_TIME_MS=10000
MC_POOL_SIZE=100

function conn(ip, port, timeout_ms)
    local mc_t = require('resty.memcached')
    local mc, err = mc_t:new()
    if mc then
        local ok, err = mc:connect(ip, port)
        if not ok then
            ngx.log(ngx.ERR, 'failed to conn MC(' .. ip .. ':' .. port .. '): ' .. err)
        end
        timeout_ms = timeout_ms or MC_DEFAULT_TIMEOUT_MS
        --ngx.log(ngx.ERR, 'MC timeout: ' .. timeout_ms)
        mc:set_timeout(timeout_ms)
        local times, err = mc:get_reused_times()
        if err then
            ngx.log(ngx.ERR, 'MC(' .. ip .. ':' .. port .. '): ' .. err)
        else
            ngx.log(ngx.INFO, 'MC(' .. ip .. ':' .. port .. ') reused times: ' .. times)
        end
        return mc
    else
        ngx.log(ngx.ERR, 'MC init error: ' .. err)
    end
    return nil
end

function close(mc)
    if not mc then
        return false
    end
    local ok, err = mc:set_keepalive(MC_MAX_IDLE_TIME_MS, MC_POOL_SIZE)
    if not ok then
        ngx.log(ngx.INFO, 'failed to set keepalive of MC: ' .. err)
        return false
    end
    ngx.log(ngx.INFO, 'set keepalive of MC: max_idle_time=' .. MC_MAX_IDLE_TIME_MS .. ', pool_size=' .. MC_POOL_SIZE)
    return true
end

function real_close(mc)
    if not mc then
        return false
    end
    local ok, err = mc:close()
    if not ok then
        ngx.log(ngx.ERR, 'failed to close MC: ' .. err)
        return false
    end
    return true
end


--
-- Module schduler
--
-- @author Tang Linhua(linhua@staff.weibo.com)
-- @version 20141111
--
module(..., package.seeall)
local name = ...

-- Abstract class

--function new(self, core)
--   local parent = require('uve.scheduler')
--   setmetatable(self, {__index = parent})
--   return setmetatable({core = core, modules = {}}, {__index=self})
--end

function init(core)
    core.debug:n('Loading scheduler...')
    local c = core.service_conf.scheduler
    if not c then
        c = 'uve.scheduler.default'
    end
    local t = require(c)
    return t:new(core)
end

-- Instance method
function process_modules(self)
    self.core.debug:n(name .. ': processing module')
    local reqs = {} 
    for _, mo in ipairs(self.modules) do
        self.core.debug:n(name .. ': module: ' .. mo.id)
        local _method, _uri, _body = mo:get_req_params()
        local method = 'GET'
        if _method == ngx.HTTP_POST then
            --TODO change to configurable Content-Type
            ngx.req.set_header('Content-Type', 'application/x-www-form-urlencoded')
            method = 'POST'
        elseif _method == ngx.HTTP_GET then
            method = 'GET'
        else
            method = 'UNKNOWN'
        end
        self.core.debug:n(string.format("%s(%d): %s %s #body# %s", mo.name, mo.id, method, _uri, _body))
        if ngx.HTTP_POST == _method then
            table.insert(reqs, {_uri, {method=_method, body=_body}})
        else
            table.insert(reqs, {_uri})
        end
    end

    local utils = require('lib.utils')
    local tstart = utils.microtime(true)
    local resps = {ngx.location.capture_multi(reqs)}
    local tc = (utils.microtime(true) - tstart) * 1000
    self.core.debug:n(name .. '#capture_multi latency(ms):' .. tc)
    self.core.trace:append(string.format(name .. ':capm:ms:%.3f', tc))

    if #resps == #reqs then
        for _i, mo in ipairs(self.modules) do
            mo:run(resps[_i])
        end
    else
        self.core.trace:append('scheduler:error:capture')
    end
end


-- 
-- Debugger
--
-- @author Tang Linhua<linhua@staff.sina.com.cn>
-- @version 20140305
-- 
module(..., package.seeall)

local utils = require("lib.utils")
local ffi = require("ffi")

function new(self, request)
    local _enabled = tonumber(request:get('__ldebug__')) or tonumber(request:get('__debug__'))
    local _uid = request:get('uid')
    local _fd = -1
    local _log_enabled = false
    if not _enabled or _enabled == 0 then
        _enabled = false
    else
        _enabled = true
    end
    return setmetatable({fd = _fd, uid = _uid, enabled = _enabled, log_enabled = _log_enabled}, {__index = self})
end

function n(self, msg)
    local _msg = 'Notice: ' .. msg
    if self.enabled then
        ngx.say(_msg)
    elseif self.log_enabled then
        ffi.C.write(self.fd, _msg .. "\n", #_msg + 1)
    end
end

function w(self, msg)
    local _msg = 'Warning: ' .. msg
    if self.enabled then
        ngx.say(_msg)
    elseif self.log_enabled then
        ffi.C.write(self.fd, _msg .. "\n", #_msg + 1)
    end
end

function e(self, msg)
    local _msg = 'Error: ' .. msg
    if self.enabled then
        ngx.say(_msg)
    elseif self.log_enabled then
        ffi.C.write(self.fd, _msg .. "\n", #_msg + 1)
    end
end

function close(self)
    if self.fd > 0 then
        ffi.C.close(self.fd)
    end
end


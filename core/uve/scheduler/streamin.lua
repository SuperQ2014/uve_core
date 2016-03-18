--
-- Streamin Schedule
--
-- @author Cao zhenliang(zhenliang@staff.weibo.com)
-- @version 20151202
--
module(..., package.seeall)
local name = ...

function new(self, core)
    core.debug:n('Init: ' .. name)
    -- Inherit from super class
    local parent = require('uve.scheduler')
    setmetatable(self, {__index = parent})
    return setmetatable({core = core, modules = {}}, {__index=self})
end

function run(self)
    self.core.debug:n('scheduler: ' .. name)
    local modules = self.core.service_conf.modules
    for smid, m in pairs(modules) do
        self.core.debug:n('Load module: ' .. m)
        local mt = require(m)
        local mo = mt:new(smid, self.core)
        local limited, reason = mo:ctrl()
        if not limited then
            table.insert(self.modules, mo)
        else
            self.core.debug:n(m .. ' is limited: ' .. reason)
        end
    end
    if #self.modules < 1 then
        self.core.debug:w('NO module instance')
        return
    end
    -- TODO fetch backend service
    self:process_modules()
end

function process_modules(self)
    for _, mo in ipairs(self.modules) do
        self.core.debug:n(name .. ': module: ' .. mo.id)
        mo:run({})
    end
end


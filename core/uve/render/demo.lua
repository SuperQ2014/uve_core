--
-- Local Render 
--
-- @author Tang Linhua(linhua@staff.weibo.com)
-- @version 20141111
--
module(..., package.seeall)
local name = ...

function new(self, core)
    core.debug:n('Init:' .. name)
    return setmetatable({core = core}, {__index=self})
end

function render(self)
    local modules = self.core.scheduler.modules
    if modules and #modules > 0 then
        for _, mo in ipairs(modules) do
            if mo.data then
                for _, item in ipairs(mo.data) do
                    table.insert(self.core.final_resp, item)
                end
                local smc = require('uve.service_module.config')
                mo.status = smc.STATUS_OK
            else
                self.core.debug:w(name .. '#no data: ' .. mo.name .. '(' .. mo.id .. ')')
                self.core.trace:append('source:' .. mo.id .. ':nodata')
            end
        end
    else
        self.core.debug:n(name .. '#No moules')
    end
end


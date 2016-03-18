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
            if mo.data and #mo.data > 0 then
                for _, _data in ipairs(mo.data) do
                    if _data.cardlist or (_data.feeds and #_data.feeds > 0) then
                        table.insert(self.core.final_resp, _data)
                    end
                end
                local smc = require('uve.sm.config')
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


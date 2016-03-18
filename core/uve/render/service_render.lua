--
-- Service Render 
--
-- @author Tang Linhua(linhua@staff.weibo.com)
-- @version 20141111
--
module(..., package.seeall)
local name = ...

function new(self, core)
    core.debug:n('Init: ' .. name)
    return setmetatable({core = core}, {__index=self})
end

function render(self)
    local modules = self.core.scheduler.modules
    if modules and #modules > 0 then
    else
        self.core.debug:n(name .. '#No moules')
    end
end


--
-- Prerender
--
-- @author Li Delong(delong1@staff.weibo.com)
-- @version 20150126
--
module(..., package.seeall)
local name = ...

function new(self, core)
    core.debug:n('Init:' .. name)
    return setmetatable({core = core}, {__index = self})
end

function run(self)
    local smc = require('uve.sm.config')
    local modules = self.core.scheduler.modules
    local resource_type = ''
    if modules and #modules > 0 then
        for _, mo in ipairs(modules) do
            if mo.resource_type and #mo.resource_type > 0 then
                if mo.resource_type == 'ad' then
                    resource_type = 'ad'
                    self.core.render_data = mo.resp_data
                elseif mo.resource_type == 'bo' then
                    if resource_type ~= 'ad' then
                        resource_type = 'bo'
                        self.core.render_data = mo.resp_data
                    end
                elseif mo.resource_type == 'nr' then
                    if resource_type ~= 'ad' and resource_type ~= 'bo' then
                        resource_type = 'nr'
                        self.core.render_data = mo.resp_data
                    end
                else
                    self.core.debug:w(name .. '#wrong resource_type' .. mo.name .. '(' .. mo.id .. ')')
                    self.core.trace:append('prerender' .. '(' .. mo.id .. ')' .. '#wrong resource_type')
                end
                if resource_type and #resource_type > 0 then
                    mo.status = smc.STATUS_OK
                    self.core.resource_type = resource_type
                    self.core.debug:n(name .. ' final resource_type: ' .. self.core.resource_type)
                end            
            else
                self.core.debug:w(name .. '#no resource_type' .. mo.name .. '(' .. mo.id .. ')')
                self.core.trace:append('prerender' .. mo.id .. 'no resource_type')
            end
        end
    else
        self.core.debug:n(name .. '#No modules')
    end
end

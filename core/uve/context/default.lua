--
-- Default Context
--
-- @author Zhao Xinyu(xinyu16@staff.weibo.com)
-- @version 20151218
--
module(..., package.seeall)
local name = ...

function new(self, core)
    core.debug:n('Init: ' .. name)
    -- Inherit from super class
    local parent = require('uve.context')
    setmetatable(self, {__index = parent})
    return setmetatable({core = core, modules = {}}, {__index=self})
end

function run(self)
    self:init_whitelist_data()
    self:init_user_data()
end



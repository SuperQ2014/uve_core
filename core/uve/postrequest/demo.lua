module(..., package.seeall)
local name = ...

function new(self, core)
    core.debug:n('Init:' .. name)
    return setmetatable({core = core}, {__index=self})
end

function run(self)
    self.core.debug:n('run: ' .. name)
end


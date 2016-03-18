--
-- Strategy super
--
-- @author Tang Linhua(linhua@staff.weibo.com)
-- @version 20141111
--
module(..., package.seeall)

--
-- Static method
--
function init(core)
    core.debug:n('Loading global strategy...')
    local c = core.service_conf.strategy
    if c then
        local t = require(c)
        return t:new(core)
    end
    return nil
end

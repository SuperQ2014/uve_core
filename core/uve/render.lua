--
-- Render super
--
-- @author Tang Linhua(linhua@staff.weibo.com)
-- @version 20141111
--
module(..., package.seeall)

function run(core)
    core.debug:n('render...')
    local c = core.service_conf.render
    if c then
        local t = require(c)
        local _render = t:new(core)
        _render:render()
    else
        core.errno = 9903
    end
    return nil
end


--
-- Pre Render super
--
-- @author Tang Linhua(linhua@staff.weibo.com)
-- @version 20141111
--
module(..., package.seeall)

function run(core)
    core.debug:n('pre-render...')
    local c = core.service_conf.prerender
    if c then
        local t = require(c)
        local o = t:new(core)
        o:run()
    end
end


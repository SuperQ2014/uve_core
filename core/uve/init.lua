--
-- Initializer super 
--
-- @author Tang Linhua(linhua@staff.weibo.com)
-- @version 20141111
--
module(..., package.seeall)

function init(core)
    core.debug:n('Initializing application...')
    local c = core.service_conf.init
    if not c then
        c = 'uve.init.default'
    end
    local init_t = require(c)
    init_t.run(core)
end

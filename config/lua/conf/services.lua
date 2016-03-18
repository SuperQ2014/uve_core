--
-- Modules configration
--
-- @author Tang Linhua<linhua@staff.weibo.com>
-- @version 20141111
--
module(..., package.seeall)

demo = {
    modules = {
        [10] = 'uve.service_module.demo',
        [20] = 'uve.service_module.demo',
        [30] = 'uve.service_module.demo2',
    },
    init = 'uve.init.default',
    scheduler = 'uve.scheduler.default',
    strategy = 'uve.strategy.demo',
    prerender = 'uve.prerender.demo',
    render = 'uve.render.demo',
    postrender = 'uve.postrender.demo',
    postrequest = 'uve.postrequest.demo',
}



--
-- UVE Core
--
-- @author Tang Linhua<linhua@staff.weibo.com>
-- @version 20141110
--
module(..., package.seeall)

function new(self)
    local utils = require('lib.utils')
    return setmetatable({errno=0, err = '', start_time = utils.microtime(true), final_resp = {}}, {__index = self})
end

function run(self)
    local request_t = require('lib.request')
    local utils = require('lib.utils')
    local helper = require('uve.helper')
    local error_map_t = require('conf.error')
    local error_map = error_map_t.error_map
    local debug_t = require('lib.debug')
    local logger_t = require('lib.logger')
    local conf = require('conf.common')
    local cjson = require('cjson')

    local services = require('conf.services')
    local init = require('uve.init')
    local strategy = require('uve.strategy')
    local scheduler = require('uve.scheduler')
    local render = require('uve.render')
    local prerender = require('uve.prerender')
    local postrender = require('uve.postrender')
    local postrequest = require('uve.postrequest')
    local context = require('uve.context')

    self.request = request_t:new()
    self.debug = debug_t:new(self.request)
    self.trace = logger_t:new(conf.FEED_LOG_PATH_TRACE, '-trace.log')
    self.stats = logger_t:new(conf.FEED_LOG_PATH_STATS, '-stats.log', conf.LOG_FS)

    if not ngx.var.uve_service_name then
        ngx.log(ngx.ERR, 'uve_service_name not defined')
        self.errno = 9901
        goto uve_final 
    end

    self.service_name = ngx.var.uve_service_name
    self.uid = self.request:get('uid')
    self.from = self.request:get('from')

    self.service_conf = services[self.service_name]
    if not self.service_conf then
        self.errno = 9902
        self.err = self.service_name
        goto uve_final
    end

    -- Request ID
    self.req_id = helper.generate_request_id()
    self.stats:append('reqtime:' .. self.request.start_time_s)
    self.stats:append('reqid:' .. self.req_id)
    self.stats:append('service_name:' .. self.service_name)
    self.category_r = {}

    self.trace:append(string.format('%s|%s|%s|%s|%s', self.request.start_time_str, self.req_id, self.uid, self.from, self.service_name))

    -- Run level
    self.run_level = os.getenv('UVE_FEED_RUN_LEVEL_V7') or 0
    self.debug:n('UVE_ENV_DATACENTER: ' .. conf.UVE_ENV_DATACENTER)
    self.debug:n('UVE_V7 Run level: ' .. self.run_level)

    -- Initialize
    self.context = context.init(self)
    init.init(self)

    self.strategy = strategy.init(self)
    self.scheduler = scheduler.init(self)
    
    self.scheduler:run()

    prerender.run(self)
    render.run(self)
    postrender.run(self)

    if not self.final_resp or #self.final_resp < 1 then
        self.errno = 9001
    end

    -- Error section should NOT depends on instance objects, such as self.debug
    ::uve_final::
    if self.errno > 0 then
        local _error = ''
        if self.err and #self.err > 0 then
            _error = ':' .. self.err
        end
        self.err = error_map[self.errno] .. _error
    end

    local _resp = {errno = self.errno, ['error'] = self.err}
    if self.errno == 0 and #self.final_resp then
        if self.service_conf.resp_raw_data then
            _resp = self.final_resp[1]
        else
            _resp.data = self.final_resp
        end
    end
    local f, resp_str = pcall(cjson.encode, _resp)

    if not f then
        resp_str = '{"errno": 999, "error":"encode error"}'
    end

    -- Response
    self.resp_str = resp_str
    ngx.print(resp_str)

    if not self.debug.enabled then
        ngx.eof()
        if self.debug.log_enabled then
            self.debug:n(resp_str)
        end
    else
        ngx.print("\n")
    end

    if self.errno == 0 or self.errno == 9001 then

        self.trace:append(string.format('total:ms:%.3f', (utils.microtime(true) - self.start_time) * 1000))
        postrequest.run(self)

        -- Flush Log
        self.trace:flush()
        self.stats:flush()
    end

    self.debug:n('Total time(ms):' .. ((utils.microtime(true) - self.start_time) * 1000))
end


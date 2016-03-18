-- 
-- HTTP request wrapper
--
-- @author Tang Linhua<linhua@staff.sina.com.cn>
-- @version 20140305
-- 
module(..., package.seeall)

function check(args)
    local int_keys = {
        'uid',
        'from',
        'proxy_source',
        'list_id',
        'max_id',
        'last_span',
        'unread_status',
        'from_p',
        'trend_version',
    }
    for _,k in ipairs(int_keys) do
        if args[k] and not string.match(args[k], '^[-0-9]+$') then
            args[k] = ''
        end
    end

    if args['posid']  and not string.match(args['posid'], '^pos[0-9a-zA-Z]+$') then
        args['posid'] = ''
    end

    if args['wm']  and not string.match(args['wm'], '^[0-9_]+$') then
        args['wm'] = ''
    end

    if args['ip']  and not string.match(args['ip'], '^[0-9.]$') then
        args['ip'] = ''
    end

    if args['lang']  and not string.match(args['lang'], '^[a-zA-Z0-9_-]+$') then
        args['lang'] = ''
    end

    return args
end

function new(self)
    --local utils = require('lib.utils') 
    ngx.req.read_body()
    local _start_time = ngx.req.start_time()
    return setmetatable({
        get_args = ngx.req.get_uri_args(),
        post_args = ngx.req.get_post_args(),
        start_time = _start_time,
        start_time_s = math.floor(_start_time),
        start_time_str = os.date('%Y-%m-%d %H:%M:%S', _start_time),
        customized_args = {},
        global_args = {},
    }, {
        __index = self,
        __tostring = function (t)
            local _tmp = {}
            for k,v in pairs(t.customized_args) do
                _tmp[k] = v
                --_tmp[k] = utils.trim(v)
            end
            for k,v in pairs(t.post_args) do
                if not _tmp[k] then
                    _tmp[k] = v
                    --_tmp[k] = utils.trim(v)
                end
            end

            for k,v in pairs(t.get_args) do
                if not _tmp[k] then
                    _tmp[k] = v
                    --_tmp[k] = utils.trim(v)
                end
            end
            return ngx.encode_args(_tmp) 
        end
    })
end

function get(self, key, default)
    --local utils = require('lib.utils')
    local v = self.post_args[key] or self.get_args[key] or self.customized_args[key] or nil
    if not v and default then
        return default
    end

    if type(v) == 'table' and #v > 0 then
        v = v[1]
    end
    --v = utils.trim(v)

    return v
end

function get_get(self, key)
    return self.get_args[key] or nil
end

function get_post(self, key)
    return self.post_args[key] or nil
end


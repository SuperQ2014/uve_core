module(..., package.seeall)

function sort_response_data(data, data_type)
    local sm_config = require('uve.sm.config')
    if data and #data > 1  then
        local _tmp = {}
        local _tkeys = {}
        local _suffix = 0 --UVEx#f4ZEOve6, fix http://issue.internal.sina.com.cn/browse/WEIBOCURLBUG-4571
        for _,_i in ipairs(data) do
            local _p = 0
            if data_type == sm_config.SM_DTYPE_TREND then
                _p = tonumber(_i['position'])
            else
                local ci = 2
                local c = _i['mark']:byte(ci)
                while c >= 48 and c <= 57 do
                    ci = ci + 1
                    c = _i['mark']:byte(ci)
                end
                _p = tonumber(_i['mark']:sub(1, ci-1))
            end
            _p = 100 * _p + _suffix
            _suffix = _suffix + 1
            _tkeys[#_tkeys + 1] = _p
            _tmp['' .. _p] = _i
        end
        table.sort(_tkeys)
        local _tmp2 = {}
        for _,_k in ipairs(_tkeys) do
            _tmp2[#_tmp2 + 1] = _tmp['' .. _k]
        end
        return _tmp2
    end
    return data
end

function generate_request_id(uid)
    uid = uid or ''
    local utils = require('lib.utils')
    return tostring(math.floor(utils.microtime(true) * 1000)) .. uid .. math.random(100,999)
end

local main_feed_qps = -2
local main_feed_qps_count = 0
function get_main_feed_qps()
    if main_feed_qps == -2 or main_feed_qps_count > 30000 then
        main_feed_qps_count = 0
        local conf = require('conf.common')
        local redis_t = require('lib.redis')
        local redis = redis_t.conn(conf.REDIS_HOST_LOCAL, conf.REDIS_PORT_LOCAL)
        local qps, err = redis:get('uve_main_feed_qps')
        redis_t.close(redis)
        main_feed_qps = tonumber(qps) or -1
    else
        main_feed_qps_count = main_feed_qps_count + 1
    end
    return main_feed_qps
end

function anti_congestion(threshold)
    threshold = tonumber(threshold) or -1
    local qps = get_main_feed_qps()  
    if threshold > 0 and qps > threshold then
        local tp = (qps - threshold) * 1000 / qps
        local rand = math.random(1, 1000)
        if rand <= tp then
            return true
        end
    end
    return false
end

--
-- @see http://uve.intra.mobile.sina.cn/uvewiki/index.php?title=UVE整体架构设计#.E5.85.83.E4.BF.A1.E6.81.AF
-- @param table temeta
-- @return string
function tmeta_logs_to_string(logs)
    local str = ''
    str = _tmeta_logs_to_string({logs}, 1)
    return str
end

function _tmeta_logs_to_string(logs, level)
    local cjson = require('cjson')
    local result = {}
    local s1 = ''
    local s2 = ''

    if level == 1 then
        s1 = string.char(0x1A)
        --s2 = string.char(0x01)
        s2 = string.char(0x1C)
    elseif level == 2 then
        --s1 = string.char(0x1C)
        s1 = string.char(0x01)
        s2 = string.char(0x1D)
    elseif level == 3 then
        s1 = string.char(0x1E)
        s2 = string.char(0x1F)
    else
        return ''
    end

    local tmp1 = {}
    if logs and logs ~= cjson.null then
        for _, v1 in ipairs(logs) do
            if v1 and v1 ~= cjson.null then
                local tmp2 = {}
                for k,v in pairs(v1) do
                    if k == 'tmeta_l2' or k == 'tmeta_l3' then
                        v = _tmeta_logs_to_string(v, level + 1)
                    end
                    local str = k .. ':' .. tostring(v)
                    table.insert(tmp2, str)
                end
                tmp2 = table.concat(tmp2, s2)
                table.insert(tmp1, tmp2)
            end
        end
    end
    result = table.concat(tmp1, s1)

    return result
end

--
-- Transform old-version temta log to new version
--
-- @see http://uve.intra.mobile.sina.cn/uvewiki/index.php?title=New-tmeta-logs-demo
-- @see http://uve.intra.mobile.sina.cn/uvewiki/index.php?title=Old-tmeta-logs-demo
--
-- @param table logs
--
function transform_tmeta_logs(old_logs)
    local logs = {}
    for k,v in pairs(old_logs) do
        if type(v) == 'table' then
            local l2 = {}
            local _k2c = 0
            for k2, v2 in pairs(v) do
                if type(v2) == 'table' then
                    local l3 = {}
                    local _k3c = 0
                    for k3, v3 in pairs(v2) do
                        _k3c = _k3c + 1
                        if type(v3) ~= 'string' then
                            v3 = tostring(v3)
                        end
                        l3[k3] = v3
                    end
                    if _k3c > 0 then
                        if not l2['tmeta_l3'] then
                            l2['tmeta_l3'] = {}
                        end
                        table.insert(l2['tmeta_l3'], l3)
                        _k2c = _k2c + 1
                    end
                else
                    _k2c = _k2c + 1
                    if type(v2) ~= 'string' then
                        v2 = tostring(v2)
                    end
                    l2[k2] = v2
                end
            end
            if _k2c > 0 then
                if not logs['tmeta_l2'] then
                    logs['tmeta_l2'] = {}
                end
                table.insert(logs['tmeta_l2'], l2)
            end
        else
            if type(v) ~= 'string' then
                v = tostring(v)
            end
            logs[k] = v
        end
    end
    return logs
end

function get_device_info(core, ua)
    local model = ''
    local os = ''
    local osv = ''
    local key

    local pos = string.find(ua, '__weibo__')
    if pos then
        model = string.sub(ua, 1, pos-1)
    end

    local platform = core.request:get('platform', '')
    if platform == 'iphone' then
        key = '__iphone__os'
        os = 'iOS'
    elseif platform == 'android' then
        key = '__android__android'
        os = 'android'
    elseif platform == 'ipad' then
        key = '__ipad__os'
        os = 'iOS'
    else
        return model, os, osv
    end

    local _, position = string.find(ua, key)
    if position then
        osv = string.sub(ua, position+1)
    end

    return model, os, osv
end

function get_uve_timestamp()
    local utils = require('lib.utils')

    local time = utils.microtime(false)
    local sec = tostring(time[1])
    local usec = tostring(time[2])
    usec = string.format('%06d', usec)

    local uve_timestamp = sec .. usec
    return uve_timestamp
end



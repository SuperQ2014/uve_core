--
-- Post Request
--
-- @author Tang Linhua(linhua@staff.weibo.com)
-- @version 20141111
--
module(..., package.seeall)

function run(core)
    core.debug:n('Post-Request...')
    if core.service_conf then
        local c = core.service_conf.postrequest
        if c then
            local t = require(c)
            local o = t:new(core)
            o:run()
        end
    end

    if core.scheduler then
        local modules = core.scheduler.modules
        if modules and #modules > 0 then
            for _, mo in ipairs(modules) do
                mo:finish()
            end
        end
    end

    local category_r = ''
    if core.category_r and #core.category_r > 0 then
        for _, category in ipairs(core.category_r) do
            if category_r and #category_r > 0 then
                category_r = category_r .. '|' .. category
            else
                category_r = category
            end
        end
    else 
        core.debug:n('no category_r')
    end
    core.debug:n('category_r:' .. category_r)
    core.stats:append('category_r:' .. category_r)

    if core.hard_info and core.hard_info.connectd == true then
        if core.hard_info.imei then
            core.stats:append('imei:' .. core.hard_info.imei)
        end
        if core.hard_info.idfa then
            core.stats:append('idfa:' .. core.hard_info.idfa)
        end
        if core.hard_info.data and core.hard_info.data.location then
            core.stats:append('location:' .. core.hard_info.data.location)
        end
    end

    if core.tmeta and core.tmeta.logs then
        core.tmeta.logs.reqtime = nil
        core.tmeta.logs.uid = nil
        core.tmeta.logs.reqid = nil
        core.tmeta.logs.from = nil
        core.tmeta.logs.version = nil
        core.tmeta.logs.platform = nil
        core.tmeta.logs.service_name = nil

        local helper = require('uve.helper')
        local tmeta_str = helper.tmeta_logs_to_string(core.tmeta.logs)
        if tmeta_str then
            core.debug:n('temeta added')
            --core.stats:append_line(tmeta_str)
            core.stats:append(tmeta_str)
        else
            core.debug:w('failed to construct temeta string')
        end
    else
        core.debug:w('No temeta detected')
    end
end


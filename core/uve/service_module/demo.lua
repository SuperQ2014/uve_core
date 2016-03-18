--
-- Demo module
--
-- @author Tang Linhua<linhua@staff.weibo.com>
-- @version 20141111
--
module(..., package.seeall)
local name = ...

function new(self, smid, core)
    local smc = require('uve.service_module.config')
    local parent = require('uve.module')
    setmetatable(self, {__index=parent})
    local m = {id = smid, name = name, core = core, status = smc.STATUS_NOT_INIT}
    -- m.data -- Raw data, will be set in run()
    -- m.rendered_data -- Rendered data, will be set by render object
    return setmetatable(m, {__index=self})
end

-- @return boolean, reason
function ctrl(self)
    return false, ''
end

--@override
function run(self, resp)
    self.core.debug:n(self.name .. '#overrided method')
    local parent = require('uve.module')
    parent.run(self, resp)
end

--
-- set valid data to attribute self.data, used for rendering
--
function run1(self, resp)
    self.core.debug:n(name .. '(' .. self.id .. ')#HTTP status: ' .. resp.status .. ', body = ' .. resp.body)
    local conf = require('conf.common')
    if resp.status == 200 then
        local cjson = require('cjson')
        local f, data = pcall(cjson.decode, resp.body)
        if f then
            if data.data then
                if data['__tmeta'] then
                    self.core.debug:n(name .. '#extract tmeta')
                    self.tmeta = data['__tmeta']
                else
                    self.core.debug:n(name .. '#NO tmeta')
                end
                self.data = data.data
            end
        else
            self.core.trace:append(name .. ':cjson:decode_error')
        end
    else
        self.core.trace:append(name .. ':http_error:' .. resp.status)
    end
end

-- @return ngx.HTTP_{POST|GET}, url, body
function get_req_params(self)
    local args = {}
    args[#args+1] = tostring(self.core.request)
    args[#args+1] = 'uve_module_name=' .. name
    args[#args+1] = 'uve_module_id=' .. self.id
    args[#args+1] = 'uve_service_name=' .. self.core.service_name

    self.http_method = ngx.HTTP_POST
    self.http_uri = '/demo/demo.php?service_module=' .. name
    self.http_body = table.concat(args, '&')
    return self.http_method, self.http_uri, self.http_body
end


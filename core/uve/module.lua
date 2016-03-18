--
--Abstract service module
--
--@author Tang Linhua<linhua@staff.weibo.com
--@version 20141114
--
module(..., package.seeall)

--
--Create new instance of service module
--
--@param int smid, service module ID
--@param uve_core core
--
--function new(self, smid, core);

--
--@return boolean,reason
--
--functoin ctrl(self);

--
--The data will be used by scheduler to request backend service
--
--@return ngx.HTTP_{POST|GET}, url, body
--
--function get_req_params(self);

--
--Called by scheduler
--
--@param table resp, response object
--
function run(self, resp)
    local _prefix = self.name .. '(' .. self.id .. ')'
    if self.category and #self.category > 0 then
        table.insert(self.core.category_r, self.category)
    else
        self.core.debug:w(_prefix .. '#no category')
    end

    self.core.debug:n(_prefix .. '#HTTP status: ' .. resp.status .. ', body = ' .. resp.body)
    local conf = require('conf.common')
    if resp.status == 200 then
        local cjson = require('cjson')
        local f, data = pcall(cjson.decode, resp.body)
        if f then
            if data.data then
                if data['__tmeta'] then
                    self.core.debug:n(_prefix .. '#extract tmeta')
                    self.tmeta = data['__tmeta']
                else
                    self.core.debug:n(_prefix .. '#NO tmeta')
                end
                self.data = data.data
            end
        else
            self.core.trace:append(_prefix .. ':cjson:decode_error')
        end
    else
        self.core.trace:append(_prefix .. ':http_error:' .. resp.status)
    end
end

--
--Called after request
--
function finish(self)
    local smc = require('uve.service_module.config')
    local _prefix = self.name .. '(' .. self.id .. ')'
    if smc.STATUS_OK == self.status then
        self.core.debug:n(_prefix .. ': OK')
        self:save_stats_log()
    else
        self.core.debug:n(_prefix .. ': Failed')
    end
end

--
--Called by scheduler
--
--@param table resp, response object
--
--function run(self, resp)
--    self:_run(resp)
--end

function save_stats_log(self)
    local conf = require('conf.common')
    if self.tmeta and self.tmeta.logs and type(self.tmeta.logs) == 'table' then
        local L1 = {}
        for k1,v1 in pairs(self.tmeta.logs) do
            if type(v1) == 'table' then
                local L2 = {}
                for k2,v2 in pairs(v1) do
                    if type(v2) == 'table' then
                        local L3 = {}
                        for k3,v3 in pairs(v2) do
                            table.insert(L3, k3 .. ':' .. tostring(v3))
                        end
                        if #L3 > 0 then
                            table.insert(L2, table.concat(L3, conf.LOG_RS))
                        end
                    else
                        table.insert(L2, k2 .. ':' .. tostring(v2))
                    end
                end
                if #L2 > 0 then
                    table.insert(L1, table.concat(L2, conf.LOG_GS))
                end
            else
                table.insert(L1, k1 .. ':' .. tostring(v1))
            end
        end
        if #L1 > 0 then
            local log = table.concat(L1, conf.LOG_FS)
            if #log > 0 then
                self.core.stats:append(log)
                self.core.debug:n(self.name .. '(' .. self.id .. ')#stats log saved')
            end
        end
    end
end

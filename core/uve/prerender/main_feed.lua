
--
-- Prerender main_fedd
--
-- @author Li Delong(delong1@staff.weibo.com)
-- @version 20151118
--
module(..., package.seeall)
local name = ...

function new(self, core)
    core.debug:n('Init:' .. name)
    return setmetatable({core = core}, {__index = self})
end

function run(self)
    local helper = require('uve.helper')
    local smc = require('uve.sm.config')
    local modules = self.core.scheduler.modules
    if modules and #modules > 0 then
        for _, mo in ipairs(modules) do
            if mo.id == smc.SMID_IDX then       --fill up relationship flow
                if mo.data and mo.data['data'] then
                    for _, item in ipairs(mo.data['data']) do
                        --addfans
                        local actiontype = self.core.request:get('actiontype')
                        if not actiontype or actiontype == 'slide' then
                            if item.business_type == '011010' and item.ext.addfans_style == 'horizontal' then
                                self.core.debug:n(name .. '#IDX addfans fillup')
                                local resp = helper.idx_addfans_fillup(self.core, item)
                                if resp then
                                    item = resp
                                end
                            end
                        end

                        --apollo
                        if item.business_type == '01120' then
                            if item.result and #item.result > 0 then
                                helper.app2_idx_fillup(self.core, item.result)
                            end
                        end
                    end
                end
            end
        end
    end
end

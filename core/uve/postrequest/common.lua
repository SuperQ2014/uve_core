module(..., package.seeall)
local name = ...

function new(self, core)
    core.debug:n('Init:' .. name)
    return setmetatable({core = core}, {__index=self})
end

function run(self)
    self.core.debug:n('run: ' .. name)
    local count = 0
    if self.core.final_resp then
        count = #self.core.final_resp
    end
    self.core.stats:append('feedsnum:' .. count)

    local helper = require('uve.helper')
    local modules = self.core.scheduler.modules
    if modules and #modules > 0 then
        self.core.tmeta = {}
        for _, mo in ipairs(modules) do
            if not mo.tmeta then
                mo.tmeta = {}
            end
            --if mo.tmeta.logs then
            --    mo.tmeta.logs = helper.transform_tmeta_logs(mo.tmeta.logs)
            --end
            for k, v in pairs(mo.tmeta) do
                if k == 'logs' then
                    if not self.core.tmeta.logs then
                        self.core.tmeta.logs = v
                    else
                        for log_k, log in pairs(v) do
                            if log_k == 'tmeta_l2' then
                                for _, l2 in ipairs(log) do
                                    table.insert(self.core.tmeta.logs.tmeta_l2, l2)
                                end
                            else
                                self.core.tmeta.logs[log_k] = log
                            end
                        end
                    end
                else
                    self.core.tmeta[k] = v
                end
            end
        end
    end
    --self.core.trace:append('final:resp:' .. self.core.resp_str)
end


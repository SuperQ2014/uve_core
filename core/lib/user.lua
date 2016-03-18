module(..., package.seeall)

function new(self, uid)
    local conf = require('conf.common')
    local _u = {uid = uid}
    _u.init_status = -1 -- 0: OK, -1: failed
    -- XXX User initialization goes here
    setmetatable(_u, {__index = self})
    return _u
end

function get_register_ts(self)
    local ts = -1
    if self._init_status == 0 and self.register_date and self.register_date ~= '' then
        local p = '(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)'
        local year,month,day,hour,min,sec = self.register_date:match(p)
        local tz="CST"
        ts = os.time({tz=tz,day=day,month=month,year=year,hour=hour,min=min,sec=sec})
    else
        if not self.user_details then
            self:get_details()
        end
        local ct = self.user_details.created_at
        if ct then
            local MON={Jan=1,Feb=2,Mar=3,Apr=4,May=5,Jun=6,Jul=7,Aug=8,Sep=9,Oct=10,Nov=11,Dec=12}
            local p="%a+ (%a+) (%d+) (%d+):(%d+):(%d+) %+0800 (%d+)"
            local month,day,hour,min,sec,year = ct:match(p)
            month=MON[month]
            local tz="CST"
            ts = os.time({tz=tz,day=day,month=month,year=year,hour=hour,min=min,sec=sec})
        end
    end
    return ts
end


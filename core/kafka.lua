-- 
-- @author YangYang<yangyang21@staff.weibo.com>
--
local logkafka = require "liblogk"

local x = logkafka.create_kafka("10.77.96.122:33334")

local _M = {
    _VERSION = '1.0'
} 

local mt = { 
    __index = _M,
    kafka = x,
    t1 =  logkafka.create_topic("dj95", x),
    t2 =  logkafka.create_topic("dj96", x), 
    t3 =  logkafka.create_topic("dj97", x), 
    t4 =  logkafka.create_topic("dj98", x), 
}

function _M.log(topic, content)
    if mt[topic] ~= nil then
        logkafka.klog(mt[topic], x, -1, content)
    else
        mt[topic] = logkafka.create_topic(topic ,x)
        logkafka.klog(mt[topic], x, -1, content)
    end
end

return _M

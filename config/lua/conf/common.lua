-- 
-- Global Configuration
-- @author Tang Linhua<linhua@staff.sina.com.cn>
-- @version 20140305
-- 
module(..., package.seeall)

UVE_ENV_IS_DEV = os.getenv('UVE_ENV_IS_DEV')
UVE_ENV_DATACENTER = os.getenv('UVE_ENV_DATACENTER')

if UVE_ENV_IS_DEV and UVE_ENV_IS_DEV == '1' then
    UVE_ENV_IS_DEV = true
else
    UVE_ENV_IS_DEV = false
end

-- 统计日志一级分隔符(v7)
LOG_FS = string.char(0x1C)

-- 统计日志二级分隔符(v7)
LOG_GS = string.char(0x1D)

-- 统计日志三级分隔符(v7)
LOG_RS = string.char(0x1E)

--统计日志多值分隔符(v7)
LOG_VS = ','

-- 本地MC
MC_HOST_LOCAL = '127.0.0.1'
MC_PORT_LOCAL= 11512

REDIS_HOST_LOCAL = '127.0.0.1'
REDIS_PORT_LOCAL = 6379

-- 广告控制数据MC
MC_HOST_AD_CONTROL = '172.16.38.82'
MC_HOST_AD_CONTROL2 = '172.16.38.81'
--MC_HOST_AD_CONTROL2 = '172.16.193.178' --XXX for testing only
MC_PORT_AD_CONTROL = 11210

-- 用于共享其它接口数据
-- 如：趋势lbs数据
-- Host @see uid_ip_feed_new($uid)
MC_PORT_DATA_SHARED = 11514

-- 与用户相关的广告控制数据
-- Host @see uid_ip_feed_new2($uid)
MC_PORT_USER_AD_CTRL = 11516

-- 用户登录频次，及学校信息
-- Host @see uid_ip($uid)
MC_PORT_USER_FREQ = 12517

-- 用户广告分组数据
MC_PORT_USER_AD_GROUP = 12610

-- 用户基本信息
MC_PORT_USER_INFO = 12611

-- 弹窗广告激活趋势MC Port
MC_PORT_WIN_APP = 11811

-- 北显共享数据，如：imei, networktype等
-- Host @see uid_ip_wbapp()
MC_PORT_DATA_SHARED_BX = 11520

--
-- 阀值以内流量只请求自然推荐
-- 
RETURN_USER_CTRL_THRESHOLD = 1000000
--RETURN_USER_CTRL_THRESHOLD = 10

--
-- 单位小时, 7天认为是回流用户
--
CONSIDERED_AS_RETURN_USER = 168

--
-- Profile控制数据端口
--
REDIS_PORT_PROFILE_CTRL = 8701

-- 
-- XXX: make sure the following directories have been created
--
UVE_LOG_PREFIX='/data0/nginx/logs'

if UVE_ENV_IS_DEV then
    UVE_LOG_PREFIX = 'logs'
end

FEED_LOG_PATH_STATS = UVE_LOG_PREFIX .. '/uve_core/stats'
FEED_LOG_PATH_TRACE = UVE_LOG_PREFIX .. '/uve_core/trace'

UPSTREAM = require('conf.upstream_' .. UVE_ENV_DATACENTER)

function uid_ip(uid)
    local mc_ips = UPSTREAM.uid_ips
    local idx = tonumber(uid) % #mc_ips + 1
    return mc_ips[idx]
end


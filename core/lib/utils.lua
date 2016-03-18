-- 
-- Common Utilities
--
-- @author Tang Linhua<linhua@staff.sina.com.cn>
-- @version 20140305
-- 
module(..., package.seeall)

local ffi = require("ffi")
ffi.cdef[[
    typedef unsigned int mode_t;
    typedef long int time_t;
    typedef long int ssize_t;
    struct timeval {
        long int tv_sec;     /* seconds */
        long int tv_usec;    /* microseconds */
    };
    struct tm {
        int tm_sec;         /* seconds */
        int tm_min;         /* minutes */
        int tm_hour;        /* hours */
        int tm_mday;        /* day of the month */
        int tm_mon;         /* month */
        int tm_year;        /* year */
        int tm_wday;        /* day of the week */
        int tm_yday;        /* day in the year */
        int tm_isdst;       /* daylight saving time */
    };

    int gettimeofday(struct timeval *tv, void *tz);
    struct tm *localtime(const time_t *timep);
    time_t time(time_t *t);

    /*int stat(const char *path, struct stat *buf);*/
    int mkdir(const char *pathname, mode_t mode);
    int access(const char *pathname, int mode);
    int creat(const char *pathname, mode_t mode);
    int open(const char *pathname, int flags, mode_t mode);
    ssize_t read(int fd, void *buf, size_t count);
    ssize_t write(int fd, const void *buf, size_t count);
    int close(int fd);

    long int mrand48(void);
    double drand48(void);

    char *getenv(const char *name);
]]


--
-- @param boolean as_float
-- @return float|table, float if as_float=ture, table(sec, usec) otherwise
--
function microtime(as_float)
    local tm = ffi.new("struct timeval");
    ffi.C.gettimeofday(tm, nil)
    local sec =  tonumber(tm.tv_sec)
    local usec =  tonumber(tm.tv_usec)
    if as_float then
        return sec + usec * 10^-6
    else
        return {sec, usec}
    end
end

function time()
    local t = ffi.new("time_t[1]")
    ffi.C.time(t)
    return tonumber(t[0])
end

function localtime(ts)
    local t
    if ts then
        t = ffi.new("time_t[1]", ts)
    else
        t = ffi.new("time_t[1]")
        ffi.C.time(t)
    end
    local tm = ffi.new("struct tm")
    tm = ffi.C.localtime(t)
    tm.tm_year = 1900 + tm.tm_year
    tm.tm_mon = tm.tm_mon + 1
    return tm
end

--
-- Timestamp of day
-- @param int ts, unix timestamp
-- @return int
--
function daytime(ts)
    if not ts then
        ts = time()
    end
    local d = os.date("*t", ts)
    d.hour = 0
    d.min = 0
    d.sec = 0
    local ds = os.time(d)
    local dayts = ts - ds
    return dayts
end

function random(min, max)
    local v = ffi.new('long int')
    v = ffi.C.mrand48()
    if v < 0 then
        v = -v
    end
    if min and max then
        local d = max - min + 1
        local r = v % d + min
        return tonumber(r)
    end
    return tonumber(v)
end

-- 
-- NOTE: Use os.getenv(name) instead
--
-- Get System Environment
-- e.g. SAD_ENV_LOCAL_IP
-- 
-- @param string name
-- @return string
--
function getenv(name)
    local v = ffi.C.getenv(name)
    local _v = tostring(v)

    if string.sub(_v, -4) ~= 'NULL' then
        local lv = ffi.string(v)
        if #lv > 0 then
            return lv
        end
    end
    return nil
end

function _pack(len)
        tmp = len
        bitt = {}
        for i=1,4 do
                quotient = math.floor(tmp/256)
                remainder = tmp - quotient*256
                tmp = quotient
                bitt[i] = remainder
        end
	return string.char(bitt[1],bitt[2],bitt[3],bitt[4],1,0,0,0,0,0,0,0,0,0,0,0)
end

function _unpack(line)
	local r1=string.byte(line,1)
	local r2=string.byte(line,2)
	local r3=string.byte(line,3)
	local r4=string.byte(line,4)
	local rev_len=r4*256*256*256 + r3*256*256 + r2*256 + r1
	return rev_len
end

-- 
-- @return result, errno, err, tc(ms)
--
function woo_request(ip, port, query, timeout)
    local _tc_start = microtime(true)
    timeout = timeout or 10 -- default 10ms
    local sock = ngx.socket.tcp()
    sock:settimeout(timeout)

    local ipport = 'sock#' .. ip .. ':' .. port
    local ok, err = sock:connect(ip, port)
    if not ok then
        return nil, 263, ipport .. ' connect error#' .. err, -1
    end

    l = string.len(query)
    s = _pack(l)

    local bytes, err = sock:send(s .. query)
    if not bytes then
        return nil, 273, ipport .. ' send error#' .. err, -1
    end

    local line, err = sock:receive(4)                                         
    if not line then
        return nil, 279, ipport .. ' receive(4) error#' .. err, -1
    end

    local rev_len = _unpack(line) 
    local line, err = sock:receive(12)                                             
    if not line then
        return nil, 286, ipport .. ' receive(12) error#' .. err, -1
    end

    local result, err = sock:receive(rev_len)                                                         
    if not result then
        return nil, 292, ipport .. ' receive(rev_len) error#' .. err, -1
    end

    local ok, err = sock:setkeepalive(10000, 100) --(max_idle_time-1s,max_connection_num)
    if not line then
        return nil, 292, ipport .. ' receive(rev_len) error#' .. err, -1
    end

    local tc = (microtime(true) - _tc_start) * 1000

    return result, 0, '', tc
end

local function _gzreader(s)
	local done
	return function()
		if done then return end
		done = true
		return s
	end
end

local function _gzwriter()
	local t = {}
	return function(data, sz)
		if not data then return table.concat(t) end
		t[#t+1] = ffi.string(data, sz)
	end
end

function gzuncompress(raw, format)
    format = format or 'zlib'
	local write = _gzwriter()
    local zlib = require('lib.zlib')
	zlib.inflate(_gzreader(raw), write, nil, format)
	local udata = write()
    if #udata > 0 then
        return udata
    end
    return nil
end

function mkdir(path)
    local r = ffi.C.mkdir(path, 0x1ED) -- 0755
    local errno = ffi.errno()
    if 0 == r or 17 == errno then -- EEXIST = 17
        return 0
    end
    return errno
end

function split(str, delim, maxNb)
    
    if string.find(str, delim) == nil then
        return { str }
    end
    if maxNb == nil or maxNb < 1 then
        maxNb = 0    -- No limit
    end
    local result = {}
    local pat = "(.-)" .. delim .. "()"
    local nb = 0
    local lastPos
    for part, pos in string.gfind(str, pat) do
        nb = nb + 1
        result[nb] = part
        lastPos = pos
        if nb == maxNb then break end
    end
   
    if nb ~= maxNb then
        result[nb + 1] = string.sub(str, lastPos)
    end
    return result
end

function file_put_contents(filename, content)
    --local fd = ffi.C.open(filename, bit.bor(0x1, 0x40, 0x400, 0x2000), 0x1A4)
    local fd = ffi.C.open(filename, bit.bor(0x1, 0x40, 0x2000), 0x1A4)
    if -1 == fd then
        return -1
    end
    local b = ffi.C.write(fd, content, #content)
    ffi.C.close(fd)
    return tonumber(b)
end

function trim(s)
    if s and type(s) == 'string' then
        s = (string.gsub(s, "^%s*(.-)%s*$", "%1"))
    end 
    return s
end

function decode_into_number(str, default)
    local num = ''
    if default then
        num = default
    end

    if str and #str > 0 then
        local decode_str = ngx.decode_base64(str)
        if decode_str and #decode_str > 0 and string.match(decode_str, '^[0-9]+$')then
            num = decode_str
        end
    end

    return num
end

function dump_table(t, l)
    l = tonumber(l) or 0
    local prefix = ''
    if l > 0 then
        local pt = {}
        for i = 1, l do
            table.insert(pt, '    ')
        end
        prefix = table.concat(pt)
    end
    if type(t) ~= 'table' then
        ngx.say(tostring(t))
        return
    end
    ngx.say('{')
    for k,v in pairs(t) do
        ngx.print(prefix, k, ':')
        if l < 10 then
            dump_table(v, l + 1)
        else
            ngx.say(tostring(v))
        end
    end
    ngx.say(prefix, '}')
end


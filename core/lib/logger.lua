-- 
-- Logger
--
-- @author Tang Linhua<linhua@staff.sina.com.cn>
-- @version 20140305
-- 
module(..., package.seeall)

function new(self, path, suffix, separator, append_hour, sub_files)
    if not separator then
        separator =  '|'
    end
    if not append_hour then
        append_hour = true
    end
    sub_files = tonumber(sub_files)
    if not sub_files then
        sub_files = 10
    end
    return setmetatable({
        path = path,
        suffix = suffix,
        separator = separator,
        append_hour = append_hour,
        sub_files = sub_files,
        fields = {},
        lines = {},
    }, {__index = self})
end

function append(self, field)
    self.fields[#self.fields+1] = field
end

function newline(self)
    if #self.fields > 0 then
        self.lines[#self.lines+1] = table.concat(self.fields, self.separator)
        self.fields = {}
    end
end

function append_line(self, line)
    self.lines[#self.lines+1] = line
end

function flush(self)
    self:newline()
    if #self.lines > 0 then
        --local adlog = require('adlog')
        local str = table.concat(self.lines, "\n") .. "\n"
        --adlog.write_log(str, self.path, self.suffix, self.append_hour)
        --self:_save_log(str)
        self:_save_log2(str)
    end
end

function _save_log(self, str)
    local adlog = require('adlog')
    adlog.write_log(str, self.path, self.suffix, self.append_hour)
end

function _save_log2(self, str)
    local utils = require("lib.utils")
    local ffi = require("ffi")
    --local mtrandom = require("random")

    local root_path = self.path

    local r = utils.mkdir(root_path)
    if 0 ~= r then
        ngx.log(ngx.ERR, 'failed to mkdir(' .. root_path .. ')');
        return false
    end

    local last_c = string.sub(self.path, -1)
    if last_c ~= '/' then
        root_path = self.path .. '/'
    end
    local tm = utils.localtime()
    local date_path = string.format(root_path .. '%d-%02d-%02d', tm.tm_year, tm.tm_mon, tm.tm_mday)

    local r = utils.mkdir(date_path)
    if 0 ~= r then
        ngx.log(ngx.ERR, 'failed to mkdir(' .. date_path .. ')');
        return false
    end

    local hour_path
    if self.append_hour then
        hour_path = string.format(date_path .. '/%02d', tm.tm_hour)
        local r = utils.mkdir(hour_path)
        if 0 ~= r then
            ngx.log(ngx.ERR, 'failed to mkdir(' .. hour_path .. ')');
            return false
        end
    else
        hour_path = date_path
    end

    -- local mt = mtrandom.new(utils.random())
    -- local rand = math.ceil(mt()*100)
    local rand = math.random(0, self.sub_files - 1)

    local file_path = string.format(hour_path .. '/%d' .. self.suffix, rand)
    -- O_WRONLY|O_CREAT|O_APPEND|O_ASYNC, 0644
    local fd = ffi.C.open(file_path, bit.bor(0x1, 0x40, 0x400, 0x2000), 0x1A4)
    -- O_WRONLY|O_CREAT|O_APPEND|O_SYNC, 0644
    -- local fd = ffi.C.open(file_path, bit.bor(0x1, 0x40, 0x400, 0x1000), 0x1A4)
    if -1 == fd then
        local errno = ffi.errno()
        ngx.log(ngx.ERR, 'failed to open(' .. file_path .. '),errno=' .. errno)
    else
        local r = ffi.C.write(fd, str, #str)
        if -1 == r then
            local errno = ffi.errno()
            ngx.log(ngx.ERR, 'failed to write(' .. file_path .. '),errno=' .. errno)
            return false
        end
        ffi.C.close(fd)
    end
    return true
end


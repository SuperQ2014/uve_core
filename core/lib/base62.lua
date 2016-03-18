--
-- weibo_base62 decode
--
-- @author Li Delong<delong1@staff.sina.com.cn>
-- @version 20150420
--
module(..., package.seeall)

local base = 62
local base62_code = {
    '0','1','2','3','4','5','6','7','8','9',
    'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z',
    'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z',
}

function table_index(table, char)
    for index, value in ipairs(table) do
        if value == char then
            return index
        end
    end
    return nil
end

function base62_convert(str)
    local num = 0
    local len = string.len(str)
    for i = len, 1, -1 do
        local c = string.sub(str, i, i)
        local d = table_index(base62_code, c) 
        local n = (d - 1) * math.pow(base, len - i)
        num = num + n
    end
    return num
end

function decode(murl)
    local mid = ''
    local sub_murl = ''
    local decode_mid = ''
    local len = string.len(murl)

    for i = len, 1, -4 do
        if i - 3 > 1 then
            sub_murl = string.sub(murl, i-3, i)
            decode_mid = base62_convert(sub_murl)
            decode_mid = string.format('%07d', decode_mid)
            mid = decode_mid .. mid
        else
            sub_murl = string.sub(murl, 1, i)
            mid = base62_convert(sub_murl) .. mid
        end
    end
    return mid
end

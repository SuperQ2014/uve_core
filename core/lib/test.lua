local zlib = require('zlib')
local ffi = require('ffi')

local function gen(n)
	local t = {}
	for i=1,n do
		t[i] = string.format('dude %x\r\n', i)
	end
	return table.concat(t)
end

local function reader(s)
	local done
	return function()
		if done then return end
		done = true
		return s
	end
end

local function writer()
	local t = {}
	return function(data, sz)
		if not data then return table.concat(t) end
		t[#t+1] = ffi.string(data, sz)
	end
end

local function test(format)
	--local src = gen(100000)
    local src = 'hello, world!123333333333333333333333333333334123412341322222222224'
	local write = writer()
	zlib.deflate(reader(src), write, nil, format)
	local dst = write()
	local write = writer()
	zlib.inflate(reader(dst), write, nil, format)
	local src2 = write()
	assert(src == src2)
	print(string.format('size: %dK, ratio: %d%%', #src/1024, #dst / #src * 100))
end
test('zlib')

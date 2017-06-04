-- Issue: Mapping Chinese Pinyin First Letter Implementation
-- Copyright (C)2017 ms2008 <ms2008vip@gmail.com>

local bit = require "bit"
local ffi = require "ffi"
local ffi_new = ffi.new
local ffi_str = ffi.string
local bit_band = bit.band
local bit_bor = bit.bor
local bit_lshift = bit.lshift
local bit_rshift = bit.rshift
local string_format = string.format
local string_gmatch = string.gmatch
local string_match = string.match
local string_byte = string.byte
local string_char = string.char
local string_sub = string.sub
local table_concat = table.concat
local io_open = io.open
local io_close = io.close
local math_randomseed = math.randomseed
local math_random = math.random
local os_time = os.time
local ipairs = ipairs
local tonumber = tonumber
local type = type

ffi.cdef[[
    char pinyinFirstLetter(unsigned short hanzi);
]]

local _M = {
    _VERSION = '0.11'
}

local pyf_lib

-- Find shared object file package.cpath, obviating the need of setting
-- LD_LIBRARY_PATH
local function find_shared_obj(cpath, so_name)
    for k in string_gmatch(cpath, "[^;]+") do
        local so_path = string_match(k, "(.*/)")
        so_path = so_path .. so_name

        -- Don't get me wrong, the only way to know if a file exist is trying
        -- to open it.
        local f = io_open(so_path)
        if f ~= nil then
            io_close(f)
            return so_path
        end
    end
end

-- Helper wrappring script for loading shared object pinyin.so (FFI interface)
-- from package.cpath instead of LD_LIBRARTY_PATH.
local function load_pyf_parser()
    if pyf_lib ~= nil then
        return pyf_lib
    else
        local so_path = find_shared_obj(package.cpath, "pinyin.so")
        if so_path ~= nil then
            pyf_lib = ffi.load(so_path)
            return pyf_lib
        end
    end
end

-- Unicode code point range[19968, 40870]
local function pinyinFirstLetter(hanzi)
    if not pyf_lib then
        pyf_lib = load_pyf_parser()
    end
    local result = pyf_lib.pinyinFirstLetter(hanzi)
    -- return ffi_str(result)
    return string_char(result)
end

-- taken from http://jinnianshilongnian.iteye.com/blog/2187643
local function utf8_to_unicode(str)
    if not str or str == "" then
        return nil
    end
    local res, seq, val = {}, 0, nil
    for i = 1, #str do
        local c = string_byte(str, i)
        if seq == 0 then
            if val then
                res[#res + 1] = string_format("%04x", val)
            end

            seq = c < 0x80 and 1 or c < 0xE0 and 2 or c < 0xF0 and 3 or
                  c < 0xF8 and 4 or --c < 0xFC and 5 or c < 0xFE and 6 or
                               0
            if seq == 0 then
                ngx.log(ngx.ERR, 'invalid UTF-8 character sequence' .. ",,," .. tostring(str))
                return str
            end

            val = bit_band(c, 2 ^ (8 - seq) - 1)
        else
            val = bit_bor(bit_lshift(val, 6), bit_band(c, 0x3F))
        end
        seq = seq - 1
    end
    if val then
        res[#res + 1] = string_format("%04x", val)
    end
    if #res == 0 then
        return str
    end
    return table_concat(res, "")
end

-- unicode to utf8
local function unicode_to_utf8(convertStr)
    if type(convertStr) ~= "string" then
        return convertStr
    end

    local res, i = {}, 1
    while true do
        local num1 = string_byte(convertStr,i)
        local unicode

        if num1 ~= nil and string_sub(convertStr,i,i+1) == "\\u" then
            unicode = tonumber("0x"..string_sub(convertStr,i+2,i+5))
            i = i + 6
        elseif num1 ~= nil then
            unicode = num1
            i = i + 1
        else
            break
        end

        if unicode <= 0x007f then
            res[#res + 1] = string_char(bit.band(unicode,0x7f))
        elseif unicode >= 0x0080 and unicode <= 0x07ff then
            res[#res + 1] = string_char(bit_bor(0xc0,bit_band(bit_rshift(unicode,6),0x1f)))
            res[#res + 1] = string_char(bit_bor(0x80,bit_band(unicode,0x3f)))
        elseif unicode >= 0x0800 and unicode <= 0xffff then
            res[#res + 1] = string_char(bit_bor(0xe0,bit_band(bit_rshift(unicode,12),0x0f)))
            res[#res + 1] = string_char(bit_bor(0x80,bit_band(bit_rshift(unicode,6),0x3f)))
            res[#res + 1] = string_char(bit_bor(0x80,bit_band(unicode,0x3f)))
        end
    end

    res[#res + 1] = '\0'
    return table_concat(res, "")
end

local function uniStr(str)
    if not str then
        return nil
    end
    local tab = {}
    for uchar in string_gmatch(str, "[%z\1-\127\194-\244][\128-\191]*") do
        tab[#tab+1] = uchar
    end
    return tab
end

function _M:pinyin(s)
    local pyf = {}
    for i, v in ipairs(uniStr(s)) do
        pyf[i] = pinyinFirstLetter(tonumber(utf8_to_unicode(v), 16))
    end
    return table_concat(pyf, "")
end

-- experimental test
function _M:jieba(l)
    local hanzi = {}
    math_randomseed(os_time())
    for i=1,l,1 do
        local s = string_format("\\u%04x", math_random(19968, 40869))
        hanzi[i] = unicode_to_utf8(s)
    end
    return table_concat(hanzi, "")
end

return _M
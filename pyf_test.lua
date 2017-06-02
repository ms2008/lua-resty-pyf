-- /usr/bin/env luajit
package.path = "./?.lua;;"
package.cpath = "./?.so;;"

local pyf = require "pyf"

local test_str = [[
汉字是迄今为止连续使用时间最长的文字，也是上古时期各大文字体系中唯一传承至今的文字，中国历代皆以汉字为主要官方文字。汉字在古代已发展至高度完备的水准，不单中国使用，在很长时期内还充当东亚地区唯一的国际交流文字，20世纪前都是日本、朝鲜半岛、越南、琉球等国家官方的书面规范文字，东亚诸国都有一定程度地自行创制汉字。]]

print(test_str)

for i in string.gmatch(pyf:pinyin(test_str), ".") do
    io.write(string.format("%2s", i))
end

print()
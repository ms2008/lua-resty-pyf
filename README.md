# lua-resty-pyf

Lua 汉字拼音首字母提取。可以用于汉字拼音排序、检索。

## Requirements

- LuaJIT

## Install

默认安装到 `/usr/local/openresty/lualib`
```
make
make install
```

测试
```
[root@master:lua-resty-pyf (master)]# luajit pyf_test.lua
汉字是迄今为止连续使用时间最长的文字，也是上古时期各大文字体系中唯一传承至今的文字，中国历代皆以汉字为主要官方文字。汉字在古代已发展至高度完备的水准，不单中国使用，在很长时期内还充当东亚地区唯一的国际交流文字，20世纪前都是日本、朝鲜半岛、越南、琉球等国家官方的书面规范文字，东亚诸国都有一定程度地自行创制汉字。
 h z s q j w z l x s y s j z z d w z # y s s g s q g d w z t x z w y c c z j d w z # z g l d j y h z w z y g f w z # h z z g d y f z z g d w b d s z # b d z g s y # z h z s q n h c d d y d q w y d g j j l w z # # # s j q d s r b # c x b d # y n # l q d g j g f d s m g f w z # d y z g d y y d c d d z x c z h z #
[root@master:lua-resty-pyf (master)]#
```

## Usage

```lua
local pyf = require "pyf"

local result = pyf:pinyin("你好世界")
print(result)
```

## API

### `pyf:pinyin(s)`

将传入的字符串提取出汉字拼音的首字母。

`s` 必须为 UTF-8 编码，目前对数字和标点符号的处理均返回 `#`

### `pyf:jieba(l)`

实验性功能，随机生成 `l` 个汉字(有很多生僻字)。

## License

[MIT](http://hotoo.mit-license.org/)

## Thanks...

George wrote the clib.

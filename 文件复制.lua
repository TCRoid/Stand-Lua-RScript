
-- 以只读方式打开文件
file = io.open("D:\\Python\\MyProjects\\StandLua\\RScripts.lua", "r")

-- 设置默认输入文件为 test.lua
io.input(file)

local text = io.read("*a")

-- 关闭打开的文件
io.close(file)

-- 以写入的方式打开只写文件
file2 = io.open("C:\\Users\\Rostal\\AppData\\Roaming\\Stand\\Lua Scripts\\RScripts.lua", "w")

-- 设置默认输出文件为 test.lua
io.output(file2)

-- 在文件最后一行添加 Lua 注释
io.write(text)

-- 关闭打开的文件
io.close(file2)

print("完成")





package.path = './lib/?.lua;./lib/?/init.lua;/Users/apple/Documents/GitHub/lua-resty-core-headers/./lua_modules/share/lua/5.1/?.lua;/Users/apple/Documents/GitHub/lua-resty-core-headers/./lua_modules/share/lua/5.1/?/init.lua;/opt/homebrew/Cellar/luarocks/3.9.1/share/lua/5.1/?.lua;/opt/homebrew/share/lua/5.1/?.lua;/opt/homebrew/share/lua/5.1/?/init.lua;/opt/homebrew/lib/lua/5.1/?.lua;/opt/homebrew/lib/lua/5.1/?/init.lua;./?.lua;./?/init.lua;/Users/apple/.luarocks/share/lua/5.1/?.lua;/Users/apple/.luarocks/share/lua/5.1/?/init.lua;'
    .. package.path
local event = require 'resty.core.headers.event'
local ptr = event.ngx_posted_events()
print(ptr)
local ev = event()
local flag = false
ev.handler = function(ev)
    flag = true
end
print(ev)
ev:post(ptr)

while not flag do
    ngx.sleep(0.001)
end
print('end')

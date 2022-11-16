package = "lua-resty-core-headers"
version = "0.0.1-0"
source = {
   url = "git+https://github.com/fesily/lua-resty-core-headers.git"
}
description = {
   homepage = "https://github.com/fesily/lua-resty-core-headers",
   license = "MIT"
}
dependencies = {
   "lua-resty-template = 2.0",
   "lua-resty-configure >= 0.0.1-0"
}
build = {
   type = "builtin",
   modules = {}
}

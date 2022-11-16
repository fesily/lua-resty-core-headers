local is_debug = ngx.config.debug
return function(...)
    if is_debug then
        ngx.log(ngx.DEBUG, ...)
    end
end

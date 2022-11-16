it("event", function()
    local event = require 'resty.core.headers.event'
    local ptr = assert(event.ngx_posted_events())
    local ev = event()
    assert(ev)
    local flag = false
    ev.handler = function(e)
        assert(ev == e)
        flag = true
    end
    ev:post(ptr)

    while not flag do
        ngx.sleep(0.001)
    end
end)

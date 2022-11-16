require 'resty.core.headers.core'
local template = require 'resty.template'
local ffi = require 'ffi'
local logger = require 'resty.core.headers.logger'
if ffi.os == 'Windows' then
    ffi.cdef [[
        typedef struct ngx_event_s ngx_event_t;
        typedef struct _WSAOVERLAPPED {
            DWORD    Internal;
            DWORD    InternalHigh;
            DWORD    Offset;
            DWORD    OffsetHigh;
            HANDLE hEvent;
          } WSAOVERLAPPED, *LPWSAOVERLAPPED;
          typedef struct {
            WSAOVERLAPPED    ovlp;
            ngx_event_t     *event;
            int              error;
        } ngx_event_ovlp_t;
    ]]
else

end

local event_template = template.compile([[
    struct ngx_event_s {
        void            *data;
    
        unsigned         write:1;
    
        unsigned         accept:1;
    
        /* used to detect the stale events in kqueue and epoll */
        unsigned         instance:1;
    
        /*
         * the event was passed or would be passed to a kernel;
         * in aio mode - operation was posted.
         */
        unsigned         active:1;
    
        unsigned         disabled:1;
    
        /* the ready event; in aio mode 0 means that no operation can be posted */
        unsigned         ready:1;
    
        unsigned         oneshot:1;
    
        /* aio operation is complete */
        unsigned         complete:1;
    
        unsigned         eof:1;
        unsigned         error:1;
    
        unsigned         timedout:1;
        unsigned         timer_set:1;
    
        unsigned         delayed:1;
    
        unsigned         deferred_accept:1;
    
        /* the pending eof reported by kqueue, epoll or in aio chain operation */
        unsigned         pending_eof:1;
    
        unsigned         posted:1;
    
        unsigned         closed:1;
    
        /* to test on worker exit */
        unsigned         channel:1;
        unsigned         resolver:1;
    {% if HAVE_SOCKET_CLOEXEC_PATCH then %}
        unsigned         skip_socket_leak_check:1;
    {% end %}
    
        unsigned         cancelable:1;
    
    {% if NGX_HAVE_KQUEUE then %}
        unsigned         kq_vnode:1;
    
        /* the pending errno reported by kqueue */
        int              kq_errno;
    {% end %}
    
        /*
         * kqueue only:
         *   accept:     number of sockets that wait to be accepted
         *   read:       bytes to read when event is ready
         *               or lowat when event is set with NGX_LOWAT_EVENT flag
         *   write:      available space in buffer when event is ready
         *               or lowat when event is set with NGX_LOWAT_EVENT flag
         *
         * iocp: TODO
         *
         * otherwise:
         *   accept:     1 if accept many, 0 otherwise
         *   read:       bytes to read when event is ready, -1 if not known
         */
    
        int              available;
    
        ngx_event_handler_pt  handler;
    
    
    {% if NGX_HAVE_IOCP then %}
        ngx_event_ovlp_t ovlp;
    {% end %}
    
        ngx_uint_t       index;
    
        ngx_log_t       *log;
    
        ngx_rbtree_node_t   timer;
    
        /* the posted queue */
        ngx_queue_t      queue;
    };

typedef struct {
    ngx_int_t  (*add)(ngx_event_t *ev, ngx_int_t event, ngx_uint_t flags);
    ngx_int_t  (*del)(ngx_event_t *ev, ngx_int_t event, ngx_uint_t flags);

    ngx_int_t  (*enable)(ngx_event_t *ev, ngx_int_t event, ngx_uint_t flags);
    ngx_int_t  (*disable)(ngx_event_t *ev, ngx_int_t event, ngx_uint_t flags);

    ngx_int_t  (*add_conn)(ngx_connection_t *c);
    ngx_int_t  (*del_conn)(ngx_connection_t *c, ngx_uint_t flags);

    ngx_int_t  (*notify)(ngx_event_handler_pt handler);

    ngx_int_t  (*process_events)(ngx_cycle_t *cycle, ngx_msec_t timer,
                                 ngx_uint_t flags);

    ngx_int_t  (*init)(ngx_cycle_t *cycle, ngx_msec_t timer);
    void       (*done)(ngx_cycle_t *cycle);
} ngx_event_actions_t;


extern ngx_event_actions_t   ngx_event_actions;

extern ngx_queue_t  ngx_posted_accept_events;
extern ngx_queue_t  ngx_posted_next_events;
extern ngx_queue_t  ngx_posted_events;
extern ngx_queue_t  ngx_posted_delayed_events;
]])

local event_t = event_template(require 'resty.configure')
ffi.cdef(event_t)

local ngx_event_t = ffi.typeof('ngx_event_t')
local event_queue_offset = ffi.offsetof(ngx_event_t, "queue")
local ptr_t = ffi.typeof("void*")
local ptr1_t = ffi.typeof("intptr_t")
local ngx_queue_t_ptr = ffi.typeof("ngx_queue_t*")
local function get_queue_ptr(event)
    local ptr = ffi.cast(ptr1_t, ffi.cast(ptr_t, event)) + event_queue_offset
    print(ffi.cast(ptr_t, ptr))
    return ffi.cast(ngx_queue_t_ptr, ptr)
end

local _M = {}
ffi.metatype("ngx_event_t", {
    __index = _M
})

local C = ffi.C
function _M.ngx_posted_accept_events()
    return C.ngx_posted_accept_events
end

function _M.ngx_posted_next_events()
    return C.ngx_posted_next_events
end

function _M.ngx_posted_events()
    return C.ngx_posted_events
end

function _M.ngx_posted_delayed_events()
    return C.ngx_posted_delayed_events
end

function _M:post(q)
    local ev = self
    if ev.posted == 0 then
        ev.posted = 1
        q:insert_tail(get_queue_ptr(ev))
        logger("post event ", tostring(ev))
    else
        logger("update posted event ", tostring(ev))
    end
end

function _M:delete()
    local ev = self
    ev.posted = 0
    ev.queue:remove()

    logger("delete posted event ", tostring(ev))
end

return setmetatable(_M, {
    __call = function(t)
        return ngx_event_t(t and t or nil)
    end
}
)

local ffi = require "ffi"
ffi.cdef [[
    typedef struct ngx_queue_s  ngx_queue_t;
    
    struct ngx_queue_s {
        ngx_queue_t  *prev;
        ngx_queue_t  *next;
    };
    ngx_queue_t *ngx_queue_middle(ngx_queue_t *queue);
    void ngx_queue_sort(ngx_queue_t *queue,
        ngx_int_t (*cmp)(const ngx_queue_t *, const ngx_queue_t *));
]]

---@class ngx.queue
---@field prev ngx.queue
---@field next ngx.queue
local _M = {}

function _M:init()
    self.prev = self
    self.next = self
end

function _M:empty()
    return self == self.prev
end

---@param x ngx.queue
function _M:insert_head(x)
    local h = self
    x.next = h.next;
    x.next.prev = x;
    x.prev = h;
    h.next = x
end

_M.insert_after = _M.insert_head

---@param x ngx.queue
function _M:insert_tail(x)
    local h = self
    x.prev = h.prev;
    x.prev.next = x;
    x.next = h;
    h.prev = x
end

function _M:head()
    return self.next
end

function _M:last()
    return self.prev
end

function _M:sentinel()
    return self
end

function _M:remove()
    local x = self
    x.next.prev = x.prev;
    x.prev.next = x.next
end

function _M:split(q, n)
    local h = self
    n.prev = h.prev
    n.prev.next = n
    n.next = q
    h.prev = q.prev
    h.prev.next = h
    q.prev = n;
end

---@param n ngx.queue
function _M:add(n)
    local h = self;
    h.prev.next = n.next;
    n.next.prev = h.prev;
    h.prev = n.prev;
    h.prev.next = h;
end

local u_char_t = ffi.typeof("u_char*")
function _M:data(type, link)
    local q = self
    local ofs = ffi.offsetof(type, link)
    local ptr = ffi.cast(u_char_t, q)
    return ffi.cast(type, ptr - ofs)
end

local C = ffi.C
function _M:middle()
    return C.ngx_queue_middle(self)
end

function _M:sort(cmp)
    C.ngx_queue_sort(self, cmp)
end

ffi.metatype("ngx_queue_t", {
    __index = _M
})
return _M

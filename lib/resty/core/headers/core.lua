local ffi = require "ffi"

if ffi.os == 'Windows' then
    ffi.cdef [[
        typedef unsigned int DWORD;
    ]]
else
    ffi.cdef [[
        typedef uint64_t                ino_t;
        typedef intptr_t        ngx_int_t;
        typedef uintptr_t       ngx_uint_t;
        typedef intptr_t        ngx_flag_t;
        typedef unsigned char u_char;
    ]]
end

ffi.cdef [[
    typedef struct ngx_module_s          ngx_module_t;
    typedef struct ngx_conf_s            ngx_conf_t;
    typedef struct ngx_cycle_s           ngx_cycle_t;
    typedef struct ngx_pool_s            ngx_pool_t;
    typedef struct ngx_chain_s           ngx_chain_t;
    typedef struct ngx_log_s             ngx_log_t;
    typedef struct ngx_open_file_s       ngx_open_file_t;
    typedef struct ngx_command_s         ngx_command_t;
    typedef struct ngx_file_s            ngx_file_t;
    typedef struct ngx_event_s           ngx_event_t;
    typedef struct ngx_event_aio_s       ngx_event_aio_t;
    typedef struct ngx_connection_s      ngx_connection_t;
    typedef struct ngx_thread_task_s     ngx_thread_task_t;
    typedef struct ngx_ssl_s             ngx_ssl_t;
    typedef struct ngx_proxy_protocol_s  ngx_proxy_protocol_t;
    typedef struct ngx_ssl_connection_s  ngx_ssl_connection_t;
    typedef struct ngx_udp_connection_s  ngx_udp_connection_t;
    typedef void (*ngx_event_handler_pt)(ngx_event_t *ev);
    typedef void (*ngx_connection_handler_pt)(ngx_connection_t *c);
]]

ffi.cdef [[
typedef ngx_uint_t  ngx_rbtree_key_t;
typedef ngx_int_t   ngx_rbtree_key_int_t;

typedef struct ngx_rbtree_node_s  ngx_rbtree_node_t;

struct ngx_rbtree_node_s {
    ngx_rbtree_key_t       key;
    ngx_rbtree_node_t     *left;
    ngx_rbtree_node_t     *right;
    ngx_rbtree_node_t     *parent;
    u_char                 color;
    u_char                 data;
};

]]

ffi.cdef [[
    typedef ngx_rbtree_key_t      ngx_msec_t;
    typedef ngx_rbtree_key_int_t  ngx_msec_int_t;
]]
require 'resty.core.headers.queue'

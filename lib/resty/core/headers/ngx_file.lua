require 'resty.core.headers.core'
local ffi = require 'ffi'
local template = require 'resty.template'
local configure = require 'resty.configure'
assert(ffi.abi("64bit"), "only supported on 64bit platform")
if ffi.os == 'Windows' then
    ffi.cdef [[
    typedef struct _FILETIME {
        DWORD dwLowDateTime;
        DWORD dwHighDateTime;
    } FILETIME, *PFILETIME, *LPFILETIME;
    typedef struct _BY_HANDLE_FILE_INFORMATION {
        DWORD    dwFileAttributes;
        FILETIME ftCreationTime;
        FILETIME ftLastAccessTime;
        FILETIME ftLastWriteTime;
        DWORD    dwVolumeSerialNumber;
        DWORD    nFileSizeHigh;
        DWORD    nFileSizeLow;
        DWORD    nNumberOfLinks;
        DWORD    nFileIndexHigh;
        DWORD    nFileIndexLow;
    } BY_HANDLE_FILE_INFORMATION, *PBY_HANDLE_FILE_INFORMATION, *LPBY_HANDLE_FILE_INFORMATION;
    typedef void *HANDLE;
    typedef HANDLE                      ngx_fd_t;
    typedef BY_HANDLE_FILE_INFORMATION  ngx_file_info_t;
    typedef uint64_t                    ngx_file_uniq_t;
    ]]
else
    ffi.cdef [[
        typedef int                      ngx_fd_t;
        typedef struct stat              ngx_file_info_t;
        typedef ino_t                 ngx_file_uniq_t;
    ]]
end

local ngx_file_tempalte = template.compile([[
    struct ngx_file_s {
        ngx_fd_t                   fd;
        ngx_str_t                  name;
        ngx_file_info_t            info;
    
        off_t                      offset;
        off_t                      sys_offset;
    
        ngx_log_t                 *log;
    
    {% if NGX_THREADS or NGX_COMPAT then %}
        ngx_int_t                (*thread_handler)(ngx_thread_task_t *task,
                                                   ngx_file_t *file);
        void                      *thread_ctx;
        ngx_thread_task_t         *thread_task;
    {% end %}
    
    {% if NGX_HAVE_FILE_AIO or NGX_COMPAT then %}
        ngx_event_aio_t           *aio;
    {% end %}
    
        unsigned                   valid_info:1;
        unsigned                   directio:1;
    };
]])

local ngx_file_t = ngx_file_tempalte(configure)

ffi.cdef(ngx_file_t)

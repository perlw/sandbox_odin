package shm

// TODO: These should be in their own package.
IPC_RMID :: 0x0
IPC_PRIVATE :: 0x0

S_IRUSR :: 0x00000100
S_IWUSR :: 0x00000080
S_IRGRP :: 0x00000020
S_IWGRP :: 0x00000010
S_IROTH :: 0x00000004
S_IWOTH :: 0x00000002
IPC_CREAT :: 0x00000200
IPC_EXCL :: 0x00000400

TS_NP :: 0x00010000
RESIZE_NP :: 0x00040000
MAP_FIXED_NP :: 0x00100000

foreign import shm "system:c"
@(default_calling_convention = "std")
@(link_prefix = "shm")
foreign shm {
	at :: proc(shm_id: i32, shm_addr: rawptr, shm_flag: i32) -> rawptr ---
	ctl :: proc(shm_id: i32, cmd: i32, buf: rawptr) -> i32 ---
	dt :: proc(shm_addr: rawptr) -> i32 ---
	get :: proc(key: u32, size: u32, shm_flag: i32) -> i32 ---
}

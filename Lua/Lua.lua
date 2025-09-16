

[[
类别		  格式符		含义说明						  字节数		取值范围 / 说明
基础整数		b	有符号字符（char）					1		-128 ~ 127
			B	无符号字符（char）					1		0 ~ 255
短整数		h	有符号短整数（小端序，short）			2		-32768 ~ 32767
			H	无符号短整数（小端序）				2		0 ~ 65535
			>h	有符号短整数（大端序）				2		同上
			>H	无符号短整数（大端序）				2		同上
长整数		l	有符号长整数（小端序，long）			4		通常为 -2¹⁴⁷⁴⁸³⁶⁴⁸ ~ 2¹⁴⁷⁴⁸³⁶⁴⁷（取决于系统，Lua 中固定为 4 字节）
			L	无符号长整数（小端序，）				4		0 ~ 4294967295
			>l	有符号长整数（大端序）				4		同上
			>L	无符号长整数（大端序）				4		同上
64 位整数	j	Lua 整数（int64_t，有符号）			8		-9223372036854775808 ~ 9223372036854775807
			J	Lua 无符号整数（uint64_t）			8		0 ~ 18446744073709551615
指定长度整数	iN	N字节有符号整数（如i1=1字节，i4=4字节）N		范围：-2^(8N-1) ~ 2^(8N-1)-1
			IN	N字节无符号整数（如I2=2字节，I8=8字节）N		范围：0 ~ 2^(8N)-1
浮点数		f	单精度浮点数（小端序，float）			4		约 ±3.4e±38（6-7 位有效数字）
			d	双精度浮点数（小端序，double）			8		约 ±1.8e±308（15-17 位有效数字）
			>f	单精度浮点数（大端序）				4		同上
			>d	双精度浮点数（大端序）				8		同上
字符串		s	以 null 结尾的字符串（C 风格字符串）	可变		自动读取到 '\0' 终止符（不包含终止符在结果中）
			z	长度前缀为1字节的字符串(前缀表示字符串长度）		    1+len	前缀范围 0~255，后跟对应长度的字符串
			zN	长度前缀为N字节的字符串(N为数字,如z2用2字节表示长度）   N+len	前缀为无符号整数，后跟对应长度的字符串
			cN	固定长度为N的字符串（不足补 '\0'，超长截断）			N		如 c4 表示 4 字节固定长度字符串
字节序控制	>	后续格式使用大端序（big-endian，网络字节序）			-		如 ">i4f" 表示 4 字节有符号整数（大端）+ 单精度浮点数（大端）
			<	后续格式使用小端序（little-endian，默认）				-		如 "<Hd" 表示 2 字节无符号整数（小端）+ 双精度浮点数（小端）
			=	后续格式使用系统原生字节序								-		依赖运行环境的字节序（如 x86 为小端，PowerPC 为大端）
重复格式		n*	重复格式 n 次（n 为数字）								可变		如 3I2 表示 3 个 2 字节无符号整数（总长度 3×2=6 字节）
			*	尽可能多地重复格式（仅用于解包，直到数据结束）			可变		如 string.unpack("*i2", data) 解包所有 2 字节有符号整数

]]
-------------------------------------------------------------------------------

socket.connect(host, port [, timeout]) -- 建立 TCP 连接到指定主机和端口，返回连接对象，可选超时时间
socket.bind(host, port [, backlog])     -- 绑定 TCP 套接字到指定主机和端口，返回服务器套接字，backlog 为最大等待连接数
socket.select(r, w, e [, timeout]) -- I/O 多路复用，监控读 (r)、写 (w)、异常 (e) 集合中的套接字，返回就绪的套接字
socket.tcp()                -- 创建一个 TCP 套接字对象，返回该对象
socket.udp()                -- 创建一个 UDP 套接字对象，返回该对象
socket.gettime()            -- 返回当前时间（秒），高精度
socket.sleep(seconds)       -- 使程序休眠指定秒数
socket.VERSION -- LuaSocket 版本字符串
socket.BLOCK -- 阻塞模式常量
socket.NBIO -- 非阻塞模式常量

socket.dns.toip(host)       -- 将主机名解析为 IP 地址，返回 IP 字符串
socket.dns.gethostname()    -- 返回本地主机名
socket.dns.getaddrinfo(host [, service]) -- 获取主机的地址信息，返回包含地址的表

socket.try(expr)            -- 执行表达式，若出错则抛出异常，常用于错误处理
socket.newtry([finalizer]) -- 创建一个错误处理函数，可指定最终化函数在出错时执行
socket.protect(func)        -- 包装函数，捕获函数执行中的错误并返回错误信息

tcp:send(data [, i [, j]])  --发送数据，i 和 j 指定数据的起始和结束索引，返回发送的字节数或 nil + 错误
tcp:receive([pattern [, prefix]]) -- 接收数据，pattern 指定接收模式（如 "*l" 接收一行），返回接收的数据
tcp:accept([timeout])       -- 服务器套接字接受客户端连接，返回新的连接对象，可选超时
tcp:close()                 -- 关闭 TCP 套接字
tcp:shutdown([how])         -- 关闭连接的读或写端，how 为 "read"、"write" 或 "both"
tcp:setoption(option, value) -- 设置套接字选项，如 {keepalive=true} 启用保活
tcp:getoption(option)       -- 获取套接字选项的值
tcp:settimeout(value [, mode]) -- 设置超时时间，mode 为 "connect"、"send"、"receive" 或 "all"
tcp:gettimeout([mode])          -- 获取指定模式的超时时间
tcp:getsockname()               -- 返回套接字绑定的本地地址和端口
tcp:getpeername()               -- 返回连接的对端地址和端口
tcp:listen([backlog])           -- 服务器套接字开始监听连接，backlog 为最大等待连接数


Lua 5.1
string.byte (s [, i [, j]])     -- 返回字符串 s 中从索引 i 到 j 的字符的 ASCII 码，默认 i=1, j=i
string.char (...)               -- 将一系列 ASCII 码转换为对应的字符，返回拼接后的字符串
string.find (s, pattern [, init [, plain]]) -- 在 s 中查找 pattern，init 为起始位置，plain 为 true 则关闭模式匹配，返回匹配位置
string.format (formatstring, ...)   -- 按格式化字符串 formatstring 处理参数，返回格式化后的字符串
string.gmatch (s, pattern)          -- 返回迭代器，遍历 s 中所有匹配 pattern 的子串
string.gsub (s, pattern, replacement [, n]) -- 用 replacement 替换 s 中匹配 pattern 的子串，n 为最大替换次数，返回结果和替换次数
string.len (s)                      -- 返回字符串 s 的长度
string.lower (s)                    -- 将 s 中所有大写字母转为小写，返回新字符串
string.match (s, pattern [, init])  -- 从 s 的 init 位置开始匹配 pattern，返回第一个匹配的捕获结果
string.rep (s, n [, sep])           -- 将 s 重复 n 次，sep 为分隔符（可选），返回结果
string.reverse (s)                  -- 反转字符串 s，返回新字符串
string.sub (s, i [, j])             -- 返回 s 中从 i 到 j 的子串，i/j 可负数（表示从末尾计数）
string.upper (s)                    -- 将 s 中所有小写字母转为大写，返回新字符串
string.dump (function)              -- 将函数序列化为二进制字符串，可用于保存和加载函数

Lua 5.3
string.pack (format, ...)           -- 按 format 指定的格式将参数打包为二进制字符串（Lua 5.3+）
string.packsize (format)            -- 返回按 format 格式打包后的字符串长度（Lua 5.3+）
string.unpack (format, s [, pos])   -- 从 s 的 pos 位置开始按 format 格式解包数据，返回解包的值和下一个位置（Lua 5.3+）

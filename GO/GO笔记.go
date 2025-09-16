JETBRAINS 下载地址
	https://www.jetbrains.com/go/download/other.html
	https://nopj.cn/article/jetbrains/serial

教程
http://www.topgoer.com/ 插件

MongoDB数据库：
https://www.mongodb.com/zh-cn/docs/drivers/go/current/quick-start/
MySQL:https://www.jianshu.com/p/1513f55f8192

🧡💛💚💙💜
1，数据库 MySQL
2，http服务器+web
	https://segmentfault.com/a/1190000043820294



配置系统变量
	安装目录： GOROOT=目录路径
	下载包路径： GOPATH=目录路径

一，字符串常用函数：
	strings.ToUpper()
	strings.ToLower()
	strings.Index() //开始索引的位置
	strings.Count()
	strings.Contains()
	strings.Trim() //去掉两头空字符串
	len()
	strings.Join()
	strings.Split()
	strings.Fields()//空格分割字符串
	strings.EqualFold() //忽略大小写
	strings.ReplaceAll()

	 rand.Seed(time.Now().UnixNano()) //随机数
	 rand.Intn(100)          //生成0~99的随机整数

	转义字符，%v %s %T

二，变量及数据类型
	int,int64,int16,int8,uint8,uint16,uint32,uint64,uintptr
	byte,bool,string,float32,float64
	_ := map[keyType]valueType{} delete(dic, key) //字典声明
	_ := []valueType{} 	append()//数组声明
	_ := make([]valueType, int) //声明指定长度的数组
	_,_ := 1,2 //支持元表
	_ := map[int16]func(*Session, *packet.Packet)[]byte{} //函数变量
	[n:m] //切片区间只对数组有效

	strconv.Atoi() //字符串转换为数字
	strconv.Itoa() //数字转换为字符串
	string([]byte), []byte(string)//字符串和字节互相转换
	fmt.Sprintln(...) //将任意类型转换为字符串
	fmt.Scanln(&name)//控制台输入


三，错误和异常
	panic(any)//引发异常，终止程序
	defer func //延时调用函数
	recover() //阻止程序中断，恢复正常

四，文件和包导入
	import "net/http" // 以包名http为类调用函数
	import  . "time"   // 省略包名，直接调用函数
	import  format "fmt"  // 别名format类调用函数
	import  _ "math/rand" // 忽略此包名，但init函数被执行一次

	package 包名  //目录名来作为包名
	首字母大写为公开，小写为私有

五，语句
	if else switch case default //条件判断
	for break continue range  //for循环
	func return ...//可变参数 
	type struct //指针和C类似
	const iota //常量声明 iota=0
	go func() //线程
	goto LABEL  LABEL://类似于C#

六，json结构体 tag标签
	json：结构体字段名首字母需大写
	   json.Marshal(obj) 对象转换为字节
	   json.MarshalIndent(obj, "", "\t") 格式化
	   json.Unmarshal([]byte(""),&obj) 解析字符串
	 //结构体，字段后的标签
	type User struct {
		//表示 Name 序列化的值 为"name"
	    Name      string    `json:"name"`
	}
	new(结构体)

七，闭包函数和 接口 interface
	定义结构体方法和接口方法同名
	func (a 结构体A) 方法名S() string
	func (b 结构体B) 方法名S() string
	type 接口名 interface { 方法名S() string }
	func 方法名(i 接口名) {i.方法名S()}//接口方法实现多态 

	interface{} //空接口可以是任意类型
	//闭包类似于Lua中的闭包
	func Hander(method func(...any), params ...any) func() {
		return func() {
			method(params...)
		}
	}


八，锁和通道
	sync.Mutex.Lock()
	sync.Mutex.Unlock()
	sync.WaitGroup.Wait() //等待前面携程完成

	sync.WaitGroup.Add(int)
	sync.WaitGroup.Done()
	sync.WaitGroup.Wait()
 chan
	//声明通道
	ch := make(chan []byte, 100000)
	ch <- data

	//循环输出消息
	for{
		select {
			case msg, ok := <-ch: 
		}
	}
	//关闭
	close(chan)


九，数据库
	MongoDB, MySQL

十，文件流 ,Tcp和http
	listener, err := net.Listen("tcp", "localhost:0000")//tcp监听

配置：Settings>Go>Go Modules>Environment
GOPROXY=https://goproxy.cn,direct

输出命令
go run demo.go
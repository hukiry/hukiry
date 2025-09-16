1. 版本冲突

	Error : mysql57-community-release conflicts with mysql80-community-release-el8-1.noarch

	分析

	安装了其他版本的mysql再安装mysql57的时候依赖出问题

	解决

	删除老的mysql工具

	rpm -Uvh mysql57-community-release-el7-10.noarch.rpm

	#命令行出现 mysql57-community-release-el7-8.noarch

	rpm -e --nodeps mysql57-community-release-el7-8.noarch

2. 依赖报错

	Error: Package: mysql-community-server-5.7.20-1.el7.x86_64 (mysql57-community)

	Requires: libsasl2.so.3()(64bit)

	Error: Package: mysql-community-client-5.7.20-1.el7.x86_64 (mysql57-community)

	Requires: libstdc++.so.6(GLIBCXX_3.4.15)(64bit)

	Error: Package: mysql-community-libs-5.7.20-1.el7.x86_64 (mysql57-community)

	...

	分析

	因为 旧版本 mysql 的依赖问题；最快的解决方案就是卸载重装

3. 卸载

	1.快速删除
	yum remove mysql mysql-server mysql-libs mysql-server

	2.查找残留文件
	rpm -qa | grep -i mysql
	## 将查询出来的文件删除
	yum remove mysql-community-common-5.7.20-1.el6.x86_64
	## 删除残余目录
	whereis mysql
	## mysql : /usr/lib64/mysql
	rm –rf /usr/lib64/mysql

	3.删除依赖
	## 查找依赖
	yum list installed | grep mysql
	## 删除找到的依赖
	yum -y remove mysql-libs.x86_64

	4,删除缓存： sudo yum clean all --verbose

4. 安装新mysql
	1.添加镜像源，从官网downloads选取
	wget dev.mysql.com/get/mysql-community-release-el6-5.noarch.rpm
	yum localinstall mysql-community-release-el6-5.noarch.rpm
	yum repolist all | grep mysql
	yum-config-manager --disable mysql55-community
	yum-config-manager --disable mysql56-community
	yum-config-manager --enable mysql57-community-dmr
	yum repolist enabled | grep mysql

	2.安装
	yum install mysql-community-server

	原文链接：https://blog.csdn.net/weixin_33782854/article/details/113276938



https://help.aliyun.com/document_detail/116727.html?spm=a2c4g.25365.0.i1

-------------------------------------------------MySQL 笔记----------------------------------------------------
window必须以管理员打开cmd
    一，本地安装命令行（切换到mysql安装目录下的bin目录下）
        mysqld --initialize --console   此命令生成临时的密码
        mysqld --install                检查安装情况
        mysqld --initialize--insecure 
        mysqld --initialize 
        net start mysql         启动SQL服务器        
        net stop mysql          停止SQL服务器
        退出mysql：exit          
        mysql -u root -p   登录mysql：输入mysql生成的那个密码或修改后的密码
        重置密码命令（最后面的分号要加上）
        ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '新密码'; 

    二，操作命令：
        use mysql    切换到数据库
        select host,user from user;
        UPDATE user SET Host = '%' WHERE User = 'root' LIMIT 1;    允许外部远程访问
        flush privileges;   让上面的命令生效

        show global variables like 'port';    查看MySQL端口
        status   查看MySQL端口状态
        打开mysql的配置文件    my.ini进入后直接查看    port

        CREATE DATABASE 数据库名称;    创建数据库
        show databases;             显示数据库列表
        SHOW TABLES;                显示表列表
        desc 表名                   显示表数据
        drop database 数据库名       删除数据库
        drop table 表名            删除表

        判断表字段是否存在
        SELECT column_name FROM information_schema.columns WHERE table_name="表名" AND column_name="字段名"

    三，MySQL教程：
        api查询： http://www.yiidian.com/mysql/mysql-show-list-tables.html

    四，MySQL地址：
        官方下载地址： https://dev.mysql.com/doc/connector-net/en/connector-net-ref.html
        本地搭建mysql： https://blog.csdn.net/m0_72755989/article/details/127388356

Linux--------------------------
https://dev.mysql.com/get/mysql80-community-release-el7-3.noarch.rpm
sudo yum -y install mysql-community-server --enablerepo=mysql80-community --nogpgcheck

	1，下载： wget https://repo.mysql.com//mysql80-community-release-el8-1.noarch.rpm
	2，安装： yum install mysql80-community-release-el8-1.noarch.rpm
	3,查看MySQL源是否安装成功:yum repolist enabled | grep "mysql.*-community.*"
	4, 禁止自带：yum module disable mysql
	5，安装服务： yum install mysql-community-server --nogpgcheck
	6，启动服务： /bin/systemctl start mysqld.service
	7, 查看状态： service mysqld status
	8, 查看随机密码： grep 'temporary password' /var/log/mysqld.log
	9, 登录服务： mysql -u root -p
	10, 修改密码：ALTER USER 'root'@'localhost' IDENTIFIED BY 'mySQL#123mySQL'; 
	11，切换数据库：use mysql;
	12, 查看user表： select Host, User from user;
	13, 远程登录权限修改，update user set Host = '%' where User='root';
    14, 让13步生效: flush privileges;
    15, 查看开机启动：systemctl list-unit-files|grep mysqld
    16，设置开机启动：systemctl enable mysqld.service



以下是在 Linux 操作系统上安装 MySQL 数据库的一些常用命令：
	更新 yum 包管理器：sudo yum update

	安装 MySQL 服务器和客户端：sudo yum install mysql-server mysql

	启动 MySQL 服务器：sudo systemctl start mysqld

	设置 MySQL 服务器开机自启动：sudo systemctl enable mysqld

	查看 MySQL 服务器状态：sudo systemctl status mysqld

	登录 MySQL 服务器：mysql -u username -p

	创建新用户：CREATE USER 'username'@'localhost' IDENTIFIED BY 'password';

	授予新用户权限：GRANT ALL PRIVILEGES ON . TO 'username'@'localhost';

	刷新权限：FLUSH PRIVILEGES;

	退出 MySQL：exit
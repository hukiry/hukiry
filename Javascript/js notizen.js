教程：https://www.w3school.com.cn/jsref/jsref_obj_array.asp
JavaScript 数组参考手册

vue 资源：https://hu-snail.github.io/vue3-resource/platform/introduction.html
参考
https://w3ccoo.com/howto/howto_js_dropdown.html


一，HTMLDOM
	document.getElementById() //id标记
	document.getElementsByClassName() //类标记
	document.getElementsByTagName() //html标记
	document.querySelectorAll()//所有html标记

	onload,onunload //进入或离开页面时被触发
	onchange //输入字段的验证来使用
	//鼠标事件
	onmouseover,onmouseout 
	onmousedown,onmouseup,onclick 
	//注册和移动事件
	removeEventListener() 
	addEventListener() 

	document.createElement() //创建元素
	document.createTextNode() //创建文本节点
	element.appendChild();//添加节点到最后
	element.insertBefore()//添加节点到最前
	element.removeChild()//移除节点
	element.replaceChild()//替换节点

	setInterval() - 间隔指定的毫秒数不停地执行指定的代码。
	setTimeout() - 在指定的毫秒数后执行指定代码。
	document.cookie 修改 Cookie

二，string对象
	concat()	返回两个或多个连接的字符串。
	endsWith()	返回字符串是否以指定值结尾。
	indexOf()	返回字符串中第一次出现指定值的索引（位置）。
	lastIndexOf()	返回字符串中最后一次出现指定值的索引（位置）。
	match()	在字符串中搜索值或正则表达式，并返回匹配项。
	replace()	在字符串中搜索模式，并返回替换第一个匹配项后的字符串。
	replaceAll()	在字符串中搜索模式，并返回替换所有匹配项后的新字符串。
	slice()	提取字符串的一部分并返回新字符串。
	split()	将字符串拆分为子字符串数组。
	startsWith()	检查字符串是否以指定字符开头。
	substr()	从字符串的指定索引（位置）开始提取指定数量的字符。
	substring()	提取字符串中两个指定索引（位置）之间的字符。
	toLowerCase()	返回转换为小写字母的字符串。
	toString()	将字符串或字符串对象作为字符串返回。
	toUpperCase()	返回转换为大写字母的字符串。
	trim()	返回去除空格的字符串。
	trimEnd()	返回去除末尾空格的字符串。
	trimStart()	返回去除开头空格的字符串。
	valueOf()	返回字符串或字符串对象的原始值。

三，全局函数
	decodeURI()	解码某个编码的 URI。
	decodeURIComponent()	解码一个编码的 URI 组件。
	encodeURI()	把字符串编码为 URI。
	encodeURIComponent()	把字符串编码为 URI 组件。
	escape()	对字符串进行编码。
	unescape()	对由 escape() 编码的字符串进行解码。
	eval()	计算 JavaScript 字符串，并把它作为脚本代码来执行。
	isFinite()	检查某个值是否为有穷大的数。
	isNaN()	检查某个值是否是数字。
	Number()	把对象的值转换为数字。
	parseFloat()	解析一个字符串并返回一个浮点数。
	parseInt()	解析一个字符串并返回一个整数。
	String()	把对象的值转换为字符串。

四，Canvas——API
	fillStyle	设置或返回用于填充绘图的颜色、渐变或图案。
	strokeStyle	设置或返回用于笔划的颜色、渐变或图案。
	shadowColor	设置或返回用于阴影的颜色。
	shadowBlur	设置或返回阴影的模糊级别。
	shadowOffsetX	设置或返回阴影到形状的水平距离。
	shadowOffsetY	设置或返回阴影到形状的垂直距离。
	createLinearGradient()	创建线性渐变（用于画布内容）。
	createPattern()	在指定方向重复指定的元素。
	createRadialGradient()	创建径向/圆形渐变（用于画布内容）。
	addColorStop()	规定渐变对象中的颜色和停止位置。
	lineCap	设置或返回线的端盖样式。
	lineJoin	设置或返回两条线相交时创建的角的类型。
	lineWidth	设置或返回当前线宽。
	miterLimit	设置或返回最大斜接长度。
	rect()	创建矩形。
	fillRect()	绘制“填充的”矩形。
	strokeRect()	绘制矩形（无填充）。
	clearRect()	清除给定矩形内的指定像素。
	fill()	填充当前图形（路径）。
	stroke()	实际上绘制您定义的路径。
	beginPath()	开始路径，或重置当前路径。
	moveTo()	将路径移动到画布中的指定点，而不创建线。
	closePath()	创建从当前点返回起点的路径。
	lineTo()	添加一个新点并创建一条从该点到画布中最后一个指定点的线。
	clip()	从原始画布中剪裁任意形状和大小的区域。
	quadraticCurveTo()	创建二次贝塞尔曲线。
	bezierCurveTo()	创建三次贝塞尔曲线。
	arc()	创建圆弧/曲线（用于创建圆或圆的一部分）。
	arcTo()	在两条切线之间创建圆弧/曲线。
	isPointInPath()	如果指定点在当前路径中，则返回 true，否则返回 false。
	scale()	放大或缩小当前图形。
	rotate()	旋转当前图形。
	translate()	重新映射画布上的 (0,0) 位置。
	transform()	替换绘图的当前转换矩阵。
	setTransform()	将当前转换重置为单位矩阵。然后运行 transform()。
	font	设置或返回文本内容的当前字体属性。
	textAlign	设置或返回文本内容的当前对齐方式。
	textBaseline	设置或返回绘制文本时使用的当前文本基线。
	fillText()	在画布上绘制“填充”文本。
	strokeText()	在画布上绘制文本（无填充）。
	measureText()	返回包含指定文本宽度的对象。
	drawImage()	在画布上绘制图像、画布或视频。
	width	返回 ImageData 对象的宽度。
	height	返回 ImageData 对象的高度。
	data	返回包含指定 ImageData 对象的图像数据的对象。
	createImageData()	创建新的空白 ImageData 对象。
	getImageData()	返回 ImageData 对象，该对象复制画布上指定矩形的像素数据。
	putImageData()	将图像数据（来自指定的 ImageData 对象）放回画布上。
	globalAlpha	设置或返回绘图的当前 alpha 或透明度值。
	globalCompositeOperation	设置或返回如何将新图像绘制到现有图像上。
	save()	保存当前上下文的状态。
	restore()	返回之前保存的路径状态和属性。

==============================
Tolua C# 插件升级到 Lua 5.3 修改指南
==============================

1. Lua 库引用修改
-------------------
- 替换 Lua 5.1 动态库为 Lua 5.3

示例：
// Lua 5.1
[DllImport("lua51")]
// Lua 5.3
[DllImport("lua53")]

注意事项：
- Windows: lua53.dll
- macOS / Linux: liblua5.3.so 或 liblua5.3.dylib
- 确保路径和库文件正确

2. 整数类型修改
-----------------
- Lua 5.3 引入 lua_Integer 与 lua_Number 区分

示例：
// Lua 5.1
int val = LuaDLL.luaL_checkint(L, idx);
// Lua 5.3
long val = LuaDLL.luaL_checkinteger(L, idx);

API 替换表：
Lua 5.1 API       -> Lua 5.3 API           -> C# 类型建议
luaL_checkint     -> luaL_checkinteger     -> long
luaL_optint       -> luaL_optinteger       -> long

- 浮点数仍使用 double 对应 lua_Number

3. 栈操作函数修改
------------------
- Lua 5.3 替换 lua_objlen → lua_rawlen

示例：
// Lua 5.1
uint len = LuaDLL.lua_objlen(L, idx);
// Lua 5.3
ulong len = LuaDLL.lua_rawlen(L, idx)

- 所有字符串和表长度获取处都需要修改

4. Tolua 绑定生成部分修改（tolua.lua）
---------------------------------------
- 使用 Lua 5.3 的 tolua.lua 重新生成 C++ 绑定
- 替换模板中不兼容的 API：
  - lua_objlen → lua_rawlen
  - luaL_checkint → luaL_checkinteger
  - luaL_optint → luaL_optinteger
- 确认整数类型映射正确（lua_Integer 对应 C++ long / int64）
- 可选：添加 Lua 5.3 新增函数绑定，如：
tolua_beginmodule(L,"string")
tolua_function(L,"pack",string.pack)
tolua_function(L,"unpack",string.unpack)
tolua_function(L,"packsize",string.packsize)
tolua_endmodule(L)

5. 错误处理与其他 API
-----------------------
- 常用 API 保持不变：
  - lua_pcall
  - luaL_error
  - lua_settop
- 注意整数与浮点数类型匹配，防止溢出或类型错误

6. 升级步骤总结
-----------------
1. 替换 Lua 5.3 库和头文件
2. 修改 C# DllImport 指向 Lua 5.3
3. 替换整数相关 API：
   - luaL_checkint → luaL_checkinteger
   - luaL_optint → luaL_optinteger
   - C# 类型 int → long
4. 替换字符串 / 表长度函数：
   - lua_objlen → lua_rawlen
5. 重新生成 tolua C++ 绑定代码
6. 可选：绑定 Lua 5.3 新函数（如 string.pack）
7. 编译 C++ 绑定和 C# 工程
8. 测试整数、字符串、新函数调用是否正常

7. 注意事项
-------------
- 确保 Lua 版本与绑定代码一致
- 不要直接替换 Lua 5.1 DLL/so，必须重新编译绑定
- 绑定代码和 C# 代码需要同步修改类型和 API
- 测试整数、浮点、字符串长度以及 Lua 5.3 新增函数

==============================
End of Tolua C# Lua 5.3 Upgrade Guide
==============================

```C#

using System;
using System.Runtime.InteropServices;

public static class LuaDLL
{
    // --------------------------
    // Lua 5.3 DLL 引用
    // --------------------------
#if UNITY_STANDALONE_WIN || UNITY_EDITOR_WIN
    public const string LUA_DLL = "lua53";  // Windows
#else
    public const string LUA_DLL = "lua5.3"; // macOS / Linux
#endif

    // --------------------------
    // 核心 Lua API
    // --------------------------
    [DllImport(LUA_DLL, CallingConvention = CallingConvention.Cdecl)]
    public static extern int luaL_checkinteger(IntPtr L, int idx);

    [DllImport(LUA_DLL, CallingConvention = CallingConvention.Cdecl)]
    public static extern int luaL_optinteger(IntPtr L, int idx, int def);

    [DllImport(LUA_DLL, CallingConvention = CallingConvention.Cdecl)]
    public static extern double lua_tonumber(IntPtr L, int idx);

    [DllImport(LUA_DLL, CallingConvention = CallingConvention.Cdecl)]
    public static extern long lua_tointeger(IntPtr L, int idx);

    [DllImport(LUA_DLL, CallingConvention = CallingConvention.Cdecl)]
    public static extern ulong lua_rawlen(IntPtr L, int idx);

    [DllImport(LUA_DLL, CallingConvention = CallingConvention.Cdecl)]
    public static extern void lua_settop(IntPtr L, int idx);

    [DllImport(LUA_DLL, CallingConvention = CallingConvention.Cdecl)]
    public static extern int lua_pcallk(IntPtr L, int nargs, int nresults, int errfunc, IntPtr ctx, IntPtr k);

    [DllImport(LUA_DLL, CallingConvention = CallingConvention.Cdecl)]
    public static extern void luaL_error(IntPtr L, string msg);

    // --------------------------
    // Lua 5.3 新增整数 API
    // --------------------------
    [DllImport(LUA_DLL, CallingConvention = CallingConvention.Cdecl)]
    public static extern long lua_tointegerx(IntPtr L, int idx, out int isnum);

    [DllImport(LUA_DLL, CallingConvention = CallingConvention.Cdecl)]
    public static extern double lua_tonumberx(IntPtr L, int idx, out int isnum);

    [DllImport(LUA_DLL, CallingConvention = CallingConvention.Cdecl)]
    public static extern void lua_integer2number(IntPtr L, int idx);

    // --------------------------
    // Lua 5.3 新增字符串函数
    // 需要在 tolua C++ 绑定生成时支持
    // --------------------------
    [DllImport(LUA_DLL, CallingConvention = CallingConvention.Cdecl)]
    public static extern IntPtr string_pack(IntPtr L);

    [DllImport(LUA_DLL, CallingConvention = CallingConvention.Cdecl)]
    public static extern IntPtr string_unpack(IntPtr L);

    [DllImport(LUA_DLL, CallingConvention = CallingConvention.Cdecl)]
    public static extern int string_packsize(IntPtr L);

    // --------------------------
    // Lua 5.3 新增数学函数
    // --------------------------
    [DllImport(LUA_DLL, CallingConvention = CallingConvention.Cdecl)]
    public static extern long math_tointeger(double n);

    [DllImport(LUA_DLL, CallingConvention = CallingConvention.Cdecl)]
    public static extern int math_type(double n); // 返回 0=number,1=integer
}


public class LuaHelper
{
    // --------------------------
    // 示例：获取整数
    // --------------------------
    public static long GetInteger(IntPtr L, int idx)
    {
        return LuaDLL.luaL_checkinteger(L, idx);
    }

    // --------------------------
    // 示例：获取浮点数
    // --------------------------
    public static double GetNumber(IntPtr L, int idx)
    {
        return LuaDLL.lua_tonumber(L, idx);
    }

    // --------------------------
    // 示例：获取字符串长度
    // --------------------------
    public static ulong GetStringLength(IntPtr L, int idx)
    {
        return LuaDLL.lua_rawlen(L, idx);
    }

    // --------------------------
    // 示例：调用 Lua 函数（保护调用）
    // --------------------------
    public static void CallLuaFunction(IntPtr L, int nargs, int nresults)
    {
        int err = LuaDLL.lua_pcallk(L, nargs, nresults, 0, IntPtr.Zero, IntPtr.Zero);
        if (err != 0)
        {
            LuaDLL.luaL_error(L, "Lua function call failed");
        }
    }
}

// --------------------------
// 可选：绑定 Lua 5.3 新函数示例
// --------------------------
public static class LuaStringExtensions
{
    [DllImport(LuaDLL.LUA_DLL, CallingConvention = CallingConvention.Cdecl)]
    public static extern IntPtr string_pack(IntPtr L); // 需要在绑定生成时添加

    [DllImport(LuaDLL.LUA_DLL, CallingConvention = CallingConvention.Cdecl)]
    public static extern IntPtr string_unpack(IntPtr L);

    [DllImport(LuaDLL.LUA_DLL, CallingConvention = CallingConvention.Cdecl)]
    public static extern int string_packsize(IntPtr L);
}
```
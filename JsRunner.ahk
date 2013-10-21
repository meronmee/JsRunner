#Persistent
#SingleInstance force

;变量
;SplitPath, A_ScriptFullPath, , , , name_no_ext
AppName = JsRunner
configFile = %A_ScriptDir%\%AppName%.ini

;命令行参数运行模式
CmdParamCount = %0% ;取变量0的内容

if CmdParamCount
{
	GoSub, RunJs
}
else
{
	GoSub, Init
}
Return

;初始化
Init:
	IniRead, IsFirst, %configFile%, Config, IsFirst, ERROR
	if IsFirst = ERROR
	{
		IsFirst = true
	}
	else if (IsFirst == "true") || (IsFirst == 1) || (IsFirst == "yes")
	{
	
		IsFirst = true
	}
	else
	{
		;不是第一次第一次执行， 退出脚本
		IsFirst = false
		ExitApp
	}
	;检查node.exe路径配置的是否正确
	GoSub, CheckNodePath
	if NodePath = ERROR
	{
		MsgBox, 48, 警告, 请先在 %configFile% 中配置 NodePath 为 node.exe 的完整路径,然后再运行本程序！
		;配置错误，退出程序
		ExitApp
	}
	
	;更新配置
	IniWrite, false, %configFile%, Config, IsFirst
	
	;将关联文件类型
	KeyValue = "%A_ScriptFullPath%" "`%1"
	RegWrite, REG_SZ, HKEY_LOCAL_MACHINE, SOFTWARE\Classes\JSFile\Shell\Open\command, ,%KeyValue%

	MsgBox, 64, 成功, 关联 .js 文件类型成功！`n以后双击 js 文件可以直接使用 Node 执行之。
	ExitApp
Return

;命令行带参数运行JS脚本
RunJs:
	;检查node.exe路径配置的是否正确
	GoSub, CheckNodePath
	if NodePath = ERROR
	{
		MsgBox, 48, 警告, 请先在 %configFile% 中配置 NodePath 为 node.exe 的完整路径！
		;配置错误，退出程序
		ExitApp
	}
	
	;运行
	Loop, %0%  ; For each parameter:
	{
	       ;Ahk2exe.exe /in MyScript.ahk [/out MyScript.exe][/icon MyIcon.ico][/pass password][/NoDecompile]        
		param := %A_Index%  ; Fetch the contents of the variable whose name is contained in A_Index.
		;MsgBox,%A_Index%：%param%
		if (A_Index = 1)
		{
			   InFile := param
			   IfNotExist, %InFile%
			   {
					Return
			   }
			   SplitPath, InFile, name, dir, ext, name_no_ext
			   if (ext != "js")
			   {
					;Return
			   }
			  
			   ;用Node运行Js脚本
			   Run, %comspec% /k ""%NodePath%" "%InFile%"", %dir%
			   ;执行完成，退出程序
			   ExitApp
		}
	}
	ExitApp
Return

;检查node.exe路径配置的是否正确
CheckNodePath:
	IniRead, NodePath, %configFile%, Config, NodePath, ERROR
	if NodePath = ERROR
	{
	
	}
	else IfNotExist, %NodePath%
	{
		NodePath = ERROR
	}
	else
	{
		;SplitPath, NodePath, , , , name_no_ext
		FileGetAttrib, Attributes, %NodePath%
		IfInString, Attributes, D ;文件夹
		{
			IfNotExist, %NodePath%\node.exe
			{
				NodePath = ERROR
			}
			else
			{
				NodePath = %NodePath%\node.exe 
			}
		}
	}	
Return



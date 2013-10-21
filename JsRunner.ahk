#Persistent
#SingleInstance force

;����
;SplitPath, A_ScriptFullPath, , , , name_no_ext
AppName = JsRunner
configFile = %A_ScriptDir%\%AppName%.ini

;�����в�������ģʽ
CmdParamCount = %0% ;ȡ����0������

if CmdParamCount
{
	GoSub, RunJs
}
else
{
	GoSub, Init
}
Return

;��ʼ��
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
		;���ǵ�һ�ε�һ��ִ�У� �˳��ű�
		IsFirst = false
		ExitApp
	}
	;���node.exe·�����õ��Ƿ���ȷ
	GoSub, CheckNodePath
	if NodePath = ERROR
	{
		MsgBox, 48, ����, ������ %configFile% ������ NodePath Ϊ node.exe ������·��,Ȼ�������б�����
		;���ô����˳�����
		ExitApp
	}
	
	;��������
	IniWrite, false, %configFile%, Config, IsFirst
	
	;�������ļ�����
	KeyValue = "%A_ScriptFullPath%" "`%1"
	RegWrite, REG_SZ, HKEY_LOCAL_MACHINE, SOFTWARE\Classes\JSFile\Shell\Open\command, ,%KeyValue%

	MsgBox, 64, �ɹ�, ���� .js �ļ����ͳɹ���`n�Ժ�˫�� js �ļ�����ֱ��ʹ�� Node ִ��֮��
	ExitApp
Return

;�����д���������JS�ű�
RunJs:
	;���node.exe·�����õ��Ƿ���ȷ
	GoSub, CheckNodePath
	if NodePath = ERROR
	{
		MsgBox, 48, ����, ������ %configFile% ������ NodePath Ϊ node.exe ������·����
		;���ô����˳�����
		ExitApp
	}
	
	;����
	Loop, %0%  ; For each parameter:
	{
	       ;Ahk2exe.exe /in MyScript.ahk [/out MyScript.exe][/icon MyIcon.ico][/pass password][/NoDecompile]        
		param := %A_Index%  ; Fetch the contents of the variable whose name is contained in A_Index.
		;MsgBox,%A_Index%��%param%
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
			  
			   ;��Node����Js�ű�
			   Run, %comspec% /k ""%NodePath%" "%InFile%"", %dir%
			   ;ִ����ɣ��˳�����
			   ExitApp
		}
	}
	ExitApp
Return

;���node.exe·�����õ��Ƿ���ȷ
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
		IfInString, Attributes, D ;�ļ���
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



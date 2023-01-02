/*Online Help*/


MODULE  'lowlevel',
        'libraries/lowlevel',
        'reqtools',
        'libraries/reqtools',
        'tools/ttparse_oo'

CONST DEFHOT=$5F, DEFQUIT=$59

DEF req:PTR TO rtfilerequester,
    html[300]:STRING,
    guide[300]:STRING,
    txt[300]:STRING,
    opendir[300]:STRING,
    s,
    quitkey,
    hotkey

PROC main()
DEF ttype:PTR TO ttparse


NEW ttype.ttparse(TRUE)

IF ttype.error()
    StrCopy(guide,'SYS:UTILITIES/MULTIVIEW')
    StrCopy(html,'SYS:UTILITIES/MULTIVIEW')
    StrCopy(txt,'SYS:UTILITIES/MULTIVIEW')
    StrCopy(opendir,'HELP:')
    quitkey:=DEFQUIT
    hotkey:=DEFHOT
ELSE

    IF (s:=ttype.get('GUIDE'))<>0
        StrCopy(guide,s)
    ELSE
        StrCopy(guide,'SYS:UTILITIES/MULTIVIEW')
    ENDIF

    IF (s:=ttype.get('DIR'))<>0
        StrCopy(opendir,s)
    ELSE
        StrCopy(opendir,'HELP:')
    ENDIF

    IF (s:=ttype.get('HTML'))<>0
        StrCopy(html,s)
    ELSE
        StrCopy(html,'SYS:UTILITIES/MULTIVIEW')
    ENDIF

    IF (s:=ttype.get('TXT'))<>0
        StrCopy(txt,s)
    ELSE
        StrCopy(txt,'SYS:UTILITIES/MULTIVIEW')
    ENDIF

    IF (s:=ttype.get('QUIT'))<>0
        quitkey:=hotkeys()
    ELSE
        quitkey:=DEFQUIT
    ENDIF


    IF (s:=ttype.get('HOTKEY'))<>0
        hotkey:=hotkeys()
    ELSE
        hotkey:=DEFHOT
    ENDIF

ENDIF

END ttype

beginloop()
CleanUp()
ENDPROC


PROC beginloop()

DEF key,
quit

quit:=50
key:=NIL

IF (reqtoolsbase:=OpenLibrary('reqtools.library',38))<>NIL
    IF (lowlevelbase:=OpenLibrary('lowlevel.library',40))<>NIL

        req:=RtAllocRequestA(RT_FILEREQ,NIL)

        REPEAT
            WaitTOF()
            key:=GetKey()
            IF key=hotkey THEN select()
            IF key=quitkey THEN quit:=RtEZRequestA('Quit Multihelp 0.95?','Yes|No',NIL,NIL,NIL)
        UNTIL quit=1

        CloseLibrary(lowlevelbase)

    ELSE
        PrintF('Unable to open lowlevel.library V40+\n')
    ENDIF

    RtFreeRequest(req)
    CloseLibrary(reqtoolsbase)

ELSE
    PrintF('Unable to open reqtools.library V38+\n')
ENDIF

ENDPROC


PROC select()
DEF ret,
    exestr[200]:STRING,
    document[250]:STRING,
    path[250]:STRING,
    len

RtChangeReqAttrA(req,[RTFI_DIR,opendir,NIL,NIL])
ret:=RtFileRequestA(req,document,'Choose Document',[RTFI_FLAGS,FREQF_PATGAD,NIL,NIL])

IF ret<>FALSE

    StrCopy(path,req.dir,ALL)
    len:=StrLen(path)
    IF path[len-1] <>58
        IF path[len-1]<>47
            StrAdd(path,'/',ALL)
        ENDIF
    ENDIF

    IF InStr(document,'.guide',0)>NIL
        StringF(exestr,'run \s \s\s',guide,path,document)
    ELSEIF InStr(document,'.htm',0)>NIL
        StringF(exestr,'run \s file://localhost/\s\s',html,path,document)
    ELSE
        StringF(exestr,'run \s \s\s',txt,path,document)
    ENDIF

    Execute(exestr,NIL,NIL)

ELSE
->No File Selected
ENDIF


ENDPROC

PROC hotkeys()
DEF value

IF InStr(s,'F10',0)>-1
    value:=$59
ELSEIF InStr(s,'F9',0)>-1
    value:=$58
ELSEIF InStr(s,'F8',0)>-1
    value:=$57
ELSEIF InStr(s,'F7',0)>-1
    value:=$56
ELSEIF InStr(s,'F6',0)>-1
    value:=$55
ELSEIF InStr(s,'F5',0)>-1
    value:=$54
ELSEIF InStr(s,'F4',0)>-1
    value:=$53
ELSEIF InStr(s,'F3',0)>-1
    value:=$52
ELSEIF InStr(s,'F2',0)>-1
    value:=$51
ELSEIF InStr(s,'F1',0)>-1
    value:=$50
ELSEIF InStr(s,'HELP',0)>-1
    value:=$5F
ENDIF

ENDPROC value



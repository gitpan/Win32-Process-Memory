#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

MODULE = Win32::Process::Memory		PACKAGE = Win32::Process::Memory		

int
OpenByPid(nPid, nDesiredAccess)
	int nPid
	int nDesiredAccess
 CODE:
	RETVAL = (int)OpenProcess((DWORD)nDesiredAccess, 0, (DWORD)nPid);
 OUTPUT:
	RETVAL

int
CloseProcess(hProcess)
	int hProcess
 CODE:
	RETVAL = (int)CloseHandle((HANDLE)hProcess);
 OUTPUT:
	RETVAL

int
ReadMemory(hProcess, nOffset, sv, nLen)
	int hProcess
	int nOffset
	SV *sv
	int nLen
 PREINIT:
	SIZE_T nBytesRead;
 CODE:
	SvUPGRADE(sv, SVt_PV);
	SvUTF8_off(sv);
	SvGROW(sv, (STRLEN)nLen);
	if( !ReadProcessMemory((HANDLE)hProcess, (LPCVOID)nOffset,
		(LPVOID)SvPV_nolen(sv), (SIZE_T)nLen, &nBytesRead) ) { /* Fail */
		nBytesRead=0;
	}
	SvCUR_set(sv, (STRLEN)nBytesRead);
	SvPOK_on(sv);
	RETVAL = (int)nBytesRead;
 OUTPUT:
    sv
    RETVAL

int
WriteMemory(hProcess, nOffset, sv, nLen)
	int hProcess
	int nOffset
	SV *sv
	int nLen
 PREINIT:
	SIZE_T nBytesWrite;
 CODE:
	if( !WriteProcessMemory((HANDLE)hProcess, (LPVOID)nOffset,
		(LPCVOID)SvPV_nolen(sv), (SIZE_T)nLen, &nBytesWrite) ) { /* Fail */
		nBytesWrite=0;
	}
	RETVAL = (int)nBytesWrite;
 OUTPUT:
    RETVAL

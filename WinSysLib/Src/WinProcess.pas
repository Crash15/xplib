{$IFDEF WinProcess}
	{$DEFINE DEBUG_UNIT}
{$ENDIF}
{$I WinSysLib.inc}

unit WinProcess;

interface

uses
    Classes, SysUtils;

type
    TUserMachineScope = (umsAllUsers, umsCurrent, umsLocalService, umsSystem, umsNetworkService);

    TProcessMemoryInfo = record
        PhysicalMemoryUsage:     Integer;
        VirtualMemoryUsage:      Integer;
        PeakPhysicalMemoryUsage: Integer;
        PeakVirtualMemoryUsage:  Integer;
        PageFaultCount:          Integer;
    end;

    TWinApp = class
    private
        class function GetInstalledAppsAllUsers(List : TStrings) : Integer;
    public
        class function GetInstalledApps(Scope : TUserMachineScope; List : TStrings) : Integer;
    end;

function GetProcessMemoryInfo(PID : cardinal) : TProcessMemoryInfo;
function GetProcessCPUTime(PID : cardinal) : int64;
function GetProcessCPUUsagePerc(PID : cardinal; Interval : Integer) : Integer;
function GetProcessStartTime(PID : cardinal) : TDateTime;


implementation

uses
    psapi, Windows, FileHnd, WinReg32;


function GetProcessMemoryInfo(PID : cardinal) : TProcessMemoryInfo;
    //----------------------------------------------------------------------------------------------------------------------------------
    // retorna um record com informa��es de uso de mem�ria (f�sica e virtual), pico de uso de mem�ria e falhas de p�gina.
var
    myHandle :   THandle;
    MemoryInfo : psapi.TProcessMemoryCounters;
begin
    // Abre um handle para o processo...
    myHandle := OpenProcess(PROCESS_ALL_ACCESS, False, PID);
    // Pega as informa��es de mem�ria...
    try
        psapi.GetProcessMemoryInfo(myHandle, @MemoryInfo, SizeOf(MemoryInfo));
        Result.PhysicalMemoryUsage := MemoryInfo.WorkingSetSize;
        Result.VirtualMemoryUsage := MemoryInfo.PagefileUsage;
        Result.PeakPhysicalMemoryUsage := MemoryInfo.PeakWorkingSetSize;
        Result.PeakVirtualMemoryUsage := MemoryInfo.PeakPagefileUsage;
        Result.PageFaultCount := MemoryInfo.PageFaultCount;
    finally
        // Fecha o handle do processo...
        CloseHandle(myHandle);
    end;
end;


function GetProcessCPUTime2(PID : cardinal) : int64;
    //----------------------------------------------------------------------------------------------------------------------------------
    // Retorna o tempo de processador que o processo usou desde a sua inicializa��o em unidades de nanosegundos.
var
    myHandle : THandle;
    CreationTime, ExitTime, UserTime, KernelTime : TFileTime;
    Kernel64, User64 : int64;
begin
    // zera as vari�veis para evitar que fiquem com lixo...
    KernelTime.dwHighDateTime := 0;
    KernelTime.dwLowDateTime  := 0;
    UserTIme.dwLowDateTime    := 0;
    UserTime.dwHighDateTime   := 0;

    // Abre um handle para o processo...
    myHandle := OpenProcess(PROCESS_QUERY_INFORMATION, False, PID);
    try
        // Pega as informa��es de tempo...
        GetProcessTimes(myHandle, CreationTime, ExitTime, KernelTime, UserTime);

        // Calcula os valores de tempo do kernel e user compondo os dois bytes 32 bits para um de 64 bits.
        Kernel64 := KernelTime.dwHighDateTime;
        Kernel64 := (Kernel64 shl 32) + KernelTime.dwLowDateTime;
        User64   := UserTime.dwHighDateTime;
        User64   := (User64 shl 32) + UserTime.dwLowDateTime;

        Result := (Kernel64 + User64);
    finally
        // Fecha o handle do processo...
        CloseHandle(myHandle);
    end;
end;


function GetProcessCPUTime(PID : cardinal) : int64;
    //----------------------------------------------------------------------------------------------------------------------------------
    // Retorna o tempo de processador que o processo usou desde a sua inicializa��o em milisegundos.
begin
    Result := GetProcessCPUTime2(PID) div 10000; // Transforma unidades de 100 nanosegundos em milisegundos.
end;


function GetProcessCPUUsagePerc(PID : cardinal; Interval : Integer) : Integer;
    //----------------------------------------------------------------------------------------------------------------------------------
    // Retorna o percentual de utiliza��o de CPU do processo identificado por PID nos pr�ximos Interval milesegundos.
var
    InitValue, FinalValue : int64;
begin
    InitValue := GetProcessCPUTime2(PID);
    Sleep(Interval);
    FinalValue := GetProcessCPUTime2(PID);
    //%    //Acha a dif. no tempo  // Transforma o intervalo passado em unidades de 100 nanosegundos
    Result     := 100 * (FinalValue - InitValue) div (Interval * 10000);
end;


function GetProcessStartTime(PID : cardinal) : TDateTime;
    //------------------------------------------------------------------------------------------------------------------------
    // Retorna a um TdateTime contendo a data e a hora que o processo foi startado. Recebe o PID do Processo
var
    myHandle : THandle;
    CreationTime, ExitTime, UserTime, KernelTime : TFileTime;
    ProcSystemTime : TSystemTime;

begin
    // zera as vari�veis para evitar que fiquem com lixo...
    CreationTime.dwLowDateTime  := 0;
    CreationTime.dwHighDateTime := 0;

    // Abre um handle para o processo...
    myHandle := OpenProcess(PROCESS_QUERY_INFORMATION, False, PID);
    try
        // Pega as informa��es de tempo...
        GetProcessTimes(myHandle, CreationTime, ExitTime, KernelTime, UserTime);

        // Converte um TFileTime em TSystemTime...
        FileTimeToSystemTime(CreaTionTime, ProcSystemTime);

        // Retorna um TDateTime...
        Result := SystemTimeToDateTime(ProcSystemTime);
    finally
        // Fecha o handle do processo...
        CloseHandle(myHandle);
    end;
end;


class function TWinApp.GetInstalledApps(Scope : TUserMachineScope; List : TStrings) : Integer;
begin
    case Scope of
        umsAllUsers : begin
            Result := GetInstalledAppsAllUsers(List);
        end;
        else begin
            raise Exception.Create('Opera��o n�o suportada para este escopo de usu�rio.');
        end;
    end;
end;

class function TWinApp.GetInstalledAppsAllUsers(List : TStrings) : Integer;
{
Rotina retorna lista com aplicativos instalados no computador para todos os usu�rios, para montar a lista completa deve-se
usar o mesmo caminho para HKEY_CURRENT_USER e para todos os us�rios isoladamente
DICA: Varrer m�todo mais gen�rico de realizar esta carga

}
const
    UNINST_ROOT = 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall';
var
    I :     Integer;
    reg :   TRegistryNT;
    keyList : TStringList;
    entry : string;
begin
	 try
		 reg := TRegistryNT.Create;
		 try
			 reg.OpenFullKey(UNINST_ROOT, False);
            keyList := TStringList.Create;
            try
                reg.GetKeyNames(keyList);
                for I := 0 to keyList.Count - 1 do begin
                    if (reg.ReadFullString(TFileHnd.ConcatPath([UNINST_ROOT, keyList.Strings[I], 'DisplayName']), entry))
                    then begin
                        list.Add(entry);
                    end;
                end;
                Result := ERROR_SUCCESS;
            finally
                keyList.Free;
            end;
        finally
            reg.Free;
        end;
    except
        Result := ERROR_ACCESS_DENIED;
    end;
end;

end.

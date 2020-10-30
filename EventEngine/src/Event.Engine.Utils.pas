unit Event.Engine.Utils;

interface

uses
{$IFDEF MSWINDOWS}
  Winapi.Windows,
{$ENDIF}
  System.SysUtils,

  Spring,

  Event.Engine.Interfaces;

type
  Utils = record
  private
    class var Reference: TStopwatch;

    class procedure CreateIni; static;
  public
    class function CreateEvent<T>: IEvent<T>; static;
{$IFDEF MSWINDOWS}
    class procedure IdeDebugMsg(const AMsg: String); static;
{$ENDIF}
    class function iif<T>(const ACondition: Boolean; AResult_True, AResult_False: T): T; overload; static;
    class function iif<T>(const ACondition: Boolean; AResult_True, AResult_False: TFunc<T>): T; overload; static;
    class function StringToCaseSelect(const Selector: string; const CaseList: array of string): integer; static;
    class function InterfaceToCaseSelect(Selector: IInterface; const CaseList: array of TGUID): integer; static;
    class function IsMainThreadUI: Boolean; static;

    class procedure DelegateExecution(AProc: TProc; AExecutionMode: EDelegatedExecutionMode); overload; static;
    class procedure DelegateExecution<T>(AData: T; AProc: TProc<T>; AExecutionMode: EDelegatedExecutionMode); overload; static;

    class function ElapsedMiliseconds: Int64; static;
    class function ElapsedTicks: Int64; static;
    class function GetTimeStamp: Int64; static;
    class function Elapsed: TTimeSpan; static;
    class function GetReferenceTime: Double; static;
  end;

implementation

uses
  System.Classes,
  System.Threading;

{ Utils }

class function Utils.CreateEvent<T>: IEvent<T>;
var
  E: Event<T>;
begin
  Result := E;
end;

class procedure Utils.CreateIni;
begin
  Reference             := TStopwatch.Create;
  Reference.Start;
end;

class procedure Utils.DelegateExecution(AProc: TProc; AExecutionMode: EDelegatedExecutionMode);
begin
  case AExecutionMode of
    medQueue:
      begin
        TThread.Queue(TThread.CurrentThread,
          procedure
          begin
            AProc;
          end);
      end;
    medSynchronize:
      begin
        TThread.Synchronize(TThread.CurrentThread,
          procedure
          begin
            AProc
          end);
      end;
    medNewTask:
      begin
        TTask.Create(
          procedure
          begin
            AProc
          end).Start;
      end;
    medNormal:
      begin
        AProc;
      end;
  end;
end;

class procedure Utils.DelegateExecution<T>(AData: T; AProc: TProc<T>; AExecutionMode: EDelegatedExecutionMode);
begin
  case AExecutionMode of
    medQueue:
      begin
        TThread.Queue(TThread.CurrentThread,
          procedure
          begin
            AProc(AData);
          end);
      end;
    medSynchronize:
      begin
        TThread.Synchronize(TThread.CurrentThread,
          procedure
          begin
            AProc(AData)
          end);
      end;
    medNewTask:
      begin
        TTask.Create(
          procedure
          begin
            AProc(AData)
          end).Start;
      end;
    medNormal:
      begin
        AProc(AData);
      end;
  end;
end;

class function Utils.Elapsed: TTimeSpan;
begin
  Result := Reference.Elapsed;
end;

class function Utils.ElapsedMiliseconds: Int64;
begin
  Result := Reference.ElapsedMilliseconds;
end;

class function Utils.ElapsedTicks: Int64;
begin
  Result := Reference.ElapsedTicks;
end;

class function Utils.GetReferenceTime: Double;
begin
  Result := TStopwatch.GetTimeStamp / TStopwatch.Frequency;
end;

class function Utils.GetTimeStamp: Int64;
begin
  Result := Reference.GetTimeStamp
end;

{$IFDEF MSWINDOWS}
class procedure Utils.IdeDebugMsg(const AMsg: String);
begin
  OutputDebugString(PChar(FormatDateTime('hhnnss.zzz', Now) + AMsg));
end;
{$ENDIF}

class function Utils.iif<T>(const ACondition: Boolean; AResult_True, AResult_False: TFunc<T>): T;
begin
  if ACondition then
    Result := AResult_True
  else
    Result := AResult_False;
end;

class function Utils.iif<T>(const ACondition: Boolean; AResult_True, AResult_False: T): T;
begin
  if ACondition then
    Result := AResult_True
  else
    Result := AResult_False;
end;

class function Utils.InterfaceToCaseSelect(Selector: IInterface; const CaseList: array of TGUID): integer;
var
  LCnt: integer;
begin
  Result   := -1;
  for LCnt := 0 to Length(CaseList) - 1 do
  begin
    if Supports(Selector, CaseList[LCnt]) then
    begin
      Result := LCnt;
      break;
    end;
  end;
end;

class function Utils.IsMainThreadUI: Boolean;
begin
  Result := TThread.Current.ThreadID = MainThreadID;
end;

class function Utils.StringToCaseSelect(const Selector: string; const CaseList: array of string): integer;
var
  LCnt: integer;
begin
  Result   := -1;
  for LCnt := 0 to Length(CaseList) - 1 do
  begin
    if CompareText(Selector, CaseList[LCnt]) = 0 then
    begin
      Result := LCnt;
      break;
    end;
  end;
end;

end.

unit DPN.Core.Scheduler;

interface

uses
  System.Classes,
  System.SyncObjs,
  System.Generics.Defaults,

  Spring.Collections,

  Helper.ThreadedQueue,
  Event.Engine.Interfaces;

type
  TCallBackTimer = reference to procedure;

  TEventsScheduler = class sealed(TThread)
  const
    CTE_INITIAL_QUEUE_SIZE = 10;
    CTE_PUSH_TIMEOUT       = 100;
  private
    FIndex              : Int64;
    FSC                 : TSpinLock;
    FTaskQueue          : TThreadedQueue<ISchedulerTask>;
    FColaOrdenesEliminar: TThreadedQueue<Int64>;
    FTaskList           : IList<ISchedulerTask>;
    FComparer           : IComparer<ISchedulerTask>;

    FTaskListToRemove: IList<ISchedulerTask>;

    procedure Execute; override;

    function Checks: Boolean;
    procedure RecalcScheduling;
    function GetIndex: Int64;

    procedure DoScheduling;

    function GetNewTask(out AQueueSize: Integer; out ATask: ISchedulerTask): TWaitResult; overload;
    function GetNewTask(out AQueueSize: Integer; out ATask: ISchedulerTask; const ATimeOut: Cardinal): TWaitResult; overload;

  public
    constructor Create;
    destructor Destroy; override;

    function SetTimer(const AAvisarCuandoPasenMilisegundos: Int64; const ACallBack: TCallBackTimer): Int64;
    function RemoveTimer(const ATimerID: Int64): Boolean;
  end;

implementation

uses
  System.SysUtils,
  System.DateUtils,

  Event.Engine,
  Event.Engine.Utils;
type

  TSchedulerTask = class sealed(TInterfacedObject, ISchedulerTask)
  private
    FTaskID                     : Int64;
    FTimeStampCreation          : Int64;
    FTimeStampAwake             : Int64;
    FMilisecondsToAwake         : Int64;
    FIsDone                     : Boolean;
    FCallBack                   : TCallBackTimer;

    function GetTaskID: Int64;
    function GetMilisecondsToAwake: Int64;

    procedure CalculateAwakeTime;
    procedure Notify;
  public
    constructor Create(const ATaskID: Int64; const AEllapsedMilisecondsToExecute: Int64; const ACallBack: TCallBackTimer); overload;
    destructor Destroy; override;

    function IsDone: Boolean;
    function CheckAndNotify: Boolean;

    property TaskID: Int64 read GetTaskID;
    property MilisecondsToAwake: Int64 read GetMilisecondsToAwake;
  end;

{ TEventsScheduler }

function TEventsScheduler.Checks: Boolean;
var
  LTask: ISchedulerTask;
begin
  Result := False;
  if FTaskList.Count <> 0 then
  begin
    FTaskListToRemove.Clear;
    for LTask in FTaskList do
    begin
      if LTask.CheckAndNotify then
      begin
        Result := True;
      end;
      if LTask.IsDone then
      begin
        Result := True;
        FTaskListToRemove.Add(LTask);
      end;
    end;
    for LTask in FTaskListToRemove do
    begin
      FTaskList.Remove(LTask);
    end;
    FTaskListToRemove.Clear;
    if (Result) then
    begin
      if FTaskList.Count = 0 then
      begin
        Result := False;
      end
    end;
  end;
end;

constructor TEventsScheduler.Create;
begin
  inherited Create(False);
  FIndex                    := 0;
  FTaskQueue                := TThreadedQueue<ISchedulerTask>.Create(CTE_INITIAL_QUEUE_SIZE, CTE_PUSH_TIMEOUT, INFINITE);
  FTaskList                 := TCollections.CreateList<ISchedulerTask>;
  FColaOrdenesEliminar
  FTaskListToRemove         := TCollections.CreateList<ISchedulerTask>;
  FComparer                 := TComparerSchedulerTask.Create;
end;

destructor TEventsScheduler.Destroy;
begin
  Terminate;
  FTaskQueue.DoShutDown;
  WaitFor;
  FComparer              := nil;
  FTaskList              := nil;
  FTaskListToRemove      := nil;
  FTaskQueue.Destroy;
  inherited;
end;

procedure TEventsScheduler.Execute;
begin
  DoScheduling;
end;

function TEventsScheduler.GetIndex: Int64;
begin
  FSC.Enter;
  try
    Inc(FIndex);
    Result := FIndex;
  finally
    FSC.Exit;
  end;
end;

function TEventsScheduler.GetNewTask(out AQueueSize: Integer; out ATask: ISchedulerTask): TWaitResult;
begin
  Result := FTaskQueue.PopItem(AQueueSize, ATask);
end;

function TEventsScheduler.GetNewTask(out AQueueSize: Integer; out ATask: ISchedulerTask; const ATimeOut: Cardinal): TWaitResult;
begin
  Result := FTaskQueue.PopItem(AQueueSize, ATask, ATimeOut);
end;

procedure TEventsScheduler.DoScheduling;
var
  LTarea               : ISchedulerTask;
  LNoTarea             : Int64;
  LTimeToSleep         : Int64;
  LWaitingTask         : ISchedulerTask;
  LRes                 : TWaitResult;
  LSize                : Integer;
  LRecalcChecks        : Boolean;
begin
  LRecalcChecks := False;
  while not(Terminated) do
  begin
    repeat
      case FTaskList.Count of
        0:
          begin
            LRes := GetNewTask(LSize, LTarea);
          end
      else
        begin
          LWaitingTask  := FTaskList[0];
          LTimeToSleep  := LWaitingTask.MiliSecondsToAwake;
          LWaitingTask  := nil;
          if LTimeToSleep <= 0 then
          begin
            if Checks then
            begin
              RecalcScheduling;
            end;
            Continue;
          end
          else begin
                 LRecalcChecks := True;
                 LRes := GetNewTask(LSize, LTarea, LTimeToSleep);
               end;
        end;
      end;
      case LRes of
        wrSignaled:
          begin
            if (not Terminated) then
            begin
              FTaskList.Add(LTarea);
              RecalcScheduling;
              LRecalcChecks := True;
              LTarea        := nil;
            end
            else
            begin
              Exit;
            end;
          end;
        wrAbandoned:
          begin
            Exit;
          end;
      end;
    until (LSize = 0) or (LRes = TWaitResult.wrTimeout);
    if LRecalcChecks then
    begin
      if Checks then
      begin
        RecalcScheduling;
      end;
      LRecalcChecks := False;
    end;
  end;
end;

procedure TEventsScheduler.RecalcScheduling;
var
  LComparison: TComparison<ISchedulerTask>;
begin
  if (FTaskList.Count > 1) then
  begin
    FTaskList.Sort(FComparer);
  end;
end;

function TEventsScheduler.RemoveTimer(const ATimerID: Int64): Boolean;
var
  LSize: Integer;
  LRes : TWaitResult;
begin
  repeat
    LRes := FTaskQueue.PushItem(ATimerID, LSize);
    case LRes of
      wrTimeout:
        begin
          FTaskQueue.Grow(LSize);
          if Terminated then Exit;
        end;
    end;
  until LRes = TWaitResult.wrSignaled;
end;

function TEventsScheduler.SetTimer(const AAvisarCuandoPasenMilisegundos: Int64; const ACallBack: TCallBackTimer): Int64;
var
  LTarea: ISchedulerTask;
  LSize : Integer;
  LRes  : TWaitResult;
begin
  Result := GetIndex;
  LTarea := TSchedulerTask.Create(Result, AAvisarCuandoPasenMilisegundos, ACallBack);
  repeat
    LRes := FTaskQueue.PushItem(LTarea, LSize);
    case LRes of
      wrTimeout:
        begin
          FTaskQueue.Grow(LSize);
          if Terminated then Exit;
        end;
    end;
  until LRes = TWaitResult.wrSignaled;
end;

{ TSchedulerTask }

procedure TSchedulerTask.CalculateAwakeTime;
begin
  FTimeStampAwake := FTimeStampCreation + FMilisecondsToAwake;
end;

function TSchedulerTask.CheckAndNotify: Boolean;
var
  LElapsed: Int64;
begin
  Result := False;
  if not(FIsDone) then
  begin
    LElapsed := Utils.ElapsedMiliseconds;
    FIsDone := (LElapsed >= FTimeStampAwake);
    Result  := FIsDone;
    if FIsDone then
      Notify;
  end;
end;

constructor TSchedulerTask.Create(const ATaskID: Int64; const AEllapsedMilisecondsToExecute: Int64; const ACallBack: TCallBackTimer);
begin
  inherited Create;
  FTaskID             := ATaskID;
  FTimeStampCreation  := Utils.ElapsedMiliseconds;
  FMilisecondsToAwake := AEllapsedMilisecondsToExecute;
  FCallBack           := ACallBack;
  FIsDone             := False;
  CalculateAwakeTime;
end;

destructor TSchedulerTask.Destroy;
begin
  FCallBack := nil;
  inherited;
end;

function TSchedulerTask.GetTaskID: Int64;
begin
  Result := FTaskID;
end;

function TSchedulerTask.GetMilisecondsToAwake: Int64;
begin
  FMilisecondsToAwake := FTimeStampAwake - Utils.ElapsedMiliseconds;
  Result              := FMilisecondsToAwake;
end;

function TSchedulerTask.IsDone: Boolean;
begin
  Result := FIsDone
end;

procedure TSchedulerTask.Notify;
begin
  FCallBack();
end;

end.

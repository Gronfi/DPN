unit Event.Engine.Interfaces;

interface

uses
  System.Generics.Defaults,

  Spring;

type

{$REGION 'IObject'}

  IObject = interface
    ['{61A3454D-3B58-4CDE-83AE-4C3E73732977}']
    function GetAsObject: TObject;
  end;
{$ENDREGION}

{$REGION 'IEvent'}
  IEvent = interface(IObject)
    ['{8C6AE8E2-B18D-41B4-AAED-88CF3B110F1D}']
    function GetCreationDateTime: TDateTime;
    function GetSender: TObject;

    procedure Post;
    procedure Schedule(const AMilisecondsToExecute: Int64); overload;
    procedure Schedule(const ADateTimeWhenExecute: TDateTime); overload;

    property CreationDateTime: TDateTime read GetCreationDateTime;
    property Sender: TObject read GetSender;
  end;
{$ENDREGION}

  TNotifyEvent = procedure(AEvent: IEvent) of Object;

  TListenerFilter = reference to function(AEvent: IEvent): Boolean;

{$REGION 'IEventListener'}
  EEventTypeRestriction = (mtrAllowDescendants, mtrDefinedTypeOnly);
  EDelegatedExecutionMode = (medQueue, medSynchronize, medNewTask, medNormal);

  IEventListener = interface(IObject)
    ['{ABC992B0-4CB4-470A-BDCE-EBE6651C84DD}']
    function GetIsCodeToExecuteInUIMainThread: Boolean;
    procedure SetIsCodeToExecuteInUIMainThread(const AValue: Boolean);

    function GetTypeRestriction: EEventTypeRestriction;
    procedure SetTypeRestriction(const ATypeRestriction: EEventTypeRestriction);

    function GetListenerFilter: TListenerFilter;
    procedure SetListenerFilter(const AFilter: TListenerFilter);

    function GetEnabled: Boolean;
    procedure SetEnabled(const AValue: Boolean);

    function GetChannel: String;

    function GetMessajeClass: TClass;

    function GetConditionsMatch(AEvent: IEvent): Boolean;

    procedure Register;
    procedure UnRegister;

    procedure DoOnNewEvent(AEvent: IEvent);

    property FilterCondition: TListenerFilter read GetListenerFilter write SetListenerFilter;
    property IsCodeToExecuteInUIMainThread: Boolean read GetIsCodeToExecuteInUIMainThread write SetIsCodeToExecuteInUIMainThread;
    property TypeRestriction: EEventTypeRestriction read GetTypeRestriction write SetTypeRestriction;
    property Enabled        : Boolean read GetEnabled write SetEnabled;
    property Channel        : String read GetChannel;
  end;
{$ENDREGION}
{$REGION 'IEventListener<T: TEvent>'}
  IEventListener<T: IEvent> = interface(IEventListener)
    ['{CA3B8245-46E2-4827-B7D4-B3CAA91EE965}']
    function GetOnEvent: IEvent<TNotifyEvent>;
    function GetMessajeClass: TClass;

    property OnEvent: IEvent<TNotifyEvent> read GetOnEvent;
  end;
{$ENDREGION}

{$REGION 'TIMERS'}
  ISchedulerTask = interface
    ['{6FFF8050-664B-4AE0-AD2D-2A1CD2F07CDB}']
    function GetTaskID: Int64;
    function GetMilisecondsToAwake: Int64;

    function IsDone: Boolean;
    function CheckAndNotify: Boolean;

    property TaskID: Int64 read GetTaskID;
    property MilisecondsToAwake: Int64 read GetMilisecondsToAwake;
  end;
{$ENDREGION}

  TComparerSchedulerTask = class(TComparer<ISchedulerTask>)
  public
    function Compare(const Left, Right: ISchedulerTask): Integer; override;
  end;

implementation

{ TComparerSchedulerTask }

function TComparerSchedulerTask.Compare(const Left, Right: ISchedulerTask): Integer;
begin
  Result := 0;
  if (Left = Right) then
    Exit;
  if Left.MilisecondsToAwake < Right.MilisecondsToAwake then
    Result := -1
  else
    Result := 1;
end;

end.

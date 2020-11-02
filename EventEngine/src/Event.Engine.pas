unit Event.Engine;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Types,
  System.SyncObjs,
  System.Diagnostics,

  Spring,
  Spring.Collections,

  Helper.ThreadedQueue,
  Event.Engine.Scheduler,
  Event.Engine.Interfaces;

const
  MAX_DEFAULT_POOLED_THREADS = 4;
  DEFAULT_CHANNEL_SINGLED_THREADED = 'CHANNEL.DEFAULT.SINGLE';
  DEFAULT_CHANNEL_MULTI_THREADED   = 'CHANNEL.DEFAULT.MULTI';

type
  { Forward Declarations }
  TEvent                  = class;
  TThreadEventHandlerBase = class;
  TThreadEventHandler     = class;
  TEventChannel           = class;
  TChannel                  = class;
  TThreadEventHandlerType = class of TThreadEventHandler;

{$REGION 'TEvent'}

  TEvent = class abstract(TInterfacedObject, IEventEE)
  private
    FCreationDateTime: TDateTime;
    FSender          : TObject;
  protected
    function GetCreationDateTime: TDateTime;
    function GetSender: TObject;
  public
    constructor Create; reintroduce; overload;
    constructor Create(ASender: TObject); overload;
    destructor Destroy; override;

    procedure Post; virtual;
    procedure Schedule(const AMilisecondsToExecute: Int64); overload; virtual;
    procedure Schedule(const ADateTimeWhenExecute: TDateTime); overload; virtual;

    function GetAsObject: TObject;

    property CreationDateTime: TDateTime read GetCreationDateTime;
    property Sender: TObject read GetSender;
  end;
{$ENDREGION}
{$REGION 'TEventListener'}

  TEventListener = class abstract(TInterfacedObject, IEventEEListener, IObject)
  private
    FRegistered                   : Boolean;
    FIsCodeToExecuteInUIMainThread: Boolean;
    FChannelName                  : String;
    FChannel                      : TEventChannel;
    FTypeRestriction              : EEventTypeRestriction;
    FFilterCondition              : TListenerFilter;
    FEnabled                      : Boolean;

    function GetIsCodeToExecuteInUIMainThread: Boolean;
    procedure SetIsCodeToExecuteInUIMainThread(const AValue: Boolean);

    function GetTypeRestriction: EEventTypeRestriction;
    procedure SetTypeRestriction(const ATypeRestriction: EEventTypeRestriction);

    function GetListenerFilter: TListenerFilter;
    procedure SetListenerFilter(const AFilter: TListenerFilter);

    function GetEnabled: Boolean;
    procedure SetEnabled(const AValue: Boolean);

    function GetChannel: String;
  protected
    function GetDefaultTypeRestriction: EEventTypeRestriction; virtual;
    function GetDefaultEnabled: Boolean; virtual;
  public
    procedure AfterConstruction; override;

    constructor Create(const AChannel: String = ''; const AFilterCondition: TListenerFilter = nil; const ACodeExecutesInMainUIThread: Boolean = False; const ATypeRestriction: EEventTypeRestriction = EEventTypeRestriction.mtrAllowDescendants); reintroduce;
      overload; virtual;

    destructor Destroy; override;

    function GetConditionsMatch(AEvent: IEventEE): Boolean; virtual;

    function GetMessajeClass: TClass; virtual; abstract;

    procedure Register;
    procedure UnRegister;

    function GetAsObject: TObject;

    procedure DoOnNewEvent(AEvent: IEventEE); virtual;

    property IsCodeToExecuteInUIMainThread: Boolean read GetIsCodeToExecuteInUIMainThread write SetIsCodeToExecuteInUIMainThread;
    property FilterCondition: TListenerFilter read GetListenerFilter write SetListenerFilter;
    property TypeRestriction: EEventTypeRestriction read GetTypeRestriction write SetTypeRestriction;
    property Enabled        : Boolean read GetEnabled write SetEnabled;
    property Channel        : String read GetChannel;
  end;

  TEventListenerBase<T: IEventEE> = class abstract(TEventListener, IEventEEListener<T>, IEventEEListener)
  private
    FOnEvent: IEvent<TNotifyEvent>;
  protected
    function GetOnEvent: IEvent<TNotifyEvent>;
    procedure DoOnNewEvent(AEvent: IEventEE); override;
  public
    constructor Create(const AChannel: String = ''; const AFilterCondition: TListenerFilter = nil; const ACodeExecutesInMainUIThread: Boolean = False; const ATypeRestriction: EEventTypeRestriction = EEventTypeRestriction.mtrAllowDescendants); overload; override;
    destructor Destroy; override;

    function GetMessajeClass: TClass; override; final;

    property OnEvent: IEvent<TNotifyEvent> read GetOnEvent;
  end;

  TEventListener<T: IEventEE> = class (TEventListenerBase<T>, IEventEEListener<T>, IEventEEListener)
  private
    FAction: TListenerAction;
  protected
    procedure DoOnNewEvent(AEvent: IEventEE); override; final;
  public
    constructor Create(const AAction: TListenerAction; const AFilterCondition: TListenerFilter; const AChannel: String = ''; const ACodeExecutesInMainUIThread: Boolean = False; const ATypeRestriction: EEventTypeRestriction = EEventTypeRestriction.mtrAllowDescendants); overload;
    destructor Destroy; override;
  end;

{$ENDREGION}
{$REGION 'TThreadEventHandlerBase'}

  TThreadEventHandlerBase = class abstract(TThread)
  const
    CTE_INITIAL_QUEUE_SIZE = 10;
    CTE_PUSH_TIMEOUT       = 100;
  private
    FSynchronizer: TLightweightMREW;
    FLock        : TSpinLock;
    FEventCount: Int64;
    FEvents    : TThreadedQueue<IEventEE>;
    FIsBusy      : Boolean;

    procedure AdquireWrite;
    procedure ReleaseWrite;
    procedure AdquireRead;
    procedure ReleaseRead;

    procedure ProcessQueuedEvent(AEvent: IEventEE);
    procedure ProcessEvents;

    function GetNextEvent(out AQueueSize: Integer; var AEvent: IEventEE): TWaitResult;
  protected
    procedure SetIsBusy(const AValue: Boolean);
    function GetIsBusy: Boolean;

    procedure Execute; override;

    function GetProcessedEventCount: Int64;

    procedure ProcessEvent(AEvent: IEventEE); virtual; abstract;
  public
    constructor Create; overload; virtual;
    destructor Destroy; override;

    procedure AddEvent(AEvent: IEventEE); virtual;

    property ProcessedEventCount: Int64 read GetProcessedEventCount;
    property IsBusy: Boolean read GetIsBusy;
  end;

{$ENDREGION}
{$REGION 'TThreadEventHandler'}

  TThreadEventHandler = class(TThreadEventHandlerBase)
  private
    FListeners            : IList<IEventEEListener>;
    FSynchronizerListeners: TLightweightMREW;
    FChannel              : TEventChannel;
  protected
    procedure ProcessEvent(AEvent: IEventEE); override;

    procedure InitializeListeners; virtual;
    procedure FinalizeListeners; virtual;

    function GetListenersCount: Integer;
    function GetEventRelevant(AEvent: IEventEE): Boolean; virtual;
  public
    procedure AfterConstruction; override;

    constructor Create; overload; override;
    constructor Create(const AChannel: TEventChannel); overload;
    destructor Destroy; override;

    procedure RegisterListener(AEventListener: IEventEEListener);
    procedure UnregisterListener(AEventListener: IEventEEListener);

    property ListenersCount: Integer read GetListenersCount;

    procedure Register;
    procedure UnRegister;
  end;
{$ENDREGION}
{$REGION 'TEventChannel'}

  TEventChannel = class abstract(TThreadEventHandlerBase)
  private
    FName             : string;
    FSynchronizer     : TLightweightMREW;
    FThreadsMessajes  : IList<TThreadEventHandler>;
    FExecutors        : IList<TThreadEventHandler>;
    FThreadCount      : Integer;

    procedure AddThreadMensajes(const AThreadMensajes: TThreadEventHandler);
    procedure RemoveThreadMensajes(const AThreadMensajes: TThreadEventHandler);

    procedure CreateThreads;
    procedure DestroyThreads;

    function GetThreadCount: Integer;

    procedure AdquireWrite;
    procedure ReleaseWrite;
    procedure AdquireRead;
    procedure ReleaseRead;

    function GetName: string;
  protected
    function GetMessajeThreadType: TThreadEventHandlerType; virtual; abstract;

    procedure ProcessEvent(AEvent: IEventEE); override;
    procedure PoolEvent(AEvent: IEventEE); virtual;
  public
    constructor Create(const AName: string; const AThreadCount: Integer); reintroduce;
    destructor Destroy; override;

    procedure AfterConstruction; override;

    //procedure Register;
    //procedure UnRegister;

    procedure RegisterListener(AEventListener: IEventEEListener);
    procedure UnregisterListener(AEventListener: IEventEEListener);

    property ThreadCount: Integer read GetThreadCount;
    property Name: string read GetName;
  end;
{$ENDREGION}
{$REGION 'TEventChannel<T>'}

  TEventChannel<T: TThreadEventHandler> = class(TEventChannel)
  protected
    function GetMessajeThreadType: TThreadEventHandlerType; override; final;
  end;
{$ENDREGION}

  TEventChannelBase = class(TEventChannel<TThreadEventHandler>);
  TChannel = class(TEventChannelBase);

  //TEventChannel_Main                = class(TEventChannel<TThreadEventHandler>);
  //TEventChannel_Main_SingleThreaded = class(TEventChannel<TThreadEventHandler>);

{$REGION 'EventBus'}
  EEventDeploymentKind = (mdkFifo, mdkPooled);

  EventBus = record
  private
    class var FScheduler             : TEventsScheduler;
    class var FSynchronizerChannels  : TLightweightMREW;
    class var FChannels              : IList<TEventChannel>;
    class var FChannelsByName        : IDictionary<String, TEventChannel>;
    class var FEventDeploymentKind   : EEventDeploymentKind;

    class procedure CreateIni; static;
    class procedure DestroyIni; static;

    class procedure QueueInchannels(AEvent: IEventEE); static;
  public
    class procedure RegisterChannel(const AChannelName: String; const AThreadCount: Integer); static;
    class procedure UnregisterChannel(const AChannelName: String); static;
    class function GetChannel(const AChannelName: String; out AChannel: TEventChannel): Boolean; static;

    class procedure QueueEvent(AEvent: IEventEE); static;

    class property Scheduler: TEventsScheduler read FScheduler;
  end;
{$ENDREGION}
{$REGION 'TEvent_Generic'}

  TEvent_Generic<T> = class(TEvent)
  public
    Data: T;
  end;

{$ENDREGION}

implementation

uses
  Event.Engine.Utils,
  System.Generics.Defaults;

{$REGION 'TEvent'}

constructor TEvent.Create;
begin
  inherited Create;
  FCreationDateTime := Now;
  FSender           := nil;
end;

constructor TEvent.Create(ASender: TObject);
begin
  Create;
  FSender := ASender;
end;

destructor TEvent.Destroy;
begin
  inherited Destroy;
end;

function TEvent.GetAsObject: TObject;
begin
  Result := Self;
end;

function TEvent.GetCreationDateTime: TDateTime;
begin
  Result := FCreationDateTime;
end;

function TEvent.GetSender: TObject;
begin
  Result := FSender;
end;

procedure TEvent.Post;
begin
  EventBus.QueueEvent(Self)
end;

procedure TEvent.Schedule(const ADateTimeWhenExecute: TDateTime);
begin
  EventBus.Scheduler.ScheduleEvent(Self, ADateTimeWhenExecute);
end;

procedure TEvent.Schedule(const AMilisecondsToExecute: Int64);
begin
  EventBus.Scheduler.ScheduleEvent(Self, AMilisecondsToExecute);
end;

{$ENDREGION}
{$REGION 'TEventListener'}

procedure TEventListener.AfterConstruction;
begin
  inherited;
  Register;
end;

constructor TEventListener.Create(const AChannel: String; const AFilterCondition: TListenerFilter; const ACodeExecutesInMainUIThread: Boolean; const ATypeRestriction: EEventTypeRestriction);
begin
  FChannelName := AChannel;
  if AChannel.IsEmpty then
  begin
    case EventBus.FEventDeploymentKind of
      EEventDeploymentKind.mdkFifo:
        begin
          EventBus.GetChannel(DEFAULT_CHANNEL_SINGLED_THREADED, FChannel);
        end;
      EEventDeploymentKind.mdkPooled:
        begin
          EventBus.GetChannel(DEFAULT_CHANNEL_MULTI_THREADED, FChannel);
        end;
    end;
  end
  else begin
         if not EventBus.GetChannel(AChannel, FChannel) then
           raise Exception.Create('The channel ' + AChannel + '  is not registered');
       end;
  inherited Create;
  FEnabled                       := GetDefaultEnabled;
  FIsCodeToExecuteInUIMainThread := ACodeExecutesInMainUIThread;
  FFilterCondition               := AFilterCondition;
end;

destructor TEventListener.Destroy;
begin
  UnRegister;
  inherited;
end;

function TEventListener.GetIsCodeToExecuteInUIMainThread: Boolean;
begin
  Result := FIsCodeToExecuteInUIMainThread
end;

function TEventListener.GetAsObject: TObject;
begin
  Result := Self
end;

function TEventListener.GetChannel: String;
begin
  Result := FChannelName
end;

function TEventListener.GetConditionsMatch(AEvent: IEventEE): Boolean;
begin
  if Assigned(FFilterCondition) then
    Result := FFilterCondition(AEvent)
  else
    Result := True
end;

function TEventListener.GetDefaultEnabled: Boolean;
begin
  Result := True;
end;

function TEventListener.GetDefaultTypeRestriction: EEventTypeRestriction;
begin
  Result := mtrAllowDescendants;
end;

function TEventListener.GetEnabled: Boolean;
begin
  Result := FEnabled;
end;

function TEventListener.GetListenerFilter: TListenerFilter;
begin
  Result := FFilterCondition
end;

function TEventListener.GetTypeRestriction: EEventTypeRestriction;
begin
  Result := FTypeRestriction;
end;

procedure TEventListener.DoOnNewEvent(AEvent: IEventEE);
begin
  //
end;

procedure TEventListener.Register;
begin
  FChannel.RegisterListener(Self);
end;

procedure TEventListener.SetEnabled(const AValue: Boolean);
begin
  FEnabled := AValue;
end;

procedure TEventListener.SetIsCodeToExecuteInUIMainThread(const AValue: Boolean);
begin
  FIsCodeToExecuteInUIMainThread := AValue;
end;

procedure TEventListener.SetListenerFilter(const AFilter: TListenerFilter);
begin
  FFilterCondition := AFilter
end;

procedure TEventListener.SetTypeRestriction(const ATypeRestriction: EEventTypeRestriction);
begin
  FTypeRestriction := ATypeRestriction;
end;

procedure TEventListener.UnRegister;
begin
  FChannel.UnregisterListener(Self);
end;
{$ENDREGION}
{$REGION 'TEventListener<T>'}

constructor TEventListenerBase<T>.Create(const AChannel: String; const AFilterCondition: TListenerFilter; const ACodeExecutesInMainUIThread: Boolean; const ATypeRestriction: EEventTypeRestriction);
begin
  inherited;
  FOnEvent := Utils.CreateEvent<TNotifyEvent>;
end;

destructor TEventListenerBase<T>.Destroy;
begin
  FOnEvent := nil;
  inherited;
end;

function TEventListenerBase<T>.GetMessajeClass: TClass;
begin
  Result := PTypeInfo(TypeInfo(T))^.TypeData.ClassType;
end;

function TEventListenerBase<T>.GetOnEvent: IEvent<TNotifyEvent>;
begin
  Result := FOnEvent
end;

procedure TEventListenerBase<T>.DoOnNewEvent(AEvent: IEventEE);
begin
  if FIsCodeToExecuteInUIMainThread then
  begin
    if not Utils.IsMainThreadUI then
      Utils.DelegateExecution<IEventEE>(AEvent,
        procedure(AAEvent: IEventEE)
        begin
          FOnEvent.Invoke(AAEvent)
        end, EDelegatedExecutionMode.medQueue)
    else
      FOnEvent.Invoke(AEvent);
  end
  else
    FOnEvent.Invoke(AEvent);
end;

{$ENDREGION}
{$REGION 'TThreadEventHandlerBase'}

procedure TThreadEventHandlerBase.AdquireRead;
begin
  FSynchronizer.BeginRead;
end;

procedure TThreadEventHandlerBase.AdquireWrite;
begin
  FSynchronizer.BeginWrite;
end;

constructor TThreadEventHandlerBase.Create;
begin
  inherited Create(False);
  FLock         := TSpinLock.Create(False);
  FEvents     := TThreadedQueue<IEventEE>.Create(CTE_INITIAL_QUEUE_SIZE, CTE_PUSH_TIMEOUT, Cardinal.MaxValue);
  FEventCount := 0;
end;

destructor TThreadEventHandlerBase.Destroy;
begin
  Terminate;
  FEvents.DoShutDown;
  WaitFor;
  FEvents.Free;
  inherited Destroy;
end;

function TThreadEventHandlerBase.GetProcessedEventCount: Int64;
begin
  Result := FEventCount
end;

function TThreadEventHandlerBase.GetIsBusy: Boolean;
begin
  FLock.Enter;
  try
    Result := FIsBusy;
  finally
    FLock.Exit;
  end;
end;

function TThreadEventHandlerBase.GetNextEvent(out AQueueSize: Integer; var AEvent: IEventEE): TWaitResult;
begin
  Result := FEvents.PopItem(AQueueSize, AEvent);
end;

procedure TThreadEventHandlerBase.ProcessEvents;
var
  LRes : TWaitResult;
  LSize: Integer;
  LMsg : IEventEE;
begin
  while not(Terminated) do
  begin
    repeat
      LRes := GetNextEvent(LSize, LMsg);
      case LRes of
        wrSignaled:
          begin
            if not Terminated then
            begin
              try
                try
                  SetIsBusy(True);
                  ProcessQueuedEvent(LMsg);
                finally
                  SetIsBusy(False);
                end;
              except
                on E: Exception do
                begin
                  Utils.IdeDebugMsg('Exception at <TThreadEventHandlerBase.ProcessEvents> ' + TThread.CurrentThread.ThreadID.ToString + ' - ' + LSize.ToString + ' - Error: ' + E.Message);
                end;
              end;
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
  end;
end;

procedure TThreadEventHandlerBase.ProcessQueuedEvent(AEvent: IEventEE);
begin
  ProcessEvent(AEvent);
end;

procedure TThreadEventHandlerBase.AddEvent(AEvent: IEventEE);
var
  LSize: Integer;
  LRes : TWaitResult;
begin
  repeat
    LRes := FEvents.PushItem(AEvent, LSize);
    case LRes of
      wrTimeout:
        begin
          FEvents.Grow(LSize);
          if Terminated then
            Exit;
        end;
    end;
  until LRes = TWaitResult.wrSignaled;
  Inc(FEventCount);
end;

procedure TThreadEventHandlerBase.ReleaseRead;
begin
  FSynchronizer.EndRead;
end;

procedure TThreadEventHandlerBase.ReleaseWrite;
begin
  FSynchronizer.EndWrite;
end;

procedure TThreadEventHandlerBase.SetIsBusy(const AValue: Boolean);
begin
  FLock.Enter;
  try
    FIsBusy :=  AValue;
  finally
    FLock.Exit;
  end;
end;

procedure TThreadEventHandlerBase.Execute;
begin
  ProcessEvents;
end;
{$ENDREGION}
{$REGION 'TThreadEventHandler'}

procedure TThreadEventHandler.AfterConstruction;
begin
  inherited;
  Register;
end;

constructor TThreadEventHandler.Create;
begin
  inherited Create;
  FChannel               := nil;
  FListeners             := TCollections.CreateList<IEventEEListener>;
  InitializeListeners;
end;

constructor TThreadEventHandler.Create(const AChannel: TEventChannel);
begin
  Create;
  FChannel := AChannel;
end;

destructor TThreadEventHandler.Destroy;
begin
  UnRegister;
  FinalizeListeners;
  FListeners := nil;

  inherited Destroy;
end;

procedure TThreadEventHandler.FinalizeListeners;
var
  LListener: IEventEEListener;
  LList    : IList<IEventEEListener>;
begin
  LList := TCollections.CreateList<IEventEEListener>;
  FSynchronizerListeners.BeginRead;
  try
    LList.AddRange(FListeners.ToArray);
  finally
    FSynchronizerListeners.EndRead;
  end;
  for LListener in LList do
    LListener.UnRegister;
end;

function TThreadEventHandler.GetEventRelevant(AEvent: IEventEE): Boolean;
begin
  Result := True;
end;

function TThreadEventHandler.GetListenersCount: Integer;
begin
  FSynchronizerListeners.BeginRead;
  try
    Result := FListeners.Count;
  finally
    FSynchronizerListeners.EndRead;
  end;
end;

procedure TThreadEventHandler.InitializeListeners;
begin
  //
end;

procedure TThreadEventHandler.ProcessEvent(AEvent: IEventEE);
var
  I: Integer;
begin
  FSynchronizerListeners.BeginRead;
  try
    for I := 0 to FListeners.Count - 1 do
    begin
      if (FListeners[I].Enabled) and (((FListeners[I].TypeRestriction = mtrAllowDescendants) and (AEvent is FListeners[I].GetMessajeClass)) or ((FListeners[I].GetTypeRestriction = mtrDefinedTypeOnly) and (AEvent.GetAsObject.ClassType = FListeners[I].GetMessajeClass))) and
        (FListeners[I].GetConditionsMatch(AEvent)) then
      begin
        try
          FListeners[I].DoOnNewEvent(AEvent);
        except
          on E: Exception do
          begin
            Utils.IdeDebugMsg('Exception executing the listener: ' + FListeners[I].GetAsObject.QualifiedClassName + ' - Error: ' + E.Message);
            Utils.IdeDebugMsg('Exception Event class type: ' + AEvent.GetAsObject.QualifiedClassName);
          end;
        end;
      end;
    end;
  finally
    FSynchronizerListeners.EndRead;
  end;
end;

procedure TThreadEventHandler.Register;
begin
  FChannel.AddThreadMensajes(Self)
end;

procedure TThreadEventHandler.RegisterListener(AEventListener: IEventEEListener);
begin
  FSynchronizerListeners.BeginWrite;
  try
    if (not FListeners.Contains(AEventListener)) then
      FListeners.Add(AEventListener);
  finally
    FSynchronizerListeners.EndWrite;
  end;
end;

procedure TThreadEventHandler.UnRegister;
begin
  FChannel.RemoveThreadMensajes(Self)
end;

procedure TThreadEventHandler.UnregisterListener(AEventListener: IEventEEListener);
begin
  FSynchronizerListeners.BeginWrite;
  try
    if FListeners.Contains(AEventListener) then
      FListeners.remove(AEventListener);
  finally
    FSynchronizerListeners.EndWrite;
  end;
end;
{$ENDREGION}
{$REGION 'EventBus' }

class procedure EventBus.CreateIni;
begin
  FChannels             := TCollections.CreateList<TEventChannel>;
  FChannelsByName       := TCollections.CreateDictionary<String, TEventChannel>;
  FEventDeploymentKind  := EEventDeploymentKind.mdkPooled;
  FScheduler            := TEventsScheduler.Create;

  RegisterChannel(DEFAULT_CHANNEL_SINGLED_THREADED, 1);
  RegisterChannel(DEFAULT_CHANNEL_MULTI_THREADED, Utils.iif<Integer>((TThread.ProcessorCount > MAX_DEFAULT_POOLED_THREADS), MAX_DEFAULT_POOLED_THREADS, TThread.ProcessorCount));
end;

class procedure EventBus.DestroyIni;
var
  LChannel: TEventChannel;
begin
  FScheduler.Destroy;
  for LChannel in FChannelsByName.Values do
    LChannel.Free;
  FChannelsByName       := nil;
  FChannels             := nil;
end;

class function EventBus.GetChannel(const AChannelName: String; out AChannel: TEventChannel): Boolean;
begin
  Result   := FChannelsByName.TryGetValue(AChannelName, AChannel);
end;

class procedure EventBus.QueueEvent(AEvent: IEventEE);
begin
  Guard.CheckNotNull(AEvent, 'The Event can not be nil');
  QueueInchannels(AEvent);
end;

class procedure EventBus.QueueInchannels(AEvent: IEventEE);
var
  I: Integer;
begin
  FSynchronizerChannels.BeginRead;
  try
    for I := 0 to FChannels.Count - 1 do
    begin
      FChannels[I].AddEvent(AEvent);
    end;
  finally
    FSynchronizerChannels.EndRead;
  end;
end;

class procedure EventBus.RegisterChannel(const AChannelName: String; const AThreadCount: Integer);
var
  LChannel: TChannel;
begin
  FSynchronizerChannels.BeginWrite;
  try
    if (not FChannelsByName.ContainsKey(AChannelName)) then
    begin
      LChannel := TChannel.Create(AChannelName, AThreadCount);
      FChannels.Add(LChannel);
      FChannelsByName.Add(AChannelName, LChannel);
    end
    else raise Exception.Create('The channel ' + AChannelName + ' already is registered!');
  finally
    FSynchronizerChannels.EndWrite
  end;
end;

class procedure EventBus.UnregisterChannel(const AChannelName: String);
var
  LIndex  : Integer;
  LChannel: TEventChannel;
begin
  FSynchronizerChannels.BeginWrite;
  try
    if FChannelsByName.TryGetValue(AChannelName, LChannel) then
    begin
      FChannelsByName.Remove(AChannelName);
      LIndex := FChannels.IndexOf(LChannel);
      if LIndex > -1 then
        FChannels.Delete(LIndex);
    end;
  finally
    FSynchronizerChannels.EndWrite;
  end;
end;
{$ENDREGION}
{$REGION 'TEventChannel'}

procedure TEventChannel.AdquireRead;
begin
  FSynchronizer.BeginRead;
end;

procedure TEventChannel.AdquireWrite;
begin
  FSynchronizer.BeginWrite;
end;

procedure TEventChannel.AddThreadMensajes(const AThreadMensajes: TThreadEventHandler);
begin
  if not(AThreadMensajes is GetMessajeThreadType) then
    raise Exception.CreateFmt('Event Pool quiere Threads de Mensajes del tipo "%s", pero se ha intentado registrar un thread de mensajes del tipo "%s"', [GetMessajeThreadType.ClassName, AThreadMensajes.ClassName]);
  AdquireWrite;
  try
    if (not FThreadsMessajes.Contains(AThreadMensajes)) then
      FThreadsMessajes.Add(AThreadMensajes);
  finally
    ReleaseWrite;
  end;
end;

procedure TEventChannel.AfterConstruction;
begin
  inherited;
  CreateThreads;
  //Register;
end;

constructor TEventChannel.Create(const AName: string; const AThreadCount: Integer);
begin
  inherited Create;
  FName              := AName;
  FThreadCount       := AThreadCount;
  FThreadsMessajes   := TCollections.CreateList<TThreadEventHandler>;
  FExecutors         := TCollections.CreateList<TThreadEventHandler>;
end;

procedure TEventChannel.CreateThreads;
var
  I: Integer;
begin
  for I := 1 to FThreadCount do
  begin
    GetMessajeThreadType.Create(Self);
  end;
end;

destructor TEventChannel.Destroy;
begin
  DestroyThreads;
  FThreadsMessajes := nil;
  FExecutors       := nil;
  inherited;
end;

procedure TEventChannel.DestroyThreads;
var
  I, LCount: Integer;
begin
  AdquireWrite;
  try
    FThreadCount := 0;
    AdquireWrite;
    try
      LCount := FThreadsMessajes.Count;
      for I  := LCount - 1 downto 0 do
        FThreadsMessajes[I].Free;
    finally
      ReleaseWrite;
    end;
  finally
    ReleaseWrite;
  end;
end;

function TEventChannel.GetName: string;
begin
  Result := FName;
end;

function TEventChannel.GetThreadCount: Integer;
begin
  AdquireRead;
  try
    Result := FThreadCount;
  finally
    ReleaseRead;
  end;
end;

function Comparador_TThreadEventHandler(const DatoI, DatoD: TThreadEventHandler): Integer;
var
  LThisThreadEventCountI, LThisThreadEventCountD: Int64;
  LBusyI, LBusyD                                : Boolean;
begin
  Result := 0;
  if (DatoI = DatoD) then
    Exit(0);
  LBusyI                 := DatoI.IsBusy;
  LBusyD                 := DatoD.IsBusy;
  if (LBusyI or LBusyD) then
  begin
    if not (LBusyI and LBusyD) then
    begin
      if LBusyI then
        Exit(1)
      else Exit(-1);
    end;
  end;
  LThisThreadEventCountI := DatoI.ProcessedEventCount;
  LThisThreadEventCountD := DatoD.ProcessedEventCount;
  if LThisThreadEventCountI < LThisThreadEventCountD then
    Exit(-1);
  if LThisThreadEventCountI > LThisThreadEventCountD then
    Exit(1);
end;

procedure TEventChannel.PoolEvent(AEvent: IEventEE);
var
  LSelected: TThreadEventHandler;
begin
  AdquireRead;
  try
    FExecutors.AddRange(FThreadsMessajes.ToArray);
    FExecutors.Sort(Comparador_TThreadEventHandler);
    if FExecutors.Count <> 0 then
    begin
      LSelected := FExecutors.First;
      LSelected.AddEvent(AEvent);
      FExecutors.Clear;
    end;
  finally
    ReleaseRead;
  end;
end;

procedure TEventChannel.ProcessEvent(AEvent: IEventEE);
begin
  if FThreadsMessajes.Count > 0 then
    PoolEvent(AEvent);
end;

(*
procedure TEventChannel.Register;
begin
  EventBus.RegisterChannel(Self);
end;
*)

procedure TEventChannel.RegisterListener(AEventListener: IEventEEListener);
var
  I: Integer;
begin
  AdquireRead;
  try
    for I := 0 to FThreadsMessajes.Count - 1 do
    begin
      FThreadsMessajes[I].RegisterListener(AEventListener);
    end;
  finally
    ReleaseRead;
  end;
end;

procedure TEventChannel.ReleaseRead;
begin
  FSynchronizer.EndRead
end;

procedure TEventChannel.ReleaseWrite;
begin
  FSynchronizer.EndWrite
end;

procedure TEventChannel.RemoveThreadMensajes(const AThreadMensajes: TThreadEventHandler);
var
  LIndex: Integer;
begin
  AdquireWrite;
  try
    LIndex := FThreadsMessajes.IndexOf(AThreadMensajes);
    if LIndex > -1 then
      FThreadsMessajes.Delete(LIndex);
  finally
    ReleaseWrite;
  end;
end;

(*
procedure TEventChannel.UnRegister;
begin
  EventBus.UnregisterChannel(Self);
end;
*)

procedure TEventChannel.UnregisterListener(AEventListener: IEventEEListener);
var
  I: Integer;
begin
  AdquireRead;
  try
    for I := 0 to FThreadsMessajes.Count - 1 do
    begin
      FThreadsMessajes[I].UnregisterListener(AEventListener);
    end;
  finally
    ReleaseRead;
  end;
end;
{$ENDREGION}
{$REGION 'TEventChannel<T>'}

function TEventChannel<T>.GetMessajeThreadType: TThreadEventHandlerType;
begin
  Result := T;
end;
{$ENDREGION}

{ TEventListenerAutonomo<T> }

constructor TEventListener<T>.Create(const AAction: TListenerAction; const AFilterCondition: TListenerFilter; const AChannel: String; const ACodeExecutesInMainUIThread: Boolean; const ATypeRestriction: EEventTypeRestriction);
begin
  inherited Create(AChannel, AFilterCondition, ACodeExecutesInMainUIThread, ATypeRestriction);
  FAction := AAction;
end;

destructor TEventListener<T>.Destroy;
begin
  FAction := nil;
  inherited;
end;

procedure TEventListener<T>.DoOnNewEvent(AEvent: IEventEE);
begin
  if FIsCodeToExecuteInUIMainThread then
  begin
    if not Utils.IsMainThreadUI then
      Utils.DelegateExecution<IEventEE>(AEvent,
        procedure(AAEvent: IEventEE)
        begin
          FAction(AAEvent)
        end, EDelegatedExecutionMode.medQueue)
    else
      FAction(AEvent);
  end
  else
    FAction(AEvent);
end;

initialization

EventBus.CreateIni;

finalization

EventBus.DestroyIni;

end.

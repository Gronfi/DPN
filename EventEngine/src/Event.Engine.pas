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
  TEvento                   = class;
  TThreadEventoHandlerBase  = class;
  TThreadEventoHandler      = class;
  TEventoChannel            = class;
  TChannel                  = class;
  TThreadEventoHandlerType  = class of TThreadEventoHandler;

{$REGION 'TEvento'}

  TEvento = class abstract(TInterfacedObject, IEvento)
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
{$REGION 'TEventoListener'}

  TEventoListener = class abstract(TInterfacedObject, IEventoListener, IObject)
  private
    FIsCodeToExecuteInUIMainThread: Boolean;
    FChannelName                  : String;
    FChannel                      : TEventoChannel;
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

    procedure DoOnNewEvento(AEvento: IEvento); virtual;
  public
    procedure AfterConstruction; override;

    constructor Create(const AChannel: String = ''; const AFilterCondition: TListenerFilter = nil; const ACodeExecutesInMainUIThread: Boolean = False; const ATypeRestriction: EEventTypeRestriction = EEventTypeRestriction.mtrAllowDescendants); reintroduce;
      overload; virtual;

    destructor Destroy; override;

    function GetConditionsMatch(AEvento: IEvento): Boolean; virtual;

    function GetMessajeClass: TClass; virtual; abstract;

    procedure Register;
    procedure UnRegister;

    function GetAsObject: TObject;

    property IsCodeToExecuteInUIMainThread: Boolean read GetIsCodeToExecuteInUIMainThread write SetIsCodeToExecuteInUIMainThread;
    property FilterCondition: TListenerFilter read GetListenerFilter write SetListenerFilter;
    property TypeRestriction: EEventTypeRestriction read GetTypeRestriction write SetTypeRestriction;
    property Enabled        : Boolean read GetEnabled write SetEnabled;
    property Channel        : String read GetChannel;
  end;

  TEventoListenerBase<T: IEvento> = class abstract(TEventoListener, IEventoListener<T>, IEventoListener)
  private
    FOnEvento: IEvent<TNotifyEvent>;
  protected
    function GetOnEvento: IEvent<TNotifyEvent>;
    procedure DoOnNewEvento(AEvento: IEvento); override;
  public
    constructor Create(const AChannel: String = ''; const AFilterCondition: TListenerFilter = nil; const ACodeExecutesInMainUIThread: Boolean = False; const ATypeRestriction: EEventTypeRestriction = EEventTypeRestriction.mtrAllowDescendants); overload; override;
    destructor Destroy; override;

    function GetMessajeClass: TClass; override; final;

    property OnEvento: IEvent<TNotifyEvent> read GetOnEvento;
  end;

  TEventoListener<T: IEvento> = class (TEventoListenerBase<T>, IEventoListener<T>, IEventoListener)
  private
    FAction: TListenerAction;
  protected
    procedure DoOnNewEvento(AEvento: IEvento); override; final;
  public
    constructor Create(const AAction: TListenerAction; const AFilterCondition: TListenerFilter; const AChannel: String = ''; const ACodeExecutesInMainUIThread: Boolean = False; const ATypeRestriction: EEventTypeRestriction = EEventTypeRestriction.mtrAllowDescendants); overload;
    destructor Destroy; override;
  end;

{$ENDREGION}
{$REGION 'TThreadEventoHandlerBase'}

  TThreadEventoHandlerBase = class abstract(TThread)
  const
    CTE_INITIAL_QUEUE_SIZE = 10;
    CTE_PUSH_TIMEOUT       = 100;
  private
    FSynchronizer: TLightweightMREW;
    FLock        : TSpinLock;
    FEventCount: Int64;
    FEvents    : TThreadedQueue<IEvento>;
    FIsBusy      : Boolean;

    procedure AdquireWrite;
    procedure ReleaseWrite;
    procedure AdquireRead;
    procedure ReleaseRead;

    procedure ProcessQueuedEvent(AEvento: IEvento);
    procedure ProcessEvents;

    function GetNextEvent(out AQueueSize: Integer; var AEvento: IEvento): TWaitResult;
  protected
    procedure SetIsBusy(const AValue: Boolean);
    function GetIsBusy: Boolean;

    procedure Execute; override;

    function GetProcessedEventCount: Int64;

    procedure ProcessEvent(AEvento: IEvento); virtual; abstract;
  public
    constructor Create; overload; virtual;
    destructor Destroy; override;

    procedure AddEvent(AEvento: IEvento); virtual;

    property ProcessedEventCount: Int64 read GetProcessedEventCount;
    property IsBusy: Boolean read GetIsBusy;
  end;

{$ENDREGION}
{$REGION 'TThreadEventoHandler'}

  TThreadEventoHandler = class(TThreadEventoHandlerBase)
  private
    FListeners            : IList<IEventoListener>;
    FSynchronizerListeners: TLightweightMREW;
    FChannel              : TEventoChannel;
  protected
    procedure ProcessEvent(AEvento: IEvento); override;

    procedure InitializeListeners; virtual;
    procedure FinalizeListeners; virtual;

    function GetListenersCount: Integer;
    function GetEventRelevant(AEvento: IEvento): Boolean; virtual;
  public
    procedure AfterConstruction; override;

    constructor Create; overload; override;
    constructor Create(const AChannel: TEventoChannel); overload;
    destructor Destroy; override;

    procedure RegisterListener(AEventoListener: IEventoListener);
    procedure UnregisterListener(AEventoListener: IEventoListener);

    property ListenersCount: Integer read GetListenersCount;

    procedure Register;
    procedure UnRegister;
  end;
{$ENDREGION}
{$REGION 'TEventoChannel'}

  TEventoChannel = class abstract(TThreadEventoHandlerBase)
  private
    FName             : string;
    FSynchronizer     : TLightweightMREW;
    FThreadsMessajes  : IList<TThreadEventoHandler>;
    FExecutors        : IList<TThreadEventoHandler>;
    FThreadCount      : Integer;

    procedure AddThreadMensajes(const AThreadMensajes: TThreadEventoHandler);
    procedure RemoveThreadMensajes(const AThreadMensajes: TThreadEventoHandler);

    procedure CreateThreads;
    procedure DestroyThreads;

    function GetThreadCount: Integer;

    procedure AdquireWrite;
    procedure ReleaseWrite;
    procedure AdquireRead;
    procedure ReleaseRead;

    function GetName: string;
  protected
    function GetMessajeThreadType: TThreadEventoHandlerType; virtual; abstract;

    procedure ProcessEvent(AEvento: IEvento); override;
    procedure PoolEvent(AEvento: IEvento); virtual;
  public
    constructor Create(const AName: string; const AThreadCount: Integer); reintroduce;
    destructor Destroy; override;

    procedure AfterConstruction; override;

    procedure RegisterListener(AEventoListener: IEventoListener);
    procedure UnregisterListener(AEventoListener: IEventoListener);

    property ThreadCount: Integer read GetThreadCount;
    property Name: string read GetName;
  end;
{$ENDREGION}
{$REGION 'TEventoChannel<T>'}

  TEventoChannel<T: TThreadEventoHandler> = class(TEventoChannel)
  protected
    function GetMessajeThreadType: TThreadEventoHandlerType; override; final;
  end;
{$ENDREGION}

  TEventoChannelBase = class(TEventoChannel<TThreadEventoHandler>);
  TChannel = class(TEventoChannelBase);

{$REGION 'EventoBus'}
  EEventoDeploymentKind = (mdkFifo, mdkPooled);

  EventoBus = record
  private
    class var FScheduler             : TEventsScheduler;
    class var FSynchronizerChannels  : TLightweightMREW;
    class var FChannels              : IList<TEventoChannel>;
    class var FChannelsByName        : IDictionary<String, TEventoChannel>;
    class var FEventDeploymentKind   : EEventoDeploymentKind;

    class procedure CreateIni; static;
    class procedure DestroyIni; static;

    class procedure QueueInchannels(AEvento: IEvento); static;
  public
    class procedure RegisterChannel(const AChannelName: String; const AThreadCount: Integer); static;
    class procedure UnregisterChannel(const AChannelName: String); static;
    class function GetChannel(const AChannelName: String; out AChannel: TEventoChannel): Boolean; static;

    class procedure QueueEvento(AEvento: IEvento); static;

    class property Scheduler: TEventsScheduler read FScheduler;
  end;
{$ENDREGION}
{$REGION 'TEvent_Generic'}

  TEvent_Generic<T> = class(TEvento)
  public
    Data: T;
  end;

{$ENDREGION}

implementation

uses
  Event.Engine.Utils,
  System.Generics.Defaults;

{$REGION 'TEvent'}

constructor TEvento.Create;
begin
  inherited Create;
  FCreationDateTime := Now;
  FSender           := nil;
end;

constructor TEvento.Create(ASender: TObject);
begin
  Create;
  FSender := ASender;
end;

destructor TEvento.Destroy;
begin
  inherited Destroy;
end;

function TEvento.GetAsObject: TObject;
begin
  Result := Self;
end;

function TEvento.GetCreationDateTime: TDateTime;
begin
  Result := FCreationDateTime;
end;

function TEvento.GetSender: TObject;
begin
  Result := FSender;
end;

procedure TEvento.Post;
begin
  EventoBus.QueueEvento(Self)
end;

procedure TEvento.Schedule(const ADateTimeWhenExecute: TDateTime);
begin
  EventoBus.Scheduler.ScheduleEvent(Self, ADateTimeWhenExecute);
end;

procedure TEvento.Schedule(const AMilisecondsToExecute: Int64);
begin
  EventoBus.Scheduler.ScheduleEvent(Self, AMilisecondsToExecute);
end;

{$ENDREGION}
{$REGION 'TEventoListener'}

procedure TEventoListener.AfterConstruction;
begin
  inherited;
  Register;
end;

constructor TEventoListener.Create(const AChannel: String; const AFilterCondition: TListenerFilter; const ACodeExecutesInMainUIThread: Boolean; const ATypeRestriction: EEventTypeRestriction);
begin
  FChannelName := AChannel;
  if AChannel.IsEmpty then
  begin
    case EventoBus.FEventDeploymentKind of
      EEventoDeploymentKind.mdkFifo:
        begin
          EventoBus.GetChannel(DEFAULT_CHANNEL_SINGLED_THREADED, FChannel);
        end;
      EEventoDeploymentKind.mdkPooled:
        begin
          EventoBus.GetChannel(DEFAULT_CHANNEL_MULTI_THREADED, FChannel);
        end;
    end;
  end
  else begin
         if not EventoBus.GetChannel(AChannel, FChannel) then
           raise Exception.Create('The channel ' + AChannel + '  is not registered');
       end;
  inherited Create;
  FEnabled                       := GetDefaultEnabled;
  FIsCodeToExecuteInUIMainThread := ACodeExecutesInMainUIThread;
  FFilterCondition               := AFilterCondition;
end;

destructor TEventoListener.Destroy;
begin
  UnRegister;
  inherited;
end;

function TEventoListener.GetIsCodeToExecuteInUIMainThread: Boolean;
begin
  Result := FIsCodeToExecuteInUIMainThread
end;

function TEventoListener.GetAsObject: TObject;
begin
  Result := Self
end;

function TEventoListener.GetChannel: String;
begin
  Result := FChannelName
end;

function TEventoListener.GetConditionsMatch(AEvento: IEvento): Boolean;
begin
  if Assigned(FFilterCondition) then
    Result := FFilterCondition(AEvento)
  else
    Result := True
end;

function TEventoListener.GetDefaultEnabled: Boolean;
begin
  Result := True;
end;

function TEventoListener.GetDefaultTypeRestriction: EEventTypeRestriction;
begin
  Result := mtrAllowDescendants;
end;

function TEventoListener.GetEnabled: Boolean;
begin
  Result := FEnabled;
end;

function TEventoListener.GetListenerFilter: TListenerFilter;
begin
  Result := FFilterCondition
end;

function TEventoListener.GetTypeRestriction: EEventTypeRestriction;
begin
  Result := FTypeRestriction;
end;

procedure TEventoListener.DoOnNewEvento(AEvento: IEvento);
begin
  //
end;

procedure TEventoListener.Register;
begin
  FChannel.RegisterListener(Self);
end;

procedure TEventoListener.SetEnabled(const AValue: Boolean);
begin
  FEnabled := AValue;
end;

procedure TEventoListener.SetIsCodeToExecuteInUIMainThread(const AValue: Boolean);
begin
  FIsCodeToExecuteInUIMainThread := AValue;
end;

procedure TEventoListener.SetListenerFilter(const AFilter: TListenerFilter);
begin
  FFilterCondition := AFilter
end;

procedure TEventoListener.SetTypeRestriction(const ATypeRestriction: EEventTypeRestriction);
begin
  FTypeRestriction := ATypeRestriction;
end;

procedure TEventoListener.UnRegister;
begin
  FChannel.UnregisterListener(Self);
end;
{$ENDREGION}
{$REGION 'TEventoListener<T>'}

constructor TEventoListenerBase<T>.Create(const AChannel: String; const AFilterCondition: TListenerFilter; const ACodeExecutesInMainUIThread: Boolean; const ATypeRestriction: EEventTypeRestriction);
begin
  inherited;
  FOnEvento := Utils.CreateEvent<TNotifyEvent>;
end;

destructor TEventoListenerBase<T>.Destroy;
begin
  FOnEvento := nil;
  inherited;
end;

function TEventoListenerBase<T>.GetMessajeClass: TClass;
begin
  Result := PTypeInfo(TypeInfo(T))^.TypeData.ClassType;
end;

function TEventoListenerBase<T>.GetOnEvento: IEvent<TNotifyEvent>;
begin
  Result := FOnEvento
end;

procedure TEventoListenerBase<T>.DoOnNewEvento(AEvento: IEvento);
begin
  if FIsCodeToExecuteInUIMainThread then
  begin
    if not Utils.IsMainThreadUI then
      Utils.DelegateExecution<IEvento>(AEvento,
        procedure(AAEvento: IEvento)
        begin
          FOnEvento.Invoke(AAEvento)
        end, EDelegatedExecutionMode.medQueue)
    else
      FOnEvento.Invoke(AEvento);
  end
  else
    FOnEvento.Invoke(AEvento);
end;

{$ENDREGION}
{$REGION 'TThreadEventoHandlerBase'}

procedure TThreadEventoHandlerBase.AdquireRead;
begin
  FSynchronizer.BeginRead;
end;

procedure TThreadEventoHandlerBase.AdquireWrite;
begin
  FSynchronizer.BeginWrite;
end;

constructor TThreadEventoHandlerBase.Create;
begin
  inherited Create(False);
  FLock         := TSpinLock.Create(False);
  FEvents     := TThreadedQueue<IEvento>.Create(CTE_INITIAL_QUEUE_SIZE, CTE_PUSH_TIMEOUT, Cardinal.MaxValue);
  FEventCount := 0;
end;

destructor TThreadEventoHandlerBase.Destroy;
begin
  Terminate;
  FEvents.DoShutDown;
  WaitFor;
  FEvents.Free;
  inherited Destroy;
end;

function TThreadEventoHandlerBase.GetProcessedEventCount: Int64;
begin
  Result := FEventCount
end;

function TThreadEventoHandlerBase.GetIsBusy: Boolean;
begin
  FLock.Enter;
  try
    Result := FIsBusy;
  finally
    FLock.Exit;
  end;
end;

function TThreadEventoHandlerBase.GetNextEvent(out AQueueSize: Integer; var AEvento: IEvento): TWaitResult;
begin
  Result := FEvents.PopItem(AQueueSize, AEvento);
end;

procedure TThreadEventoHandlerBase.ProcessEvents;
var
  LRes : TWaitResult;
  LSize: Integer;
  LMsg : IEvento;
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
                  Utils.IdeDebugMsg('Exception at <TThreadEventoHandlerBase.ProcessEvents> ' + TThread.CurrentThread.ThreadID.ToString + ' - ' + LSize.ToString + ' - Error: ' + E.Message);
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

procedure TThreadEventoHandlerBase.ProcessQueuedEvent(AEvento: IEvento);
begin
  ProcessEvent(AEvento);
end;

procedure TThreadEventoHandlerBase.AddEvent(AEvento: IEvento);
var
  LSize: Integer;
  LRes : TWaitResult;
begin
  repeat
    LRes := FEvents.PushItem(AEvento, LSize);
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

procedure TThreadEventoHandlerBase.ReleaseRead;
begin
  FSynchronizer.EndRead;
end;

procedure TThreadEventoHandlerBase.ReleaseWrite;
begin
  FSynchronizer.EndWrite;
end;

procedure TThreadEventoHandlerBase.SetIsBusy(const AValue: Boolean);
begin
  FLock.Enter;
  try
    FIsBusy :=  AValue;
  finally
    FLock.Exit;
  end;
end;

procedure TThreadEventoHandlerBase.Execute;
begin
  ProcessEvents;
end;
{$ENDREGION}
{$REGION 'TThreadEventoHandler'}

procedure TThreadEventoHandler.AfterConstruction;
begin
  inherited;
  Register;
end;

constructor TThreadEventoHandler.Create;
begin
  inherited Create;
  FChannel               := nil;
  FListeners             := TCollections.CreateList<IEventoListener>;
  InitializeListeners;
end;

constructor TThreadEventoHandler.Create(const AChannel: TEventoChannel);
begin
  Create;
  FChannel := AChannel;
end;

destructor TThreadEventoHandler.Destroy;
begin
  UnRegister;
  FinalizeListeners;
  FListeners := nil;

  inherited Destroy;
end;

procedure TThreadEventoHandler.FinalizeListeners;
var
  LListener: IEventoListener;
  LList    : IList<IEventoListener>;
begin
  LList := TCollections.CreateList<IEventoListener>;
  FSynchronizerListeners.BeginRead;
  try
    LList.AddRange(FListeners.ToArray);
  finally
    FSynchronizerListeners.EndRead;
  end;
  for LListener in LList do
    LListener.UnRegister;
end;

function TThreadEventoHandler.GetEventRelevant(AEvento: IEvento): Boolean;
begin
  Result := True;
end;

function TThreadEventoHandler.GetListenersCount: Integer;
begin
  FSynchronizerListeners.BeginRead;
  try
    Result := FListeners.Count;
  finally
    FSynchronizerListeners.EndRead;
  end;
end;

procedure TThreadEventoHandler.InitializeListeners;
begin
  //
end;

procedure TThreadEventoHandler.ProcessEvent(AEvento: IEvento);
var
  I: Integer;
begin
  FSynchronizerListeners.BeginRead;
  try
    for I := 0 to FListeners.Count - 1 do
    begin
      if (FListeners[I].Enabled) and (((FListeners[I].TypeRestriction = mtrAllowDescendants) and (AEvento is FListeners[I].GetMessajeClass)) or ((FListeners[I].GetTypeRestriction = mtrDefinedTypeOnly) and (AEvento.GetAsObject.ClassType = FListeners[I].GetMessajeClass))) and
        (FListeners[I].GetConditionsMatch(AEvento)) then
      begin
        try
          FListeners[I].DoOnNewEvento(AEvento);
        except
          on E: Exception do
          begin
            Utils.IdeDebugMsg('Exception executing the listener: ' + FListeners[I].GetAsObject.QualifiedClassName + ' - Error: ' + E.Message);
            Utils.IdeDebugMsg('Exception Event class type: ' + AEvento.GetAsObject.QualifiedClassName);
          end;
        end;
      end;
    end;
  finally
    FSynchronizerListeners.EndRead;
  end;
end;

procedure TThreadEventoHandler.Register;
begin
  FChannel.AddThreadMensajes(Self)
end;

procedure TThreadEventoHandler.RegisterListener(AEventoListener: IEventoListener);
begin
  FSynchronizerListeners.BeginWrite;
  try
    if (not FListeners.Contains(AEventoListener)) then
      FListeners.Add(AEventoListener);
  finally
    FSynchronizerListeners.EndWrite;
  end;
end;

procedure TThreadEventoHandler.UnRegister;
begin
  FChannel.RemoveThreadMensajes(Self)
end;

procedure TThreadEventoHandler.UnregisterListener(AEventoListener: IEventoListener);
begin
  FSynchronizerListeners.BeginWrite;
  try
    if FListeners.Contains(AEventoListener) then
      FListeners.remove(AEventoListener);
  finally
    FSynchronizerListeners.EndWrite;
  end;
end;
{$ENDREGION}
{$REGION 'EventoBus' }

class procedure EventoBus.CreateIni;
begin
  FChannels             := TCollections.CreateList<TEventoChannel>;
  FChannelsByName       := TCollections.CreateDictionary<String, TEventoChannel>;
  FEventDeploymentKind  := EEventoDeploymentKind.mdkPooled;
  FScheduler            := TEventsScheduler.Create;

  RegisterChannel(DEFAULT_CHANNEL_SINGLED_THREADED, 1);
  RegisterChannel(DEFAULT_CHANNEL_MULTI_THREADED, Utils.iif<Integer>((TThread.ProcessorCount > MAX_DEFAULT_POOLED_THREADS), MAX_DEFAULT_POOLED_THREADS, TThread.ProcessorCount));
end;

class procedure EventoBus.DestroyIni;
var
  LChannel: TEventoChannel;
begin
  FScheduler.Destroy;
  for LChannel in FChannelsByName.Values do
    LChannel.Free;
  FChannelsByName       := nil;
  FChannels             := nil;
end;

class function EventoBus.GetChannel(const AChannelName: String; out AChannel: TEventoChannel): Boolean;
begin
  Result   := FChannelsByName.TryGetValue(AChannelName, AChannel);
end;

class procedure EventoBus.QueueEvento(AEvento: IEvento);
begin
  Guard.CheckNotNull(AEvento, 'The Event can not be nil');
  QueueInchannels(AEvento);
end;

class procedure EventoBus.QueueInchannels(AEvento: IEvento);
var
  I: Integer;
begin
  FSynchronizerChannels.BeginRead;
  try
    for I := 0 to FChannels.Count - 1 do
    begin
      FChannels[I].AddEvent(AEvento);
    end;
  finally
    FSynchronizerChannels.EndRead;
  end;
end;

class procedure EventoBus.RegisterChannel(const AChannelName: String; const AThreadCount: Integer);
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

class procedure EventoBus.UnregisterChannel(const AChannelName: String);
var
  LIndex  : Integer;
  LChannel: TEventoChannel;
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
{$REGION 'TEventoChannel'}

procedure TEventoChannel.AdquireRead;
begin
  FSynchronizer.BeginRead;
end;

procedure TEventoChannel.AdquireWrite;
begin
  FSynchronizer.BeginWrite;
end;

procedure TEventoChannel.AddThreadMensajes(const AThreadMensajes: TThreadEventoHandler);
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

procedure TEventoChannel.AfterConstruction;
begin
  inherited;
  CreateThreads;
end;

constructor TEventoChannel.Create(const AName: string; const AThreadCount: Integer);
begin
  inherited Create;
  FName              := AName;
  FThreadCount       := AThreadCount;
  FThreadsMessajes   := TCollections.CreateList<TThreadEventoHandler>;
  FExecutors         := TCollections.CreateList<TThreadEventoHandler>;
end;

procedure TEventoChannel.CreateThreads;
var
  I: Integer;
begin
  for I := 1 to FThreadCount do
  begin
    GetMessajeThreadType.Create(Self);
  end;
end;

destructor TEventoChannel.Destroy;
begin
  DestroyThreads;
  FThreadsMessajes := nil;
  FExecutors       := nil;
  inherited;
end;

procedure TEventoChannel.DestroyThreads;
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

function TEventoChannel.GetName: string;
begin
  Result := FName;
end;

function TEventoChannel.GetThreadCount: Integer;
begin
  AdquireRead;
  try
    Result := FThreadCount;
  finally
    ReleaseRead;
  end;
end;

function Comparador_TThreadEventoHandler(const DatoI, DatoD: TThreadEventoHandler): Integer;
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

procedure TEventoChannel.PoolEvent(AEvento: IEvento);
var
  LSelected: TThreadEventoHandlerBase;
begin
  AdquireRead;
  try
    FExecutors.AddRange(FThreadsMessajes.ToArray);
    FExecutors.Sort(Comparador_TThreadEventoHandler);
    if FExecutors.Count <> 0 then
    begin
      LSelected := FExecutors.First;
      LSelected.AddEvent(AEvento);
      FExecutors.Clear;
    end;
  finally
    ReleaseRead;
  end;
end;

procedure TEventoChannel.ProcessEvent(AEvento: IEvento);
begin
  if FThreadsMessajes.Count > 0 then
    PoolEvent(AEvento);
end;

procedure TEventoChannel.RegisterListener(AEventoListener: IEventoListener);
var
  I: Integer;
begin
  AdquireRead;
  try
    for I := 0 to FThreadsMessajes.Count - 1 do
    begin
      FThreadsMessajes[I].RegisterListener(AEventoListener);
    end;
  finally
    ReleaseRead;
  end;
end;

procedure TEventoChannel.ReleaseRead;
begin
  FSynchronizer.EndRead
end;

procedure TEventoChannel.ReleaseWrite;
begin
  FSynchronizer.EndWrite
end;

procedure TEventoChannel.RemoveThreadMensajes(const AThreadMensajes: TThreadEventoHandler);
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

procedure TEventoChannel.UnregisterListener(AEventoListener: IEventoListener);
var
  I: Integer;
begin
  AdquireRead;
  try
    for I := 0 to FThreadsMessajes.Count - 1 do
    begin
      FThreadsMessajes[I].UnregisterListener(AEventoListener);
    end;
  finally
    ReleaseRead;
  end;
end;
{$ENDREGION}
{$REGION 'TEventoChannel<T>'}

function TEventoChannel<T>.GetMessajeThreadType: TThreadEventoHandlerType;
begin
  Result := T;
end;
{$ENDREGION}

{ TEventoListenerAutonomo<T> }

constructor TEventoListener<T>.Create(const AAction: TListenerAction; const AFilterCondition: TListenerFilter; const AChannel: String; const ACodeExecutesInMainUIThread: Boolean; const ATypeRestriction: EEventTypeRestriction);
begin
  inherited Create(AChannel, AFilterCondition, ACodeExecutesInMainUIThread, ATypeRestriction);
  FAction := AAction;
end;

destructor TEventoListener<T>.Destroy;
begin
  FAction := nil;
  inherited;
end;

procedure TEventoListener<T>.DoOnNewEvento(AEvento: IEvento);
begin
  if FIsCodeToExecuteInUIMainThread then
  begin
    if not Utils.IsMainThreadUI then
      Utils.DelegateExecution<IEvento>(AEvento,
        procedure(AAEvento: IEvento)
        begin
          FAction(AAEvento)
        end, EDelegatedExecutionMode.medQueue)
    else
      FAction(AEvento);
  end
  else
    FAction(AEvento);
end;

initialization

EventoBus.CreateIni;

finalization

EventoBus.DestroyIni;

end.

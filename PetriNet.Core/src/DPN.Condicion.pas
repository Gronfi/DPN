unit DPN.Condicion;

interface

uses
  System.JSON,
  System.SyncObjs,

  Spring,
  Spring.Collections,

  Event.Engine.Interfaces,
  DPN.Interfaces,
  DPN.NodoPetriNet;

type
  TdpnCondicion = class abstract(TdpnNodoPetriNet, ICondicion)
  protected
    FTransicion: ITransicion;
    FNombreTransicion: string;
    FIsCondicionNegada: Boolean;
    FEventoOnContextoCondicionChanged: IEvent<EventoNodoPN>;

    function GetDependencias: IList<IBloqueable>; virtual;
    function GetOnContextoCondicionChanged: IEvent<EventoNodoPN>;

    function GetEventoHabilitado: Boolean; virtual;
    procedure SetEventoHabilitado(const AValor: Boolean); virtual;

    function GetEventosCount: integer; virtual;

    function GetIsRecursiva: Boolean; virtual;
    function GetIsEvaluacionNoDependeDeTokensOEvento: Boolean; virtual;
    function GetIsCondicionQueEsperaEvento: Boolean; virtual;

    function GetIsCondicionNegada: boolean; virtual;
    procedure SetIsCondicionNegada(const Valor: Boolean); virtual;

    function GetTransicion: ITransicion; virtual;
    procedure SetTransicion(const Value: ITransicion); virtual;

    function EvaluarInternal(ATokens: IMarcadoTokens; AEvento: IEvento = nil): Boolean; virtual;

    procedure DoNotificarOncontextoCondicionChanged; virtual;
  public
    constructor Create; override;

    Procedure CargarDeJSON(NodoJson_IN: TJSONObject); override;
    Procedure FormatoJSON(NodoJson_IN: TJSONObject); overload; override;

    procedure Setup; override;
    function CheckIsOK(out AListaErrores: IList<string>): boolean; override;

    procedure ClearEventos; virtual;
    procedure RemovePrimerEvento; virtual;
    function GetPrimerEvento: IEvento; virtual;

    function Evaluar(ATokens: IMarcadoTokens; AEvento: IEvento = nil): Boolean;

    property Dependencias: IList<IBloqueable> read GetDependencias;
    property Transicion: ITransicion read GetTransicion write SetTransicion;
    property OnContextoCondicionChanged: IEvent<EventoNodoPN> read GetOnContextoCondicionChanged;
    property IsRecursiva: boolean read GetIsRecursiva;
    property IsEvaluacionNoDependeDeTokensOEvento: boolean read GetIsEvaluacionNoDependeDeTokensOEvento;
    property IsCondicionQueEsperaEvento: boolean read GetIsCondicionQueEsperaEvento;
    property IsCondicionNegada: boolean read GetIsCondicionNegada write SetIsCondicionNegada;
    property ListenerEventoHabilitado: Boolean read GetEventoHabilitado write SetEventoHabilitado;
    property EventosCount: integer read GetEventosCount;
  end;

  TdpnCondicionBaseEsperaEvento = class abstract(TdpnCondicion)
  protected
    FLocker: TSpinLock;
    FListenerEvento: IEventoListener;
    FListaEventosRecibidos: IList<IEvento>;

    function GetEventoHabilitado: Boolean; override;
    procedure SetEventoHabilitado(const AValor: Boolean); override;

    function GetIsEvaluacionNoDependeDeTokensOEvento: Boolean; override;

    function GetEventosCount: integer; override;

    function DoOnEventoRequiereFiltrado(AEvento: IEvento): Boolean; virtual; abstract;
    procedure DoOnEventoRecibido(AEvento: IEvento); virtual;

    function CrearListenerEvento: IEventoListener; virtual; abstract;

    function GetIsCondicionQueEsperaEvento: Boolean; override;

    procedure AdquireLock; inline;
    procedure ReleaseLock; inline;
  public
    constructor Create; override;
    destructor Destroy; override;

    procedure ClearEventos; override;
    procedure RemovePrimerEvento; override;
    function GetPrimerEvento: IEvento; override;
  end;

implementation

uses
  System.SysUtils,

  DPN.Core;

{ TdpnCondicion }

procedure TdpnCondicion.CargarDeJSON(NodoJson_IN: TJSONObject);
begin
  inherited;
  DPNCore.CargarCampoDeNodo<string>(NodoJson_IN, 'NombreTransicion', ClassName, FNombreTransicion);
end;

function TdpnCondicion.CheckIsOK(out AListaErrores: IList<string>): boolean;
begin
  Result := inherited;
  if not Assigned(Transicion) then
  begin
    Result := False;
    AListaErrores.Add('Transicion = nil');
  end;
end;

procedure TdpnCondicion.ClearEventos;
begin
  ;
end;

constructor TdpnCondicion.Create;
begin
  inherited;
  FEventoOnContextoCondicionChanged := DPNCore.CrearEvento<EventoNodoPN>;
  FIsCondicionNegada := False;
end;

procedure TdpnCondicion.DoNotificarOncontextoCondicionChanged;
begin
  FEventoOnContextoCondicionChanged.Invoke(ID);
end;

function TdpnCondicion.Evaluar(ATokens: IMarcadoTokens; AEvento: IEvento = nil): Boolean;
begin
  case FIsCondicionNegada of
    True: Result := not EvaluarInternal(ATokens, AEvento);
    False: Result := EvaluarInternal(ATokens, AEvento)
  end;
end;

function TdpnCondicion.EvaluarInternal(ATokens: IMarcadoTokens; AEvento: IEvento): Boolean;
begin
  Result := False;
end;

procedure TdpnCondicion.FormatoJSON(NodoJson_IN: TJSONObject);
begin
  inherited;
  NodoJson_IN.AddPair('NombreTransicion', TJSONString.Create(Transicion.Nombre));
end;

function TdpnCondicion.GetDependencias: IList<IBloqueable>;
begin
  Result := TCollections.CreateList<IBloqueable>;
end;

function TdpnCondicion.GetEventoHabilitado: Boolean;
begin
  Result := False;
end;

function TdpnCondicion.GetEventosCount: integer;
begin
  Result := 0;
end;

function TdpnCondicion.GetIsCondicionNegada: boolean;
begin
  Result := FIsCondicionNegada;
end;

function TdpnCondicion.GetIsCondicionQueEsperaEvento: Boolean;
begin
  Result := False;
end;

function TdpnCondicion.GetIsEvaluacionNoDependeDeTokensOEvento: Boolean;
begin
  Result := True;
end;

function TdpnCondicion.GetIsRecursiva: Boolean;
begin
  Result := False;
end;

function TdpnCondicion.GetOnContextoCondicionChanged: IEvent<EventoNodoPN>;
begin
  Result := FEventoOnContextoCondicionChanged;
end;

function TdpnCondicion.GetPrimerEvento: IEvento;
begin
  Result := nil
end;

function TdpnCondicion.GetTransicion: ITransicion;
begin
  Result := FTransicion
end;

procedure TdpnCondicion.RemovePrimerEvento;
begin
  ;
end;

procedure TdpnCondicion.SetEventoHabilitado(const AValor: Boolean);
begin
  ;
end;procedure TdpnCondicion.SetIsCondicionNegada(const Valor: Boolean);
begin
  if FIsCondicionNegada <> Valor then
  begin
    FIsCondicionNegada := Valor;
  end;
end;

procedure TdpnCondicion.SetTransicion(const Value: ITransicion);
begin
  FTransicion := Value;
end;

procedure TdpnCondicion.Setup;
var
  LTransicion: ITransicion;
begin
  inherited;
  if not FNombreTransicion.IsEmpty then
  begin
    LTransicion := PetriNetController.GetTransicion(FNombreTransicion);
    if Assigned(LTransicion) then
      Transicion := LTransicion;
  end;
end;

{ TdpnCondicionBaseEsperaEvento }

procedure TdpnCondicionBaseEsperaEvento.AdquireLock;
begin
  FLocker.Enter;
end;

procedure TdpnCondicionBaseEsperaEvento.ClearEventos;
begin
  AdquireLock;
  try
    FListaEventosRecibidos.Clear;
  finally
    ReleaseLock;
  end;
end;

constructor TdpnCondicionBaseEsperaEvento.Create;
begin
  inherited;
  FListenerEvento        := CrearListenerEvento;
  FListaEventosRecibidos := TCollections.CreateList<IEvento>;
end;

destructor TdpnCondicionBaseEsperaEvento.Destroy;
begin
  FListenerEvento.Unregister;
  FListenerEvento := nil;
  FListaEventosRecibidos := nil;
  inherited;
end;

procedure TdpnCondicionBaseEsperaEvento.DoOnEventoRecibido(AEvento: IEvento);
begin
  //WriteLn(FormatDateTime('hh:nn:ss.zzz ', Now) + '<TdpnCondicionBaseEsperaEvento.DoOnEventoRecibido> ID: ' + ID.ToString);
  AdquireLock;
  try
    FListaEventosRecibidos.Add(AEvento);
  finally
    ReleaseLock;
  end;
  FEventoOnContextoCondicionChanged.Invoke(ID)
end;

function TdpnCondicionBaseEsperaEvento.GetEventoHabilitado: Boolean;
begin
  Result := FListenerEvento.Enabled
end;

function TdpnCondicionBaseEsperaEvento.GetEventosCount: integer;
begin
  Result := FListaEventosRecibidos.Count;
end;

function TdpnCondicionBaseEsperaEvento.GetIsCondicionQueEsperaEvento: Boolean;
begin
  Result := True
end;

function TdpnCondicionBaseEsperaEvento.GetIsEvaluacionNoDependeDeTokensOEvento: Boolean;
begin
  Result := False;
end;

function TdpnCondicionBaseEsperaEvento.GetPrimerEvento: IEvento;
begin
  AdquireLock;
  try
    if FListaEventosRecibidos.Count > 0 then
      Result := FListaEventosRecibidos[0]
    else Result := nil;
  finally
    ReleaseLock;
  end;
end;

procedure TdpnCondicionBaseEsperaEvento.ReleaseLock;
begin
  FLocker.Exit;
end;

procedure TdpnCondicionBaseEsperaEvento.RemovePrimerEvento;
begin
  AdquireLock;
  try
    if FListaEventosRecibidos.Count > 0 then
      FListaEventosRecibidos.Delete(0);
  finally
    ReleaseLock;
  end;
end;

procedure TdpnCondicionBaseEsperaEvento.SetEventoHabilitado(const AValor: Boolean);
begin
  FListenerEvento.Enabled := AValor
end;

end.

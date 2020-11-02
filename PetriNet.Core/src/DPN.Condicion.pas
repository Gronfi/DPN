unit DPN.Condicion;

interface

uses
  Spring,
  Spring.Collections,

  Event.Engine.Interfaces,
  DPN.Interfaces,
  DPN.NodoPetriNet;

type
  TdpnCondicion = class abstract(TdpnNodoPetriNet, ICondicion)
  protected
    FTransicion: ITransicion;
    FEventoOnContextoCondicionChanged: IEvent<EventoNodoPN>;

    function GetDependencias: IList<IBloqueable>; virtual;
    function GetOnContextoCondicionChanged: IEvent<EventoNodoPN>;

    function GetEventoHabilitado: Boolean; virtual;
    procedure SetEventoHabilitado(const AValor: Boolean); virtual;

    function GetEventosCount: integer; virtual;

    function GetIsRecursiva: Boolean; virtual;
    function GetIsEvaluacionNoDependeDeTokensOEvento: Boolean; virtual;
    function GetIsCondicionQueEsperaEvento: Boolean; virtual;

    function GetTransicion: ITransicion; virtual;
    procedure SetTransicion(const Value: ITransicion); virtual;

    procedure DoNotificarOncontextoCondicionChanged; virtual;
  public
    constructor Create; override;

    procedure ClearEventos; virtual;
    procedure RemovePrimerEvento; virtual;
    function GetPrimerEvento: IEventEE; virtual;

    function Evaluar(ATokens: IMarcadoTokens; AEvento: IEventEE = nil): Boolean; virtual;

    property Dependencias: IList<IBloqueable> read GetDependencias;
    property Transicion: ITransicion read GetTransicion write SetTransicion;
    property OnContextoCondicionChanged: IEvent<EventoNodoPN> read GetOnContextoCondicionChanged;
    property IsRecursiva: boolean read GetIsRecursiva;
    property IsEvaluacionNoDependeDeTokensOEvento: boolean read GetIsEvaluacionNoDependeDeTokensOEvento;
    property IsCondicionQueEsperaEvento: boolean read GetIsCondicionQueEsperaEvento;
    property ListenerEventoHabilitado: Boolean read GetEventoHabilitado write SetEventoHabilitado;
    property EventosCount: integer read GetEventosCount;
  end;

  TdpnCondicionBaseEsperaEvento = class abstract(TdpnCondicion)
  protected
    FListenerEvento: IEventEEListener;
    FListaEventosRecibidos: IList<IEventEE>;

    function GetEventoHabilitado: Boolean; override;
    procedure SetEventoHabilitado(const AValor: Boolean); override;

    function GetEventosCount: integer; override;
    procedure ClearEventos; override;
    procedure RemovePrimerEvento; override;
    function GetPrimerEvento: IEventEE; override;

    function DoOnEventoRequiereFiltrado(AEvento: IEventEE): Boolean; virtual; abstract;
    procedure DoOnEventoRecibido(AEvento: IEventEE); virtual;

    function CrearListenerEvento: IEventEEListener; virtual; abstract;

    function GetIsCondicionQueEsperaEvento: Boolean; override;
  public
    constructor Create; override;
    destructor Destroy; override;
  end;

implementation

uses
  DPN.Core;

{ TdpnCondicion }

procedure TdpnCondicion.ClearEventos;
begin
  ;
end;

constructor TdpnCondicion.Create;
begin
  inherited;
  FEventoOnContextoCondicionChanged := DPNCore.CrearEvento<EventoNodoPN>;
end;

procedure TdpnCondicion.DoNotificarOncontextoCondicionChanged;
begin
  FEventoOnContextoCondicionChanged.Invoke(ID);
end;

function TdpnCondicion.Evaluar(ATokens: IMarcadoTokens; AEvento: IEventEE = nil): Boolean;
begin
  Result := False;
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

function TdpnCondicion.GetPrimerEvento: IEventEE;
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
end;

procedure TdpnCondicion.SetTransicion(const Value: ITransicion);
begin
  FTransicion := Value;
end;

{ TdpnCondicionBaseEsperaEvento }

procedure TdpnCondicionBaseEsperaEvento.ClearEventos;
begin
  FListaEventosRecibidos.Clear;
end;

constructor TdpnCondicionBaseEsperaEvento.Create;
begin
  inherited;
  FListenerEvento        := CrearListenerEvento;
  FListaEventosRecibidos := TCollections.CreateList<IEventEE>;
end;

destructor TdpnCondicionBaseEsperaEvento.Destroy;
begin
  FListenerEvento.Unregister;
  FListenerEvento := nil;
  FListaEventosRecibidos := nil;
  inherited;
end;

procedure TdpnCondicionBaseEsperaEvento.DoOnEventoRecibido(AEvento: IEventEE);
begin
  FListaEventosRecibidos.Add(AEvento);
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

function TdpnCondicionBaseEsperaEvento.GetPrimerEvento: IEventEE;
begin
  if FListaEventosRecibidos.Count > 0 then
    Result := FListaEventosRecibidos[0]
  else Result := nil;
end;

procedure TdpnCondicionBaseEsperaEvento.RemovePrimerEvento;
begin
  if FListaEventosRecibidos.Count > 0 then
    FListaEventosRecibidos.Delete(0);
end;

procedure TdpnCondicionBaseEsperaEvento.SetEventoHabilitado(const AValor: Boolean);
begin
  FListenerEvento.Enabled := AValor
end;

end.

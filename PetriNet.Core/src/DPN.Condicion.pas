unit DPN.Condicion;

interface

uses
  Spring,
  Spring.Collections,

  DPN.Interfaces,
  DPN.NodoPetriNet;

type
  TdpnCondicion = class abstract(TdpnNodoPetriNet, ICondicion)
  protected
    FTransicion: ITransicion;
    FEventoOnContextoCondicionChanged: IEvent<EventoNodoPN>;

    function GetDependencias: IList<IBloqueable>; virtual; abstract;
    function GetOnContextoCondicionChanged: IEvent<EventoNodoPN>;

    function GetIsRecursiva: Boolean; virtual;
    function GetIsEvaluacionNoDependeDeTokens: Boolean; virtual;
    function GetIsCondicionQueEsperaEvento: Boolean; virtual;

    function GetTransicion: ITransicion; virtual;
    procedure SetTransicion(const Value: ITransicion); virtual;

    procedure DoNotificarOncontextoCondicionChanged; virtual;
  public
    constructor Create; override;

    function Evaluar(ATokens: IMarcadoTokens): Boolean; overload; virtual;
    function Evaluar(AToken: IToken): Boolean; overload; virtual;

    property Dependencias: IList<IBloqueable> read GetDependencias;
    property Transicion: ITransicion read GetTransicion write SetTransicion;
    property OnContextoCondicionChanged: IEvent<EventoNodoPN> read GetOnContextoCondicionChanged;
    property IsRecursiva: boolean read GetIsRecursiva;
    property IsEvaluacionNoDependeDeTokens: boolean read GetIsEvaluacionNoDependeDeTokens;
    property IsCondicionQueEsperaEvento: boolean read GetIsCondicionQueEsperaEvento;
  end;

implementation

uses
  DPN.Core;

{ TdpnCondicion }

constructor TdpnCondicion.Create;
begin
  inherited;
  FEventoOnContextoCondicionChanged := DPNCore.CrearEvento<EventoNodoPN>;
end;

procedure TdpnCondicion.DoNotificarOncontextoCondicionChanged;
begin
  FEventoOnContextoCondicionChanged.Invoke(ID);
end;

function TdpnCondicion.Evaluar(AToken: IToken): Boolean;
begin
  Result :=  False;
end;

function TdpnCondicion.Evaluar(ATokens: IMarcadoTokens): Boolean;
begin
  Result := False;
end;

function TdpnCondicion.GetIsCondicionQueEsperaEvento: Boolean;
begin
  Result := False;
end;

function TdpnCondicion.GetIsEvaluacionNoDependeDeTokens: Boolean;
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

function TdpnCondicion.GetTransicion: ITransicion;
begin
  Result := FTransicion
end;

procedure TdpnCondicion.SetTransicion(const Value: ITransicion);
begin
  FTransicion := Value;
end;

end.

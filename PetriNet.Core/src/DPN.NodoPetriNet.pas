unit DPN.NodoPetriNet;

interface

uses
  Spring,

  DPN.Interfaces;

type
  TdpnNodoPetriNet = class(TInterfacedObject, INodoPetriNet)
  protected
    FID: integer;
    FNombre: string;
    FIsEnWarning: Boolean;
    FEnabled: Boolean;
    FEvento_OnEnabledChanged:  IEvent<EventoNodoPN_ValorBooleano>;

    function GetID: integer; virtual;
    procedure SetID(const Value: integer); virtual;

    function GetOnEnabledChanged: IEvent<EventoNodoPN_ValorBooleano>;
    function GetIsEnWarning: Boolean; virtual;
    function GetEnabled: Boolean; virtual;

    function GetNombre: string; virtual;
    procedure SetNombre(const Valor: string); virtual;

    procedure Stop; virtual;
    procedure Start; virtual;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    property ID: integer read GetID write SetID;
    property Nombre: string read GetNombre write SetNombre;
    property Enabled: boolean read GetEnabled;
    property OnEnabledChanged: IEvent<EventoNodoPN_ValorBooleano> read GetOnenabledChanged;
    property IsEnWarning: boolean read GetIsEnWarning;
  end;

implementation

uses
  System.SysUtils,

  DPN.Core;

{ TdpnObjetoBasico }

constructor TdpnNodoPetriNet.Create;
begin
  inherited;
  FID := DPNCore.GetNuevoID;
  FEnabled := False;
  FIsEnWarning := True;
  FEvento_OnEnabledChanged := DPNCore.CrearEvento<EventoNodoPN_ValorBooleano>;
end;

destructor TdpnNodoPetriNet.Destroy;
begin
  FEvento_OnEnabledChanged := nil;
  inherited;
end;

function TdpnNodoPetriNet.GetEnabled: Boolean;
begin
  Result := FEnabled;
end;

function TdpnNodoPetriNet.GetID: integer;
begin
  Result := FID;
end;

function TdpnNodoPetriNet.GetIsEnWarning: Boolean;
begin
  Result := FIsEnWarning;
end;

function TdpnNodoPetriNet.GetNombre: string;
begin
  Result := FNombre
end;

function TdpnNodoPetriNet.GetOnEnabledChanged: IEvent<EventoNodoPN_ValorBooleano>;
begin
  Result := FEvento_OnEnabledChanged
end;

procedure TdpnNodoPetriNet.SetID(const Value: integer);
begin
  FID := Value;
end;

procedure TdpnNodoPetriNet.SetNombre(const Valor: string);
begin
  Guard.CheckFalse(Valor.IsEmpty, 'El nombre no puede ser nul');
  if (FNombre <> Valor) then
  begin
    FNombre := Valor;
    //DAVE
  end;
end;

procedure TdpnNodoPetriNet.Start;
begin
  if not FEnabled then
  begin
    FEnabled := True;
    FEvento_OnEnabledChanged.Invoke(ID, FEnabled);
  end;
end;

procedure TdpnNodoPetriNet.Stop;
begin
  if FEnabled then
  begin
    FEnabled := False;
    FEvento_OnEnabledChanged.Invoke(ID, FEnabled);
  end;
end;

end.

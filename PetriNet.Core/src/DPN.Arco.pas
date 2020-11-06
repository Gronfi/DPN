unit DPN.Arco;

interface

uses
  Spring,
  Spring.Collections,

  DPN.Interfaces,
  DPN.NodoPetriNet;

type
  TdpnArco = class abstract(TdpnNodoPetriNet, IArco)
  protected
    FPeso: Integer;
    FPlaza: IPlaza;
    FTransicion: ITransicion;
    FIsHabilitado: Boolean;
    FPlazaIsEnabled: Boolean;
    FTransicionIsEnabled: Boolean;
    FIsForzado: Boolean;
    FValorForzado: Boolean;
    FEventoOnHabilitacionChanged: IEvent<EventoNodoPN_ValorBooleano>;

    function GetOnHabilitacionChanged: IEvent<EventoNodoPN_ValorBooleano>;

    function GetIsHabilitado: Boolean; virtual;
    function GetPeso: Integer; virtual;
    procedure SetPeso(const Value: Integer); virtual;
    function GetPlaza: IPlaza; virtual;
    procedure SetPlaza(Value: IPlaza); virtual;
    function GetTransicion: ITransicion; virtual;
    procedure SetTransicion(Value: ITransicion); virtual;

    procedure DoOnTokenCountChanged(const AID: integer; const ACount: Integer); virtual;
    procedure DoOnPlazaEnabledChanged(const AID: integer; const AEnabled: boolean); virtual;
    procedure DoOnTransicionEnabledChanged(const AID: integer; const AEnabled: boolean); virtual;

    function GetIsForzado: Boolean; virtual;
    procedure SetIsForzado(const Value: Boolean); virtual;

    function GetValorForzado: Boolean; virtual;
    procedure SetValorForzado(const Value: Boolean); virtual;

    function Evaluar(const ATokenCount: Integer): Boolean; virtual; abstract;
  public
    constructor Create; override;
    destructor Destroy; override;

    procedure Start; override;

    procedure DoOnTransicionando(ATokens: TListaTokens); overload; virtual; abstract;
    procedure DoOnTransicionando(ATokens: TArrayTokens); overload; virtual; abstract;

    property IsHabilitado: Boolean read GetIsHabilitado;
    property Peso: Integer read GetPeso write SetPeso;
    property Plaza: IPlaza read GetPlaza write SetPlaza;
    property Transicion: ITransicion read GetTransicion write SetTransicion;

    property OnHabilitacionChanged: IEvent<EventoNodoPN_ValorBooleano> read GetOnHabilitacionChanged;
    property IsForzado: Boolean read GetIsForzado write SetIsForzado;
    property ValorForzado: Boolean read GetValorForzado write SetValorForzado;
  end;

implementation

uses
  DPN.Core;

{ TdpnArco }

constructor TdpnArco.Create;
begin
  inherited;
  FIsHabilitado      := False;
  FIsForzado         := False;
  FValorForzado      := True;
  FPlazaIsEnabled    := False;
  FTransicionIsEnabled := False;
  FEventoOnHabilitacionChanged := DPNCore.CrearEvento<EventoNodoPN_ValorBooleano>;
end;

destructor TdpnArco.Destroy;
begin
  if Assigned(FPlaza) then
  begin

  end;
  inherited;
end;

procedure TdpnArco.DoOnPlazaEnabledChanged(const AID: integer; const AEnabled: boolean);
begin
  if (FPlazaIsEnabled <> AEnabled) then
  begin
    FPlazaIsEnabled := AEnabled;
    if FPlazaIsEnabled then
      Evaluar(FPlaza.TokenCount);
  end;
end;

procedure TdpnArco.DoOnTokenCountChanged(const AID: integer; const ACount: Integer);
var
  LOldValue, LNewValue: Boolean;
begin
  LOldValue := IsHabilitado;
  LNewValue := Evaluar(ACount);
  if (LOldValue <> LNewValue) then
    FEventoOnHabilitacionChanged.Invoke(ID, LNewValue);
end;

procedure TdpnArco.DoOnTransicionEnabledChanged(const AID: integer; const AEnabled: boolean);
begin
  if (FTransicionIsEnabled <> AEnabled) then
  begin
    FTransicionIsEnabled := AEnabled;
    if FTransicionIsEnabled and FPlazaIsEnabled then
      Evaluar(FPlaza.TokenCount);
  end;
end;

function TdpnArco.GetIsForzado: Boolean;
begin
  Result := FIsForzado;
end;

function TdpnArco.GetIsHabilitado: Boolean;
begin
  if (not FTransicionIsEnabled) or (not FPlazaIsEnabled) then
    Exit(False);
  if FIsForzado then
    Result := FValorForzado
  else Result := FIsHabilitado;
end;

function TdpnArco.GetOnHabilitacionChanged: IEvent<EventoNodoPN_ValorBooleano>;
begin
  Result := FEventoOnHabilitacionChanged
end;

function TdpnArco.GetPeso: Integer;
begin
  Result := FPeso;
end;

function TdpnArco.GetPlaza: IPlaza;
begin
  Result := FPlaza;
end;

function TdpnArco.GetTransicion: ITransicion;
begin
  Result := FTransicion;
end;

function TdpnArco.GetValorForzado: Boolean;
begin
  Result := FValorForzado
end;

procedure TdpnArco.SetIsForzado(const Value: Boolean);
begin
  FIsForzado := Value;
  FEventoOnHabilitacionChanged.Invoke(ID, IsHabilitado);
end;

procedure TdpnArco.SetPeso(const Value: Integer);
begin
  Guard.CheckTrue(Value >= 0, 'El peso del arco debe ser >= 0');
  FPeso := Value;
  if Assigned(FPlaza) then
    Evaluar(FPlaza.TokenCount);
end;

procedure TdpnArco.SetPlaza(Value: IPlaza);
begin
  if Assigned(FPlaza) then
  begin
    FPlaza.OnTokenCountChanged.Remove(DoOnTokenCountChanged);
    FPlaza.OnEnabledChanged.Remove(DoOnPlazaEnabledChanged);
  end;
  FPlaza := Value;
  if Assigned(FPlaza) then
  begin
    FPlaza.OnTokenCountChanged.Add(DoOnTokenCountChanged);
    FPlaza.OnEnabledChanged.Add(DoOnPlazaEnabledChanged);
    FPlazaIsEnabled := Plaza.Enabled;
    if Enabled and FPlazaIsEnabled and FTransicionIsEnabled then
    begin
      Evaluar(FPlaza.TokenCount);
      if FPlaza.TokenCount <> 0 then
        FEventoOnHabilitacionChanged.Invoke(ID, IsHabilitado);
    end;
  end
  else FPlazaIsEnabled := False;
end;

procedure TdpnArco.SetTransicion(Value: ITransicion);
begin
  if Assigned(FTransicion) then
  begin
    FTransicion.OnEnabledChanged.Remove(DoOnTransicionEnabledChanged);
  end;
  FTransicion := Value;
  if Assigned(FTransicion) then
  begin
    FTransicion.OnEnabledChanged.Add(DoOnTransicionEnabledChanged);
    FTransicionIsEnabled := FTransicion.Enabled;
  end
  else FTransicionIsEnabled := False;
end;

procedure TdpnArco.SetValorForzado(const Value: Boolean);
begin
  FValorForzado := Value;
  FEventoOnHabilitacionChanged.Invoke(ID, IsHabilitado);
  if Assigned(FPlaza) then
    Evaluar(FPlaza.TokenCount);
end;

procedure TdpnArco.Start;
begin
  inherited;
  if Assigned(FPlaza) then
  begin
    if FPlaza.Enabled then
    begin
      Evaluar(FPlaza.TokenCount);
      if FPlaza.TokenCount <> 0 then
        FEventoOnHabilitacionChanged.Invoke(ID, IsHabilitado);
    end;
  end;
end;

end.

unit DPN.ArcoOut;

interface

uses
  DPN.Interfaces,
  DPN.Arco;

type
  TdpnArcoOut = class(TdpnArco, IArcoOut)
  protected
    FGenerarTokensDeSistema: Boolean;
    function GetGenerarTokensDeSistema: Boolean;
    procedure SetGenerarTokensDeSistema(const Value: Boolean);

    procedure SetPeso(const Value: Integer); override;
  public
    constructor Create; override;
    function Evaluar(const ATokenCount: Integer): Boolean; override;

    procedure DoOnTransicionando(ATokens: TListaTokens); overload; override;
    procedure DoOnTransicionando(ATokens: TArrayTokens); overload; override;

    property GenerarTokensDeSistema: boolean read GetGenerarTokensDeSistema write SetGenerarTokensDeSistema;
  end;

implementation

uses
  Spring;

{ TdpnArcoOut }

function TdpnArcoOut.Evaluar(const ATokenCount: Integer): Boolean;
begin
  FIsHabilitado := (Plaza.TokenCount + Peso <= Plaza.Capacidad);
  Result        := FIsHabilitado;
end;

function TdpnArcoOut.GetGenerarTokensDeSistema: Boolean;
begin
  Result := FGenerarTokensDeSistema
end;

procedure TdpnArcoOut.SetGenerarTokensDeSistema(const Value: Boolean);
begin
  FGenerarTokensDeSistema := Value;
end;

procedure TdpnArcoOut.SetPeso(const Value: Integer);
begin
  Guard.CheckTrue(Value > 0, 'En un arco de tipo Out el peso debe ser > 0');
  inherited;
end;

procedure TdpnArcoOut.DoOnTransicionando(ATokens: TListaTokens);
begin
  Plaza.AddTokens(ATokens);
end;

constructor TdpnArcoOut.Create;
begin
  inherited;
  FGenerarTokensDeSistema := True;
end;

procedure TdpnArcoOut.DoOnTransicionando(ATokens: TArrayTokens);
begin
  Plaza.AddTokens(ATokens);
end;

end.

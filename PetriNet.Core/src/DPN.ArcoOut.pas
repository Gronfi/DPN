unit DPN.ArcoOut;

interface

uses
  Spring.Collections,

  DPN.Interfaces,
  DPN.Arco;

type
  TdpnArcoOut = class(TdpnArco, IArcoOut)
  protected
    FGenerarTokensDeSistema: Boolean;
    function GetGenerarTokensDeSistema: Boolean;
    procedure SetGenerarTokensDeSistema(const Value: Boolean);

    function GetPreCondicionesPlaza: IList<ICondicion>; virtual;

    procedure SetPeso(const Value: Integer); override;
    procedure SetPlaza(APlaza: IPlaza);
  public
    constructor Create; override;
    function Evaluar(const ATokenCount: Integer): Boolean; override;

    procedure DoOnTransicionando(ATokens: TListaTokens); overload; override;
    procedure DoOnTransicionando(ATokens: TArrayTokens); overload; override;

    property PreCondicionesPlaza: IList<ICondicion> read GetPreCondicionesPlaza;
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

function TdpnArcoOut.GetPreCondicionesPlaza: IList<ICondicion>;
begin
  Guard.CheckTrue(FPlaza <> nil, 'La plaza debe estar asignada');
  Result := FPlaza.PreCondiciones;
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

procedure TdpnArcoOut.SetPlaza(APlaza: IPlaza);
begin
  if Assigned(APlaza) then
  begin
    Guard.CheckTrue(APlaza.AceptaArcosOUT, 'La plaza no acepta arcos IN');
  end;
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

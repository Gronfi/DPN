unit DPN.MarcadoPlazasCantidadTokens;

interface
uses
  Spring,
  Spring.Collections,

  DPN.Interfaces;

type
  TdpnMarcadoPlazasCantidadTokens = class(TInterfacedObject, IMarcadoPlazasCantidadTokens)
  protected
    FTokenCount: integer;
    FPlazasTokens: IDictionary<Integer, Integer>;
    function GetMarcado: IDictionary<Integer, Integer>;
    function GetTokenCount: Integer;
  public
    constructor Create;
    destructor Destroy; override;

    procedure AddTokensPlaza(APlazaID: integer; ATokensCount: integer);
    procedure AddTokensPlazas(AMarcado: IDictionary<Integer, Integer>);

    property Marcado: IDictionary<Integer, Integer> read GetMarcado;
    property TokenCount: Integer read GetTokenCount;
  end;

implementation

{ TdpnMarcadoPlazasCantidadTokens }

procedure TdpnMarcadoPlazasCantidadTokens.AddTokensPlaza(APlazaID: Integer; ATokensCount: integer);
begin
  FPlazasTokens[APlazaID] := ATokensCount;
  Inc(FTokenCount, ATokensCount);
end;

procedure TdpnMarcadoPlazasCantidadTokens.AddTokensPlazas(AMarcado: IDictionary<Integer, Integer>);
var
  LPlaza: integer;
begin
  for LPlaza in AMarcado.Keys do
  begin
    AddTokensPlaza(LPlaza, AMarcado[LPlaza])
  end;
end;

constructor TdpnMarcadoPlazasCantidadTokens.Create;
begin
  inherited;
  FPlazasTokens := TCollections.CreateDictionary<Integer, Integer>;
  FTokenCount := 0;
end;

destructor TdpnMarcadoPlazasCantidadTokens.Destroy;
begin
  FPlazasTokens := nil;
  inherited;
end;

function TdpnMarcadoPlazasCantidadTokens.GetMarcado: IDictionary<Integer, Integer>;
begin
  Result := FPlazasTokens
end;

function TdpnMarcadoPlazasCantidadTokens.GetTokenCount: Integer;
begin
  Result := FTokenCount;
end;

end.

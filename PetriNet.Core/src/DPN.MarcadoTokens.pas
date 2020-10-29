unit DPN.MarcadoTokens;

interface

uses
  Spring,
  Spring.Collections,

  DPN.Interfaces;

type
  TdpnMarcadoTokens = class(TInterfacedObject, IMarcadoTokens)
  protected
    FTokenCount: integer;
    FPlazasTokens: IDictionary<IPlaza, IList<IToken>>;
    function GetMarcado: IDictionary<IPlaza, IList<IToken>>;
    function GetTokenCount: Integer;
  public
    constructor Create;
    destructor Destroy; override;

    procedure AddPlaza(APlaza: IPlaza);
    procedure AddTokenPlaza(APlaza: IPlaza; AToken: IToken);
    procedure AddTokensPlaza(APlaza: IPlaza; ATokens: IList<IToken>); overload;
    procedure AddTokensPlaza(APlaza: IPlaza; ATokens: IEnumerable<IToken>); overload;
    procedure AddTokensMarcado(AMarcado: IMarcadoTokens);

    procedure RemovePlaza(APlaza: IPlaza);
    procedure RemoveToken(AToken: IToken);
    procedure RemoveTokenPlaza(APlaza: IPlaza; AToken: IToken);
    procedure RemoveTokensPlaza(APlaza: IPlaza); overload;
    procedure RemoveTokensPlaza(APlaza: IPlaza; ATokens: IList<IToken>); overload;

    procedure Clear;

    property Marcado: IDictionary<IPlaza, IList<IToken>> read GetMarcado;
    property TokenCount: Integer read GetTokenCount;
  end;

implementation

{ TMarcadoTokens }

procedure TdpnMarcadoTokens.AddPlaza(APlaza: IPlaza);
var
  LTokensPlaza: IList<IToken>;
begin
  if not FPlazasTokens.TryGetValue(APlaza, LTokensPlaza) then
  begin
    LTokensPlaza := TCollections.CreateList<IToken>;
    FPlazasTokens.Add(APlaza, LTokensPlaza);
  end;
end;

procedure TdpnMarcadoTokens.AddTokenPlaza(APlaza: IPlaza; AToken: IToken);
var
  LTokensPlaza: IList<IToken>;
begin
  if not FPlazasTokens.TryGetValue(APlaza, LTokensPlaza) then
  begin
    LTokensPlaza := TCollections.CreateList<IToken>;
    FPlazasTokens.Add(APlaza, LTokensPlaza);
  end;
  LTokensPlaza.Add(AToken);
  Inc(FTokenCount);
end;

procedure TdpnMarcadoTokens.AddTokensPlaza(APlaza: IPlaza; ATokens: IList<IToken>);
var
  LTokensPlaza: IList<IToken>;
begin
  if not FPlazasTokens.TryGetValue(APlaza, LTokensPlaza) then
  begin
    LTokensPlaza := TCollections.CreateList<IToken>;
    FPlazasTokens.Add(APlaza, LTokensPlaza);
  end;
  LTokensPlaza.AddRange(ATokens);
  Inc(FTokenCount, ATokens.Count);
end;

procedure TdpnMarcadoTokens.AddTokensMarcado(AMarcado: IMarcadoTokens);
var
  LPlaza: IPlaza;
begin
  for LPlaza in AMarcado.Marcado.Keys do
  begin
    AddTokensPlaza(LPlaza, AMarcado.Marcado[LPlaza]);
  end;
end;

procedure TdpnMarcadoTokens.AddTokensPlaza(APlaza: IPlaza; ATokens: IEnumerable<IToken>);
var
  LTokensPlaza: IList<IToken>;
begin
  if not FPlazasTokens.TryGetValue(APlaza, LTokensPlaza) then
  begin
    LTokensPlaza := TCollections.CreateList<IToken>;
    FPlazasTokens.Add(APlaza, LTokensPlaza);
  end;
  LTokensPlaza.AddRange(ATokens);
  Inc(FTokenCount, ATokens.Count);
end;

procedure TdpnMarcadoTokens.Clear;
begin
  FPlazasTokens.Clear;
  FTokenCount := 0;
end;

constructor TdpnMarcadoTokens.Create;
begin
  inherited;
  FPlazasTokens := TCollections.CreateDictionary<IPlaza, IList<IToken>>;
  FTokenCount := 0;
end;

destructor TdpnMarcadoTokens.Destroy;
begin
  FPlazasTokens := nil;
  inherited;
end;

function TdpnMarcadoTokens.GetMarcado: IDictionary<IPlaza, IList<IToken>>;
begin
  Result := FPlazasTokens
end;

function TdpnMarcadoTokens.GetTokenCount: Integer;
begin
  Result := FTokenCount;
end;

procedure TdpnMarcadoTokens.RemovePlaza(APlaza: IPlaza);
var
  LTokensPlaza: IList<IToken>;
begin
  if FPlazasTokens.TryGetValue(APlaza, LTokensPlaza) then
  begin
    Dec(FTokenCount, LTokensPlaza.Count);
    FPlazasTokens.Remove(APlaza);
  end;
end;

procedure TdpnMarcadoTokens.RemoveToken(AToken: IToken);
var
  LPlaza: IPlaza;
  LTokensPlaza: IList<IToken>;
begin
  for LPlaza in FPlazasTokens.Keys do
  begin
    if FPlazasTokens[LPlaza].Contains(AToken) then
    begin
      FPlazasTokens[LPlaza].Remove(AToken);
      Dec(FTokenCount);
      Break;
    end;
  end;
end;

procedure TdpnMarcadoTokens.RemoveTokenPlaza(APlaza: IPlaza; AToken: IToken);
var
  LTokensPlaza: IList<IToken>;
begin
  if FPlazasTokens.TryGetValue(APlaza, LTokensPlaza) then
  begin
    LTokensPlaza.Remove(AToken);
    Dec(FTokenCount);
  end;
end;

procedure TdpnMarcadoTokens.RemoveTokensPlaza(APlaza: IPlaza);
var
  LTokensPlaza: IList<IToken>;
begin
  if FPlazasTokens.TryGetValue(APlaza, LTokensPlaza) then
  begin
    Dec(FTokenCount, LTokensPlaza.Count);
    LTokensPlaza.Clear;
  end;
end;

procedure TdpnMarcadoTokens.RemoveTokensPlaza(APlaza: IPlaza; ATokens: IList<IToken>);
var
  LTokensPlaza: IList<IToken>;
  LToken: IToken;
begin
  if FPlazasTokens.TryGetValue(APlaza, LTokensPlaza) then
  begin
    for LToken in ATokens do
      if LTokensPlaza.Remove(LToken) then
        Dec(FTokenCount);
  end;
end;

end.

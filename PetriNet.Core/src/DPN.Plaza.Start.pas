unit DPN.Plaza.Start;

interface

uses
  Spring,
  Spring.Collections,

  DPN.Interfaces,
  DPN.Plaza;

type
  TdpnPlazaStart = class (TdpnPlaza)
  protected
    FEjecutado: Boolean;
    FGeneracionContinua: Boolean;
    FGenerarTokenDeSistema: Boolean;

    function GetCapacidad: Integer; override;

    function GetGeneracionContinua: boolean; virtual;
    procedure SetGeneracionContinua(const AValor: boolean); virtual;

    function GetGenerarTokensDeSistema: Boolean; virtual;
    procedure SetGenerarTokensDeSistema(const Value: Boolean); virtual;

    function GetAceptaArcosOUT: Boolean; override;
    procedure CrearToken;
  public
    constructor Create; override;

    procedure EliminarToken(AToken: IToken); override;
    procedure EliminarTokens(ATokens: TListaTokens); overload; override;
    procedure EliminarTokens(ATokens: TArrayTokens); overload; override;
    procedure EliminarTokens(const ACount: integer); overload; override;
    procedure EliminarTodosTokens; override;

    procedure Start; override;
    procedure Reset; override;

    property GeneracionContinua: boolean read GetGeneracionContinua write SetGeneracionContinua;
    property GenerarTokensDeSistema: boolean read GetGenerarTokensDeSistema write SetGenerarTokensDeSistema;
  end;

implementation

uses
  DPN.TokenColoreado,
  DPN.TokenSistema;

{ TdpnPlazaStart }

procedure TdpnPlazaStart.CrearToken;
var
  LToken: IToken;
begin
  if (FTokens.Count = 0) and (FEjecutado = false) then
  begin
    case GenerarTokensDeSistema of
      False: LToken := TdpnTokenColoreado.Create;
      True: LToken := TdpnTokenSistema.Create;
    end;
    FTokens.Add(LToken);
    if not GeneracionContinua then
      FEjecutado := True;
  end;
end;

constructor TdpnPlazaStart.Create;
begin
  inherited;
  FEjecutado := False;
  FGenerarTokenDeSistema := False;
  FGeneracionContinua := False;
end;

procedure TdpnPlazaStart.EliminarTodosTokens;
begin
  inherited;
  CrearToken;
end;

procedure TdpnPlazaStart.EliminarToken(AToken: IToken);
begin
  inherited;
  CrearToken;
end;

procedure TdpnPlazaStart.EliminarTokens(ATokens: TListaTokens);
begin
  inherited;
  CrearToken;
end;

procedure TdpnPlazaStart.EliminarTokens(ATokens: TArrayTokens);
begin
  inherited;
  CrearToken;
end;

procedure TdpnPlazaStart.EliminarTokens(const ACount: integer);
begin
  inherited;
  CrearToken;
end;

function TdpnPlazaStart.GetAceptaArcosOut: Boolean;
begin
  Result := False;
end;

function TdpnPlazaStart.GetCapacidad: Integer;
begin
  Result := 1;
end;

function TdpnPlazaStart.GetGeneracionContinua: boolean;
begin
  Result := FGeneracionContinua
end;

function TdpnPlazaStart.GetGenerarTokensDeSistema: Boolean;
begin
  Result := FGenerarTokenDeSistema
end;

procedure TdpnPlazaStart.Reset;
begin
  FEjecutado := False;
  CrearToken;
end;

procedure TdpnPlazaStart.SetGeneracionContinua(const AValor: boolean);
begin
  FGeneracionContinua := AValor
end;

procedure TdpnPlazaStart.SetGenerarTokensDeSistema(const Value: Boolean);
begin
  FGenerarTokenDeSistema := Value;
end;

procedure TdpnPlazaStart.Start;
begin
  CrearToken;
  inherited;
end;

end.

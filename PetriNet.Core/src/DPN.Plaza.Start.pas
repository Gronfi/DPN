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
    FGenerarTokenDeSistema: Boolean;

    function GetCapacidad: Integer; override;

    function GetGenerarTokensDeSistema: Boolean;
    procedure SetGenerarTokensDeSistema(const Value: Boolean);

    function GetAceptaArcosOUT: Boolean; override;
    procedure CrearToken;
  public
    constructor Create; override;

    procedure Start; override;
    procedure Reset; override;

    property GenerarTokensDeSistema: boolean read GetGenerarTokensDeSistema write SetGenerarTokensDeSistema;
  end;

implementation

uses
  DPN.TokenSistema;

{ TdpnPlazaStart }

procedure TdpnPlazaStart.CrearToken;
var
  LToken: IToken;
begin
  if (FTokens.Count = 0) and (FEjecutado = false) then
  begin
    LToken := TdpnTokenSistema.Create;
    FTokens.Add(LToken);
    FEjecutado := True;
  end;
end;

constructor TdpnPlazaStart.Create;
begin
  inherited;
  FEjecutado := False;
  FGenerarTokenDeSistema := False;
end;

function TdpnPlazaStart.GetAceptaArcosOut: Boolean;
begin
  Result := False;
end;

function TdpnPlazaStart.GetCapacidad: Integer;
begin
  Result := 1;
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

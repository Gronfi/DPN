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

    function GetAceptaArcosOUT: Boolean; override;
    procedure CrearToken;
  public
    constructor Create; override;

    procedure Reset; override;
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
  CrearToken;
end;

function TdpnPlazaStart.GetAceptaArcosOUT: Boolean;
begin
  Result := False;
end;

procedure TdpnPlazaStart.Reset;
begin
  FEjecutado := False;
  CrearToken;
end;

end.

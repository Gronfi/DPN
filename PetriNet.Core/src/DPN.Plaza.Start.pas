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

    function GetAceptaArcosOut: Boolean; override;
    procedure CrearToken;
  public
    constructor Create; override;

    procedure Reset; override;

    procedure AddToken(AToken: IToken); override;
    procedure AddTokens(ATokens: TListaTokens); overload; override;
    procedure AddTokens(ATokens: TArrayTokens); overload; override;

    procedure AddPreCondicion(ACondicion: ICondicion); override;
    procedure AddPreCondiciones(ACondiciones: TCondiciones); overload; override;
    procedure AddPreCondiciones(ACondiciones: TArrayCondiciones); overload; override;
    procedure EliminarPreCondicion(ACondicion: ICondicion); override;
    procedure EliminarPreCondiciones(ACondiciones: TCondiciones); overload; override;
    procedure EliminarPreCondiciones(ACondiciones: TArrayCondiciones); overload; override;
  end;

implementation

uses
  DPN.TokenSistema;

{ TdpnPlazaStart }

procedure TdpnPlazaStart.AddPreCondicion(ACondicion: ICondicion);
begin
  ;
end;

procedure TdpnPlazaStart.AddPreCondiciones(ACondiciones: TArrayCondiciones);
begin
  ;
end;

procedure TdpnPlazaStart.AddPreCondiciones(ACondiciones: TCondiciones);
begin
  ;
end;

procedure TdpnPlazaStart.AddToken(AToken: IToken);
begin
  ;
end;

procedure TdpnPlazaStart.AddTokens(ATokens: TListaTokens);
begin
  ;
end;

procedure TdpnPlazaStart.AddTokens(ATokens: TArrayTokens);
begin
  ;
end;

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

procedure TdpnPlazaStart.EliminarPreCondicion(ACondicion: ICondicion);
begin
  ;
end;

procedure TdpnPlazaStart.EliminarPreCondiciones(ACondiciones: TCondiciones);
begin
  ;
end;

procedure TdpnPlazaStart.EliminarPreCondiciones(ACondiciones: TArrayCondiciones);
begin
  ;
end;

function TdpnPlazaStart.GetAceptaArcosOut: Boolean;
begin
  Result := False;
end;

procedure TdpnPlazaStart.Reset;
begin
  FEjecutado := False;
  CrearToken;
end;

end.

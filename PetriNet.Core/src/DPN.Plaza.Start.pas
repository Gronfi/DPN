unit DPN.Plaza.Start;

interface

uses
  System.JSON,

  Spring,
  Spring.Collections,

  DPN.Interfaces,
  DPN.Plaza;

type
  TdpnPlazaStart = class (TdpnPlaza)
  protected
    FEjecutado: Boolean;
    FPrimeraVez: Boolean;
    FGeneracionContinua: Boolean;
    FGenerarTokenDeSistema: Boolean;

    function GetCapacidad: Integer; override;

    function GetGeneracionContinua: boolean; virtual;
    procedure SetGeneracionContinua(const AValor: boolean); virtual;

    function GetGenerarTokensDeSistema: Boolean; virtual;
    procedure SetGenerarTokensDeSistema(const Value: Boolean); virtual;

    function GetAceptaArcosOUT: Boolean; override;
    procedure CrearToken;

    procedure AddToken(AToken: IToken); override;
  public
    constructor Create; override;

    Procedure CargarDeJSON(NodoJson_IN: TJSONObject); override;
    Procedure FormatoJSON(NodoJson_IN: TJSONObject); overload; override;

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
  DPN.Core,
  DPN.TokenColoreado,
  DPN.TokenSistema;

{ TdpnPlazaStart }

procedure TdpnPlazaStart.AddToken(AToken: IToken);
begin
  FTokens.Add(AToken);
  AToken.PetriNetController := PetriNetController;
  AToken.Plaza := Self;
  if FPrimeraVez then
  begin
    FPrimeraVez := False;
    FEventoOnTokenCountChanged.Invoke(ID, TokenCount);
  end;
end;

procedure TdpnPlazaStart.CargarDeJSON(NodoJson_IN: TJSONObject);
begin
  inherited;
  DPNCore.CargarCampoDeNodo<boolean>(NodoJson_IN, 'GeneracionContinua', ClassName, FGeneracionContinua);
  DPNCore.CargarCampoDeNodo<boolean>(NodoJson_IN, 'GenerarTokensDeSistema', ClassName, FGenerarTokenDeSistema);
end;

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
    AddToken(LToken);
    if not GeneracionContinua then
    begin
      FEjecutado := True;
      FEventoOnTokenCountChanged.Invoke(ID, TokenCount);
    end;
  end
  else FEventoOnTokenCountChanged.Invoke(ID, TokenCount);
end;

constructor TdpnPlazaStart.Create;
begin
  inherited;
  FEjecutado := False;
  FPrimeraVez := True;
  FGenerarTokenDeSistema := False;
  FGeneracionContinua := False;
end;

procedure TdpnPlazaStart.EliminarTodosTokens;
begin
  FTokens.Clear;
  CrearToken;
end;

procedure TdpnPlazaStart.EliminarToken(AToken: IToken);
begin
  FTokens.Remove(AToken);
  CrearToken;
end;

procedure TdpnPlazaStart.EliminarTokens(ATokens: TListaTokens);
begin
  FTokens.RemoveRange(ATokens.ToArray);
  CrearToken;
end;

procedure TdpnPlazaStart.EliminarTokens(ATokens: TArrayTokens);
begin
  FTokens.RemoveRange(ATokens);
  CrearToken;
end;

procedure TdpnPlazaStart.EliminarTokens(const ACount: integer);
begin
  FTokens.DeleteRange(0, ACount);
  CrearToken;
end;

procedure TdpnPlazaStart.FormatoJSON(NodoJson_IN: TJSONObject);
begin
  inherited;
  NodoJson_IN.AddPair('GeneracionContinua', TJSONBool.Create(GeneracionContinua));
  NodoJson_IN.AddPair('GenerarTokensDeSistema', TJSONBool.Create(GenerarTokensDeSistema));
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

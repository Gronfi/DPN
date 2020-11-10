unit DPN.ArcoIn;

interface

uses
  System.JSON,

  DPN.Interfaces,
  DPN.Arco;

type
  TdpnArcoIn = class(TdpnArco, IArcoIn)
  protected
    FIsInhibidor: Boolean;
    FPesoEvaluar: Integer;

    function GetIsInhibidor: Boolean; virtual;
    procedure SetIsInhibidor(const Value: Boolean); virtual;

    function GetPesoEvaluar: Integer; virtual;
    procedure SetPesoEvaluar(const Value: Integer); virtual;
    procedure SetPlaza(APlaza: IPlaza); override;
  public
    constructor Create; override;

    Procedure CargarDeJSON(NodoJson_IN: TJSONObject); override;
    Procedure FormatoJSON(NodoJson_IN: TJSONObject); overload; override;

    function Evaluar(const ATokenCount: Integer): Boolean; override;

    function ObtenerTokensEvaluacion: IMarcadoTokens; virtual;

    procedure DoOnTransicionando(ATokens: TListaTokens); overload; override;
    procedure DoOnTransicionando(ATokens: TArrayTokens); overload; override;

    property PesoEvaluar: Integer read GetPesoEvaluar write SetPesoEvaluar;
    property IsInhibidor: boolean read GetIsInhibidor write SetIsInhibidor;
  end;


implementation

uses
  System.SysUtils,

  Spring,
  Spring.Collections,

  DPN.Core,
  DPN.MarcadoTokens;

{ TdpnArcoIn }

procedure TdpnArcoIn.CargarDeJSON(NodoJson_IN: TJSONObject);
begin
  inherited;
  DPNCore.CargarCampoDeNodo<integer>(NodoJson_IN, 'PesoEvaluar', ClassName, FPesoEvaluar);
  DPNCore.CargarCampoDeNodo<boolean>(NodoJson_IN, 'IsInhibidor', ClassName, FIsInhibidor);
end;

constructor TdpnArcoIn.Create;
begin
  inherited;
  FPesoEvaluar       := 0;
  FIsInhibidor       := False;
end;

procedure TdpnArcoIn.DoOnTransicionando(ATokens: TListaTokens);
begin
  case FIsInhibidor of
    True: ; //nada
    False: FPlaza.EliminarTokens(ATokens);
  end;
end;

procedure TdpnArcoIn.DoOnTransicionando(ATokens: TArrayTokens);
begin
  case FIsInhibidor of
    True: ; //nada
    False: FPlaza.EliminarTokens(ATokens);
  end;
end;

function TdpnArcoIn.Evaluar(const ATokenCount: Integer): Boolean;
begin
  case FIsInhibidor of
    True: FIsHabilitado := not(ATokenCount > 0);
    False: FIsHabilitado := (ATokenCount >= Peso);
  end;
  Result := FIsHabilitado;
end;

procedure TdpnArcoIn.FormatoJSON(NodoJson_IN: TJSONObject);
begin
  inherited;
  NodoJson_IN.AddPair('PesoEvaluar', TJSONNumber.Create(PesoEvaluar));
  NodoJson_IN.AddPair('IsInhibidor', TJSONBool.Create(IsInhibidor));
end;

function TdpnArcoIn.GetIsInhibidor: Boolean;
begin
  Result := FIsInhibidor;
end;

function TdpnArcoIn.GetPesoEvaluar: Integer;
begin
  Result := FPesoEvaluar;
end;

function TdpnArcoIn.ObtenerTokensEvaluacion: IMarcadoTokens;
begin
  Result := TdpnMarcadoTokens.Create;
  case FIsInhibidor of
    False:
      begin
        if (FPlaza.TokenCount > 0) and (PesoEvaluar > 0) then
        begin
          Result.AddTokensPlaza(FPlaza, FPlaza.Tokens.Take(PesoEvaluar));
        end;
      end;
  end;
end;

procedure TdpnArcoIn.SetIsInhibidor(const Value: Boolean);
begin
  FIsInhibidor := Value;
  if Assigned(FPlaza) then
    Evaluar(FPlaza.TokenCount);
end;

procedure TdpnArcoIn.SetPesoEvaluar(const Value: Integer);
begin
  Guard.CheckTrue(Value >= 0, 'El peso a evaluar debe ser >= 0');
  FPesoEvaluar := Value;
  if Assigned(FPlaza) then
    Evaluar(FPlaza.TokenCount);
end;

procedure TdpnArcoIn.SetPlaza(APlaza: IPlaza);
begin
  if Assigned(APlaza) then
  begin
    Guard.CheckTrue(APlaza.AceptaArcosIN, 'La plaza no acepta arcos IN');
  end;
  inherited;
end;

end.

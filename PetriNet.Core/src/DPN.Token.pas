unit DPN.Token;

interface

uses
  System.Rtti,

  Spring.Collections,

  DPN.Interfaces;

type
  TdpnToken = class(TInterfacedObject, IToken)
  protected
    FID: int64;
    FPlaza: IPlaza;

    FTablaVariables: IDictionary<String, TValue>;

    FCantidadCambiosPlaza: int64;
    FMomentoCreacion: int64;
    FMomentoCambioPlaza: int64;

    function GetID: int64;

    function GetVariable(const AKey: string): TValue; virtual;
    procedure SetVariable(const AKey: string; const AValor: TValue); virtual;

    function GetTablaVariables: IDictionary<String, TValue>; virtual;

    function GetCantidadCambiosPlaza: int64;

    function GetMomentoCreacion: int64;

    function GetMomentoCambioPlaza: int64;

    function GetPlaza: IPlaza;
    procedure SetPlaza(APlaza: IPlaza);
  public
    constructor Create;
    destructor Destroy; override;

    function Clon: IToken;

    function LogAsString: string; virtual;

    property ID: int64 read GetID;
    property Plaza: IPlaza read GetPlaza write SetPlaza;
    property Variable[const AKey: string]: TValue read GetVariable write SetVariable; default;
    property TablaVariables: IDictionary<String, TValue> read GetTablaVariables;
    property CantidadCambiosPlaza: int64 read GetCantidadCambiosPlaza;
    property MomentoCreacion: int64 read GetMomentoCreacion;
    property MomentoCambioPlaza: int64 read GetMomentoCambioPlaza;
  end;

implementation

uses
  System.SysUtils,

  Event.Engine.Utils,
  DPN.Core;

{ TdpnToken }

function TdpnToken.Clon: IToken;
begin
  //DAVE
end;

constructor TdpnToken.Create;
begin
  inherited;
  FID                    := DPNCore.GetNuevoTokenID;
  FMomentoCreacion       := Utils.ElapsedMiliseconds;
  FMomentoCambioPlaza    := Utils.ElapsedMiliseconds;
  FCantidadCambiosPlaza  := 0;
  FTablaVariables        := TCollections.CreateDictionary<String, TValue>;
end;

destructor TdpnToken.Destroy;
begin
  inherited;
end;

function TdpnToken.GetCantidadCambiosPlaza: int64;
begin
  Result := FCantidadCambiosPlaza
end;

function TdpnToken.GetID: int64;
begin
  Result := FID
end;

function TdpnToken.GetMomentoCambioPlaza: int64;
begin
  Result := FMomentoCambioPlaza;
end;

function TdpnToken.GetMomentoCreacion: int64;
begin
  Result := FMomentoCreacion
end;

function TdpnToken.GetPlaza: IPlaza;
begin
  Result := FPlaza;
end;

function TdpnToken.GetTablaVariables: IDictionary<String, TValue>;
begin
  Result := FTablaVariables
end;

function TdpnToken.GetVariable(const AKey: string): TValue;
begin
  FTablaVariables.TryGetValue(AKey, Result)
end;

function TdpnToken.LogAsString: string;
var
  LKey: string;
begin
  Result := '[ID]' + ID.ToString + '[ClassName]' + ClassName + '[Plaza]' + Plaza.Nombre + '[CantidadCambiosPlaza]' + CantidadCambiosPlaza.ToString + '[MomentoCreacion]' + MomentoCreacion.ToString +
            '[MomentoCambioPlaza]' + MomentoCambioPlaza.ToString;
  Result := Result + #13#10 + '---TablaVariables:';
  for LKey in TablaVariables.Keys do
    Result := Result + #13#10 + '  |--' + LKey + ': ' + TablaVariables[LKey].ToString;
end;

procedure TdpnToken.SetPlaza(APlaza: IPlaza);
begin
  FPlaza := APlaza;
  if Assigned(FPlaza) then
  begin
    FMomentoCambioPlaza := Utils.ElapsedMiliseconds;
    Inc(FCantidadCambiosPlaza);
  end;
end;

procedure TdpnToken.SetVariable(const AKey: string; const AValor: TValue);
begin
  FTablaVariables[AKey] := AValor;
end;

end.

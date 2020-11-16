unit DPN.Token;

interface

uses
  System.JSON,
  System.Rtti,

  Spring.Collections,

  DPN.Interfaces;

type
  TdpnToken = class(TInterfacedObject, IToken)
  protected
    FID: int64;
    FPetriNetController: TdpnPetriNetCoordinadorBase;
    FPlaza: IPlaza;

    FTablaVariables: IDictionary<String, TValue>;

    FCantidadCambiosPlaza: int64;
    FMomentoCreacion: int64;
    FMomentoCambioPlaza: int64;

    function GetID: int64;

    function GetVariable(const AKey: string): TValue; virtual;
    procedure SetVariable(const AKey: string; const AValor: TValue); virtual;

    function GetPetriNetController: TdpnPetriNetCoordinadorBase; virtual;
    procedure SetPetriNetController(APetriNetController: TdpnPetriNetCoordinadorBase); virtual;

    function GetTablaVariables: IDictionary<String, TValue>; virtual;

    function GetCantidadCambiosPlaza: int64;

    function GetMomentoCreacion: int64;

    function GetMomentoCambioPlaza: int64;

    function GetPlaza: IPlaza;
    procedure SetPlaza(APlaza: IPlaza);
  public
    constructor Create;
    destructor Destroy; override;

    function GetAsObject: TObject;

    Procedure CargarDeJSON(NodoJson_IN: TJSONObject); virtual;
    Function FormatoJSON: TJSONObject; overload; virtual;
    Procedure FormatoJSON(NodoJson_IN: TJSONObject); overload; virtual;
    function Clon: ISerializable; virtual;

    Procedure CargarEstadoDeJSON(NodoJson_IN: TJSONObject); virtual;
    Function FormatoEstadoJSON: TJSONObject; overload; virtual;
    Procedure FormatoEstadoJSON(NodoJson_IN: TJSONObject); overload; virtual;

    function LogAsString: string; virtual;

    property ID: int64 read GetID;
    property Plaza: IPlaza read GetPlaza write SetPlaza;
    property Variable[const AKey: string]: TValue read GetVariable write SetVariable; default;
    property TablaVariables: IDictionary<String, TValue> read GetTablaVariables;
    property CantidadCambiosPlaza: int64 read GetCantidadCambiosPlaza;
    property MomentoCreacion: int64 read GetMomentoCreacion;
    property MomentoCambioPlaza: int64 read GetMomentoCambioPlaza;
    property PetriNetController: TdpnPetriNetCoordinadorBase read GetPetriNetController write SetPetriNetController;
  end;

implementation

uses
  System.SysUtils,

  Event.Engine.Utils,
  DPN.Core;

{ TdpnToken }

procedure TdpnToken.CargarDeJSON(NodoJson_IN: TJSONObject);
begin
  ;
end;

//la asignacion de la plaza se hace a otro nivel
procedure TdpnToken.CargarEstadoDeJSON(NodoJson_IN: TJSONObject);
var
  LDatos: TJSONArray;
  LNodoJSon: TJSONObject;
  I, J: integer;
begin
  inherited;
  DPNCore.CargarCampoDeNodo<int64>(NodoJson_IN, 'MomentoCreacion', ClassName, FMomentoCreacion);
  DPNCore.CargarCampoDeNodo<int64>(NodoJson_IN, 'MomentoCambioPlaza', ClassName, FMomentoCambioPlaza);
  DPNCore.CargarCampoDeNodo<int64>(NodoJson_IN, 'CantidadCambiosPlaza', ClassName, FCantidadCambiosPlaza);
  FTablaVariables.Clear;
  if NodoJson_IN.TryGetValue<TJSONArray>('TablaVariables', LDatos) then
  begin
    for I := 0 to LDatos.Count - 1 do
    begin
      LNodoJSon := LDatos.Items[I] as TJSONObject;
      for J := 0 to LNodoJSon.Count - 1 do
      begin
        FTablaVariables[LNodoJSon.Pairs[J].JsonString.Value] := LNodoJSon.Pairs[J].JsonValue;
      end;
    end;
  end;
end;

function TdpnToken.Clon: ISerializable;
var
  LNew: ISerializable;
  OJSon: TJSONObject;
begin
  OJSon := Self.FormatoJSON;
  try
    LNew := DPNCore.CrearInstancia<ISerializable>(OJSon);
    LNew.CargarDeJSON(OJSon);
  finally
    OJSon.Destroy;
  end;
  Result := LNew;
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

procedure TdpnToken.FormatoEstadoJSON(NodoJson_IN: TJSONObject);
var
  LDatos: TJSONArray;
  LKey: string;
begin
  NodoJson_IN.AddPair('ID', TJsonNumber.Create(ID));
  NodoJson_IN.AddPair('Plaza', TJsonString.Create(Plaza.Nombre));
  NodoJson_IN.AddPair('MomentoCreacion', TJsonNumber.Create(FMomentoCreacion));
  NodoJson_IN.AddPair('MomentoCambioPlaza', TJsonNumber.Create(FMomentoCambioPlaza));
  NodoJson_IN.AddPair('CantidadCambiosPlaza', TJsonNumber.Create(FCantidadCambiosPlaza));
  LDatos := TJSONArray.Create;
  for LKey in FTablaVariables.Keys.Ordered do
  begin
    LDatos.AddElement(TJSONObject.Create(TJSonPair.Create(LKey, FTablaVariables[LKey].ToString)));
  end;
  NodoJson_IN.AddPair('TablaVariables', LDatos);
end;

function TdpnToken.FormatoEstadoJSON: TJSONObject;
begin
  Result := DPNCore.CrearNodoJSONObjeto(Self);
  FormatoEstadoJSON(Result);
end;

procedure TdpnToken.FormatoJSON(NodoJson_IN: TJSONObject);
var
  LDatos: TJSONArray;
  LKey: string;
begin
  NodoJson_IN.AddPair('ID', TJsonNumber.Create(ID));
  NodoJson_IN.AddPair('Plaza', TJsonString.Create(Plaza.Nombre));
  LDatos := TJSONArray.Create;
  for LKey in FTablaVariables.Keys.Ordered do
  begin
    LDatos.AddElement(TJSONObject.Create(TJSonPair.Create(LKey, FTablaVariables[LKey].ToString)));
  end;
  NodoJson_IN.AddPair('TablaVariables', LDatos);
end;

function TdpnToken.FormatoJSON: TJSONObject;
begin
  Result := DPNCore.CrearNodoJSONObjeto(Self);
  FormatoJSON(Result);
end;

function TdpnToken.GetAsObject: TObject;
begin
  Result := Self
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

function TdpnToken.GetPetriNetController: TdpnPetriNetCoordinadorBase;
begin
  Result := FPetriNetController
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

procedure TdpnToken.SetPetriNetController(APetriNetController: TdpnPetriNetCoordinadorBase);
begin
  if FPetriNetController <> APetriNetController then
  begin
    FPetriNetController := APetriNetController;
  end;
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

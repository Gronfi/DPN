unit DPN.NodoPetriNet;

interface

uses
  System.JSON,

  Spring,
  Spring.Collections,

  DPN.Interfaces;

type
  TdpnNodoPetriNet = class abstract(TInterfacedObject, INodoPetriNet)
  protected
    FID: integer;
    FPetriNetController: TdpnPetriNetCoordinadorBase;
    FModelo: IModelo;
    FNombreReducido: string;
    FNombreModelo: string;
    FEvento_OnNombreChanged:  IEvent<EventoNodoPN_ValorString>;
    FIsEnWarning: Boolean;
    FEnabled: Boolean;
    FEvento_OnEnabledChanged:  IEvent<EventoNodoPN_ValorBooleano>;
    FEvento_OnReseted:  IEvent<EventoNodoPN>;

    function GetID: integer; virtual;
    procedure SetID(const Value: integer); virtual;

    function GetOnEnabledChanged: IEvent<EventoNodoPN_ValorBooleano>;
    function GetOnReseted: IEvent<EventoNodoPN>;
    function GetIsEnWarning: Boolean; virtual;
    function GetEnabled: Boolean; virtual;

    function GetNombre: string; virtual;
    function GetNombreReducido: string; virtual;
    procedure SetNombreReducido(const Valor: string); virtual;
    function GetOnNombreChanged: IEvent<EventoNodoPN_ValorString>; virtual;
    function GetDefaultNombre: String; virtual;

    procedure DoOnNombreModeloChanged(const AID: integer; const ANombre: string); virtual;

    function GetModelo: IModelo; virtual;
    procedure SetModelo(AModelo: IModelo); virtual;

    function GetPetriNetController: TdpnPetriNetCoordinadorBase; virtual;
    procedure SetPetriNetController(APetriNetController: TdpnPetriNetCoordinadorBase); virtual;

    function LogAsString: string; virtual;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure Stop; virtual;
    procedure Start; virtual;
    procedure Reset; virtual;
    procedure Setup; virtual;
    function CheckIsOK(out AListaErrores: IList<string>): boolean; virtual;

    function GetAsObject: TObject;

    Procedure CargarDeJSON(NodoJson_IN: TJSONObject); virtual;
    Function FormatoJSON: TJSONObject; overload; virtual;
    Procedure FormatoJSON(NodoJson_IN: TJSONObject); overload; virtual;
    function Clon: ISerializable; virtual;

    Procedure CargarEstadoDeJSON(NodoJson_IN: TJSONObject); virtual;
    Function FormatoEstadoJSON: TJSONObject; overload; virtual;
    Procedure FormatoEstadoJSON(NodoJson_IN: TJSONObject); overload; virtual;

    property ID: integer read GetID write SetID;
    property Nombre: string read GetNombre;
    property NombreReducido: string read GetNombreReducido write SetNombreReducido;
    property OnNombreChanged: IEvent<EventoNodoPN_ValorString> read GetOnNombreChanged;
    property PetriNetController: TdpnPetriNetCoordinadorBase read GetPetriNetController write SetPetriNetController;
    property Modelo: IModelo read GetModelo write SetModelo;
    property Enabled: boolean read GetEnabled;
    property OnEnabledChanged: IEvent<EventoNodoPN_ValorBooleano> read GetOnEnabledChanged;
    property OnReseted: IEvent<EventoNodoPN> read GetOnReseted;
    property IsEnWarning: boolean read GetIsEnWarning;
  end;

implementation

uses
  System.SysUtils,

  DPN.Core;

{ TdpnObjetoBasico }

procedure TdpnNodoPetriNet.CargarDeJSON(NodoJson_IN: TJSONObject);
begin
  DPNCore.CargarCampoDeNodo<string>(NodoJson_IN, 'Nombre', ClassName, FNombreReducido);
  DPNCore.CargarCampoDeNodo<string>(NodoJson_IN, 'Modelo', ClassName, FNombreModelo);
end;

procedure TdpnNodoPetriNet.CargarEstadoDeJSON(NodoJson_IN: TJSONObject);
begin
  DPNCore.CargarCampoDeNodo<boolean>(NodoJson_IN, 'Enabled', ClassName, FEnabled);
end;

function TdpnNodoPetriNet.CheckIsOK(out AListaErrores: IList<string>): boolean;
begin
  Result := True;
  AListaErrores := TCollections.CreateList<string>;
  if ID <= 0 then
  begin
    Result := False;
    AListaErrores.Add('ID <= 0');
  end;
  if NombreReducido.IsEmpty then
  begin
    Result := False;
    AListaErrores.Add('Nombre is Empty');
  end;
  if not Assigned(PetriNetController) then
  begin
    Result := False;
    AListaErrores.Add('PetriNetController = nil');
  end;
  if not Assigned(Modelo) then
  begin
    Result := False;
    AListaErrores.Add('Modelo = nil');
  end;
end;

function TdpnNodoPetriNet.Clon: ISerializable;
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

constructor TdpnNodoPetriNet.Create;
begin
  inherited;
  FID := DPNCore.GetNuevoID;
  FNombreReducido := GetDefaultNombre;
  FNombreModelo := '';
  FEnabled := False;
  FIsEnWarning := True;
  FEvento_OnEnabledChanged := DPNCore.CrearEvento<EventoNodoPN_ValorBooleano>;
  FEvento_OnNombreChanged  := DPNCore.CrearEvento<EventoNodoPN_ValorString>;
  FEvento_OnReseted := DPNCore.CrearEvento<EventoNodoPN>;
end;

destructor TdpnNodoPetriNet.Destroy;
begin
  FEvento_OnEnabledChanged := nil;
  inherited;
end;

procedure TdpnNodoPetriNet.DoOnNombreModeloChanged(const AID: integer; const ANombre: string);
begin
  FEvento_OnNombreChanged.Invoke(ID, Nombre);
end;

function TdpnNodoPetriNet.FormatoJSON: TJSONObject;
begin
  Result := DPNCore.CrearNodoJSONObjeto(Self);
  FormatoJSON(Result);
end;

procedure TdpnNodoPetriNet.FormatoJSON(NodoJson_IN: TJSONObject);
var
  LModelo: string;
begin
  NodoJson_IN.AddPair('Nombre', TJsonString.Create(NombreReducido)); //para asociar
  if Assigned(FModelo) then
    LModelo := FModelo.Nombre
  else LModelo := ''; //es el caso del modelo de mas alto nivel, no tiene padre
  NodoJson_IN.AddPair('Modelo', TJsonString.Create(LModelo)); //para asociar
end;

procedure TdpnNodoPetriNet.FormatoEstadoJSON(NodoJson_IN: TJSONObject);
begin
  NodoJson_IN.AddPair('Nombre', TJsonString.Create(NombreReducido)); //completo
  NodoJson_IN.AddPair('Enabled', TJSONBool.Create(Enabled));
end;

function TdpnNodoPetriNet.FormatoEstadoJSON: TJSONObject;
begin
  Result := DPNCore.CrearNodoJSONObjeto(Self);
  FormatoEstadoJSON(Result);
end;

function TdpnNodoPetriNet.GetAsObject: TObject;
begin
  Result := Self
end;

function TdpnNodoPetriNet.GetDefaultNombre: String;
begin
  Result := ClassName + '_' + ID.ToString;
end;

function TdpnNodoPetriNet.GetEnabled: Boolean;
begin
  Result := FEnabled;
end;

function TdpnNodoPetriNet.GetID: integer;
begin
  Result := FID;
end;

function TdpnNodoPetriNet.GetIsEnWarning: Boolean;
begin
  Result := FIsEnWarning;
end;

function TdpnNodoPetriNet.GetModelo: IModelo;
begin
  Result := FModelo;
end;

function TdpnNodoPetriNet.GetNombre: string;
begin
  if Assigned(FModelo) then
    Result := FModelo.Nombre + SEPARADOR_NOMBRES + FNombreReducido
  else Result := FNombreReducido;
end;

function TdpnNodoPetriNet.GetNombreReducido: string;
begin
  Result := FNombreReducido;
end;

function TdpnNodoPetriNet.GetOnEnabledChanged: IEvent<EventoNodoPN_ValorBooleano>;
begin
  Result := FEvento_OnEnabledChanged
end;

function TdpnNodoPetriNet.GetOnNombreChanged: IEvent<EventoNodoPN_ValorString>;
begin
  Result := FEvento_OnNombreChanged
end;

function TdpnNodoPetriNet.GetOnReseted: IEvent<EventoNodoPN>;
begin
  Result := FEvento_OnReseted;
end;

function TdpnNodoPetriNet.GetPetriNetController: TdpnPetriNetCoordinadorBase;
begin
  Result := FPetriNetController
end;

function TdpnNodoPetriNet.LogAsString: string;
begin
  Result := '<Nodo>' + '[ID]' + ID.ToString + '[Nombre]' + Nombre + '[Enabled]' + Enabled.ToString;
end;

procedure TdpnNodoPetriNet.Reset;
begin
  FEvento_OnReseted.Invoke(ID);
end;

procedure TdpnNodoPetriNet.SetID(const Value: integer);
begin
  FID := Value;
end;

procedure TdpnNodoPetriNet.SetModelo(AModelo: IModelo);
begin
  if Assigned(FModelo) then
  begin
    FModelo.OnNombreChanged.Remove(DoOnNombreModeloChanged);
  end;
  if (FModelo <> AModelo) then
  begin
    FModelo := AModelo;
    if Assigned(FModelo) then
      FModelo.OnNombreChanged.Add(DoOnNombreModeloChanged);
    FEvento_OnNombreChanged.Invoke(ID, Nombre);
  end;
end;

procedure TdpnNodoPetriNet.SetNombreReducido(const Valor: string);
begin
  Guard.CheckFalse(Valor.IsEmpty, 'El nombre no puede ser nul');
  if (FNombreReducido <> Valor) then
  begin
    FNombreReducido := Valor;
    FEvento_OnNombreChanged.Invoke(ID, Nombre);
  end;
end;

procedure TdpnNodoPetriNet.SetPetriNetController(APetriNetController: TdpnPetriNetCoordinadorBase);
begin
  if FPetriNetController <> APetriNetController then
  begin
    FPetriNetController := APetriNetController;
  end;
end;

procedure TdpnNodoPetriNet.Setup;
begin
  inherited;
end;

procedure TdpnNodoPetriNet.Start;
begin
  Guard.CheckFalse(FNombreReducido.IsEmpty, 'Debe tener un nombre asignado, clase:' + QualifiedClassName);
  if not FEnabled then
  begin
    FEnabled := True;
    FEvento_OnEnabledChanged.Invoke(ID, FEnabled);
  end;
end;

procedure TdpnNodoPetriNet.Stop;
begin
  if FEnabled then
  begin
    FEnabled := False;
    FEvento_OnEnabledChanged.Invoke(ID, FEnabled);
  end;
end;

end.

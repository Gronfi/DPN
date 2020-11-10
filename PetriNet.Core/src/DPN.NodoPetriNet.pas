unit DPN.NodoPetriNet;

interface

uses
  System.JSON,

  Spring,

  DPN.Interfaces;

type
  TdpnNodoPetriNet = class abstract(TInterfacedObject, INodoPetriNet)
  protected
    FID: integer;
    FModelo: IModelo;
    FNombre: string;
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
    procedure SetNombre(const Valor: string); virtual;
    function GetOnNombreChanged: IEvent<EventoNodoPN_ValorString>; virtual;
    function GetDefaultNombre: String; virtual;

    procedure DoOnNombreModeloChanged(const AID: integer; const ANombre: string); virtual;

    function GetModelo: IModelo; virtual;
    procedure SetModelo(AModelo: IModelo); virtual;

    function LogAsString: string; virtual;

    procedure Stop; virtual;
    procedure Start; virtual;
    procedure Reset; virtual;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    Procedure CargarDeJSON(NodoJson_IN: TJSONObject); virtual;
    Function FormatoJSON: TJSONObject; overload; virtual;
    Procedure FormatoJSON(NodoJson_IN: TJSONObject); overload; virtual;
    function Clon: ISerializable; virtual;

    function GetAsObject: TObject;

    property ID: integer read GetID write SetID;
    property Nombre: string read GetNombre write SetNombre;
    property OnNombreChanged: IEvent<EventoNodoPN_ValorString> read GetOnNombreChanged;
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
  DPNCore.CargarCampoDeNodo<string>(NodoJson_IN, 'Nombre', ClassName, FNombre);
end;

function TdpnNodoPetriNet.Clon: ISerializable;
var
  LNew: ISerializable;
  OJSon: TJSONObject;
begin
  OJSon := Self.FormatoJSON;
  try
    LNew := DPNCore.CrearInstancia(OJSon).AsType<ISerializable>;
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
  FNombre := GetDefaultNombre;
  FEnabled := False;
  FIsEnWarning := True;
  FEvento_OnEnabledChanged := DPNCore.CrearEvento<EventoNodoPN_ValorBooleano>;
  FEvento_OnNombreChanged  := DPNCore.CrearEvento<EventoNodoPN_ValorString>;
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
begin
  NodoJson_IN.AddPair('Nombre', TJsonString.Create(FNombre));
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
    Result := FModelo.Nombre + SEPARADOR_NOMBRES + FNombre
  else Result := FNombre;
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

function TdpnNodoPetriNet.LogAsString: string;
begin
  Result := '<Nodo>' + '[ID]' + ID.ToString + '[Nombre]' + Nombre + '[Enabled]' + Enabled.ToString;
end;

procedure TdpnNodoPetriNet.Reset;
begin
  ;
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

procedure TdpnNodoPetriNet.SetNombre(const Valor: string);
begin
  Guard.CheckFalse(Valor.IsEmpty, 'El nombre no puede ser nul');
  if (FNombre <> Valor) then
  begin
    FNombre := Valor;
    FEvento_OnNombreChanged.Invoke(ID, Nombre);
  end;
end;

procedure TdpnNodoPetriNet.Start;
begin
  Guard.CheckFalse(FNombre.IsEmpty, 'Debe tener un nombre asignado, clase:' + QualifiedClassName);
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

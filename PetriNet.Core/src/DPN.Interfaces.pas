unit DPN.Interfaces;

//******************************************************************
// NOTAS                                                           *
//******************************************************************
// 1.Los IDs de los nodos y de los tokens son �nicos por ejecuci�n *
//******************************************************************

interface

uses
  System.SyncObjs,
  System.Classes,
  System.SysUtils,
  System.JSon,

  Event.Engine.Interfaces,

  Spring,
  Spring.Collections;

const
  SEPARADOR_NOMBRES = '.';

type
  IPlaza = interface;
  TListaPlazas = IList<IPlaza>;
  TArrayPlazas = TArray<IPlaza>;

  ITransicion = interface;
  TTransiciones = IList<ITransicion>;
  TArrayTransiciones = TArray<ITransicion>;

  ICondicion = interface;
  IAccion = interface;
  TCondiciones = IList<ICondicion>;
  TArrayCondiciones = TArray<ICondicion>;
  TAcciones = IList<IAccion>;
  TArrayAcciones = TArray<IAccion>;

  IMarcadoPlazasCantidadTokens = interface;
  IModelo = interface;

  IToken = interface;
  TListaTokens = IList<IToken>;
  TArrayTokens = TArray<IToken>;

  IMarcadoTokens = interface;

  EventoNodoPN = procedure(const AID: Integer) of object;
  EventoNodoPN_ValorBooleano = procedure(const AID: Integer; const AValue: Boolean) of object;
  EventoNodoPN_ValorInteger = procedure(const AID: Integer; const AValue: Integer) of object;
  EventoNodoPN_ValorString = procedure(const AID: Integer; const AValue: String) of object;
  EventoNodoPN_ValorTValue = procedure(const AID: Integer; const AValue: TValue) of object;
  EventoNodoPN_Transicion = procedure(const AID: Integer; ATransicion: ITransicion) of object;
  EventoNodoPN_MarcadoPlazasTokenCount = procedure(const AID: Integer; AMarcado: IMarcadoPlazasCantidadTokens) of object;

  TdpnPetriNetCoordinadorBase = class;

  IObjeto = interface
    ['{89BD3FEE-9EF2-4ADE-BBA3-FECBF6F2251B}']
    function GetAsObject: TObject;
  end;

  ISerializable = interface(IObjeto)
    ['{965202FB-0847-413D-B21F-A4A86C67CB1C}']
    Procedure CargarDeJSON(NodoJson_IN: TJSONObject);
    Function FormatoJSON: TJSONObject; overload;
    Procedure FormatoJSON(NodoJson_IN: TJSONObject); overload;

    Procedure CargarEstadoDeJSON(NodoJson_IN: TJSONObject);
    Function FormatoEstadoJSON: TJSONObject; overload;
    Procedure FormatoEstadoJSON(NodoJson_IN: TJSONObject); overload;

    function Clon: ISerializable;
  end;

  IIdentificado = interface(ISerializable)
  ['{67839BCB-0819-419C-A78F-CA92566D3491}']
    function GetID: integer;
    procedure SetID(const Value: integer);

    property ID: integer read GetID write SetID;
  end;

  INombrado = interface(IIdentificado)
  ['{73DF6D15-DAB3-459A-9A58-F5D3CD2CA4A5}']
    function GetNombre: string;

    function GetNombreReducido: string;
    procedure SetNombreReducido(const Valor: string);

    function GetDefaultNombre: String;

    function GetOnNombreChanged: IEvent<EventoNodoPN_ValorString>;

    property Nombre: string read GetNombre;
    property NombreReducido: string read GetNombreReducido write SetNombreReducido;
    property OnNombreChanged: IEvent<EventoNodoPN_ValorString> read GetOnNombreChanged;
  end;

  INodoPetriNet = interface(INombrado)
  ['{B713E58D-4060-49D0-B377-AA929E274A8D}']
    function GetOnEnabledChanged: IEvent<EventoNodoPN_ValorBooleano>;

    function GetIsEnWarning: Boolean;
    function GetEnabled: Boolean;

    function GetModelo: IModelo;
    procedure SetModelo(AModelo: IModelo);

    function GetPetriNetController: TdpnPetriNetCoordinadorBase;
    procedure SetPetriNetController(APetriNetController: TdpnPetriNetCoordinadorBase);

    procedure Stop;
    procedure Start;
    procedure Reset;
    procedure Setup;
    function CheckIsOK(out AListaErrores: IList<string>): boolean;

    function LogAsString: string;

    property PetriNetController: TdpnPetriNetCoordinadorBase read GetPetriNetController write SetPetriNetController;
    property Modelo: IModelo read GetModelo write SetModelo;
    property Enabled: boolean read GetEnabled;
    property OnEnabledChanged: IEvent<EventoNodoPN_ValorBooleano> read GetOnEnabledChanged;
    property IsEnWarning: boolean read GetIsEnWarning;
  end;

  IBloqueable = interface(INodoPetriNet)
  ['{8860986D-0002-45A0-A8DD-351B48F131DD}']
    procedure AdquireLock;
    procedure ReleaseLock;
  end;

  IDependiente = interface(INodoPetriNet)
  ['{3665AB45-F7EB-416E-994F-DEC3A877F8A2}']
    function GetDependencias: IList<IBloqueable>;

    property Dependencias: IList<IBloqueable> read GetDependencias;
  end;

  IDecoracion = interface(INodoPetriNet)
  ['{513E1A74-04DB-460E-BB7A-C616F170C001}']
  end;

  IEtiqueta = interface(IDecoracion)
  ['{52F9BEFC-531B-4E33-8BBB-881DD659F5DD}']
    function GetTexto: string;
    procedure SetTexto(const Value: string);

    property Texto: string read GetTexto write SetTexto;
  end;

  IArco = interface(INodoPetriNet)
  ['{0D8B1482-8EC9-4447-8931-E29295654C79}']
    function GetIsHabilitado: Boolean;
    function GetPeso: Integer;
    procedure SetPeso(const Value: Integer);
    function GetPlaza: IPlaza;
    function GetTransicion: ITransicion;
    procedure SetPlaza(Value: IPlaza);
    procedure SetTransicion(Value: ITransicion);

    function GetIsForzado: Boolean;
    procedure SetIsForzado(const Value: Boolean);

    function GetValorForzado: Boolean;
    procedure SetValorForzado(const Value: Boolean);

    procedure DoOnTransicionando(ATokens: TListaTokens); overload;
    procedure DoOnTransicionando(ATokens: TArrayTokens); overload;

    function GetOnHabilitacionChanged: IEvent<EventoNodoPN_ValorBooleano>;

    function Evaluar(const ATokenCount: Integer): Boolean;

    property IsHabilitado: Boolean read GetIsHabilitado;
    property Peso: Integer read GetPeso write SetPeso;
    property Plaza: IPlaza read GetPlaza write SetPlaza;
    property Transicion: ITransicion read GetTransicion write SetTransicion;

    property OnHabilitacionChanged: IEvent<EventoNodoPN_ValorBooleano> read GetOnHabilitacionChanged;
    property IsForzado: Boolean read GetIsForzado write SetIsForzado;
    property ValorForzado: Boolean read GetValorForzado write SetValorForzado;
  end;

  IArcoIn = interface(IArco)
  ['{EA23BC58-D5EE-460A-8811-B83344419876}']
    function GetIsInhibidor: Boolean;
    procedure SetIsInhibidor(const Value: Boolean);

    function GetPesoEvaluar: Integer;
    procedure SetPesoEvaluar(const Value: Integer);

    function ObtenerTokensEvaluacion: IMarcadoTokens;

    property PesoEvaluar: Integer read GetPesoEvaluar write SetPesoEvaluar;
    property IsInhibidor: boolean read GetIsInhibidor write SetIsInhibidor;
  end;

  IArcoOut = interface(IArco)
  ['{64B50153-AF32-45C1-88F7-FBFCC427220E}']
    function GetGenerarTokensDeSistema: Boolean;
    procedure SetGenerarTokensDeSistema(const Value: Boolean);

    function GetPreCondicionesPlaza: IList<ICondicion>;
    function GetPreAccionesPlaza: IList<IAccion>;

    property PreCondicionesPlaza: IList<ICondicion> read GetPreCondicionesPlaza;
    property PreAccionesPlaza: IList<IAccion> read GetPreAccionesPlaza;
    property GenerarTokensDeSistema: boolean read GetGenerarTokensDeSistema write SetGenerarTokensDeSistema;
  end;

  IArcoReset = interface(IArcoOut)
  ['{2346CC59-AA41-4524-988B-73B6926759CA}']
  end;

  IPlaza = interface(IBloqueable)
  ['{78994088-B3B8-4F1D-A053-E3EFC70A8F74}']
    function GetOnTokenCountChanged: IEvent<EventoNodoPN_ValorInteger>;

    function GetTokens: IReadOnlyList<IToken>;
    function GetTokenCount: Integer;

    function GetPreCondiciones: IList<ICondicion>;
    function GetPreAcciones: IList<IAccion>;

    function GetAceptaArcosIN: Boolean;
    function GetAceptaArcosOUT: Boolean;

    function GetCapacidad: Integer;
    procedure SetCapacidad(const Value: integer);

    procedure AddToken(AToken: IToken);
    procedure AddTokens(ATokens: TListaTokens); overload;
    procedure AddTokens(ATokens: TArrayTokens); overload;

    procedure EliminarToken(AToken: IToken);
    procedure EliminarTokens(ATokens: TListaTokens); overload;
    procedure EliminarTokens(ATokens: TArrayTokens); overload;
    procedure EliminarTokens(const ACount: integer); overload;
    procedure EliminarTodosTokens;

    procedure AddPreCondicion(ACondicion: ICondicion);
    procedure AddPreCondiciones(ACondiciones: TCondiciones); overload;
    procedure AddPreCondiciones(ACondiciones: TArrayCondiciones); overload;
    procedure EliminarPreCondicion(ACondicion: ICondicion);
    procedure EliminarPreCondiciones(ACondiciones: TCondiciones); overload;
    procedure EliminarPreCondiciones(ACondiciones: TArrayCondiciones); overload;

    procedure AddPreAccion(AAccion: IAccion);
    procedure AddPreAcciones(AAcciones: TAcciones); overload;
    procedure AddPreAcciones(AAcciones: TArrayAcciones); overload;
    procedure EliminarPreAccion(AAccion: IAccion);
    procedure EliminarPreAcciones(AAcciones: TAcciones); overload;
    procedure EliminarPreAcciones(AAcciones: TArrayAcciones); overload;

    property AceptaArcosIN: boolean read GetAceptaArcosIN;
    property AceptaArcosOUT: boolean read GetAceptaArcosOUT;
    property Tokens: IReadOnlyList<IToken> read GetTokens;
    property TokenCount: Integer read GetTokenCount;
    property Capacidad: Integer read GetCapacidad write SetCapacidad;
    property PreCondiciones: IList<ICondicion> read GetPreCondiciones;
    property PreAcciones: IList<IAccion> read GetPreAcciones;

    property OnTokenCountChanged: IEvent<EventoNodoPN_ValorInteger> read GetOnTokenCountChanged;
  end;

  ICondicion = interface(IDependiente)
  ['{BF0FB22B-DA9D-4C95-B62A-286E2A0E79FD}']
    function GetOnContextoCondicionChanged: IEvent<EventoNodoPN>;

    function GetIsRecursiva: Boolean;
    function GetIsEvaluacionNoDependeDeTokensOEvento: Boolean;
    function GetIsCondicionQueEsperaEvento: Boolean;

    function GetIsCondicionNegada: boolean;
    procedure SetIsCondicionNegada(const Valor: Boolean);

    function GetEventoHabilitado: Boolean;
    procedure SetEventoHabilitado(const AValor: Boolean);

    function GetEventosCount: integer;
    procedure ClearEventos;
    procedure RemovePrimerEvento;
    function GetPrimerEvento: IEvento;

    function GetTransicion: ITransicion;
    procedure SetTransicion(const Value: ITransicion);

    function Evaluar(ATokens: IMarcadoTokens; AEvento: IEvento = nil): Boolean;

    procedure DoNotificarOncontextoCondicionChanged;

    property Transicion: ITransicion read GetTransicion write SetTransicion;
    property OnContextoCondicionChanged: IEvent<EventoNodoPN> read GetOnContextoCondicionChanged;
    property IsRecursiva: boolean read GetIsRecursiva;
    property IsEvaluacionNoDependeDeTokensOEvento: boolean read GetIsEvaluacionNoDependeDeTokensOEvento;

    property IsCondicionQueEsperaEvento: boolean read GetIsCondicionQueEsperaEvento;
    property IsCondicionNegada: boolean read GetIsCondicionNegada write SetIsCondicionNegada;
    property ListenerEventoHabilitado: Boolean read GetEventoHabilitado write SetEventoHabilitado;
    property EventosCount: integer read GetEventosCount;
  end;

  IAccion = interface(IDependiente)
  ['{E3B434CC-D13C-46DD-81B1-B4DB26BB62F7}']
    function GetTransicion: ITransicion;
    procedure SetTransicion(const Value: ITransicion);

    procedure Execute(ATokens: IMarcadoTokens; AEvento: IEvento = nil);

    property Transicion: ITransicion read GetTransicion write SetTransicion;
  end;

  EEstrategiaDisparoTransicion = (ArcosMandan, TokenByToken);

  ETransicionConMasDeUnaCondicionQueEsperaEvento = class(Exception);

  ITransicion = interface(INodoPetriNet)
  ['{905A0070-02F5-4F86-BC13-72E1398342D4}']
    function GetIsHabilitado: Boolean;
    function GetIsHabilitadoParcialmente: Boolean;
    function GetIsTransicionDependeDeEvento: Boolean;

    function GetTiempoEvaluacion: integer;
    procedure SetTiempoEvaluacion(const AValor: integer);

    function GetTransicionesIntentadas: int64;
    function GetTransicionesRealizadas: int64;

    function GetOnRequiereEvaluacionChanged: IEvent<EventoNodoPN_Transicion>;
    function GetOnMarcadoChanged: IEvent<EventoNodoPN_MarcadoPlazasTokenCount>;

    function GetArcosIn: IReadOnlyList<IArcoIn>;
    function GetArcosOut: IReadOnlyList<IArcoOut>;

    function GetCondiciones: IReadOnlyList<ICondicion>;
    function GetAcciones: IReadOnlyList<IAccion>;

    function EstrategiaDisparo(AEvento: IEvento = nil): Boolean;

    function EjecutarTransicion: Boolean;

    procedure AddCondicion(ACondicion: ICondicion);
    procedure EliminarCondicion(ACondicion: ICondicion);
    procedure AddAccion(AAccion: IAccion);
    procedure EliminarAccion(AAccion: IAccion);

    procedure AddArcoIn(AArco: IArcoIn);
    procedure EliminarArcoIn(AArco: IArcoIn);
    procedure AddArcoOut(AArco: IArcoOut);
    procedure EliminarArcoOut(AArco: IArcoOut);

    property IsHabilitado: Boolean read GetIsHabilitado;
    property IsHabilitadoParcialmente: Boolean read GetIsHabilitadoParcialmente;
    property TiempoEvaluacion: integer read GetTiempoEvaluacion write SetTiempoEvaluacion;

    property ArcosIN: IReadOnlyList<IArcoIn> read GetArcosIn;
    property ArcosOut: IReadOnlyList<IArcoOut> read GetArcosOut;

    property Condiciones: IReadOnlyList<ICondicion> read GetCondiciones;
    property Acciones: IReadOnlyList<IAccion> read GetAcciones;

    property TransicionesIntentadas: int64 read GetTransicionesIntentadas;
    property TransicionesRealizadas: int64 read GetTransicionesRealizadas;

    property OnMarcadoChanged: IEvent<EventoNodoPN_MarcadoPlazasTokenCount> read GetOnMarcadoChanged;
    property OnRequiereEvaluacionChanged: IEvent<EventoNodoPN_Transicion> read GetOnRequiereEvaluacionChanged;
    property IsTransicionDependeDeEvento: Boolean read GetIsTransicionDependeDeEvento;
  end;

  IToken = interface(ISerializable)
  ['{DBC2D293-3584-477D-9EA9-6B75251A4397}']
    function GetID: int64;

    function GetVariable(const AKey: string): TValue;
    procedure SetVariable(const AKey: string; const AValor: TValue);

    function GetTablaVariables: IDictionary<String, TValue>;

    function GetPlaza: IPlaza;
    procedure SetPlaza(APlaza: IPlaza);

    function GetPetriNetController: TdpnPetriNetCoordinadorBase;
    procedure SetPetriNetController(APetriNetController: TdpnPetriNetCoordinadorBase);

    function GetCantidadCambiosPlaza: int64;

    function GetMomentoCreacion: int64;

    function GetMomentoCambioPlaza: int64;

    function LogAsString: string;

    property ID: int64 read GetID;
    property Plaza: IPlaza read GetPlaza write SetPlaza;
    property Variable[const AKey: string]: TValue read GetVariable write SetVariable; default;
    property TablaVariables: IDictionary<String, TValue> read GetTablaVariables;
    property CantidadCambiosPlaza: int64 read GetCantidadCambiosPlaza;
    property MomentoCreacion: int64 read GetMomentoCreacion;
    property MomentoCambioPlaza: int64 read GetMomentoCambioPlaza;
    property PetriNetController: TdpnPetriNetCoordinadorBase read GetPetriNetController write SetPetriNetController;
  end;

  ITokenSistema = interface(IToken)
  ['{D3F2D055-BE0E-4283-B08C-22231F5C9574}']
  end;

  ITokenColoreado = interface(IToken) //este es el token espec�fico que transporta informacion
  ['{14BE62F3-DE76-4458-AFEB-2DB613F2C30C}']
  end;

  IMarcadoTokens = interface
    function GetTokenCount: Integer;
    function GetMarcado: IDictionary<IPlaza, IList<IToken>>;

    procedure AddPlaza(APlaza: IPlaza);
    procedure AddTokenPlaza(APlaza: IPlaza; AToken: IToken);
    procedure AddTokensPlaza(APlaza: IPlaza; ATokens: IList<IToken>); overload;
    procedure AddTokensPlaza(APlaza: IPlaza; ATokens: IEnumerable<IToken>); overload;
    procedure AddTokensMarcado(AMarcado: IMarcadoTokens);

    procedure RemovePlaza(APlaza: IPlaza);
    procedure RemoveToken(AToken: IToken);
    procedure RemoveTokensPlaza(APlaza: IPlaza); overload;
    procedure RemoveTokensPlaza(APlaza: IPlaza; ATokens: IList<IToken>); overload;

    procedure Clear;

    property Marcado: IDictionary<IPlaza, IList<IToken>> read GetMarcado;
    property TokenCount: Integer read GetTokenCount;
  end;

  IMarcadoPlazasCantidadTokens = interface
    function GetTokenCount: Integer;
    function GetMarcado: IDictionary<Integer, Integer>;

    procedure AddTokensPlaza(APlazaID: integer; ATokensCount: integer);
    procedure AddTokensPlazas(AMarcado: IDictionary<Integer, Integer>);

    property Marcado: IDictionary<Integer, Integer> read GetMarcado;
    property TokenCount: Integer read GetTokenCount;
  end;

  IVariable = interface(IBloqueable)
  ['{E6597521-24D3-4475-9247-80CF55E8AD90}']
    function GetValor: TValue;
    procedure SetValor(const Value: TValue);

    function GetOnValueChanged: IEvent<EventoNodoPN_ValorTValue>;


    property Valor: TValue read GetValor write SetValor;
    property OnValueChanged: IEvent<EventoNodoPN_ValorTValue> read GetOnValueChanged;
  end;

  IModelo = interface(INodoPetriNet)
  ['{2393661C-D3AD-40BD-82DA-D6946AA3E5CA}']
    function GetElementos: IList<INodoPetriNet>;

    function GetTipoModelo: string;
    procedure SetTipoModelo(const Valor: string);

    function GetPlazaIn: IPlaza;
    procedure SetPlazaIn(Value: IPlaza);
    function GetPlazaOut: IPlaza;
    procedure SetPlazaOut(Value: IPlaza);

    function GetModelos: IReadOnlyList<IModelo>;
    function GetArcos: IReadOnlyList<IArco>;
    function GetPlazas: IReadOnlyList<IPlaza>;
    function GetTransiciones: IReadOnlyList<ITransicion>;
    function GetTokens: IReadOnlyList<IToken>;
    function GetVariables: IReadOnlyList<IVariable>;
    function GetCondiciones: IReadOnlyList<ICondicion>;
    function GetAcciones: IReadOnlyList<IAccion>;
    function GetDecoraciones: IReadOnlyList<IDecoracion>;

    procedure AddElementoNodo(AElemento: INodoPetriNet);
    procedure AddElementosNodos(AElementos: TArray<INodoPetriNet>); overload;
    procedure AddElementosNodos(AElementos: IList<INodoPetriNet>); overload;
    procedure ClearElementos;
    procedure EliminarElementoNodo(AElemento: INodoPetriNet);
    procedure EliminarElementosNodos(AElementos: TArray<INodoPetriNet>); overload;
    procedure EliminarElementosNodos(AElementos: IList<INodoPetriNet>); overload;

    procedure AddArcoEntrada(AArco: IArcoOut);
    procedure EliminarArcoEntrada(AArco: IArcoOut);
    procedure AddArcoSalida(AArco: IArcoIn);
    procedure EliminarArcoSalida(AArco: IArcoIn);

    property PlazaIn: IPlaza read GetPlazaIn write SetPlazaIn;
    property PlazaOut: IPlaza read GetPlazaOut write SetPlazaOut;
    property Elementos: IList<INodoPetriNet> read GetElementos;
    property TipoModelo: string read GetTipoModelo write SetTipoModelo;
  end;

  TListaModelos = IList<IModelo>;
  TArrayModelos = TArray<IModelo>;

  EEstadoPetriNet = (Iniciada, Detenida, GrafoNoAsignado, GrafoSinSetup);

  EventoEstadoPN = procedure(const AEstado: EEstadoPetriNet) of object;

  TdpnPetriNetCoordinadorBase = class abstract(TThread)
  protected
    FGrafo: IModelo;
    FEstado: EEstadoPetriNet;
    FMultipleEnablednessOfTransitions: Boolean;
    FEvento_OnEstadoChanged: IEvent<EventoEstadoPN>;
    FStartedDateTimeAt: TDateTime;
    FStartedEllapsedAt: int64;

    FNodos: IDictionary<Integer, INodoPetriNet>;
    FMarcado: IDictionary<Integer, Integer>;
    FNombresPlazas: IDictionary<String, Integer>;
    FNombresTransiciones: IDictionary<String, Integer>;
    FNombresArcos: IDictionary<String, Integer>;
    FNombresModelos: IDictionary<String, Integer>;
    FNombresCondiciones: IDictionary<String, Integer>;
    FNombresAcciones: IDictionary<String, Integer>;
    FNombresVariables: IDictionary<String, Integer>;
    FNombresDecoraciones: IDictionary<String, Integer>;

    function GetMultipleEnablednessOfTransitions: Boolean; virtual;
    procedure SetMultipleEnablednessOfTransitions(const Value: Boolean); virtual;

    function GetGrafo: IModelo; virtual;
    procedure SetGrafo(AGrafo: IModelo); virtual;

    function ChequearIntegridadDeLaRed(out AListaErrores: IList<string>) : boolean;

    function GetEstado: EEstadoPetriNet; virtual;
    function GetOnEstadoChanged: IEvent<EventoEstadoPN>; virtual;
  public
    constructor Create;
    destructor Destroy; override;

    Procedure CargarDeJSON(NodoJson_IN: TJSONObject); virtual;
    Function FormatoJSON: TJSONObject; overload; virtual;
    Procedure FormatoJSON(NodoJson_IN: TJSONObject); overload; virtual;

    procedure AsociacionesPN; virtual;

    procedure Start; virtual;
    procedure Stop; virtual;
    procedure Reset; virtual;
    procedure Setup; virtual;

    function LogMarcado: string; virtual;

    function GetPlaza(const AID: integer): IPlaza; overload; virtual;
    function GetPlaza(const ANombre: string): IPlaza; overload; virtual;

    function GetArco(const AID: integer): IArco; overload; virtual;
    function GetArco(const ANombre: string): IArco; overload; virtual;

    function GetTransicion(const AID: integer): ITransicion; overload; virtual;
    function GetTransicion(const ANombre: string): ITransicion; overload; virtual;

    function GetModelo(const AID: integer): IModelo; overload; virtual;
    function GetModelo(const ANombre: string): IModelo; overload; virtual;

    function GetCondicion(const AID: integer): ICondicion; overload; virtual;
    function GetCondicion(const ANombre: string): ICondicion; overload; virtual;

    function GetAccion(const AID: integer): IAccion; overload; virtual;
    function GetAccion(const ANombre: string): IAccion; overload; virtual;

    function GetVariable(const AID: integer): IVariable; overload; virtual;
    function GetVariable(const ANombre: string): IVariable; overload; virtual;

    function GetDecoracion(const AID: integer): IDecoracion; overload; virtual;
    function GetDecoracion(const ANombre: string): IDecoracion; overload; virtual;

    function CambiarNombreNodo(const AID: integer; const ANombreNuevo: string; const AFullNombreNuevo: string): boolean; virtual;

    property Grafo: IModelo read GetGrafo write SetGrafo;
    property Estado: EEstadoPetriNet read GetEstado;
    property OnEstadoChanged: IEvent<EventoEstadoPN> read GetOnEstadoChanged;
    property Nodos: IDictionary<Integer, INodoPetriNet> read FNodos;
    property NombresPlazas: IDictionary<String, Integer> read FNombresPlazas;
    property NombresTransiciones: IDictionary<String, Integer>read FNombresTransiciones;
    property NombresArcos: IDictionary<String, Integer>read FNombresArcos;
    property NombresModelos: IDictionary<String, Integer>read FNombresModelos;
    property StartedDateTimeAt: TDateTime read FStartedDateTimeAt;
    property StartedEllapsedAt: int64 read FStartedEllapsedAt;
    property MultipleEnablednessOfTransitions: Boolean read GetMultipleEnablednessOfTransitions write SetMultipleEnablednessOfTransitions;
  end;


{$REGION 'Scheduling'}
  TCallBackTimer = reference to procedure(const ATaskID: int64);

  IdpnSchedulerBase = interface
    ['{6FFF8050-664B-4AE0-AD2D-2A1CD2F07CDB}']
    function GetTaskID: Int64;

    property TaskID: Int64 read GetTaskID;
  end;

  IdpnSchedulerTask = interface(IdpnSchedulerBase)
    ['{B80E5645-C9BC-4D2F-B746-B45F015F387E}']
    function GetMilisecondsToAwake: Int64;

    function IsDone: Boolean;
    function CheckAndNotify: Boolean;

    property MilisecondsToAwake: Int64 read GetMilisecondsToAwake;
  end;

  IdpnSchedulerRemoveTask = interface(IdpnSchedulerBase)
    ['{99479240-985A-43A4-8239-3E8C94D3F2BD}']
  end;
{$ENDREGION}

implementation

uses
  Event.Engine.Utils,
  DPN.Core;

{ TdpnPetriNetCoordinadorBase }

procedure TdpnPetriNetCoordinadorBase.AsociacionesPN;
begin
  // asociar el controlador a cada elemento
  FGrafo.Elementos.ForEach(procedure (const ANodo: INodoPetriNet)
                           begin
                             ANodo.PetriNetController := Self;
                           end
                          );
end;

function TdpnPetriNetCoordinadorBase.CambiarNombreNodo(const AID: integer; const ANombreNuevo: string; const AFullNombreNuevo: string): boolean;
var
  LNodo: INodoPetriNet;
  LNombre: string;
begin
  Result := False;
  LNombre := AFullNombreNuevo.ToUpper;
  LNodo := Nodos.Values.First(function (const ANodo: INodoPetriNet): boolean
                        begin
                          Result := (ANodo.Nombre.ToUpper = LNombre);
                        end
                       );
  if Assigned(LNodo) then
  begin
    Exit(False);
  end;
  LNodo := Nodos[AID];
  LNombre := LNodo.Nombre;
  LNodo.NombreReducido := ANombreNuevo;
  if Supports(LNodo, IPlaza) then
  begin
    NombresPlazas.Remove(LNombre);
    NombresPlazas.Add(LNodo.Nombre, LNodo.ID);
    Exit(True);
  end;
  if Supports(LNodo, ITransicion) then
  begin
    NombresTransiciones.Remove(LNombre);
    NombresTransiciones.Add(LNodo.Nombre, LNodo.ID);
    Exit(True);
  end;
  if Supports(LNodo, IArco) then
  begin
    NombresArcos.Remove(LNombre);
    NombresArcos.Add(LNodo.Nombre, LNodo.ID);
    Exit(True);
  end;
  if Supports(LNodo, IModelo) then
  begin
    NombresModelos.Remove(LNombre);
    NombresModelos.Add(LNodo.Nombre, LNodo.ID);
    Exit(True);
  end;
end;

procedure TdpnPetriNetCoordinadorBase.CargarDeJSON(NodoJson_IN: TJSONObject);
var
  LJSon: TJSONObject;
  LListaErrores: IList<string>;
begin
  DPNCore.CargarCampoDeNodo<boolean>(NodoJson_IN, 'MultiplesDisparosDeTransiciones', ClassName, FMultipleEnablednessOfTransitions);
  if NodoJson_IN.TryGetValue('Grafo', LJSon) then
  begin
    Grafo := DPNCore.CrearInstancia<IModelo>(LJSon);
    Grafo.CargarDeJSON(LJSon);
    FEstado := EEstadoPetriNet.GrafoSinSetup;
    AsociacionesPN;
    if not ChequearIntegridadDeLaRed(LListaErrores) then
    begin
      // log?
      raise Exception.Create('Hay problemas de integridad en la red');
    end;
    Setup;
    Start;
  end;
end;

function TdpnPetriNetCoordinadorBase.ChequearIntegridadDeLaRed(out AListaErrores: IList<string>): boolean;
var
  LResTotal: boolean;
  LLocal: IList<string>;
begin
  LResTotal := True;
  LLocal := TCollections.CreateList<string>;
  AListaErrores := TCollections.CreateList<string>;
  FGrafo.Elementos.ForEach(procedure (const ANodo: INodoPetriNet)
                           var
                             LRes: Boolean;
                             LListaErrores: IList<string>;
                           begin
                             LRes := ANodo.CheckIsOK(LListaErrores);
                             if not LRes then
                             begin
                               LResTotal := False;
                               LLocal.AddRange(LListaErrores.ToArray)
                             end;
                           end
                          );
  Result := LResTotal;
  AListaErrores.AddRange(LLocal.ToArray)
end;

constructor TdpnPetriNetCoordinadorBase.Create;
begin
  inherited Create(False);
  FEstado                           := EEstadoPetriNet.GrafoNoAsignado;
  FMultipleEnablednessOfTransitions := True;

  FNodos := TCollections.CreateDictionary<Integer, INodoPetriNet>;
  FMarcado := TCollections.CreateDictionary<Integer, Integer>;
  FNombresPlazas := TCollections.CreateDictionary<String, Integer>;
  FNombresTransiciones := TCollections.CreateBidiDictionary<String, Integer>;
  FNombresArcos := TCollections.CreateDictionary<String, Integer>;
  FNombresModelos := TCollections.CreateDictionary<String, Integer>;
  FNombresCondiciones := TCollections.CreateDictionary<String, Integer>;
  FNombresAcciones := TCollections.CreateDictionary<String, Integer>;
  FNombresVariables := TCollections.CreateDictionary<String, Integer>;
  FNombresDecoraciones := TCollections.CreateDictionary<String, Integer>;

  FEvento_OnEstadoChanged := DPNCore.CrearEvento<EventoEstadoPN>;
end;

destructor TdpnPetriNetCoordinadorBase.Destroy;
begin
  FEstado := EEstadoPetriNet.Detenida;
  Terminate;
  WaitFor;
end;

function TdpnPetriNetCoordinadorBase.FormatoJSON: TJSONObject;
begin
  Result := DPNCore.CrearNodoJSONObjeto(Self);
  FormatoJSON(Result);
end;

procedure TdpnPetriNetCoordinadorBase.FormatoJSON(NodoJson_IN: TJSONObject);
begin
  NodoJson_IN.AddPair('MultiplesDisparosDeTransiciones', TJSONBool.Create(FMultipleEnablednessOfTransitions));
  if Assigned(Grafo) then
    NodoJson_IN.AddPair('Grafo', Grafo.FormatoJSON);
end;

function TdpnPetriNetCoordinadorBase.GetAccion(const AID: integer): IAccion;
var
  LNodo: INodoPetriNet;
begin
  if FNodos.TryGetValue(AID, LNodo) then
    Result := LNodo as IAccion
  else Result := nil;
end;

function TdpnPetriNetCoordinadorBase.GetAccion(const ANombre: string): IAccion;
var
  LValor: integer;
begin
  if FNombresAcciones.TryGetValue(ANombre, LValor) then
    Result := GetAccion(LValor)
  else Result := nil;
end;

function TdpnPetriNetCoordinadorBase.GetArco(const ANombre: string): IArco;
var
  LValor: integer;
begin
  if FNombresArcos.TryGetValue(ANombre, LValor) then
    Result := GetArco(LValor)
  else Result := nil;
end;

function TdpnPetriNetCoordinadorBase.GetArco(const AID: integer): IArco;
var
  LNodo: INodoPetriNet;
begin
  if FNodos.TryGetValue(AID, LNodo) then
    Result := LNodo as IArco
  else Result := nil;
end;

function TdpnPetriNetCoordinadorBase.GetCondicion(const AID: integer): ICondicion;
var
  LNodo: INodoPetriNet;
begin
  if FNodos.TryGetValue(AID, LNodo) then
    Result := LNodo as ICondicion
  else Result := nil;
end;

function TdpnPetriNetCoordinadorBase.GetCondicion(const ANombre: string): ICondicion;
var
  LValor: integer;
begin
  if FNombresCondiciones.TryGetValue(ANombre, LValor) then
    Result := GetCondicion(LValor)
  else Result := nil;
end;

function TdpnPetriNetCoordinadorBase.GetDecoracion(const ANombre: string): IDecoracion;
var
  LValor: integer;
begin
  if FNombresDecoraciones.TryGetValue(ANombre, LValor) then
    Result := GetDecoracion(LValor)
  else Result := nil;
end;

function TdpnPetriNetCoordinadorBase.GetDecoracion(const AID: integer): IDecoracion;
var
  LNodo: INodoPetriNet;
begin
  if FNodos.TryGetValue(AID, LNodo) then
    Result := LNodo as IDecoracion
  else Result := nil;
end;

function TdpnPetriNetCoordinadorBase.GetEstado: EEstadoPetriNet;
begin
  Result := FEstado;
end;

function TdpnPetriNetCoordinadorBase.GetGrafo: IModelo;
begin
  Result := FGrafo;
end;

function TdpnPetriNetCoordinadorBase.GetModelo(const ANombre: string): IModelo;
var
  LValor: integer;
begin
  if FNombresModelos.TryGetValue(ANombre, LValor) then
    Result := GetModelo(LValor)
  else Result := nil;
end;

function TdpnPetriNetCoordinadorBase.GetModelo(const AID: integer): IModelo;
var
  LNodo: INodoPetriNet;
begin
  if FNodos.TryGetValue(AID, LNodo) then
    Result := LNodo as IModelo
  else Result := nil;
end;

function TdpnPetriNetCoordinadorBase.GetMultipleEnablednessOfTransitions: Boolean;
begin
  Result := FMultipleEnablednessOfTransitions
end;

function TdpnPetriNetCoordinadorBase.GetOnEstadoChanged: IEvent<EventoEstadoPN>;
begin
  Result := FEvento_OnEstadoChanged
end;

function TdpnPetriNetCoordinadorBase.GetPlaza(const ANombre: string): IPlaza;
var
  LValor: integer;
begin
  if FNombresPlazas.TryGetValue(ANombre, LValor) then
    Result := GetPlaza(LValor)
  else Result := nil;
end;

function TdpnPetriNetCoordinadorBase.GetPlaza(const AID: integer): IPlaza;
var
  LNodo: INodoPetriNet;
begin
  if FNodos.TryGetValue(AID, LNodo) then
    Result := LNodo as IPlaza
  else Result := nil;
end;

function TdpnPetriNetCoordinadorBase.GetTransicion(const ANombre: string): ITransicion;
var
  LValor: integer;
begin
  if FNombresModelos.TryGetValue(ANombre, LValor) then
    Result := GetTransicion(LValor)
  else Result := nil;
end;

function TdpnPetriNetCoordinadorBase.GetVariable(const ANombre: string): IVariable;
var
  LValor: integer;
begin
  if FNombresVariables.TryGetValue(ANombre, LValor) then
    Result := GetVariable(LValor)
  else Result := nil;
end;

function TdpnPetriNetCoordinadorBase.GetVariable(const AID: integer): IVariable;
var
  LNodo: INodoPetriNet;
begin
  if FNodos.TryGetValue(AID, LNodo) then
    Result := LNodo as IVariable
  else Result := nil;
end;

function TdpnPetriNetCoordinadorBase.GetTransicion(const AID: integer): ITransicion;
var
  LNodo: INodoPetriNet;
begin
  if FNodos.TryGetValue(AID, LNodo) then
    Result := LNodo as ITransicion
  else Result := nil;
end;

function TdpnPetriNetCoordinadorBase.LogMarcado: string;
var
  LPlaza: integer;
begin
  for LPlaza in FMarcado.Keys do
  begin
    Result := Result + LPlaza.ToString + ' : ' + FMarcado[LPlaza].ToString + #13#10;
  end;
end;

procedure TdpnPetriNetCoordinadorBase.Reset;
begin
  if Assigned(FGrafo) then
  begin
    FGrafo.Reset;
  end;
end;

procedure TdpnPetriNetCoordinadorBase.SetGrafo(AGrafo: IModelo);
begin
  FGrafo := AGrafo;
  if Assigned(FGrafo) then
  begin
    FEstado := EEstadoPetriNet.Detenida;
  end
  else FEstado := EEstadoPetriNet.GrafoNoAsignado;
end;

procedure TdpnPetriNetCoordinadorBase.SetMultipleEnablednessOfTransitions(const Value: Boolean);
begin
  FMultipleEnablednessOfTransitions := Value;
end;

procedure TdpnPetriNetCoordinadorBase.Setup;
begin
  if Assigned(FGrafo) then
  begin
    FGrafo.Setup;
    FEstado := EEstadoPetriNet.Detenida;
    FEvento_OnEstadoChanged.Invoke(FEstado);
  end;
end;

procedure TdpnPetriNetCoordinadorBase.Start;
begin
  FMarcado.Clear;
  FNodos.Clear;
  FNombresPlazas.Clear;
  FNombresTransiciones.Clear;
  if Assigned(FGrafo) then
  begin
    AsociacionesPN;
    FGrafo.Start;
    FEstado := EEstadoPetriNet.Iniciada;
    FStartedDateTimeAt := Now;
    FStartedEllapsedAt := Utils.ElapsedMiliseconds;
    FEvento_OnEstadoChanged.Invoke(FEstado);
  end;
  Sleep(500);
end;

procedure TdpnPetriNetCoordinadorBase.Stop;
begin
  if Assigned(FGrafo) then
  begin
    FEstado := EEstadoPetriNet.Detenida;
    FGrafo.Stop;
    FEvento_OnEstadoChanged.Invoke(FEstado);
  end;
end;

end.

unit DPN.Interfaces;

interface

uses
  System.SysUtils,

  Event.Engine.Interfaces,

  Spring,
  Spring.Collections;

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

  IToken = interface;
  TListaTokens = IList<IToken>;
  TArrayTokens = TArray<IToken>;

  IMarcadoTokens = interface;

  EventoNodoPN = procedure(const AID: Integer) of object;
  EventoNodoPN_ValorBooleano = procedure(const AID: Integer; const AValue: Boolean) of object;
  EventoNodoPN_ValorInteger = procedure(const AID: Integer; const AValue: Integer) of object;
  EventoNodoPN_ValorTValue = procedure(const AID: Integer; const AValue: TValue) of object;
  EventoNodoPN_Transicion = procedure(const AID: Integer; ATransicion: ITransicion) of object;

  INombrado = interface
    function GetNombre: string;
    procedure SetNombre(const Valor: string);

    property Nombre: string read GetNombre write SetNombre;
  end;

  INodoPetriNet = interface(INombrado)
    function GetID: integer;
    procedure SetID(const Value: integer);

    function GetOnEnabledChanged: IEvent<EventoNodoPN_ValorBooleano>;

    function GetIsEnWarning: Boolean;
    function GetEnabled: Boolean;

    procedure Stop;
    procedure Start;
    procedure Reset;

    property ID: integer read GetID write SetID;
    property Enabled: boolean read GetEnabled;
    property OnEnabledChanged: IEvent<EventoNodoPN_ValorBooleano> read GetOnenabledChanged;
    property IsEnWarning: boolean read GetIsEnWarning;
  end;

  IBloqueable = interface(INodoPetriNet)
    procedure AdquireLock;
    procedure ReleaseLock;
  end;

  IDependiente = interface(INodoPetriNet)
    function GetDependencias: IList<IBloqueable>;

    property Dependencias: IList<IBloqueable> read GetDependencias;
  end;

  IEtiqueta = interface(INodoPetriNet)
    function GetTexto: string;
    procedure SetTexto(const Value: string);

    property Texto: string read GetTexto write SetTexto;
  end;

  IArco = interface(INodoPetriNet)
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
    function GetIsInhibidor: Boolean;
    procedure SetIsInhibidor(const Value: Boolean);

    function GetPesoEvaluar: Integer;
    procedure SetPesoEvaluar(const Value: Integer);

    function ObtenerTokensEvaluacion: IMarcadoTokens;

    property PesoEvaluar: Integer read GetPesoEvaluar write SetPesoEvaluar;
    property IsInhibidor: boolean read GetIsInhibidor write SetIsInhibidor;
  end;

  IArcoOut = interface(IArco)
    function GetGenerarTokensDeSistema: Boolean;
    procedure SetGenerarTokensDeSistema(const Value: Boolean);

    function GetPreCondicionesPlaza: IList<ICondicion>;

    property PreCondicionesPlaza: IList<ICondicion> read GetPreCondicionesPlaza;
    property GenerarTokensDeSistema: boolean read GetGenerarTokensDeSistema write SetGenerarTokensDeSistema;
  end;

  IArcoReset = interface(IArcoOut)
  end;

  IPlaza = interface(IBloqueable)
  ['{78994088-B3B8-4F1D-A053-E3EFC70A8F74}']
    function GetOnTokenCountChanged: IEvent<EventoNodoPN_ValorInteger>;

    function GetTokens: IReadOnlyList<IToken>;
    function GetTokenCount: Integer;

    function GetPreCondiciones: IList<ICondicion>;

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

    property AceptaArcosIN: boolean read GetAceptaArcosIN;
    property AceptaArcosOUT: boolean read GetAceptaArcosOUT;
    property Tokens: IReadOnlyList<IToken> read GetTokens;
    property TokenCount: Integer read GetTokenCount;
    property Capacidad: Integer read GetCapacidad write SetCapacidad;
    property PreCondiciones: IList<ICondicion> read GetPreCondiciones;

    property OnTokenCountChanged: IEvent<EventoNodoPN_ValorInteger> read GetOnTokenCountChanged;
  end;

  ICondicion = interface(IDependiente)
    function GetOnContextoCondicionChanged: IEvent<EventoNodoPN>;

    function GetIsRecursiva: Boolean;
    function GetIsEvaluacionNoDependeDeTokensOEvento: Boolean;
    function GetIsCondicionQueEsperaEvento: Boolean;

    function GetEventoHabilitado: Boolean;
    procedure SetEventoHabilitado(const AValor: Boolean);

    function GetEventosCount: integer;
    procedure ClearEventos;
    procedure RemovePrimerEvento;
    function GetPrimerEvento: IEventEE;

    function GetTransicion: ITransicion;
    procedure SetTransicion(const Value: ITransicion);

    function Evaluar(ATokens: IMarcadoTokens; AEvento: IEventEE = nil): Boolean;

    procedure DoNotificarOncontextoCondicionChanged;

    property Transicion: ITransicion read GetTransicion write SetTransicion;
    property OnContextoCondicionChanged: IEvent<EventoNodoPN> read GetOnContextoCondicionChanged;
    property IsRecursiva: boolean read GetIsRecursiva;
    property IsEvaluacionNoDependeDeTokensOEvento: boolean read GetIsEvaluacionNoDependeDeTokensOEvento;

    property IsCondicionQueEsperaEvento: boolean read GetIsCondicionQueEsperaEvento;
    property ListenerEventoHabilitado: Boolean read GetEventoHabilitado write SetEventoHabilitado;
    property EventosCount: integer read GetEventosCount;
  end;

  IAccion = interface(IDependiente)
    function GetTransicion: ITransicion;
    procedure SetTransicion(const Value: ITransicion);

    procedure Execute(ATokens: IMarcadoTokens; AEvento: IEventEE = nil);

    property Transicion: ITransicion read GetTransicion write SetTransicion;
  end;

  EEstrategiaDisparoTransicion = (ArcosMandan, TokenByToken);

  ETransicionConMasDeUnaCondicionQueEsperaEvento = class(Exception);

  ITransicion = interface(INodoPetriNet)
  ['{905A0070-02F5-4F86-BC13-72E1398342D4}']
    function GetIsHabilitado: Boolean;
    function GetIsTransicionDependeDeEvento: Boolean;

    function GetTiempoEvaluacion: integer;
    procedure SetTiempoEvaluacion(const AValor: integer);

    function GetTransicionesIntentadas: int64;
    function GetTransicionesRealizadas: int64;

    function GetOnRequiereEvaluacionChanged: IEvent<EventoNodoPN_Transicion>;

    function GetArcosIn: IReadOnlyList<IArcoIn>;
    function GetArcosOut: IReadOnlyList<IArcoOut>;

    function GetCondiciones: IReadOnlyList<ICondicion>;
    function GetAcciones: IReadOnlyList<IAccion>;

    function EstrategiaDisparo(AEvento: IEventEE = nil): Boolean;

    function EjecutarTransicion: Boolean;

    procedure AddCondicion(ACondicion: ICondicion);
    procedure EliminarCondicion(ACondicion: ICondicion);
    procedure AddAccion(AAccion: IAccion);
    procedure EliminarAccion(AAccion: IAccion);

    procedure AddArcoIn(AArco: IArcoIn);
    procedure EliminarArcoIn(AArco: IArcoIn);
    procedure AddArcoOut(AArco: IArcoOut);
    procedure EliminarArcoOut(AArco: IArcoOut);

    function DebugLog: string;

    property IsHabilitado: Boolean read GetIsHabilitado;
    property TiempoEvaluacion: integer read GetTiempoEvaluacion write SetTiempoEvaluacion;

    property ArcosIN: IReadOnlyList<IArcoIn> read GetArcosIn;
    property ArcosOut: IReadOnlyList<IArcoOut> read GetArcosOut;

    property Condiciones: IReadOnlyList<ICondicion> read GetCondiciones;
    property Acciones: IReadOnlyList<IAccion> read GetAcciones;

    property TransicionesIntentadas: int64 read GetTransicionesIntentadas;
    property TransicionesRealizadas: int64 read GetTransicionesRealizadas;

    property OnRequiereEvaluacionChanged: IEvent<EventoNodoPN_Transicion> read GetOnRequiereEvaluacionChanged;
    property IsTransicionDependeDeEvento: Boolean read GetIsTransicionDependeDeEvento;
  end;

  IToken = interface
  ['{DBC2D293-3584-477D-9EA9-6B75251A4397}']
    function GetID: int64;

    function Clon: IToken;
    function GetPlaza: IPlaza;
    procedure SetPlaza(APlaza: IPlaza);

    property ID: int64 read GetID;
    property Plaza: IPlaza read GetPlaza write SetPlaza;
    //timestamp cambio estado
  end;

  ITokenSistema = interface(IToken)
  ['{D3F2D055-BE0E-4283-B08C-22231F5C9574}']
  end;

  ITokenColoreado = interface(IToken) //este es el token específico que transporta informacion
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

  IVariable = interface(IBloqueable)
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

    function GetPlazas: IReadOnlyList<IPlaza>;
    function GetTransiciones: IReadOnlyList<ITransicion>;

    property Elementos: IList<INodoPetriNet> read GetElementos;
    property TipoModelo: string read GetTipoModelo write SetTipoModelo;
  end;

  TListaModelos = IList<IModelo>;
  TArrayModelos = TArray<IModelo>;

  EEstadoPetriNet = (Iniciada, Detenida, GrafoNoAsignado);

//  IPetriNet = interface
//    function GetGrafo: IModelo;
//    procedure SetGrafo(AGrafo: IModelo);
//
//    function GetEstado: EEstadoPetriNet;
//    procedure SetEstado(const AValor: EEstadoPetriNet);
//
//    function GetMultipleEnablednessOfTransitions: Boolean;
//    procedure SetMultipleEnablednessOfTransitions(const AValor: Boolean);
//
//    procedure Start;
//    procedure Stop;
//
//    property MultipleEnablednessOfTransitions: Boolean read GetMultipleEnablednessOfTransitions write SetMultipleEnablednessOfTransitions;
//    property Grafo: IModelo read GetGrafo write SetGrafo;
//    property Estado: EEstadoPetriNet read GetEstado write SetEstado;
//  end;

{$REGION 'TIMERS'}
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

end.

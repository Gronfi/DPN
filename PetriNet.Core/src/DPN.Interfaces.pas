unit DPN.Interfaces;

interface

uses
  System.SysUtils,

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
    procedure SetPlaza(const Value: IPlaza);
    procedure SetTransicion(const Value: ITransicion);

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

    property GenerarTokensDeSistema: boolean read GetGenerarTokensDeSistema write SetGenerarTokensDeSistema;
  end;

  IArcoReset = interface(IArcoOut)
  end;

  IPlaza = interface(IBloqueable)
    function GetOnTokenCountChanged: IEvent<EventoNodoPN_ValorInteger>;

    function GetTokens: IReadOnlyList<IToken>;
    function GetTokenCount: Integer;

    function GetPreCondiciones: IList<ICondicion>;

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

    property Tokens: IReadOnlyList<IToken> read GetTokens;
    property TokenCount: Integer read GetTokenCount;
    property Capacidad: Integer read GetCapacidad write SetCapacidad;
    property PreCondiciones: IList<ICondicion> read GetPreCondiciones;

    property OnTokenCountChanged: IEvent<EventoNodoPN_ValorInteger> read GetOnTokenCountChanged;
  end;

  ICondicion = interface(IDependiente)
    function GetOnContextoCondicionChanged: IEvent<EventoNodoPN>;

    function GetIsRecursiva: Boolean;
    function GetIsEvaluacionNoDependeDeTokens: Boolean;

    function GetTransicion: ITransicion;
    procedure SetTransicion(const Value: ITransicion);

    function Evaluar(AToken: IToken): Boolean; overload;
    function Evaluar(ATokens: IMarcadoTokens): Boolean; overload;

    procedure DoNotificarOncontextoCondicionChanged;

    property Transicion: ITransicion read GetTransicion write SetTransicion;
    property OnContextoCondicionChanged: IEvent<EventoNodoPN> read GetOnContextoCondicionChanged;
    property IsRecursiva: boolean read GetIsRecursiva;
    property IsEvaluacionNoDependeDeTokens: boolean read GetIsEvaluacionNoDependeDeTokens;
  end;

  IAccion = interface(IDependiente)
    function GetTransicion: ITransicion;
    procedure SetTransicion(const Value: ITransicion);

    procedure Execute(ATokens: IMarcadoTokens); overload;

    property Transicion: ITransicion read GetTransicion write SetTransicion;
  end;

  EEstrategiaDisparoTransicion = (ArcosMandan, TokenByToken);

  ITransicion = interface(INodoPetriNet)
    function GetPrioridad: Integer;
    procedure SetPrioridad(const APrioridad: integer);

    function GetIsHabilitado: Boolean;

    function GetOnRequiereEvaluacionChanged: IEvent<EventoNodoPN_Transicion>;

    function GetArcosIn: IReadOnlyList<IArcoIn>;
    function GetArcosOut: IReadOnlyList<IArcoOut>;

    function GetCondiciones: IReadOnlyList<ICondicion>;
    function GetAcciones: IReadOnlyList<IAccion>;

    function GetIsActivado: Boolean;

    function EstrategiaDisparo: Boolean;
    function EjecutarTransicion: Boolean;

    procedure AddCondicion(ACondicion: ICondicion);
    procedure EliminarCondicion(ACondicion: ICondicion);
    procedure AddAccion(AAccion: IAccion);
    procedure EliminarAccion(AAccion: IAccion);

    procedure AddArcoIn(AArco: IArcoIn);
    procedure EliminarArcoIn(AArco: IArcoIn);
    procedure AddArcoOut(AArco: IArcoOut);
    procedure EliminarArcoOut(AArco: IArcoOut);

    property Prioridad: integer read GetPrioridad write SetPrioridad;
    property IsHabilitado: Boolean read GetIsHabilitado;
    property IsActivado: Boolean read GetIsActivado;

    property ArcosIN: IReadOnlyList<IArcoIn> read GetArcosIn;
    property ArcosOut: IReadOnlyList<IArcoOut> read GetArcosOut;

    property Condiciones: IReadOnlyList<ICondicion> read GetCondiciones;
    property Acciones: IReadOnlyList<IAccion> read GetAcciones;

    property OnRequiereEvaluacionChanged: IEvent<EventoNodoPN_Transicion> read GetOnRequiereEvaluacionChanged;
  end;

  IToken = interface
  ['{DBC2D293-3584-477D-9EA9-6B75251A4397}']
    function GetID: int64;

    function Clon: IToken;

    property ID: int64 read GetID;
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
    function GetElementos: IList<INodoPetriNet>;

    function GetTipoModelo: string;
    procedure SetTipoModelo(const Valor: string);

    property Elementos: IList<INodoPetriNet> read GetElementos;
    property TipoModelo: string read GetTipoModelo write SetTipoModelo;
  end;

  TListaModelos = IList<IModelo>;
  TArrayModelos = TArray<IModelo>;

implementation

end.

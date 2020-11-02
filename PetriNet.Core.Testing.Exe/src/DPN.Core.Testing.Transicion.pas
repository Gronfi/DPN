unit DPN.Core.Testing.Transicion;

interface

uses
  System.Rtti,
  Spring.Collections,

  DUnitX.TestFramework,

  Event.Engine.Interfaces,
  Event.Engine,

  DPN.Interfaces,
  DPN.Variable,
  DPN.Plaza,
  DPN.ArcoIn,
  DPN.ArcoOut,
  DPN.Transicion;

type
  //[TestFixture]
  TPetriNetCoreTesting_Transicion = class
  public
    [Test]
    procedure Test_Habilitado_1_Estado_Origen;
    [Test]
    procedure Test_Habilitado_2_Estados_Origen;
    [Test]
    procedure Test_Deshabilitado_1_Estado_Origen;
    [Test]
    procedure Test_Deshabilitado_2_Estados_Origen;
    [Test]
    procedure Test_Habilitado_1_Estado_Origen_Arco_Es_Inhabilitador;
    [Test]
    procedure Test_Deshabilitado_1_Estado_Origen_Arco_Es_Inhabilitador;
    [Test]
    procedure Test_Habilitado_2_Estados_Origen_1_Arco_Es_Inhabilitador;
    [Test]
    procedure Test_Deshabilitado_2_Estados_Origen_1_Arco_Es_Inhabilitador;

    [Test]
    procedure Test_Habilitado_1_Estado_Origen_1_Estado_Destino;
    [Test]
    procedure Test_Deshabilitado_1_Estado_Origen_1_Estado_Destino_Por_Origen;
    [Test]
    procedure Test_Deshabilitado_1_Estado_Origen_1_Estado_Destino_Por_Destino;

    [Test]
    procedure Test_Transicion_CondicionesOK_1_Estado_Origen_1_Estado_Destino;
    [Test]
    procedure Test_Transicion_CondicionesNoOK_1_Estado_Origen_1_Estado_Destino;

    [Test]
    procedure Test_Transicion_CondicionesOK_Evento_1_Estado_Origen_1_Estado_Destino;
  end;

implementation

uses
  System.SysUtils,

  DPN.Core.Testing.Funciones,
  DPN.TokenColoreado;

{ TPetriNetCoreTesting_ArcoIn }

procedure TPetriNetCoreTesting_Transicion.Test_Deshabilitado_1_Estado_Origen_1_Estado_Destino_Por_Destino;
var
  LToken: IToken;
  I     : Integer;
  LRes  : Boolean;

  FArcoI1    : IArcoIn;
  FPlazaI1   : IPlaza;

  FArcoO1    : IArcoOut;
  FPlazaO1   : IPlaza;

  FTransicion: ITransicion;
begin
  FPlazaI1   := TdpnPlaza.Create;
  FPlazaI1.Nombre    := 'I1';
  FPlazaI1.Capacidad := 1;

  FArcoI1                        := TdpnArcoIn.Create;
  FArcoI1.Plaza                  := FPlazaI1;
  FArcoI1.Peso                   := 1;
  FArcoI1.PesoEvaluar            := 1;

  FPlazaO1   := TdpnPlaza.Create;
  FPlazaO1.Nombre    := 'O1';
  FPlazaO1.Capacidad := 1;

  FArcoO1                        := TdpnArcoOut.Create;
  FArcoO1.Plaza                  := FPlazaO1;
  FArcoO1.Peso                   := 1;

  FTransicion := TdpnTransicion.Create;
  FTransicion.AddArcoIn(FArcoI1);
  FTransicion.AddArcoOut(FArcoO1);

  for I := 1 to 1 do
  begin
    LToken := TdpnTokenColoreado.Create;
    FPlazaI1.AddToken(LToken);
  end;

  for I := 1 to 1 do //saturamos plaza destino
  begin
    LToken := TdpnTokenColoreado.Create;
    FPlazaO1.AddToken(LToken);
  end;

  LRes := FTransicion.IsHabilitado;

  if not LRes then
    Assert.Pass
  else Assert.Fail;
end;

procedure TPetriNetCoreTesting_Transicion.Test_Deshabilitado_1_Estado_Origen_1_Estado_Destino_Por_Origen;
var
  LToken: IToken;
  I     : Integer;
  LRes  : Boolean;

  FArcoI1    : IArcoIn;
  FPlazaI1   : IPlaza;

  FArcoO1    : IArcoOut;
  FPlazaO1   : IPlaza;

  FTransicion: ITransicion;
begin
  FPlazaI1   := TdpnPlaza.Create;
  FPlazaI1.Nombre    := 'I1';
  FPlazaI1.Capacidad := 2;

  FArcoI1                        := TdpnArcoIn.Create;
  FArcoI1.Plaza                  := FPlazaI1;
  FArcoI1.Peso                   := 2;
  FArcoI1.PesoEvaluar            := 2;

  FPlazaO1   := TdpnPlaza.Create;
  FPlazaO1.Nombre    := 'O1';
  FPlazaO1.Capacidad := 1;

  FArcoO1                        := TdpnArcoOut.Create;
  FArcoO1.Plaza                  := FPlazaO1;
  FArcoO1.Peso                   := 1;

  FTransicion := TdpnTransicion.Create;
  FTransicion.AddArcoIn(FArcoI1);
  FTransicion.AddArcoOut(FArcoO1);

  for I := 1 to 1 do // solo 1
  begin
    LToken := TdpnTokenColoreado.Create;
    FPlazaI1.AddToken(LToken);
  end;

  LRes := FTransicion.IsHabilitado;

  if not LRes then
    Assert.Pass
  else Assert.Fail;
end;

procedure TPetriNetCoreTesting_Transicion.Test_Deshabilitado_1_Estado_Origen;
var
  LRes  : Boolean;

  FArcoI1    : IArcoIn;
  FPlazaI1   : IPlaza;
  FTransicion: ITransicion;
begin
  FPlazaI1   := TdpnPlaza.Create;
  FPlazaI1.Nombre    := 'O1';
  FPlazaI1.Capacidad := 1;

  FArcoI1                        := TdpnArcoIn.Create;
  FArcoI1.Plaza                  := FPlazaI1;
  FArcoI1.Peso                   := 1;
  FArcoI1.PesoEvaluar            := 1;

  FTransicion := TdpnTransicion.Create;
  FTransicion.AddArcoIn(FArcoI1);

  LRes := FTransicion.IsHabilitado;

  if not LRes then
    Assert.Pass
  else Assert.Fail;
end;

procedure TPetriNetCoreTesting_Transicion.Test_Deshabilitado_1_Estado_Origen_Arco_Es_Inhabilitador;
var
  LToken: IToken;
  I     : Integer;
  LRes  : Boolean;

  FArcoI1    : IArcoIn;
  FPlazaI1   : IPlaza;
  FTransicion: ITransicion;
begin
  FPlazaI1   := TdpnPlaza.Create;
  FPlazaI1.Nombre    := 'O1';
  FPlazaI1.Capacidad := 1;

  FArcoI1                        := TdpnArcoIn.Create;
  FArcoI1.IsInhibidor            := True;
  FArcoI1.Plaza                  := FPlazaI1;
  FArcoI1.Peso                   := 1;
  FArcoI1.PesoEvaluar            := 1;

  FTransicion := TdpnTransicion.Create;
  FTransicion.AddArcoIn(FArcoI1);

  for I := 1 to 1 do
  begin
    LToken := TdpnTokenColoreado.Create;
    FPlazaI1.AddToken(LToken);
  end;

  LRes := FTransicion.IsHabilitado;

  if not LRes then
    Assert.Pass
  else Assert.Fail;
end;

procedure TPetriNetCoreTesting_Transicion.Test_Deshabilitado_2_Estados_Origen;
var
  LRes  : Boolean;

  FArcoI1    : IArcoIn;
  FPlazaI1   : IPlaza;

  FArcoI2    : IArcoIn;
  FPlazaI2   : IPlaza;

  FTransicion: ITransicion;
begin
  FPlazaI1   := TdpnPlaza.Create;
  FPlazaI1.Nombre    := 'O1';
  FPlazaI1.Capacidad := 1;

  FArcoI1                        := TdpnArcoIn.Create;
  FArcoI1.Plaza                  := FPlazaI1;
  FArcoI1.Peso                   := 1;
  FArcoI1.PesoEvaluar            := 1;

  FPlazaI2   := TdpnPlaza.Create;
  FPlazaI2.Nombre    := 'O2';
  FPlazaI2.Capacidad := 1;

  FArcoI2                        := TdpnArcoIn.Create;
  FArcoI2.Plaza                  := FPlazaI2;
  FArcoI2.Peso                   := 1;
  FArcoI2.PesoEvaluar            := 1;

  FTransicion := TdpnTransicion.Create;
  FTransicion.AddArcoIn(FArcoI1);
  FTransicion.AddArcoIn(FArcoI2);

  LRes := FTransicion.IsHabilitado;

  if not LRes then
    Assert.Pass
  else Assert.Fail;
end;

procedure TPetriNetCoreTesting_Transicion.Test_Deshabilitado_2_Estados_Origen_1_Arco_Es_Inhabilitador;
var
  LToken: IToken;
  I     : Integer;
  LRes  : Boolean;

  FArcoI1    : IArcoIn;
  FPlazaI1   : IPlaza;
  FArcoI2    : IArcoIn;
  FPlazaI2   : IPlaza;
  FTransicion: ITransicion;
begin
  FPlazaI1   := TdpnPlaza.Create;
  FPlazaI1.Nombre    := 'O1';
  FPlazaI1.Capacidad := 1;

  FArcoI1                        := TdpnArcoIn.Create;
  FArcoI1.Plaza                  := FPlazaI1;
  FArcoI1.Peso                   := 1;
  FArcoI1.PesoEvaluar            := 1;
  FArcoI1.IsInhibidor            := True;

  FPlazaI2   := TdpnPlaza.Create;
  FPlazaI2.Nombre    := 'O2';
  FPlazaI2.Capacidad := 1;

  FArcoI2                        := TdpnArcoIn.Create;
  FArcoI2.Plaza                  := FPlazaI2;
  FArcoI2.Peso                   := 1;
  FArcoI2.PesoEvaluar            := 1;

  FTransicion := TdpnTransicion.Create;
  FTransicion.AddArcoIn(FArcoI1);
  FTransicion.AddArcoIn(FArcoI2);

  for I := 1 to 1 do
  begin
    LToken := TdpnTokenColoreado.Create;
    FPlazaI1.AddToken(LToken);
  end;

  LRes := FTransicion.IsHabilitado;

  if LRes then // de los 2 arcos solo 1 habilitado
    Assert.Fail;

  for I := 1 to 2 do
  begin
    LToken := TdpnTokenColoreado.Create;
    FPlazaI2.AddToken(LToken);
  end;

  LRes := FTransicion.IsHabilitado;

  if not LRes then
    Assert.Pass
  else Assert.Fail;
end;

procedure TPetriNetCoreTesting_Transicion.Test_Habilitado_1_Estado_Origen;
var
  LToken: IToken;
  I     : Integer;
  LRes  : Boolean;

  FArcoI1    : IArcoIn;
  FPlazaI1   : IPlaza;
  FTransicion: ITransicion;
begin
  FPlazaI1   := TdpnPlaza.Create;
  FPlazaI1.Nombre    := 'O1';
  FPlazaI1.Capacidad := 1;

  FArcoI1                        := TdpnArcoIn.Create;
  FArcoI1.Plaza                  := FPlazaI1;
  FArcoI1.Peso                   := 1;
  FArcoI1.PesoEvaluar            := 1;

  FTransicion := TdpnTransicion.Create;
  FTransicion.AddArcoIn(FArcoI1);

  for I := 1 to 1 do
  begin
    LToken := TdpnTokenColoreado.Create;
    FPlazaI1.AddToken(LToken);
  end;

  LRes := FTransicion.IsHabilitado;

  if LRes then
    Assert.Pass
  else Assert.Fail;
end;

procedure TPetriNetCoreTesting_Transicion.Test_Habilitado_1_Estado_Origen_1_Estado_Destino;
var
  LToken: IToken;
  I     : Integer;
  LRes  : Boolean;

  FArcoI1    : IArcoIn;
  FPlazaI1   : IPlaza;

  FArcoO1    : IArcoOut;
  FPlazaO1   : IPlaza;

  FTransicion: ITransicion;
begin
  FPlazaI1   := TdpnPlaza.Create;
  FPlazaI1.Nombre    := 'I1';
  FPlazaI1.Capacidad := 1;

  FArcoI1                        := TdpnArcoIn.Create;
  FArcoI1.Plaza                  := FPlazaI1;
  FArcoI1.Peso                   := 1;
  FArcoI1.PesoEvaluar            := 1;

  FPlazaO1   := TdpnPlaza.Create;
  FPlazaO1.Nombre    := 'O1';
  FPlazaO1.Capacidad := 1;

  FArcoO1                        := TdpnArcoOut.Create;
  FArcoO1.Plaza                  := FPlazaO1;
  FArcoO1.Peso                   := 1;

  FTransicion := TdpnTransicion.Create;
  FTransicion.AddArcoIn(FArcoI1);
  FTransicion.AddArcoOut(FArcoO1);

  for I := 1 to 1 do
  begin
    LToken := TdpnTokenColoreado.Create;
    FPlazaI1.AddToken(LToken);
  end;

  LRes := FTransicion.IsHabilitado;

  if LRes then
    Assert.Pass
  else Assert.Fail;
end;

procedure TPetriNetCoreTesting_Transicion.Test_Habilitado_1_Estado_Origen_Arco_Es_Inhabilitador;
var
  LRes  : Boolean;

  FArcoI1    : IArcoIn;
  FPlazaI1   : IPlaza;
  FTransicion: ITransicion;
begin
  FPlazaI1   := TdpnPlaza.Create;
  FPlazaI1.Nombre    := 'O1';
  FPlazaI1.Capacidad := 1;

  FArcoI1                        := TdpnArcoIn.Create;
  FArcoI1.IsInhibidor            := True;
  FArcoI1.Plaza                  := FPlazaI1;
  FArcoI1.Peso                   := 1;
  FArcoI1.PesoEvaluar            := 1;

  FTransicion := TdpnTransicion.Create;
  FTransicion.AddArcoIn(FArcoI1);

  LRes := FTransicion.IsHabilitado;

  if LRes then
    Assert.Pass
  else Assert.Fail;
end;

procedure TPetriNetCoreTesting_Transicion.Test_Habilitado_2_Estados_Origen;
var
  LToken: IToken;
  I     : Integer;
  LRes  : Boolean;

  FArcoI1    : IArcoIn;
  FPlazaI1   : IPlaza;
  FArcoI2    : IArcoIn;
  FPlazaI2   : IPlaza;
  FTransicion: ITransicion;
begin
  FPlazaI1   := TdpnPlaza.Create;
  FPlazaI1.Nombre    := 'O1';
  FPlazaI1.Capacidad := 1;

  FArcoI1                        := TdpnArcoIn.Create;
  FArcoI1.Plaza                  := FPlazaI1;
  FArcoI1.Peso                   := 1;
  FArcoI1.PesoEvaluar            := 1;

  FPlazaI2   := TdpnPlaza.Create;
  FPlazaI2.Nombre    := 'O2';
  FPlazaI2.Capacidad := 1;

  FArcoI2                        := TdpnArcoIn.Create;
  FArcoI2.Plaza                  := FPlazaI2;
  FArcoI2.Peso                   := 1;
  FArcoI2.PesoEvaluar            := 1;

  FTransicion := TdpnTransicion.Create;
  FTransicion.AddArcoIn(FArcoI1);
  FTransicion.AddArcoIn(FArcoI2);

  for I := 1 to 1 do
  begin
    LToken := TdpnTokenColoreado.Create;
    FPlazaI1.AddToken(LToken);
  end;

  LRes := FTransicion.IsHabilitado;

  if LRes then // de los 2 arcos solo 1 habilitado
    Assert.Fail;

  for I := 1 to 2 do
  begin
    LToken := TdpnTokenColoreado.Create;
    FPlazaI2.AddToken(LToken);
  end;

  LRes := FTransicion.IsHabilitado;

  if LRes then
    Assert.Pass
  else Assert.Fail;
end;

procedure TPetriNetCoreTesting_Transicion.Test_Habilitado_2_Estados_Origen_1_Arco_Es_Inhabilitador;
var
  LToken: IToken;
  I     : Integer;
  LRes  : Boolean;

  FArcoI1    : IArcoIn;
  FPlazaI1   : IPlaza;
  FArcoI2    : IArcoIn;
  FPlazaI2   : IPlaza;
  FTransicion: ITransicion;
begin
  FPlazaI1   := TdpnPlaza.Create;
  FPlazaI1.Nombre    := 'O1';
  FPlazaI1.Capacidad := 1;

  FArcoI1                        := TdpnArcoIn.Create;
  FArcoI1.Plaza                  := FPlazaI1;
  FArcoI1.Peso                   := 1;
  FArcoI1.PesoEvaluar            := 1;
  FArcoI1.IsInhibidor            := True;

  FPlazaI2   := TdpnPlaza.Create;
  FPlazaI2.Nombre    := 'O2';
  FPlazaI2.Capacidad := 1;

  FArcoI2                        := TdpnArcoIn.Create;
  FArcoI2.Plaza                  := FPlazaI2;
  FArcoI2.Peso                   := 1;
  FArcoI2.PesoEvaluar            := 1;

  FTransicion := TdpnTransicion.Create;
  FTransicion.AddArcoIn(FArcoI1);
  FTransicion.AddArcoIn(FArcoI2);

  LRes := FTransicion.IsHabilitado;

  if LRes then // de los 2 arcos solo 1 habilitado
    Assert.Fail;

  for I := 1 to 2 do
  begin
    LToken := TdpnTokenColoreado.Create;
    FPlazaI2.AddToken(LToken);
  end;

  LRes := FTransicion.IsHabilitado;

  if LRes then
    Assert.Pass
  else Assert.Fail;
end;

procedure TPetriNetCoreTesting_Transicion.Test_Transicion_CondicionesNoOK_1_Estado_Origen_1_Estado_Destino;
var
  LToken: IToken;
  I     : Integer;
  LRes  : Boolean;

  FArcoI1    : IArcoIn;
  FPlazaI1   : IPlaza;

  FArcoO1    : IArcoOut;
  FPlazaO1   : IPlaza;

  FTransicion: ITransicion;

  FFuncion : ICondicion;
  FEnabled : IVariable;
begin
  FEnabled := TdpnVariable.Create;
  FEnabled.Nombre := 'Enabled';
  FEnabled.Valor  := 0;

  FFuncion := TdpnCondicion_es_tabla_variables.Create;
  TdpnCondicion_es_tabla_variables(FFuncion).Variable     := FEnabled;
  TdpnCondicion_es_tabla_variables(FFuncion).ValorToCheck := 5;

  FPlazaI1   := TdpnPlaza.Create;
  FPlazaI1.Nombre    := 'I1';
  FPlazaI1.Capacidad := 1;

  FArcoI1                        := TdpnArcoIn.Create;
  FArcoI1.Plaza                  := FPlazaI1;
  FArcoI1.Peso                   := 1;
  FArcoI1.PesoEvaluar            := 1;

  FPlazaO1   := TdpnPlaza.Create;
  FPlazaO1.Nombre    := 'O1';
  FPlazaO1.Capacidad := 1;

  FArcoO1                        := TdpnArcoOut.Create;
  FArcoO1.Plaza                  := FPlazaO1;
  FArcoO1.Peso                   := 1;

  FTransicion := TdpnTransicion.Create;
  FTransicion.Start;

  FTransicion.AddArcoIn(FArcoI1);
  FTransicion.AddArcoOut(FArcoO1);
  FTransicion.AddCondicion(FFuncion);

  for I := 1 to 1 do
  begin
    LToken := TdpnTokenColoreado.Create;
    FPlazaI1.AddToken(LToken);
  end;

  LRes := FTransicion.IsHabilitado;
  if not LRes then
    Assert.Fail('No habilitado!');

  LRes := FTransicion.EjecutarTransicion;
  if LRes then
    Assert.Fail('No debiera!');

  FEnabled.Valor  := 7;

  LRes := FTransicion.EjecutarTransicion;

  if not LRes then
    Assert.Pass
  else Assert.Fail;
end;

procedure TPetriNetCoreTesting_Transicion.Test_Transicion_CondicionesOK_Evento_1_Estado_Origen_1_Estado_Destino;
var
  LToken: IToken;
  I     : Integer;
  LRes  : Boolean;

  FArcoI1    : IArcoIn;
  FPlazaI1   : IPlaza;

  FArcoO1    : IArcoOut;
  FPlazaO1   : IPlaza;

  FTransicion: ITransicion;

  FFuncion : ICondicion;
  FEnabled : IVariable;
  FFuncionE: ICondicion;

  LEvento  : IEventEE;
  LEventoR : IEventEE;

  LPlaza   : IPlaza;
  LMarcado : IMarcadoTokens;
begin
  FEnabled := TdpnVariable.Create;
  FEnabled.Nombre := 'Enabled';
  FEnabled.Valor  := 0;

  FFuncionE := TdpnCondicion_Evento_Prueba.Create;
  TdpnCondicion_Evento_Prueba(FFuncionE).Numero := 5;

  FFuncion := TdpnCondicion_es_tabla_variables.Create;
  TdpnCondicion_es_tabla_variables(FFuncion).Variable     := FEnabled;
  TdpnCondicion_es_tabla_variables(FFuncion).ValorToCheck := 5;

  FPlazaI1   := TdpnPlaza.Create;
  FPlazaI1.Nombre    := 'I1';
  FPlazaI1.Capacidad := 1;

  FArcoI1                        := TdpnArcoIn.Create;
  FArcoI1.Plaza                  := FPlazaI1;
  FArcoI1.Peso                   := 1;
  FArcoI1.PesoEvaluar            := 1;

  FPlazaO1   := TdpnPlaza.Create;
  FPlazaO1.Nombre    := 'O1';
  FPlazaO1.Capacidad := 1;

  FArcoO1                        := TdpnArcoOut.Create;
  FArcoO1.Plaza                  := FPlazaO1;
  FArcoO1.Peso                   := 1;

  FTransicion := TdpnTransicion.Create;

  FTransicion.AddArcoIn(FArcoI1);
  FTransicion.AddArcoOut(FArcoO1);
  FTransicion.AddCondicion(FFuncion);
  FTransicion.AddCondicion(FFuncionE);

  FTransicion.Start;

  LRes := FTransicion.IsHabilitado;
  if LRes then
    Assert.Fail('Habilitado, y no debiera');

  for I := 1 to 1 do
  begin
    LToken := TdpnTokenColoreado.Create;
    FPlazaI1.AddToken(LToken);
  end;

  LRes := FTransicion.IsHabilitado;
  if not LRes then
    Assert.Fail('No Habilitado, y debiera');

  LRes := FTransicion.EjecutarTransicion;
  if LRes then
    Assert.Fail('No debiera!');

  FEnabled.Valor  := 5;

  LEvento := TEventoPrueba.Create;
  TEventoPrueba(LEvento).Numero := 5;
  TEventoPrueba(LEvento).Texto  := 'Hola';
  LEvento.Post;
  Sleep(50);

  LRes := FTransicion.IsHabilitado;
  if not LRes then
    Assert.Fail('No habilitado, y debiera');

  LRes := FTransicion.EjecutarTransicion;

  if LRes then
    Assert.Pass
  else Assert.Fail;
end;

procedure TPetriNetCoreTesting_Transicion.Test_Transicion_CondicionesOK_1_Estado_Origen_1_Estado_Destino;
var
  LToken: IToken;
  I     : Integer;
  LRes  : Boolean;

  FArcoI1    : IArcoIn;
  FPlazaI1   : IPlaza;

  FArcoO1    : IArcoOut;
  FPlazaO1   : IPlaza;

  FTransicion: ITransicion;

  FFuncion : ICondicion;
  FEnabled : IVariable;
begin
  FEnabled := TdpnVariable.Create;
  FEnabled.Nombre := 'Enabled';
  FEnabled.Valor  := 0;

  FFuncion := TdpnCondicion_es_tabla_variables.Create;
  TdpnCondicion_es_tabla_variables(FFuncion).Variable     := FEnabled;
  TdpnCondicion_es_tabla_variables(FFuncion).ValorToCheck := 5;

  FPlazaI1   := TdpnPlaza.Create;
  FPlazaI1.Nombre    := 'I1';
  FPlazaI1.Capacidad := 1;

  FArcoI1                        := TdpnArcoIn.Create;
  FArcoI1.Plaza                  := FPlazaI1;
  FArcoI1.Peso                   := 1;
  FArcoI1.PesoEvaluar            := 1;

  FPlazaO1   := TdpnPlaza.Create;
  FPlazaO1.Nombre    := 'O1';
  FPlazaO1.Capacidad := 1;

  FArcoO1                        := TdpnArcoOut.Create;
  FArcoO1.Plaza                  := FPlazaO1;
  FArcoO1.Peso                   := 1;

  FTransicion := TdpnTransicion.Create;
  FTransicion.Start;

  FTransicion.AddArcoIn(FArcoI1);
  FTransicion.AddArcoOut(FArcoO1);
  FTransicion.AddCondicion(FFuncion);

  for I := 1 to 1 do
  begin
    LToken := TdpnTokenColoreado.Create;
    FPlazaI1.AddToken(LToken);
  end;

  LRes := FTransicion.IsHabilitado;
  if not LRes then
    Assert.Fail('No habilitado!');

  LRes := FTransicion.EjecutarTransicion;
  if LRes then
    Assert.Fail('No debiera!');

  FEnabled.Valor  := 5;

  LRes := FTransicion.EjecutarTransicion;

  if LRes then
    Assert.Pass
  else Assert.Fail;
end;

initialization
  TDUnitX.RegisterTestFixture(TPetriNetCoreTesting_Transicion);

end.

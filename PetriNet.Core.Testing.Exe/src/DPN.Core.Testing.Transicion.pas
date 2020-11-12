{$I Defines.inc}
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
{$IFDEF TESTS_HABILITADOS}
  [TestFixture]
{$ENDIF}
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

    [Test]
    procedure Test_Transicion_CondicionesNoOK_Evento_1_Estado_Origen_1_Estado_Destino;

    [Test]
    procedure Test_Transicion_CondicionesNoOK_Varios_Eventos_1_Estado_Origen_1_Estado_Destino;
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

  LArcoI1    : IArcoIn;
  LPlazaI1   : IPlaza;

  LArcoO1    : IArcoOut;
  LPlazaO1   : IPlaza;

  LTransicion: ITransicion;
begin
  LPlazaI1   := TdpnPlaza.Create;
  LPlazaI1.NombreReducido    := 'I1';
  LPlazaI1.Capacidad := 1;

  LArcoI1                        := TdpnArcoIn.Create;
  LArcoI1.Plaza                  := LPlazaI1;
  LArcoI1.Peso                   := 1;
  LArcoI1.PesoEvaluar            := 1;

  LPlazaO1   := TdpnPlaza.Create;
  LPlazaO1.NombreReducido    := 'O1';
  LPlazaO1.Capacidad := 1;

  LArcoO1                        := TdpnArcoOut.Create;
  LArcoO1.Plaza                  := LPlazaO1;
  LArcoO1.Peso                   := 1;

  LTransicion := TdpnTransicion.Create;
  LTransicion.AddArcoIn(LArcoI1);
  LTransicion.AddArcoOut(LArcoO1);

  for I := 1 to 1 do
  begin
    LToken := TdpnTokenColoreado.Create;
    LPlazaI1.AddToken(LToken);
  end;

  for I := 1 to 1 do //saturamos plaza destino
  begin
    LToken := TdpnTokenColoreado.Create;
    LPlazaO1.AddToken(LToken);
  end;

  LRes := LTransicion.IsHabilitado;

  if not LRes then
    Assert.Pass
  else Assert.Fail;
end;

procedure TPetriNetCoreTesting_Transicion.Test_Deshabilitado_1_Estado_Origen_1_Estado_Destino_Por_Origen;
var
  LToken: IToken;
  I     : Integer;
  LRes  : Boolean;

  LArcoI1    : IArcoIn;
  LPlazaI1   : IPlaza;

  LArcoO1    : IArcoOut;
  LPlazaO1   : IPlaza;

  LTransicion: ITransicion;
begin
  LPlazaI1   := TdpnPlaza.Create;
  LPlazaI1.NombreReducido    := 'I1';
  LPlazaI1.Capacidad := 2;

  LArcoI1                        := TdpnArcoIn.Create;
  LArcoI1.Plaza                  := LPlazaI1;
  LArcoI1.Peso                   := 2;
  LArcoI1.PesoEvaluar            := 2;

  LPlazaO1   := TdpnPlaza.Create;
  LPlazaO1.NombreReducido    := 'O1';
  LPlazaO1.Capacidad := 1;

  LArcoO1                        := TdpnArcoOut.Create;
  LArcoO1.Plaza                  := LPlazaO1;
  LArcoO1.Peso                   := 1;

  LTransicion := TdpnTransicion.Create;
  LTransicion.AddArcoIn(LArcoI1);
  LTransicion.AddArcoOut(LArcoO1);

  for I := 1 to 1 do // solo 1
  begin
    LToken := TdpnTokenColoreado.Create;
    LPlazaI1.AddToken(LToken);
  end;

  LRes := LTransicion.IsHabilitado;

  if not LRes then
    Assert.Pass
  else Assert.Fail;
end;

procedure TPetriNetCoreTesting_Transicion.Test_Deshabilitado_1_Estado_Origen;
var
  LRes  : Boolean;

  LArcoI1    : IArcoIn;
  LPlazaI1   : IPlaza;
  LTransicion: ITransicion;
begin
  LPlazaI1   := TdpnPlaza.Create;
  LPlazaI1.NombreReducido    := 'O1';
  LPlazaI1.Capacidad := 1;

  LArcoI1                        := TdpnArcoIn.Create;
  LArcoI1.Plaza                  := LPlazaI1;
  LArcoI1.Peso                   := 1;
  LArcoI1.PesoEvaluar            := 1;

  LTransicion := TdpnTransicion.Create;
  LTransicion.AddArcoIn(LArcoI1);

  LRes := LTransicion.IsHabilitado;

  if not LRes then
    Assert.Pass
  else Assert.Fail;
end;

procedure TPetriNetCoreTesting_Transicion.Test_Deshabilitado_1_Estado_Origen_Arco_Es_Inhabilitador;
var
  LToken: IToken;
  I     : Integer;
  LRes  : Boolean;

  LArcoI1    : IArcoIn;
  LPlazaI1   : IPlaza;
  LTransicion: ITransicion;
begin
  LPlazaI1   := TdpnPlaza.Create;
  LPlazaI1.NombreReducido    := 'O1';
  LPlazaI1.Capacidad := 1;
  LPlazaI1.Start;

  LArcoI1                        := TdpnArcoIn.Create;
  LArcoI1.IsInhibidor            := True;
  LArcoI1.Plaza                  := LPlazaI1;
  LArcoI1.Peso                   := 1;
  LArcoI1.PesoEvaluar            := 1;
  LArcoI1.Start;

  LTransicion := TdpnTransicion.Create;
  LTransicion.AddArcoIn(LArcoI1);
  LTransicion.Start;

  for I := 1 to 1 do
  begin
    LToken := TdpnTokenColoreado.Create;
    LPlazaI1.AddToken(LToken);
  end;

  LRes := LTransicion.IsHabilitado;

  if not LRes then
    Assert.Pass
  else Assert.Fail;
end;

procedure TPetriNetCoreTesting_Transicion.Test_Deshabilitado_2_Estados_Origen;
var
  LRes  : Boolean;

  LArcoI1    : IArcoIn;
  LPlazaI1   : IPlaza;

  LArcoI2    : IArcoIn;
  LPlazaI2   : IPlaza;

  LTransicion: ITransicion;
begin
  LPlazaI1   := TdpnPlaza.Create;
  LPlazaI1.NombreReducido    := 'O1';
  LPlazaI1.Capacidad := 1;

  LArcoI1                        := TdpnArcoIn.Create;
  LArcoI1.Plaza                  := LPlazaI1;
  LArcoI1.Peso                   := 1;
  LArcoI1.PesoEvaluar            := 1;

  LPlazaI2   := TdpnPlaza.Create;
  LPlazaI2.NombreReducido    := 'O2';
  LPlazaI2.Capacidad := 1;

  LArcoI2                        := TdpnArcoIn.Create;
  LArcoI2.Plaza                  := LPlazaI2;
  LArcoI2.Peso                   := 1;
  LArcoI2.PesoEvaluar            := 1;

  LTransicion := TdpnTransicion.Create;
  LTransicion.AddArcoIn(LArcoI1);
  LTransicion.AddArcoIn(LArcoI2);

  LRes := LTransicion.IsHabilitado;

  if not LRes then
    Assert.Pass
  else Assert.Fail;
end;

procedure TPetriNetCoreTesting_Transicion.Test_Deshabilitado_2_Estados_Origen_1_Arco_Es_Inhabilitador;
var
  LToken: IToken;
  I     : Integer;
  LRes  : Boolean;

  LArcoI1    : IArcoIn;
  LPlazaI1   : IPlaza;
  LArcoI2    : IArcoIn;
  LPlazaI2   : IPlaza;
  LTransicion: ITransicion;
begin
  LPlazaI1   := TdpnPlaza.Create;
  LPlazaI1.NombreReducido    := 'O1';
  LPlazaI1.Capacidad := 1;

  LArcoI1                        := TdpnArcoIn.Create;
  LArcoI1.Plaza                  := LPlazaI1;
  LArcoI1.Peso                   := 1;
  LArcoI1.PesoEvaluar            := 1;
  LArcoI1.IsInhibidor            := True;

  LPlazaI2   := TdpnPlaza.Create;
  LPlazaI2.NombreReducido    := 'O2';
  LPlazaI2.Capacidad := 1;

  LArcoI2                        := TdpnArcoIn.Create;
  LArcoI2.Plaza                  := LPlazaI2;
  LArcoI2.Peso                   := 1;
  LArcoI2.PesoEvaluar            := 1;

  LTransicion := TdpnTransicion.Create;
  LTransicion.AddArcoIn(LArcoI1);
  LTransicion.AddArcoIn(LArcoI2);

  for I := 1 to 1 do
  begin
    LToken := TdpnTokenColoreado.Create;
    LPlazaI1.AddToken(LToken);
  end;

  LRes := LTransicion.IsHabilitado;

  if LRes then // de los 2 arcos solo 1 habilitado
    Assert.Fail;

  for I := 1 to 2 do
  begin
    LToken := TdpnTokenColoreado.Create;
    LPlazaI2.AddToken(LToken);
  end;

  LRes := LTransicion.IsHabilitado;

  if not LRes then
    Assert.Pass
  else Assert.Fail;
end;

procedure TPetriNetCoreTesting_Transicion.Test_Habilitado_1_Estado_Origen;
var
  LToken: IToken;
  I     : Integer;
  LRes  : Boolean;

  LArcoI1    : IArcoIn;
  LPlazaI1   : IPlaza;
  LTransicion: ITransicion;
begin
  LPlazaI1   := TdpnPlaza.Create;
  LPlazaI1.NombreReducido    := 'O1';
  LPlazaI1.Capacidad := 1;
  LPlazaI1.Start;

  LArcoI1                        := TdpnArcoIn.Create;
  LArcoI1.NombreReducido                 := 'ArcoI1';
  LArcoI1.Plaza                  := LPlazaI1;
  LArcoI1.Peso                   := 1;
  LArcoI1.PesoEvaluar            := 1;
  LArcoI1.Start;

  LTransicion        := TdpnTransicion.Create;
  LTransicion.NombreReducido := 'Trans1';
  LTransicion.AddArcoIn(LArcoI1);
  LTransicion.Start;

  for I := 1 to 1 do
  begin
    LToken := TdpnTokenColoreado.Create;
    LPlazaI1.AddToken(LToken);
  end;

  LRes := LTransicion.IsHabilitado;

  if LRes then
    Assert.Pass
  else Assert.Fail;
end;

procedure TPetriNetCoreTesting_Transicion.Test_Habilitado_1_Estado_Origen_1_Estado_Destino;
var
  LToken: IToken;
  I     : Integer;
  LRes  : Boolean;

  LArcoI1    : IArcoIn;
  LPlazaI1   : IPlaza;

  LArcoO1    : IArcoOut;
  LPlazaO1   : IPlaza;

  LTransicion: ITransicion;
begin
  LPlazaI1   := TdpnPlaza.Create;
  LPlazaI1.NombreReducido    := 'I1';
  LPlazaI1.Capacidad := 1;
  LPlazaI1.Start;

  LArcoI1                        := TdpnArcoIn.Create;
  LArcoI1.Plaza                  := LPlazaI1;
  LArcoI1.Peso                   := 1;
  LArcoI1.PesoEvaluar            := 1;
  LArcoI1.Start;

  LPlazaO1   := TdpnPlaza.Create;
  LPlazaO1.NombreReducido    := 'O1';
  LPlazaO1.Capacidad := 1;
  LPlazaO1.Start;

  LArcoO1                        := TdpnArcoOut.Create;
  LArcoO1.Plaza                  := LPlazaO1;
  LArcoO1.Peso                   := 1;
  LArcoO1.Start;

  LTransicion := TdpnTransicion.Create;
  LTransicion.AddArcoIn(LArcoI1);
  LTransicion.AddArcoOut(LArcoO1);
  LTransicion.Start;

  for I := 1 to 1 do
  begin
    LToken := TdpnTokenColoreado.Create;
    LPlazaI1.AddToken(LToken);
  end;

  LRes := LTransicion.IsHabilitado;

  if LRes then
    Assert.Pass
  else Assert.Fail;
end;

procedure TPetriNetCoreTesting_Transicion.Test_Habilitado_1_Estado_Origen_Arco_Es_Inhabilitador;
var
  LRes  : Boolean;

  LArcoI1    : IArcoIn;
  LPlazaI1   : IPlaza;
  LTransicion: ITransicion;
begin
  LPlazaI1   := TdpnPlaza.Create;
  LPlazaI1.NombreReducido    := 'O1';
  LPlazaI1.Capacidad := 1;
  LPlazaI1.Start;

  LArcoI1                        := TdpnArcoIn.Create;
  LArcoI1.IsInhibidor            := True;
  LArcoI1.Plaza                  := LPlazaI1;
  LArcoI1.Peso                   := 1;
  LArcoI1.PesoEvaluar            := 1;
  LArcoI1.Start;

  LTransicion := TdpnTransicion.Create;
  LTransicion.AddArcoIn(LArcoI1);
  LTransicion.Start;

  LRes := LTransicion.IsHabilitado;

  if LRes then
    Assert.Pass
  else Assert.Fail;
end;

procedure TPetriNetCoreTesting_Transicion.Test_Habilitado_2_Estados_Origen;
var
  LToken: IToken;
  I     : Integer;
  LRes  : Boolean;

  LArcoI1    : IArcoIn;
  LPlazaI1   : IPlaza;
  LArcoI2    : IArcoIn;
  LPlazaI2   : IPlaza;
  LTransicion: ITransicion;
begin
  LPlazaI1   := TdpnPlaza.Create;
  LPlazaI1.NombreReducido    := 'O1';
  LPlazaI1.Capacidad := 1;
  LPlazaI1.Start;

  LArcoI1                        := TdpnArcoIn.Create;
  LArcoI1.NombreReducido                 := 'ArcoI1';
  LArcoI1.Plaza                  := LPlazaI1;
  LArcoI1.Peso                   := 1;
  LArcoI1.PesoEvaluar            := 1;
  LArcoI1.Start;

  LPlazaI2   := TdpnPlaza.Create;
  LPlazaI2.NombreReducido    := 'O2';
  LPlazaI2.Capacidad := 1;
  LPlazaI2.Start;

  LArcoI2                        := TdpnArcoIn.Create;
  LArcoI2.NombreReducido                 := 'ArcoI2';
  LArcoI2.Plaza                  := LPlazaI2;
  LArcoI2.Peso                   := 1;
  LArcoI2.PesoEvaluar            := 1;
  LArcoI2.Start;

  LTransicion := TdpnTransicion.Create;
  LTransicion.NombreReducido := 'Transi';
  LTransicion.AddArcoIn(LArcoI1);
  LTransicion.AddArcoIn(LArcoI2);
  LTransicion.Start;

  for I := 1 to 1 do
  begin
    LToken := TdpnTokenColoreado.Create;
    LPlazaI1.AddToken(LToken);
  end;

  LRes := LTransicion.IsHabilitado;

  if LRes then // de los 2 arcos solo 1 habilitado
    Assert.Fail;

  for I := 1 to 2 do
  begin
    LToken := TdpnTokenColoreado.Create;
    LPlazaI2.AddToken(LToken);
  end;

  LRes := LTransicion.IsHabilitado;

  if LRes then
    Assert.Pass
  else Assert.Fail;
end;

procedure TPetriNetCoreTesting_Transicion.Test_Habilitado_2_Estados_Origen_1_Arco_Es_Inhabilitador;
var
  LToken: IToken;
  I     : Integer;
  LRes  : Boolean;

  LArcoI1    : IArcoIn;
  LPlazaI1   : IPlaza;
  LArcoI2    : IArcoIn;
  LPlazaI2   : IPlaza;
  LTransicion: ITransicion;
begin
  LPlazaI1   := TdpnPlaza.Create;
  LPlazaI1.NombreReducido    := 'O1';
  LPlazaI1.Capacidad := 1;
  LPlazaI1.Start;

  LArcoI1                        := TdpnArcoIn.Create;
  LArcoI1.Plaza                  := LPlazaI1;
  LArcoI1.Peso                   := 1;
  LArcoI1.PesoEvaluar            := 1;
  LArcoI1.IsInhibidor            := True;
  LArcoI1.Start;

  LPlazaI2   := TdpnPlaza.Create;
  LPlazaI2.NombreReducido    := 'O2';
  LPlazaI2.Capacidad := 1;
  LPlazaI2.Start;

  LArcoI2                        := TdpnArcoIn.Create;
  LArcoI2.Plaza                  := LPlazaI2;
  LArcoI2.Peso                   := 1;
  LArcoI2.PesoEvaluar            := 1;
  LArcoI2.Start;

  LTransicion := TdpnTransicion.Create;
  LTransicion.AddArcoIn(LArcoI1);
  LTransicion.AddArcoIn(LArcoI2);
  LTransicion.Start;

  LRes := LTransicion.IsHabilitado;

  if LRes then // de los 2 arcos solo 1 habilitado
    Assert.Fail;

  for I := 1 to 2 do
  begin
    LToken := TdpnTokenColoreado.Create;
    LPlazaI2.AddToken(LToken);
  end;

  LRes := LTransicion.IsHabilitado;

  if LRes then
    Assert.Pass
  else Assert.Fail;
end;

procedure TPetriNetCoreTesting_Transicion.Test_Transicion_CondicionesNoOK_1_Estado_Origen_1_Estado_Destino;
var
  LToken: IToken;
  I     : Integer;
  LRes  : Boolean;

  LArcoI1    : IArcoIn;
  LPlazaI1   : IPlaza;

  LArcoO1    : IArcoOut;
  LPlazaO1   : IPlaza;

  LTransicion: ITransicion;

  LFuncion : ICondicion;
  LEnabled : IVariable;
begin
  LEnabled := TdpnVariable.Create;
  LEnabled.NombreReducido := 'Enabled';
  LEnabled.Valor  := 0;
  LEnabled.Start;

  LFuncion := TdpnCondicion_es_tabla_variables.Create;
  LFuncion.NombreReducido := 'es_tabla_variables' + LFuncion.ID.ToString;
  TdpnCondicion_es_tabla_variables(LFuncion).Variable     := LEnabled;
  TdpnCondicion_es_tabla_variables(LFuncion).ValorToCheck := 5;
  LFuncion.Start;

  LPlazaI1   := TdpnPlaza.Create;
  LPlazaI1.NombreReducido    := 'I1';
  LPlazaI1.Capacidad := 1;
  LPlazaI1.Start;

  LArcoI1                        := TdpnArcoIn.Create;
  LArcoI1.NombreReducido                 := 'AI1';
  LArcoI1.Plaza                  := LPlazaI1;
  LArcoI1.Peso                   := 1;
  LArcoI1.PesoEvaluar            := 1;
  LArcoI1.Start;

  LPlazaO1   := TdpnPlaza.Create;
  LPlazaO1.NombreReducido    := 'O1';
  LPlazaO1.Capacidad := 1;
  LPlazaO1.Start;

  LArcoO1                        := TdpnArcoOut.Create;
  LArcoO1.NombreReducido                 := 'AO1';
  LArcoO1.Plaza                  := LPlazaO1;
  LArcoO1.Peso                   := 1;
  LArcoO1.Start;

  LTransicion := TdpnTransicion.Create;
  LTransicion.NombreReducido := 'Tr' + LTransicion.ID.ToString;
  LTransicion.Start;

  LTransicion.AddArcoIn(LArcoI1);
  LTransicion.AddArcoOut(LArcoO1);
  LTransicion.AddCondicion(LFuncion);
  LTransicion.Start;

  for I := 1 to 1 do
  begin
    LToken := TdpnTokenColoreado.Create;
    LPlazaI1.AddToken(LToken);
  end;

  LRes := LTransicion.IsHabilitado;
  if not LRes then
    Assert.Fail('No habilitado!');

  LRes := LTransicion.EjecutarTransicion;
  if LRes then
    Assert.Fail('No debiera!');

  LEnabled.Valor  := 7;

  LRes := LTransicion.EjecutarTransicion;

  if not LRes then
    Assert.Pass
  else Assert.Fail;
end;

procedure TPetriNetCoreTesting_Transicion.Test_Transicion_CondicionesNoOK_Evento_1_Estado_Origen_1_Estado_Destino;
var
  LToken: IToken;
  I     : Integer;
  LRes  : Boolean;

  LArcoI1    : IArcoIn;
  LPlazaI1   : IPlaza;

  LArcoO1    : IArcoOut;
  LPlazaO1   : IPlaza;

  LTransicion: ITransicion;

  LFuncion : ICondicion;
  LEnabled : IVariable;
  LFuncionE: ICondicion;

  LEvento  : IEvento;
  LEventoR : IEvento;

  LPlaza   : IPlaza;
  LMarcado : IMarcadoTokens;
begin
  LEnabled := TdpnVariable.Create;
  LEnabled.NombreReducido := 'Enabled';
  LEnabled.Valor  := 0;
  LEnabled.Start;

  LFuncionE := TdpnCondicion_Evento_Prueba.Create;
  TdpnCondicion_Evento_Prueba(LFuncionE).Numero := 5;
  LFuncionE.Start;

  LFuncion := TdpnCondicion_es_tabla_variables.Create;
  TdpnCondicion_es_tabla_variables(LFuncion).Variable     := LEnabled;
  TdpnCondicion_es_tabla_variables(LFuncion).ValorToCheck := 5;
  LFuncion.Start;

  LPlazaI1   := TdpnPlaza.Create;
  LPlazaI1.NombreReducido    := 'I1';
  LPlazaI1.Capacidad := 1;
  LPlazaI1.Start;

  LArcoI1                        := TdpnArcoIn.Create;
  LArcoI1.Plaza                  := LPlazaI1;
  LArcoI1.Peso                   := 1;
  LArcoI1.PesoEvaluar            := 1;
  LArcoI1.Start;

  LPlazaO1   := TdpnPlaza.Create;
  LPlazaO1.NombreReducido    := 'O1';
  LPlazaO1.Capacidad := 1;
  LPlazaO1.Start;

  LArcoO1                        := TdpnArcoOut.Create;
  LArcoO1.Plaza                  := LPlazaO1;
  LArcoO1.Peso                   := 1;
  LArcoO1.Start;

  LTransicion := TdpnTransicion.Create;

  LTransicion.AddArcoIn(LArcoI1);
  LTransicion.AddArcoOut(LArcoO1);
  LTransicion.AddCondicion(LFuncion);
  LTransicion.AddCondicion(LFuncionE);

  LTransicion.Start;

  LRes := LTransicion.IsHabilitado;
  if LRes then
    Assert.Fail('Habilitado, y no debiera');

  for I := 1 to 1 do
  begin
    LToken := TdpnTokenColoreado.Create;
    LPlazaI1.AddToken(LToken);
  end;

  LRes := LTransicion.IsHabilitado;
  if not LRes then
    Assert.Fail('No Habilitado, y debiera');

  LRes := LTransicion.EjecutarTransicion;
  if LRes then
    Assert.Fail('No debiera!');

  LEnabled.Valor  := 3; //5

  LEvento := TEventoPrueba.Create;
  TEventoPrueba(LEvento).Numero := 5;
  TEventoPrueba(LEvento).Texto  := 'Hola';
  LEvento.Post;
  Sleep(50);

  LRes := LTransicion.IsHabilitado;
  if not LRes then
    Assert.Fail('No habilitado, y debiera');

  LRes := LTransicion.EjecutarTransicion;

  if LFuncionE.EventosCount <> 0 then
    Assert.Fail('no debiera tener ningun evento guardado');

  if not LRes then
    Assert.Pass
  else Assert.Fail;
end;

procedure TPetriNetCoreTesting_Transicion.Test_Transicion_CondicionesNoOK_Varios_Eventos_1_Estado_Origen_1_Estado_Destino;
var
  LToken: IToken;
  I     : Integer;
  LRes  : Boolean;

  LArcoI1    : IArcoIn;
  LPlazaI1   : IPlaza;

  LArcoO1    : IArcoOut;
  LPlazaO1   : IPlaza;

  LTransicion: ITransicion;

  LFuncion : ICondicion;
  LEnabled : IVariable;
  LFuncionE: ICondicion;

  LEvento  : IEvento;
  LEventoR : IEvento;

  LPlaza   : IPlaza;
  LMarcado : IMarcadoTokens;
begin
  LEnabled := TdpnVariable.Create;
  LEnabled.NombreReducido := 'Enabled';
  LEnabled.Valor  := 0;
  LEnabled.Start;

  LFuncionE := TdpnCondicion_Evento_Prueba.Create;
  TdpnCondicion_Evento_Prueba(LFuncionE).Numero := 5;
  LFuncionE.Start;

  LFuncion := TdpnCondicion_es_tabla_variables.Create;
  TdpnCondicion_es_tabla_variables(LFuncion).Variable     := LEnabled;
  TdpnCondicion_es_tabla_variables(LFuncion).ValorToCheck := 5;
  LFuncion.Start;

  LPlazaI1   := TdpnPlaza.Create;
  LPlazaI1.NombreReducido    := 'I1';
  LPlazaI1.Capacidad := 2;
  LPlazaI1.Start;

  LArcoI1                        := TdpnArcoIn.Create;
  LArcoI1.Plaza                  := LPlazaI1;
  LArcoI1.Peso                   := 1;
  LArcoI1.PesoEvaluar            := 1;
  LArcoI1.Start;

  LPlazaO1   := TdpnPlaza.Create;
  LPlazaO1.NombreReducido    := 'O1';
  LPlazaO1.Capacidad := 1;
  LPlazaO1.Start;

  LArcoO1                        := TdpnArcoOut.Create;
  LArcoO1.Plaza                  := LPlazaO1;
  LArcoO1.Peso                   := 1;
  LArcoO1.Start;

  LTransicion := TdpnTransicion.Create;

  LTransicion.AddArcoIn(LArcoI1);
  LTransicion.AddArcoOut(LArcoO1);
  LTransicion.AddCondicion(LFuncion);
  LTransicion.AddCondicion(LFuncionE);

  LTransicion.Start;

  LRes := LTransicion.IsHabilitado;
  if LRes then
    Assert.Fail('Habilitado, y no debiera');

  for I := 1 to 2 do
  begin
    LToken := TdpnTokenColoreado.Create;
    LPlazaI1.AddToken(LToken);
  end;

  LRes := LTransicion.IsHabilitado;
  if not LRes then
    Assert.Fail('No Habilitado, y debiera');

  LRes := LTransicion.EjecutarTransicion;
  if LRes then
    Assert.Fail('No debiera!');

  LEnabled.Valor  := 3; //5

  LEvento := TEventoPrueba.Create;
  TEventoPrueba(LEvento).Numero := 5;
  TEventoPrueba(LEvento).Texto  := 'Hola';
  LEvento.Post;

  LEvento := TEventoPrueba.Create;
  TEventoPrueba(LEvento).Numero := 5;
  TEventoPrueba(LEvento).Texto  := 'Hola';
  LEvento.Post;

  Sleep(50);

  LRes := LTransicion.IsHabilitado;
  if not LRes then
    Assert.Fail('No habilitado, y debiera');

  LRes := LTransicion.EjecutarTransicion;

  if LFuncionE.EventosCount <> 0 then
    Assert.Fail('no debiera tener ningun evento guardado');

  if not LRes then
    Assert.Pass
  else Assert.Fail;
end;

procedure TPetriNetCoreTesting_Transicion.Test_Transicion_CondicionesOK_Evento_1_Estado_Origen_1_Estado_Destino;
var
  LToken: IToken;
  I     : Integer;
  LRes  : Boolean;

  LArcoI1    : IArcoIn;
  LPlazaI1   : IPlaza;

  LArcoO1    : IArcoOut;
  LPlazaO1   : IPlaza;

  LTransicion: ITransicion;

  LFuncion : ICondicion;
  LEnabled : IVariable;
  LFuncionE: ICondicion;

  LEvento  : IEvento;
  LEventoR : IEvento;

  LPlaza   : IPlaza;
  LMarcado : IMarcadoTokens;
begin
  LEnabled := TdpnVariable.Create;
  LEnabled.NombreReducido := 'Enabled';
  LEnabled.Valor  := 0;
  LEnabled.Start;

  LFuncionE := TdpnCondicion_Evento_Prueba.Create;
  TdpnCondicion_Evento_Prueba(LFuncionE).Numero := 5;
  LFuncionE.Start;

  LFuncion := TdpnCondicion_es_tabla_variables.Create;
  TdpnCondicion_es_tabla_variables(LFuncion).Variable     := LEnabled;
  TdpnCondicion_es_tabla_variables(LFuncion).ValorToCheck := 5;
  LFuncion.Start;

  LPlazaI1   := TdpnPlaza.Create;
  LPlazaI1.NombreReducido    := 'I1';
  LPlazaI1.Capacidad := 1;
  LPlazaI1.Start;

  LArcoI1                        := TdpnArcoIn.Create;
  LArcoI1.Plaza                  := LPlazaI1;
  LArcoI1.Peso                   := 1;
  LArcoI1.PesoEvaluar            := 1;
  LArcoI1.Start;

  LPlazaO1   := TdpnPlaza.Create;
  LPlazaO1.NombreReducido    := 'O1';
  LPlazaO1.Capacidad := 1;
  LPlazaO1.Start;

  LArcoO1                        := TdpnArcoOut.Create;
  LArcoO1.Plaza                  := LPlazaO1;
  LArcoO1.Peso                   := 1;
  LArcoO1.Start;

  LTransicion := TdpnTransicion.Create;

  LTransicion.AddArcoIn(LArcoI1);
  LTransicion.AddArcoOut(LArcoO1);
  LTransicion.AddCondicion(LFuncion);
  LTransicion.AddCondicion(LFuncionE);

  LTransicion.Start;

  LRes := LTransicion.IsHabilitado;
  if LRes then
    Assert.Fail('Habilitado, y no debiera');

  for I := 1 to 1 do
  begin
    LToken := TdpnTokenColoreado.Create;
    LPlazaI1.AddToken(LToken);
  end;

  LRes := LTransicion.IsHabilitado;
  if not LRes then
    Assert.Fail('No Habilitado, y debiera');

  LRes := LTransicion.EjecutarTransicion;
  if LRes then
    Assert.Fail('No debiera!');

  LEnabled.Valor  := 5;

  LEvento := TEventoPrueba.Create;
  TEventoPrueba(LEvento).Numero := 5;
  TEventoPrueba(LEvento).Texto  := 'Hola';
  LEvento.Post;
  Sleep(50);

  LRes := LTransicion.IsHabilitado;
  if not LRes then
    Assert.Fail('No habilitado, y debiera');

  LRes := LTransicion.EjecutarTransicion;

  if LRes then
    Assert.Pass
  else Assert.Fail;
end;

procedure TPetriNetCoreTesting_Transicion.Test_Transicion_CondicionesOK_1_Estado_Origen_1_Estado_Destino;
var
  LToken: IToken;
  I     : Integer;
  LRes  : Boolean;

  LArcoI1    : IArcoIn;
  LPlazaI1   : IPlaza;

  LArcoO1    : IArcoOut;
  LPlazaO1   : IPlaza;

  LTransicion: ITransicion;

  LFuncion : ICondicion;
  LEnabled : IVariable;
begin
  LEnabled         := TdpnVariable.Create;
  LEnabled.NombreReducido  := 'Enabled';
  LEnabled.Valor   := 0;
  LEnabled.Start;

  LFuncion := TdpnCondicion_es_tabla_variables.Create;
  LFuncion.NombreReducido := 'es_tabla_variables' + LFuncion.ID.ToString;
  TdpnCondicion_es_tabla_variables(LFuncion).Variable     := LEnabled;
  TdpnCondicion_es_tabla_variables(LFuncion).ValorToCheck := 5;
  LFuncion.Start;

  LPlazaI1   := TdpnPlaza.Create;
  LPlazaI1.NombreReducido    := 'I1';
  LPlazaI1.Capacidad := 1;
  LPlazaI1.Start;

  LArcoI1                        := TdpnArcoIn.Create;
  LArcoI1.NombreReducido                 := 'ArcoI1';
  LArcoI1.Plaza                  := LPlazaI1;
  LArcoI1.Peso                   := 1;
  LArcoI1.PesoEvaluar            := 1;
  LArcoI1.Start;

  LPlazaO1   := TdpnPlaza.Create;
  LPlazaO1.NombreReducido    := 'O1';
  LPlazaO1.Capacidad := 1;
  LPlazaO1.Start;

  LArcoO1                        := TdpnArcoOut.Create;
  LArcoO1.NombreReducido                 := 'ArcoO1';
  LArcoO1.Plaza                  := LPlazaO1;
  LArcoO1.Peso                   := 1;
  LArcoO1.Start;

  LTransicion := TdpnTransicion.Create;
  LTransicion.NombreReducido    := 'Transi' + LTransicion.ID.ToString;
  LTransicion.AddArcoIn(LArcoI1);
  LTransicion.AddArcoOut(LArcoO1);
  LTransicion.AddCondicion(LFuncion);

  LTransicion.Start;

  for I := 1 to 1 do
  begin
    LToken := TdpnTokenColoreado.Create;
    LPlazaI1.AddToken(LToken);
  end;

  LRes := LTransicion.IsHabilitado;
  if not LRes then
    Assert.Fail('No habilitado!');

  LRes := LTransicion.EjecutarTransicion;
  if LRes then
    Assert.Fail('No debiera!');

  LEnabled.Valor  := 5;

  LRes := LTransicion.EjecutarTransicion;

  if LRes then
    Assert.Pass
  else Assert.Fail;
end;

initialization
{$IFDEF TESTS_HABILITADOS}
  TDUnitX.RegisterTestFixture(TPetriNetCoreTesting_Transicion);
{$ENDIF}
end.

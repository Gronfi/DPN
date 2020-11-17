{$I Defines.inc}
unit DPN.Core.Testing.Rendimiento;

interface

uses
  System.Classes,
  System.Rtti,
  Spring.Collections,

  DUnitX.Loggers.Console,
  DUnitX.TestFramework,

  Event.Engine.Interfaces,
  Event.Engine,

  DPN.Interfaces,
  DPN.PetriNet,
  DPN.Modelo,
  DPN.Variable,
  DPN.Plaza,
  DPN.Plaza.Start,
  DPN.Plaza.Super,
  DPN.Plaza.Finish,
  DPN.ArcoIn,
  DPN.ArcoReset,
  DPN.Condicion,
  DPN.ArcoOut,
  DPN.Transicion;

type
  TThreadTestRendimiento = class(TThread)
    protected
      FPlaza: IPlaza;
      procedure Execute; override;
    public
      constructor Create(const APlaza: IPlaza);
  end;

//{$IFDEF TESTS_HABILITADOS}
  [TestFixture]
//{$ENDIF}
  TPetriNetCoreTesting_Rendimiento = class
  public
    [Test]
    [TestCase('Test=false,5','false,5')]
    [TestCase('Test=true,5','true,5')]
    [TestCase('Test=false,100','false,100')]
    [TestCase('Test=true,100','true,100')]
    [TestCase('Test=false,5000','false,5000')]
    [TestCase('Test=true,5000','true,5000')]
    [TestCase('Test=false,100000','false,10000')]
    [TestCase('Test=true,100000','true,10000')]
    procedure Test_Con_N_Disparos_Concurrentes(const ADisparosConcurrentes: boolean; const ANoEventos: integer);
  end;

implementation

uses
  System.SysUtils,

  Event.Engine.Utils,
  DPN.Core.Testing.Funciones,
  DPN.TokenColoreado;

{ TPetriNetCoreTesting_Rendimiento }

procedure TPetriNetCoreTesting_Rendimiento.Test_Con_N_Disparos_Concurrentes(const ADisparosConcurrentes: boolean; const ANoEventos: integer);
const
  MAX_EVENTOS = 5;
  TIMEOUT = 1000;
var
  LPNet: TdpnPetriNetCoordinador;

  LModelo: IModelo;

  // Bloque 1
  LPlazaS1: IPlaza;
  LArcoIS1 : IArcoIn;

  LTransicionS1: ITransicion;
  LArcoOS1 : IArcoOut;

  LPlazaI1: IPlaza;
  LArcoI1 : IArcoIn;

  LTransicion1: ITransicion;
  LFuncionE1: ICondicion;

  LArcoO1 : IArcoOut;
  LPlazaO1: IPlaza;

  // Bloque 2
  LPlazaS2: IPlaza;
  LArcoIS2 : IArcoIn;

  LTransicionS2: ITransicion;
  LArcoOS2 : IArcoOut;

  LPlazaI2: IPlaza;
  LArcoI2 : IArcoIn;

  LTransicion2: ITransicion;
  LFuncionE2: ICondicion;

  LArcoO2 : IArcoOut;
  LPlazaO2: IPlaza;

  // Bloque 3
  LPlazaS3: IPlaza;
  LArcoIS3 : IArcoIn;

  LTransicionS3: ITransicion;
  LArcoOS3 : IArcoOut;

  LPlazaI3: IPlaza;
  LArcoI3 : IArcoIn;

  LTransicion3: ITransicion;
  LFuncionE3: ICondicion;

  LArcoO3 : IArcoOut;
  LPlazaO3: IPlaza;

  //------------

  LEvento: IEvento;

  I      : Integer;
begin
  LFuncionE1                                     := TdpnCondicion_Evento_Prueba.Create;
  TdpnCondicion_Evento_Prueba(LFuncionE1).Numero := 5;

  LFuncionE2                                     := TdpnCondicion_Evento_Prueba.Create;
  TdpnCondicion_Evento_Prueba(LFuncionE2).Numero := 5;

  LFuncionE3                                     := TdpnCondicion_Evento_Prueba.Create;
  TdpnCondicion_Evento_Prueba(LFuncionE3).Numero := 5;

  LModelo := TdpnModelo.Create;

  //Bloque 1
  LPlazaS1                                    := TdpnPlazaStart.Create;
  LPlazaS1.NombreReducido                     := 'S1';
  TdpnPlazaStart(LPlazaS1).GeneracionContinua := True;

  LArcoIS1             := TdpnArcoIn.Create;
  LArcoIS1.Plaza       := LPlazaS1;
  LArcoIS1.Peso        := 1;
  LArcoIS1.PesoEvaluar := 1;

  LArcoOS1       := TdpnArcoOut.Create;
  LArcoOS1.Peso  := 1;

  LTransicionS1 := TdpnTransicion.Create;
  LTransicionS1.AddArcoIn(LArcoIS1);
  LTransicionS1.AddArcoOut(LArcoOS1);

  LPlazaI1                := TdpnPlaza.Create;
  LPlazaI1.NombreReducido := 'I1';
  LPlazaI1.Capacidad      := ANoEventos;

  LArcoOS1.Plaza := LPlazaI1;

  LArcoI1             := TdpnArcoIn.Create;
  LArcoI1.Plaza       := LPlazaI1;
  LArcoI1.Peso        := 1;
  LArcoI1.PesoEvaluar := 1;

  LPlazaO1                := TdpnPlaza.Create;
  LPlazaO1.NombreReducido := 'O1';
  LPlazaO1.Capacidad      := ANoEventos + 10;

  LArcoO1       := TdpnArcoOut.Create;
  LArcoO1.Plaza := LPlazaO1;
  LArcoO1.Peso  := 1;

  LTransicion1 := TdpnTransicion.Create;
  LTransicion1.AddArcoIn(LArcoI1);
  LTransicion1.AddArcoOut(LArcoO1);
  LTransicion1.AddCondicion(LFuncionE1);

  LModelo.Elementos.Add(LTransicion1);
  LModelo.Elementos.Add(LPlazaS1);
  LModelo.Elementos.Add(LArcoIS1);
  LModelo.Elementos.Add(LArcoOS1);
  LModelo.Elementos.Add(LTransicionS1);
  LModelo.Elementos.Add(LPlazaI1);
  LModelo.Elementos.Add(LArcoI1);
  LModelo.Elementos.Add(LPlazaO1);
  LModelo.Elementos.Add(LArcoO1);
  LModelo.Elementos.Add(LFuncionE1);

  //Bloque 2
  LPlazaS2                                    := TdpnPlazaStart.Create;
  LPlazaS2.NombreReducido                     := 'S2';
  TdpnPlazaStart(LPlazaS2).GeneracionContinua := True;

  LArcoIS2             := TdpnArcoIn.Create;
  LArcoIS2.Plaza       := LPlazaS2;
  LArcoIS2.Peso        := 1;
  LArcoIS2.PesoEvaluar := 1;

  LArcoOS2       := TdpnArcoOut.Create;
  LArcoOS2.Peso  := 1;

  LTransicionS2 := TdpnTransicion.Create;
  LTransicionS2.AddArcoIn(LArcoIS2);
  LTransicionS2.AddArcoOut(LArcoOS2);

  LPlazaI2                := TdpnPlaza.Create;
  LPlazaI2.NombreReducido := 'I2';
  LPlazaI2.Capacidad      := ANoEventos;

  LArcoOS2.Plaza := LPlazaI2;

  LArcoI2             := TdpnArcoIn.Create;
  LArcoI2.Plaza       := LPlazaI2;
  LArcoI2.Peso        := 1;
  LArcoI2.PesoEvaluar := 1;

  LPlazaO2                := TdpnPlaza.Create;
  LPlazaO2.NombreReducido := 'O2';
  LPlazaO2.Capacidad      := ANoEventos + 10;

  LArcoO2       := TdpnArcoOut.Create;
  LArcoO2.Plaza := LPlazaO2;
  LArcoO2.Peso  := 1;

  LTransicion2 := TdpnTransicion.Create;
  LTransicion2.AddArcoIn(LArcoI2);
  LTransicion2.AddArcoOut(LArcoO2);
  LTransicion2.AddCondicion(LFuncionE2);

  LModelo.Elementos.Add(LTransicion2);
  LModelo.Elementos.Add(LPlazaS2);
  LModelo.Elementos.Add(LArcoIS2);
  LModelo.Elementos.Add(LArcoOS2);
  LModelo.Elementos.Add(LTransicionS2);
  LModelo.Elementos.Add(LPlazaI2);
  LModelo.Elementos.Add(LArcoI2);
  LModelo.Elementos.Add(LPlazaO2);
  LModelo.Elementos.Add(LArcoO2);
  LModelo.Elementos.Add(LFuncionE2);

  //Bloque 3
  LPlazaS3                                    := TdpnPlazaStart.Create;
  LPlazaS3.NombreReducido                     := 'S3';
  TdpnPlazaStart(LPlazaS3).GeneracionContinua := True;

  LArcoIS3             := TdpnArcoIn.Create;
  LArcoIS3.Plaza       := LPlazaS3;
  LArcoIS3.Peso        := 1;
  LArcoIS3.PesoEvaluar := 1;

  LArcoOS3       := TdpnArcoOut.Create;
  LArcoOS3.Peso  := 1;

  LTransicionS3 := TdpnTransicion.Create;
  LTransicionS3.AddArcoIn(LArcoIS3);
  LTransicionS3.AddArcoOut(LArcoOS3);

  LPlazaI3                := TdpnPlaza.Create;
  LPlazaI3.NombreReducido := 'I3';
  LPlazaI3.Capacidad      := ANoEventos;

  LArcoOS3.Plaza := LPlazaI3;

  LArcoI3             := TdpnArcoIn.Create;
  LArcoI3.Plaza       := LPlazaI3;
  LArcoI3.Peso        := 1;
  LArcoI3.PesoEvaluar := 1;

  LPlazaO3                := TdpnPlaza.Create;
  LPlazaO3.NombreReducido := 'O3';
  LPlazaO3.Capacidad      := ANoEventos + 10;

  LArcoO3       := TdpnArcoOut.Create;
  LArcoO3.Plaza := LPlazaO3;
  LArcoO3.Peso  := 1;

  LTransicion3 := TdpnTransicion.Create;
  LTransicion3.AddArcoIn(LArcoI3);
  LTransicion3.AddArcoOut(LArcoO3);
  LTransicion3.AddCondicion(LFuncionE3);

  LModelo.Elementos.Add(LTransicion3);
  LModelo.Elementos.Add(LPlazaS3);
  LModelo.Elementos.Add(LArcoIS3);
  LModelo.Elementos.Add(LArcoOS3);
  LModelo.Elementos.Add(LTransicionS3);
  LModelo.Elementos.Add(LPlazaI3);
  LModelo.Elementos.Add(LArcoI3);
  LModelo.Elementos.Add(LPlazaO3);
  LModelo.Elementos.Add(LArcoO3);
  LModelo.Elementos.Add(LFuncionE3);

  LPNet := TdpnPetriNetCoordinador.Create;
  try
    LPNet.MultipleEnablednessOfTransitions := ADisparosConcurrentes;
    LPNet.Grafo := LModelo;
    LPNet.Start;

    WriteLn(FormatDateTime('hh:nn:ss.zzz ', Now) + '<TPetriNetCoreTesting_Rendimiento.Test_Con_N_Disparos_Concurrentes> START');

    for I := 1 to ANoEventos do
    begin
      LEvento                       := TEventoPrueba.Create;
      TEventoPrueba(LEvento).Indice := I;
      TEventoPrueba(LEvento).Numero := 5;
      TEventoPrueba(LEvento).Texto  := 'Hola';
      LEvento.Post;
    end;

    while not((LPlazaO1.TokenCount = ANoEventos) and (LPlazaO2.TokenCount = ANoEventos) and (LPlazaO3.TokenCount = ANoEventos)) do //
      Sleep(1);
    WriteLn(FormatDateTime('hh:nn:ss.zzz ', Now) + '<TPetriNetCoreTesting_Rendimiento.Test_Con_N_Disparos_Concurrentes> STOP');

    Writeln('I1: ' + LPlazaI1.TokenCount.ToString + ' - O1: ' + LPlazaO1.TokenCount.ToString);
    Writeln('I2: ' + LPlazaI2.TokenCount.ToString + ' - O2: ' + LPlazaO2.TokenCount.ToString);
    Writeln('I3: ' + LPlazaI3.TokenCount.ToString + ' - O3: ' + LPlazaO3.TokenCount.ToString);
    Writeln('Datos1: ' + LTransicion1.TransicionesRealizadas.ToString + '/' + LTransicion1.TransicionesIntentadas.ToString);
    Writeln('Datos2: ' + LTransicion2.TransicionesRealizadas.ToString + '/' + LTransicion2.TransicionesIntentadas.ToString);
    Writeln('Datos3: ' + LTransicion3.TransicionesRealizadas.ToString + '/' + LTransicion3.TransicionesIntentadas.ToString);

    WriteLn('PN: ' + LPNet.LogMarcado);

    if not((LPlazaO1.TokenCount = ANoEventos) and (LPlazaO2.TokenCount = ANoEventos) and (LPlazaO3.TokenCount = ANoEventos)) then
      Assert.Fail('no ha ido bien');

    Assert.Pass;
  finally
    LFuncionE1   := nil;
    LFuncionE2   := nil;
    LModelo     := nil;
    LPlazaI1    := nil;
    LArcoI1     := nil;
    LPlazaO1    := nil;
    LArcoO1     := nil;
    LTransicion1 := nil;
    LPNet.Destroy;
  end;
end;

{ TThreadTestModificaPlaza }

constructor TThreadTestRendimiento.Create(const APlaza: IPlaza);
begin
  inherited Create(True);
  FPlaza := APlaza;
end;

procedure TThreadTestRendimiento.Execute;
var
  I, J : integer;
  LToken: IToken;
begin
  for i := 1 to 100 do
  begin
    for J := 1 to Random(10) do
    begin
      LToken := TdpnTokenColoreado.Create;
      FPlaza.AddToken(LToken);
    end;
    FPlaza.EliminarTodosTokens;
  end;
end;

initialization
//{$IFDEF TESTS_HABILITADOS}
TDUnitX.RegisterTestFixture(TPetriNetCoreTesting_Rendimiento);
//{$ENDIF}
end.

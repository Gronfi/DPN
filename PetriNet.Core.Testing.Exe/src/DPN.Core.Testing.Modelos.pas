{$I Defines.inc}
unit DPN.Core.Testing.Modelos;

interface

uses
  System.Rtti,
  Spring.Collections,

  DUnitX.TestFramework,

  DPN.Interfaces,
  DPN.Plaza,
  DPN.Modelo,
  DPN.Plaza.Start,
  DPN.Plaza.Finish,
  DPN.ArcoIn,
  DPN.ArcoReset,
  DPN.Condicion,
  DPN.ArcoOut,
  DPN.Transicion,
  DPN.PetriNet,
  DPN.Variable;

type
{$IFDEF TESTS_HABILITADOS}
  [TestFixture]
{$ENDIF}
  TPetriNetCoreTesting_Modelos = class
  private
  protected
  public
    [Test]
    procedure Test_Serializable;
    [Test]
    procedure Test_Submodelo_Simple;
    [Test]
    procedure Test_Submodelo_IN_OUT;
  end;

implementation

uses
  System.JSON,
  System.SysUtils,

  DPN.Core,
  DPN.TokenColoreado;

{ TPetriNetCoreTesting_Modelos }

procedure TPetriNetCoreTesting_Modelos.Test_Serializable;
var
  LModelo: IModelo;
  LModelo2: IModelo;
  LPlazaI1: IPlaza;
  LPlazaO1: IPlaza;
  LArcoI1 : IArcoIn;
  LArcoO1 : IArcoOut;
  LTransicion1: ITransicion;
  LTmp: string;
  LJSon: TJSOnObject;
begin
  LModelo := TdpnModelo.Create;
  LModelo.NombreReducido := 'Modelo test';

  LPlazaI1           := TdpnPlaza.Create;
  LPlazaI1.NombreReducido    := 'I1';
  LPlazaI1.Capacidad := 1;

  LArcoI1             := TdpnArcoIn.Create;
  LArcoI1.Plaza       := LPlazaI1;
  LArcoI1.Peso        := 1;
  LArcoI1.PesoEvaluar := 1;

  LArcoO1             := TdpnArcoOut.Create;
  LArcoO1.Peso        := 1;

  LPlazaO1           := TdpnPlazaFinish.Create;
  LPlazaO1.NombreReducido    := 'O1';
  LArcoO1.Plaza      := LPlazaO1;

  LTransicion1 := TdpnTransicion.Create;
  LTransicion1.AddArcoIn(LArcoI1);
  LTransicion1.AddArcoOut(LArcoO1);

  LModelo.AddElementoNodo(LPlazaI1);
  LModelo.AddElementoNodo(LArcoI1);
  LModelo.AddElementoNodo(LArcoO1);
  LModelo.AddElementoNodo(LPlazaO1);
  LModelo.AddElementoNodo(LTransicion1);

  LJSon := LModelo.FormatoJSON;
  LTmp := LJSON.ToString;
  WriteLn('Json: ' + LTmp);
  LModelo2 := DPNCore.CrearInstancia<IModelo>(LJSon);
  LModelo2.CargarDeJSON(LJSon);
  WriteLn(LModelo2.LogAsString);
  WriteLn(LModelo2.FormatoJSON.ToJSON);
end;

procedure TPetriNetCoreTesting_Modelos.Test_Submodelo_IN_OUT;
var
  LPNet: TdpnPetriNetCoordinador;

  LModelo: IModelo;
  LSubModelo: IModelo;
  LToken : IToken;
  I      : Integer;

  LArcoI1 : IArcoIn;
  LArcoO1 : IArcoOut;
  LPlazaI1: IPlaza;
  LPlazaO1: IPlaza;

  LArcoI2 : IArcoIn;
  LArcoO2 : IArcoOut;

  LTransicion1: ITransicion;
  LTransicionF: ITransicion;

  LArcoISub : IArcoIn;
  LPlazaISub: IPlaza;

  LArcoOSub : IArcoOut;
  LPlazaOSub: IPlaza;

  LTransicionSub: ITransicion;
begin
// (LPlazaI1) --> LArcoI1 -->|LTransicion1| --> LArcoO1 -->
//           (( (LPlazaISub) --> LArcoISub  -->|LTransicionSub| --> LArcoOSub --> (LPlazaOSub)     ))
// --> LArcoI2 --> |LTransicionF| --> LArcoO2 --> (LPlazaO1)
//---------Submodelo----------------------------------------
  LSubModelo := TdpnModelo.Create;

  LPlazaISub           := TdpnPlaza.Create;
  LPlazaISub.NombreReducido    := 'I2';
  LPlazaISub.Capacidad := 1;

  LArcoISub             := TdpnArcoIn.Create;
  LArcoISub.Plaza       := LPlazaISub;
  LArcoISub.Peso        := 1;
  LArcoISub.PesoEvaluar := 1;

  LPlazaOSub           := TdpnPlaza.Create;
  LPlazaOSub.NombreReducido    := 'O2';
  LPlazaOSub.Capacidad := 1;

  LArcoOSub       := TdpnArcoOut.Create;
  LArcoOSub.Plaza := LPlazaOSub;
  LArcoOSub.Peso  := 1;

  LTransicionSub := TdpnTransicion.Create;
  LTransicionSub.AddArcoIn(LArcoISub);
  LTransicionSub.AddArcoOut(LArcoOSub);

  LSubModelo.Elementos.Add(LTransicionSub);
  LSubModelo.Elementos.Add(LPlazaISub);
  LSubModelo.Elementos.Add(LArcoISub);
  LSubModelo.Elementos.Add(LPlazaOSub);
  LSubModelo.Elementos.Add(LArcoOSub);

  //establecimiento estado IN y OUT
  LSubModelo.PlazaIn  := LPlazaISub;
  LSubModelo.PlazaOut := LPlazaOSub;

  //---------Submodelo----------------------------------------
  LModelo := TdpnModelo.Create;
  LModelo.Elementos.Add(LSubModelo);

  LPlazaI1           := TdpnPlaza.Create;
  LPlazaI1.NombreReducido    := 'I1';
  LPlazaI1.Capacidad := 1;

  LArcoI1             := TdpnArcoIn.Create;
  LArcoI1.Plaza       := LPlazaI1;
  LArcoI1.Peso        := 1;
  LArcoI1.PesoEvaluar := 1;

  LArcoO1             := TdpnArcoOut.Create;
  LArcoO1.Peso        := 1;

  LPlazaO1           := TdpnPlazaFinish.Create;
  LPlazaO1.NombreReducido    := 'O1';

  LArcoO2             := TdpnArcoOut.Create;
  LArcoO2.Plaza       := LPlazaO1;
  LArcoO2.Peso        := 1;

  LArcoO1       := TdpnArcoOut.Create;
  LArcoO1.Peso  := 1;

  LArcoI2             := TdpnArcoIn.Create;
  LArcoI2.Peso        := 1;
  LArcoI2.PesoEvaluar := 1;

  LTransicion1 := TdpnTransicion.Create;
  LTransicion1.AddArcoIn(LArcoI1);
  LTransicion1.AddArcoOut(LArcoO1);

  LTransicionF := TdpnTransicion.Create;
  LTransicionF.AddArcoIn(LArcoI2);
  LTransicionF.AddArcoOut(LArcoO2);

  LModelo.Elementos.Add(LPlazaISub);
  LModelo.Elementos.Add(LArcoISub);
  LModelo.Elementos.Add(LPlazaOSub);
  LModelo.Elementos.Add(LArcoOSub);
  LModelo.Elementos.Add(LTransicionSub);

  //linkage entre elementos de modelos
  LSubModelo.AddArcoEntrada(LArcoO1);
  LSubModelo.AddArcoSalida(LArcoI2);

  LPNet := TdpnPetriNetCoordinador.Create;
  try
    LPNet.Grafo := LModelo;
    LPNet.Start;

    for I := 1 to 1 do
    begin
      LToken := TdpnTokenColoreado.Create;
      LPlazaI1.AddToken(LToken);
    end;

    Sleep(100);

    Writeln('I1: ' + LPlazaI1.TokenCount.ToString + ' - O1: ' + LPlazaO1.TokenCount.ToString);
    if not((LPlazaI1.TokenCount = 0) and (LPlazaO1.TokenCount = 0)) then
      Assert.Fail('no ha transicionado');

    Assert.Pass;
  finally
    LPNet.Destroy;
  end;
end;

procedure TPetriNetCoreTesting_Modelos.Test_Submodelo_Simple;
var
  LPNet: TdpnPetriNetCoordinador;

  LModelo: IModelo;
  LSubModelo: IModelo;
  LToken : IToken;
  I      : Integer;

  LArcoI1 : IArcoIn;
  LPlazaI1: IPlaza;

  LArcoO1 : IArcoOut;
  LPlazaO1: IPlaza;

  LTransicion: ITransicion;
begin
  LModelo := TdpnModelo.Create;
  LSubModelo := TdpnModelo.Create;

  LPlazaI1           := TdpnPlaza.Create;
  LPlazaI1.NombreReducido    := 'I1';
  LPlazaI1.Capacidad := 1;

  LArcoI1             := TdpnArcoIn.Create;
  LArcoI1.Plaza       := LPlazaI1;
  LArcoI1.Peso        := 1;
  LArcoI1.PesoEvaluar := 1;

  LPlazaO1           := TdpnPlazaFinish.Create;
  LPlazaO1.NombreReducido    := 'O1';
  LPlazaO1.Capacidad := 1;

  LArcoO1       := TdpnArcoOut.Create;
  LArcoO1.Plaza := LPlazaO1;
  LArcoO1.Peso  := 1;

  LTransicion := TdpnTransicion.Create;
  LTransicion.AddArcoIn(LArcoI1);
  LTransicion.AddArcoOut(LArcoO1);

  LModelo.Elementos.Add(LSubModelo);
  LSubModelo.Elementos.Add(LTransicion);
  LSubModelo.Elementos.Add(LPlazaI1);
  LSubModelo.Elementos.Add(LArcoI1);
  LSubModelo.Elementos.Add(LPlazaO1);
  LSubModelo.Elementos.Add(LArcoO1);

  LPNet := TdpnPetriNetCoordinador.Create;
  try
    LPNet.Grafo := LModelo;
    LPNet.Start;

    for I := 1 to 1 do
    begin
      LToken := TdpnTokenColoreado.Create;
      LPlazaI1.AddToken(LToken);
    end;

    Sleep(100);

    Writeln('I1: ' + LPlazaI1.TokenCount.ToString + ' - O1: ' + LPlazaO1.TokenCount.ToString);
    Writeln('Datos: ' + LTransicion.TransicionesRealizadas.ToString + '/' + LTransicion.TransicionesIntentadas.ToString);
    if not((LPlazaI1.TokenCount = 0) and (LPlazaO1.TokenCount = 0)) then
      Assert.Fail('no ha transicionado');

    Assert.Pass;
  finally
    LModelo     := nil;
    LPlazaI1    := nil;
    LArcoI1     := nil;
    LPlazaO1    := nil;
    LArcoO1     := nil;
    LTransicion := nil;

    LPNet.Destroy;
  end;
end;

initialization
{$IFDEF TESTS_HABILITADOS}
  TDUnitX.RegisterTestFixture(TPetriNetCoreTesting_Modelos);
{$ENDIF}
end.

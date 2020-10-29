program PetriNetCoreTesting;

{$UNDEF TESTINSIGHT}
{$UNDEF CI}

{$IFNDEF TESTINSIGHT}
{$APPTYPE CONSOLE}
{$ENDIF}
{$STRONGLINKTYPES ON}
uses
  System.SysUtils,
  {$IFDEF TESTINSIGHT}
  TestInsight.DUnitX,
  {$ELSE}
  DUnitX.Loggers.Console,
  {$ENDIF }
  DUnitX.TestFramework,
  DPN.Core.Testing.Variables in 'src\DPN.Core.Testing.Variables.pas',
  DPN.Core.Testing.Funciones in 'src\DPN.Core.Testing.Funciones.pas',
  DPN.Core.Testing.ArcoIn in 'src\DPN.Core.Testing.ArcoIn.pas',
  DPN.Core.Testing.ArcoOut in 'src\DPN.Core.Testing.ArcoOut.pas',
  DPN.Accion in '..\PetriNet.Core\src\DPN.Accion.pas',
  DPN.Arco in '..\PetriNet.Core\src\DPN.Arco.pas',
  DPN.ArcoIn in '..\PetriNet.Core\src\DPN.ArcoIn.pas',
  DPN.ArcoOut in '..\PetriNet.Core\src\DPN.ArcoOut.pas',
  DPN.ArcoReset in '..\PetriNet.Core\src\DPN.ArcoReset.pas',
  DPN.Bloqueable in '..\PetriNet.Core\src\DPN.Bloqueable.pas',
  DPN.Condicion in '..\PetriNet.Core\src\DPN.Condicion.pas',
  DPN.Core in '..\PetriNet.Core\src\DPN.Core.pas',
  DPN.Etiqueta in '..\PetriNet.Core\src\DPN.Etiqueta.pas',
  DPN.Interfaces in '..\PetriNet.Core\src\DPN.Interfaces.pas',
  DPN.MarcadoTokens in '..\PetriNet.Core\src\DPN.MarcadoTokens.pas',
  DPN.Modelo in '..\PetriNet.Core\src\DPN.Modelo.pas',
  DPN.NodoPetriNet in '..\PetriNet.Core\src\DPN.NodoPetriNet.pas',
  DPN.PetriNet in '..\PetriNet.Core\src\DPN.PetriNet.pas',
  DPN.Plaza in '..\PetriNet.Core\src\DPN.Plaza.pas',
  DPN.Token in '..\PetriNet.Core\src\DPN.Token.pas',
  DPN.TokenColoreado in '..\PetriNet.Core\src\DPN.TokenColoreado.pas',
  DPN.TokenSistema in '..\PetriNet.Core\src\DPN.TokenSistema.pas',
  DPN.Transicion in '..\PetriNet.Core\src\DPN.Transicion.pas',
  DPN.Transicion.TokenByToken in '..\PetriNet.Core\src\DPN.Transicion.TokenByToken.pas',
  DPN.Variable in '..\PetriNet.Core\src\DPN.Variable.pas',
  DPN.Core.Testing.Transicion in 'src\DPN.Core.Testing.Transicion.pas',
  DPN.Helpers in '..\PetriNet.Core\src\DPN.Helpers.pas',
  DPN.Core.Testing.PetriNetCoordinador in 'src\DPN.Core.Testing.PetriNetCoordinador.pas';

var
  runner: ITestRunner;
  results: IRunResults;
  logger: ITestLogger;
  nunitLogger : ITestLogger;
begin
{$IFDEF TESTINSIGHT}
  TestInsight.DUnitX.RunRegisteredTests;
{$ELSE}
  try
    //Check command line options, will exit if invalid
    TDUnitX.CheckCommandLine;
    //Create the test runner
    runner := TDUnitX.CreateRunner;
    //Tell the runner to use RTTI to find Fixtures
    runner.UseRTTI := True;
    //When true, Assertions must be made during tests;
    runner.FailsOnNoAsserts := False;

    //tell the runner how we will log things
    //Log to the console window if desired
    if TDUnitX.Options.ConsoleMode <> TDunitXConsoleMode.Off then
    begin
      logger := TDUnitXConsoleLogger.Create(TDUnitX.Options.ConsoleMode = TDunitXConsoleMode.Quiet);
      runner.AddLogger(logger);
    end;
    //Generate an NUnit compatible XML File
    //nunitLogger := TDUnitXXMLNUnitFileLogger.Create(TDUnitX.Options.XMLOutputFile);
    //runner.AddLogger(nunitLogger);

    //Run tests
    results := runner.Execute;
    if not results.AllPassed then
      System.ExitCode := EXIT_ERRORS;

    {$IFNDEF CI}
    //We don't want this happening when running under CI.
    if TDUnitX.Options.ExitBehavior = TDUnitXExitBehavior.Pause then
    begin
      System.Write('Done.. press <Enter> key to quit.');
      System.Readln;
    end;
    {$ENDIF}
  except
    on E: Exception do
      System.Writeln(E.ClassName, ': ', E.Message);
  end;
{$ENDIF}
end.

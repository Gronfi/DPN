unit DPN.Transicion.TokenByToken;

interface

uses
  Event.Engine.Interfaces,

  DPN.Transicion,
  DPN.MarcadoTokens;

type
  TdpnTransicion_TokenByToken = class(TdpnTransicion)
  protected
    function EstrategiaDisparo(AEvento: IEventEE = nil): Boolean; override;
  end;

implementation

uses
  System.SysUtils,

  Spring.Collections,

  DPN.Core,
  DPN.Interfaces;


{ TdpnTransicion_TokenByToken }
function TdpnTransicion_TokenByToken.EstrategiaDisparo(AEvento: IEventEE = nil): Boolean;
var
  LTokens: IMarcadoTokens;
  LTokenSeleccionado: IMarcadoTokens;
  LTokenEvaluar: IMarcadoTokens;
  LToken: IToken;
  LPlaza: IPlaza;
  LTokensOut: IList<IToken>;
  LCondicion: ICondicion;
  LAccion: IAccion;
  LResult: Boolean;
  LArcoIn: IArcoIn;
  LArcoOut: IArcoOut;
begin
  Result  := False;
  // Pasos:
  // 1) obtenemos los jetones implicados por estado
  LTokens := ObtenerMarcadoTokens;
  // 2) recorremos cada token para ver si cumple con las condiciones
  LTokenSeleccionado := TdpnMarcadoTokens.Create;
  LTokenEvaluar := TdpnMarcadoTokens.Create;
  for LPlaza in LTokens.Marcado.Keys do
  begin
    LTokenSeleccionado.AddPlaza(LPlaza);
    LTokenEvaluar.Clear;
    for LToken in LTokens.Marcado[LPlaza] do
    begin
      LResult := True;
      LTokenEvaluar.AddTokenPlaza(LPlaza, LToken);
      for LCondicion in FCondiciones do
      begin
        try
          LResult := LCondicion.Evaluar(LTokenEvaluar, AEvento);
          if LCondicion.IsEvaluacionNoDependeDeTokensOEvento then
          begin
            ActualizarEstadoTransicionPorCondicionQueNoDependeDeTokens(LCondicion.ID, LResult);
          end;
          if not LResult then
            Break;
        except
          on E:Exception do
          begin
            //DAVE
            Exit;
          end;
        end;
      end;
      if LResult then
      begin
        LTokenSeleccionado.AddTokenPlaza(LPlaza, LToken);
        break;
      end;
    end;
  end;
  Result := True;
  // ejecucion de acciones
  for LAccion in FAcciones do
  begin
    try
      LAccion.Execute(LTokenSeleccionado, AEvento);
    except
      on E:Exception do
      begin
        //DAVE
      end;
    end;
  end;
  // movimiento de tokens
  // ejecucion de arcos in
  for LArcoIn in FArcosIn do
  begin
    LArcoIn.DoOnTransicionando(LTokenSeleccionado.Marcado[LArcoIn.Plaza]);
  end;
  // ejecucion de arcos out
  for LArcoOut in FArcosOut do
  begin
    case LArcoOut.GenerarTokensDeSistema of
      True:
        begin
          LTokensOut := DPNCore.GenerarNTokensSistema(LArcoOut.Peso);
        end;
      False:
        begin
          LTokensOut := DPNCore.GenerarTokensAdecuados(LTokens, LArcoOut.Peso);
        end;
    end;
    LArcoOut.DoOnTransicionando(LTokensOut);
  end;
end;

end.

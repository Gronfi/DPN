unit DPN.Accion;

interface

uses
  System.JSON,

  Spring,
  Spring.Collections,

  Event.Engine.Interfaces,
  DPN.Interfaces,
  DPN.NodoPetriNet;

type
  TdpnAccion = class abstract(TdpnNodoPetriNet, IAccion)
  protected
    FTransicion: ITransicion;
    FNombreTransicion: string;

    function GetDependencias: IList<IBloqueable>; virtual; abstract;

    function GetTransicion: ITransicion; virtual;
    procedure SetTransicion(const Value: ITransicion); virtual;
  public
    constructor Create; override;

    Procedure CargarDeJSON(NodoJson_IN: TJSONObject); override;
    Procedure FormatoJSON(NodoJson_IN: TJSONObject); overload; override;

    procedure Setup; override;
    function CheckIsOK(out AListaErrores: IList<string>): boolean; override;

    procedure Execute(ATokens: IMarcadoTokens; AEvento: IEvento = nil); virtual;

    property Dependencias: IList<IBloqueable> read GetDependencias;
    property Transicion: ITransicion read GetTransicion write SetTransicion;
  end;

implementation

uses
  System.SysUtils,

  DPN.Core;

{ TdpnAccion }

procedure TdpnAccion.CargarDeJSON(NodoJson_IN: TJSONObject);
begin
  inherited;
  DPNCore.CargarCampoDeNodo<string>(NodoJson_IN, 'NombreTransicion', ClassName, FNombreTransicion);
end;

function TdpnAccion.CheckIsOK(out AListaErrores: IList<string>): boolean;
begin
  Result := inherited;
  if not Assigned(Transicion) then
  begin
    Result := False;
    AListaErrores.Add('Transicion = nil');
  end;
end;

constructor TdpnAccion.Create;
begin
  inherited;
end;

procedure TdpnAccion.Execute(ATokens: IMarcadoTokens; AEvento: IEvento = nil);
begin
  ;
end;procedure TdpnAccion.FormatoJSON(NodoJson_IN: TJSONObject);
begin
  inherited;
  NodoJson_IN.AddPair('NombreTransicion', TJSONString.Create(Transicion.Nombre));
end;

function TdpnAccion.GetTransicion: ITransicion;
begin
  Result := FTransicion
end;

procedure TdpnAccion.SetTransicion(const Value: ITransicion);
begin
  FTransicion := Value;
end;

procedure TdpnAccion.Setup;
var
  LTransicion: ITransicion;
begin
  inherited;
  if not FNombreTransicion.IsEmpty then
  begin
    LTransicion := PetriNetController.GetTransicion(FNombreTransicion);
    if Assigned(LTransicion) then
      Transicion := LTransicion;
  end;
end;

end.

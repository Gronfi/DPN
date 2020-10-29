unit DPN.Etiqueta;

interface

uses
  Spring,
  Spring.Collections,

  DPN.Interfaces,
  DPN.NodoPetriNet;

type
  TdpnEtiqueta = class abstract(TdpnNodoPetriNet, IEtiqueta)
  protected
    FTexto: string;

    function GetTexto: string;
    procedure SetTexto(const Value: string);
  public
    constructor Create; override;

    procedure Execute; virtual;

    property Texto: string read GetTexto write SetTexto;
  end;

implementation

{ TdpnAccion }

constructor TdpnEtiqueta.Create;
begin
  inherited;
end;

procedure TdpnEtiqueta.Execute;
begin
  ;
end;function TdpnEtiqueta.GetTexto: string;
begin
  Result := FTexto
end;

procedure TdpnEtiqueta.SetTexto(const Value: string);
begin
  FTexto := Value;
end;

end.

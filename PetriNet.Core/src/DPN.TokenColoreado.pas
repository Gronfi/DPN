unit DPN.TokenColoreado;

interface

uses
  DPN.Interfaces,
  DPN.Token;

type
  TdpnTokenColoreado = class(TdpnToken, ITokenColoreado)
  protected

  public
    function Clon: IToken;
  end;

implementation

{ TdpnTokenColoreado }

function TdpnTokenColoreado.Clon: IToken;
begin
  //
end;

end.

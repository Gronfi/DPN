unit DPN.TokenSistema;

interface

uses
  DPN.Interfaces,
  DPN.Token;

type
  TdpnTokenSistema = class(TdpnToken, ITokenSistema)
  protected

  public
    function Clon: IToken;
  end;

implementation

{ TdpnTokenSistema }

function TdpnTokenSistema.Clon: IToken;
begin
  //
end;

end.

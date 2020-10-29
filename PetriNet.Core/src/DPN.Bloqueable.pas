unit DPN.Bloqueable;

interface

uses
  System.SyncObjs,

  DPN.NodoPetriNet,
  DPN.Interfaces;

type
  TdpnBloqueable = class(TdpnNodoPetriNet, IBloqueable)
  protected
    FLocker: TSpinLock;
  public
    procedure AdquireLock;
    procedure ReleaseLock;
  end;

implementation

{ TdpnBloqueable }

procedure TdpnBloqueable.AdquireLock;
begin
  FLocker.Enter;
end;

procedure TdpnBloqueable.ReleaseLock;
begin
  FLocker.Exit;
end;

end.

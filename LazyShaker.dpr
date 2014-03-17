program LazyShaker;

uses
  System.StartUpCopy,
  FMX.MobilePreview,
  FMX.Forms,
  LazyShakerForm in 'LazyShakerForm.pas' {frmLazyShaker};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmLazyShaker, frmLazyShaker);
  Application.Run;
end.

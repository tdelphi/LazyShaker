unit LazyShakerForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  System.Sensors,
  {$IFDEF VER270}
  System.Sensors.Components,
  {$ELSE}
  FMX.Sensors,
  {$ENDIF}
  FMX.Layouts, FMX.Memo, FMX.Media,
  FMX.StdCtrls, System.Actions, FMX.ActnList, FMX.StdActns, FMX.Objects;

type
  TLazyShakeSensor = class
  strict private
  type
    TSensorData = double;
  var
    FMotionSensor: TMotionSensor;
    FTimer: TTimer;
    FOnShake: TNotifyEvent;
    // acceleration apart from gravity
    FAccel: TLazyShakeSensor.TSensorData;
    // current acceleration including gravity
    FAccelCurrent: TLazyShakeSensor.TSensorData;
    // last acceleration including gravity
    FAccelLast: TLazyShakeSensor.TSensorData;

    procedure DoOnSensorDataChanged(Sender: TObject);
    procedure DoTriggerShakeEvent;
  public

    procedure InitSensors;
    procedure DeInitSensors;
    constructor Create;
    destructor Destroy; override;

    property OnShake: TNotifyEvent read FOnShake write FOnShake;
  end;

  TfrmLazyShaker = class(TForm)
    MediaPlayer1: TMediaPlayer;
    ActionList1: TActionList;
    FileExit1: TFileExit;
    Button1: TButton;
    Image1: TImage;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  strict private
    FShakeSensor: TLazyShakeSensor;

    procedure PlaySound(const aFile: string);
    procedure PlayDefaultSound;

    procedure DoOnShake(Sender: TObject);
  end;

var
  frmLazyShaker: TfrmLazyShaker;

implementation

uses
  IoUtils;

{$R *.fmx}

procedure TfrmLazyShaker.DoOnShake(Sender: TObject);
begin
  PlayDefaultSound;
end;

procedure TfrmLazyShaker.FormCreate(Sender: TObject);
begin
  FShakeSensor:= TLazyShakeSensor.Create;
  FShakeSensor.OnShake := DoOnShake;
  FShakeSensor.InitSensors;
end;

procedure TfrmLazyShaker.FormDestroy(Sender: TObject);
begin
  try
    FShakeSensor.DeInitSensors;
  except
    // act bad - eat exception
  end;
  FreeAndNil(FShakeSensor);
end;

procedure TfrmLazyShaker.PlayDefaultSound;
var
  s: string;
begin
  s := TPath.GetDocumentsPath;
  s := TPath.Combine(s, 'ElevatorBell.mp3');
  PlaySound(s);
end;

procedure TfrmLazyShaker.PlaySound(const aFile: string);
begin
  if FileExists(aFile) then
  begin
    MediaPlayer1.Stop;
    MediaPlayer1.Clear;
    MediaPlayer1.Volume := 100;
    MediaPlayer1.FileName := aFile;
    MediaPlayer1.CurrentTime := 0;
    MediaPlayer1.Play;
  end;
end;

{ TLazyShakeSensor }

constructor TLazyShakeSensor.Create;
begin
  FAccel:=0;
  FAccelCurrent:=0.9;
  FAccelLast:=0.9;
end;

procedure TLazyShakeSensor.DeInitSensors;
begin
  FTimer.Enabled := False;
  FreeAndNil(FTimer);
  FreeAndNil(FMotionSensor);
end;

destructor TLazyShakeSensor.Destroy;
begin

  inherited;
end;

procedure TLazyShakeSensor.DoOnSensorDataChanged(Sender: TObject);
var
  tmpSensor: TCustomMotionSensor;
  x,y,z: TSensorData;
begin
  if FMotionSensor.Sensor<>nil then
  begin
    tmpSensor := FMotionSensor.Sensor;
    x := tmpSensor.AccelerationX;
    y := tmpSensor.AccelerationY;
    z := tmpSensor.AccelerationZ;
    FAccelLast := FAccelCurrent;
    FAccelCurrent := Sqrt(x*x+y*y+z*z);
    FAccel := FAccel*0.9+(FAccelCurrent-FAccelLast);

    if FAccel >1.3 then
      DoTriggerShakeEvent;
  end;
end;

procedure TLazyShakeSensor.DoTriggerShakeEvent;
begin
  if Assigned(FOnShake) then
    FOnShake(Self);
end;

procedure TLazyShakeSensor.InitSensors;
begin
  FMotionSensor := TMotionSensor.Create(nil);
  FMotionSensor.Active := True;
  FTimer := TTimer.Create(nil);
  FTimer.OnTimer := DoOnSensorDataChanged;
  FTimer.Interval := 50;
  FTimer.Enabled := True;
end;

end.

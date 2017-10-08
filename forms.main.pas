{

}
unit Forms.Main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls.Slider
  , player
  ;

type

  { TBackground }

  TBackground = class(TForm)
    Slider1 : TSlider;
    Slider2 : TSlider;
    procedure MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure SliderResponse(Sender :TObject);
    procedure SliderConsequence(Sender : TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

  private
    ConsequenceSound : TWavPlayer;
    ResponseSound : TWavPlayer;
    FStartTime : Cardinal;
    procedure WriteRow(AEvent : string);
  public

  end;

var
  Background: TBackground;

implementation

{$R *.lfm}

uses TabDelimitedReport, Timestamps;

const
  ScheduleLeft1 = 'VI 10000 8000';
  ScheduleLeft2 = 'FI 5000';

  ScheduleRight1 = 'VI 5000 4000';
  ScheduleRight2 = 'FI 5000';

{ TBackground }

procedure TBackground.SliderResponse(Sender: TObject);
begin
  ResponseSound.Play;
  if Sender is TComponent then
    WriteRow(TComponent(Sender).Name+'.Response');
end;

procedure TBackground.MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if Sender is TComponent then
    WriteRow(TComponent(Sender).Name+'.MouseMove');
end;

procedure TBackground.MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Sender is TComponent then
    WriteRow(TComponent(Sender).Name+'.MouseUp');
end;

procedure TBackground.MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Sender is TComponent then
    WriteRow(TComponent(Sender).Name+'.MouseDown');
end;

procedure TBackground.SliderConsequence(Sender: TObject);
var
  Slider : TSlider;
begin
  ConsequenceSound.Play;
  Slider := TSlider(Sender);
  WriteRow(Slider.Name+'.Consequence');
  if Slider = Slider1 then
  begin
    if Slider2.Panel.Visible then
    begin
      Slider1.Schedule.Load(ScheduleLeft2);
      Slider1.Panel.Color:=clNavy
    end else
    begin
      Slider1.Schedule.Load(ScheduleLeft1);
      Slider1.Panel.Color:=clGreen;
    end;
    Slider2.Panel.Visible := not Slider2.Panel.Visible;
  end;

  if Slider = Slider2 then
  begin
    if Slider1.Panel.Visible then
    begin
      Slider2.Schedule.Load(ScheduleRight2);
      Slider2.Panel.Color:=clNavy
    end else
    begin
      Slider2.Schedule.Load(ScheduleRight1);
      Slider2.Panel.Color:=clMaroon;
    end;
    Slider1.Panel.Visible := not Slider1.Panel.Visible;
  end;
  WriteRow(Slider.Name+'.ChangedTo.'+Slider.Schedule.AsString);
  Slider1.Schedule.Start;
  Slider2.Schedule.Start;
  Invalidate;
  Slider1.Panel.Invalidate;
  Slider2.Panel.Invalidate;
  Slider1.Invalidate;
  Slider2.Invalidate;
end;

procedure TBackground.FormCreate(Sender: TObject);
var
  CentralGap : integer = 400;
begin
  ShowMessage('A sessão vai começar.');
  InitializeAudio;
  ConsequenceSound := TWavPlayer.Create;
  ConsequenceSound.LoadFromResource('CSQ1');
  ResponseSound := TWavPlayer.Create;
  ResponseSound.LoadFromResource('CSQ2');

  Slider1 := TSlider.Create(Self);
  Slider1.Name:='LeftSlider';
  Slider1.Panel.Name:='LeftPanel';
  Slider1.Panel.Caption:='';
  Slider1.OnConsequence:=@SliderConsequence;
  Slider1.OnResponse:=@SliderResponse;
  Slider1.OnMouseDown:=@MouseDown;
  Slider1.OnMouseUp:=@MouseUp;
  Slider1.OnMouseMove:=@MouseMove;
  Slider1.Panel.OnMouseDown:=@MouseDown;
  Slider1.Panel.OnMouseUp:=@MouseUp;
  Slider1.Panel.OnMouseMove:=@MouseMove;
  Slider1.Panel.Parent:= Self;
  Slider1.Panel.Color := clGreen;
  Slider1.Schedule.Load(ScheduleLeft1);

  Slider2 := TSlider.Create(Self);
  Slider2.Name:='RightSlider';
  Slider2.Panel.Name:='RighPanel';
  Slider2.Panel.Caption:='';
  Slider2.OnConsequence:=@SliderConsequence;
  Slider2.OnResponse:=@SliderResponse;
  Slider2.OnMouseDown:=@MouseDown;
  Slider2.OnMouseUp:=@MouseUp;
  Slider2.OnMouseMove:=@MouseMove;
  Slider2.Panel.OnMouseDown:=@MouseDown;
  Slider2.Panel.OnMouseUp:=@MouseUp;
  Slider2.Panel.OnMouseMove:=@MouseMove;
  Slider2.Panel.Parent:= Self;
  Slider2.Panel.Color := clMaroon;
  Slider2.Schedule.Load(ScheduleRight1);


  with Slider1.Panel do
  begin
    Left := (Screen.Width div 2)-(Width div 2)-CentralGap;
    Top  := (Screen.Height div 2)-(Height div 2);
  end;
  with Slider2.Panel do
  begin
    Left := (Screen.Width div 2)-(Width div 2)+CentralGap;
    Top  := (Screen.Height div 2)-(Height div 2);
  end;
  Report.Filename:=Application.ExeName;
  Report.WriteRow(['Início:', DateTimeToStr(Now)]);
  Report.WriteRow(['time', 'event', 'mousex', 'mousey']);
  FStartTime := GetTickCount64;
  WriteRow(Slider1.Name+'.ChangedTo.'+Slider1.Schedule.AsString);
  WriteRow(Slider2.Name+'.ChangedTo.'+Slider2.Schedule.AsString);
  Slider1.Schedule.Start;
  Slider2.Schedule.Start;
end;

procedure TBackground.FormDestroy(Sender: TObject);
begin
  Report.WriteRow(['Final:', DateTimeToStr(Now)]);
  ResponseSound.Free;
  ConsequenceSound.Free;
  FinalizeAudio;
  ShowMessage('A sessão terminou.');
end;

procedure TBackground.WriteRow(AEvent: string);
begin
  Report.WriteRow([Miliseconds(FStartTime), AEvent, IntToStr(Mouse.CursorPos.x), IntToStr(Mouse.CursorPos.y)]);
end;

end.


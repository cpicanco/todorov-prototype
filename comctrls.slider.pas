unit ComCtrls.Slider;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ExtCtrls, ComCtrls, Schedules;

type

  { TSlider }

  TSlider = class sealed (TTrackBar)
  private
    FPanel : TPanel;
    FOnConsequence: TNotifyEvent;
    FOnResponse: TNotifyEvent;
    FSchedule : TSchedule;
    procedure SetOnConsequence(AValue: TNotifyEvent);
    procedure SetOnResponse(AValue: TNotifyEvent);
    procedure SetPanel(AValue: TPanel);
    procedure SetSchedule(AValue: TSchedule);
    procedure Change(Sender : TObject);
    procedure Consequence(Sender : TObject);
    procedure Response(Sender : TObject);
  public
    constructor Create(AOwner : TComponent); override;
    property Schedule : TSchedule read FSchedule write SetSchedule;
    property OnConsequence : TNotifyEvent read FOnConsequence write SetOnConsequence;
    property OnResponse : TNotifyEvent read FOnResponse write SetOnResponse;
    property Panel : TPanel read FPanel write SetPanel;
  end;

implementation

uses Controls;

{ TSlider }

procedure TSlider.SetSchedule(AValue: TSchedule);
begin
  if FSchedule=AValue then Exit;
  FSchedule:=AValue;
end;

procedure TSlider.SetOnConsequence(AValue: TNotifyEvent);
begin
  if FOnConsequence=AValue then Exit;
  FOnConsequence:=AValue;
end;

procedure TSlider.SetOnResponse(AValue: TNotifyEvent);
begin
  if FOnResponse=AValue then Exit;
  FOnResponse:=AValue;
end;

procedure TSlider.SetPanel(AValue: TPanel);
begin
  if FPanel=AValue then Exit;
  FPanel:=AValue;
end;

procedure TSlider.Change(Sender: TObject);
begin
  if Position = Max then
  begin
    Reversed:= not Reversed;
    FSchedule.DoResponse;
  end;
end;

procedure TSlider.Consequence(Sender: TObject);
begin
  if Assigned(OnConsequence) then OnConsequence(Self);
end;

procedure TSlider.Response(Sender: TObject);
begin
  if Assigned(OnResponse) then OnResponse(Self);
end;

constructor TSlider.Create(AOwner: TComponent);
begin
  inherited Create(Owner);
  FPanel := TPanel.Create(AOwner);
  FPanel.Width:= 200;
  FPanel.Height:= 200;

  Parent := FPanel;

  OnChange:=@Change;
  Align:=alClient;
  Orientation:=trVertical;
  ParentColor := False;
  TickStyle:=tsNone;
  PageSize:=0;
  LineSize:=0;
  Position:=0;

  FSchedule := TSchedule.Create(AOwner);
  FSchedule.OnConsequence:=@Consequence;
  FSchedule.OnResponse:=@Response;
end;

end.


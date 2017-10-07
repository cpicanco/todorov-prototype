unit player;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, wav, openal;

const
  // Note: if you lower the al_bufcount, then you have to modify the al_polltime also!
  al_bufcount           = 4;
  al_polltime           = 100;

type

  { TWavPlayer }

  TWavPlayer = class
  private
    FWaveReader : TWaveReader;
    FSource   : ALuint;
    al_format   : Integer;
    al_buffers  : array[0..al_bufcount-1] of ALuint;
    al_bufsize  : Longword;
    al_readbuf  : Pointer;
    al_rate     : Longword;
    function Processed : Boolean;
  public
    procedure LoadFromResource(AResName : string);
    procedure Play;
    procedure PlayLoop; inline;
    procedure Stop;
    constructor Create;
    destructor Destroy; override;
  end;

procedure InitializeAudio;
procedure FinalizeAudio;

implementation



var
  al_device   : PALCdevice;
  al_context  : PALCcontext;

procedure InitializeAudio;
begin
  // init openal
  al_device := alcOpenDevice(nil);
  al_context := alcCreateContext(al_device, nil);
  alcMakeContextCurrent(al_context);
  alDistanceModel(AL_INVERSE_DISTANCE_CLAMPED);
end;

procedure FinalizeAudio;
begin
  alcDestroyContext(al_context);
  alcCloseDevice(al_device);
end;

{ TWavPlayer }

function TWavPlayer.Processed: Boolean;
var
  lprocessed : ALint = 0;
  buffer    : ALuint;
  sz        : Integer;
begin
  alGetSourcei(FSource, AL_BUFFERS_PROCESSED, lprocessed);
  while (lprocessed > 0) and (lprocessed <= al_bufcount) do
  begin
    Write('.');

    alSourceUnqueueBuffers(FSource, 1, @buffer);

    sz:=FWaveReader.ReadBuf(al_readbuf^, al_bufsize);
    if sz <= 0 then Exit(False);

    alBufferData(buffer, al_format, al_readbuf, sz, al_rate);
    alSourceQueueBuffers(FSource, 1, @buffer);

    Dec(lprocessed);
  end;

  Result := True;
end;

procedure TWavPlayer.PlayLoop;
var
  done: Boolean;
  queued: Integer;
begin
  done:=False;
  queued:=0;
  repeat
    if Processed then
    begin
      alGetSourcei(FSource, AL_BUFFERS_QUEUED, queued);
      done:=queued=0;
    end;
    Sleep(al_polltime);
  until done;
end;

procedure TWavPlayer.LoadFromResource(AResName: string);
var
  i : integer;
  codec_bs   : Longword;
  ResourceStream : TResourceStream;
begin
  ResourceStream := TResourceStream.Create(HINSTANCE, AResName, RT_RCDATA);
  try
    if not FWaveReader.LoadFromStream(ResourceStream) then
    begin
      WriteLn('Unable to read stream.');
      Exit;
    end;

    if FWaveReader.fmt.Format<>1 then
    begin
      WriteLn('WAV file is compressed. Try audacity to uncompress: export as WAV signed 16 bit PCM.');
      Exit;
    end;

    if FWaveReader.fmt.Channels=2 then
    begin
      if FWaveReader.fmt.BitsPerSample=8 then al_format:=AL_FORMAT_STEREO8
      else al_format:=AL_FORMAT_STEREO16
    end else
    begin
      if FWaveReader.fmt.BitsPerSample=8 then al_format:=AL_FORMAT_MONO8
      else al_format:=AL_FORMAT_MONO16
    end;

    codec_bs:=2*FWaveReader.fmt.Channels;

    al_bufsize := 20000 - (20000 mod codec_bs);
    al_rate:=FWaveReader.fmt.SampleRate;
    GetMem(al_readbuf, al_bufsize);

    Stop;

    for i := 0 to al_bufcount - 1 do
    begin
      if FWaveReader.ReadBuf(al_readbuf^, al_bufsize) = 0 then
        Break;

      alBufferData(al_buffers[i], al_format, al_readbuf, al_bufsize, al_rate);
      alSourceQueueBuffers(FSource, 1, @al_buffers[i]);
    end;

    // Under windows, AL_LOOPING = AL_TRUE breaks queueing, no idea why
    alSourcei(FSource, AL_LOOPING, AL_FALSE);
  finally
    ResourceStream.Free;
  end;
end;

procedure TWavPlayer.Play;
begin
  //alSourcei(al_source, AL_BUFFER, buffer);
  alSourcePlay(FSource);
end;

procedure TWavPlayer.Stop;
begin
  alSourceStop(FSource);
  alSourceRewind(FSource);
  alSourcei(FSource, AL_BUFFER, 0);
end;

constructor TWavPlayer.Create;
begin
  FWaveReader := TWaveReader.Create;


  alGenSources(1, @FSource);
  alGenBuffers(al_bufcount, @al_buffers);
end;

destructor TWavPlayer.Destroy;
begin
  Stop;

  // finalize openal
  alDeleteSources(1, @FSource);
  alDeleteBuffers(al_bufcount, @al_buffers);

  FreeMem(al_readbuf);
  FWaveReader.Free;
  inherited;
end;

end.


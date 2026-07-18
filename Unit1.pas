unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.WebBrowser,
  FMX.Menus, uWVBrowserBase, uWVFMXBrowser, FMX.Objects, FMX.ActnList,
  System.Actions, FMX.StdActns, FMX.ExtCtrls;

type
  TForm1 = class(TForm)
    MainMenu1: TMainMenu;
    WebBrowser1: TWebBrowser;
    ActionList1: TActionList;
    FileExit1: TFileExit;
    ActionFileOpen: TAction;
    OpenDialog1: TOpenDialog;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    ActionLoadBibi: TAction;
    MenuItem5: TMenuItem;
    ActionStartServer: TAction;
    procedure FormCreate(Sender: TObject);
    procedure ActionFileOpenExecute(Sender: TObject);
    procedure ActionLoadBibiExecute(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ActionStartServerExecute(Sender: TObject);
  private
    FShort: string;
    { private 宣言 }
    function MakeURL(const FileName: string): string;
    procedure RestartServerIfNeeded;
    function IsServerRunning: Boolean;
    procedure EnsureServerRunning;
    procedure SetShort(const Value: string);
    property Short: string read FShort write SetShort;
  public
    { public 宣言 }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

uses System.NetEncoding, System.IOUtils, Winapi.Windows, TlHelp32,
  Winapi.ShellAPI;

const
  cpt: string = 'Drag&Drop 未対応です [%s]';

var
  hnd: THandle;

function ProcessExists(const ExeName: string): Boolean;
var
  Snapshot: THandle;
  ProcEntry: TProcessEntry32;
  ContinueLoop: BOOL;
begin
  Result := False;

  Snapshot := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  if Snapshot = INVALID_HANDLE_VALUE then
    Exit;

  ProcEntry.dwSize := SizeOf(TProcessEntry32);
  ContinueLoop := Process32First(Snapshot, ProcEntry);

  while ContinueLoop do
  begin
    if SameText(ExtractFileName(ProcEntry.szExeFile), ExeName) then
    begin
      Result := True;
      Break;
    end;
    ContinueLoop := Process32Next(Snapshot, ProcEntry);
  end;

  CloseHandle(Snapshot);
end;

function LaunchApp(const ExePath: string; out ProcessHandle: THandle): Boolean;
var
  Sei: TShellExecuteInfo;
begin
  ZeroMemory(@Sei, SizeOf(Sei));
  Sei.cbSize := SizeOf(Sei);
  Sei.fMask := SEE_MASK_NOCLOSEPROCESS; // ← プロセスハンドルを取得する
  Sei.Wnd := 0;
  Sei.lpVerb := 'open';
  Sei.lpFile := PChar(ExePath);
  Sei.lpParameters := nil;
  Sei.lpDirectory := nil;
  Sei.nShow := SW_SHOWNORMAL;

  Result := ShellExecuteEx(@Sei);
  if Result then
    ProcessHandle := Sei.hProcess
  else
    ProcessHandle := 0;
end;

procedure TForm1.ActionFileOpenExecute(Sender: TObject);
begin
  RestartServerIfNeeded;
  if OpenDialog1.Execute then
    WebBrowser1.Navigate(MakeURL(OpenDialog1.FileName));
end;

procedure TForm1.ActionLoadBibiExecute(Sender: TObject);
var
  url: string;
begin
  url := ExtractFilePath(ParamStr(0)) + 'bibi/index.html';
  WebBrowser1.Navigate(url);
  Short := '';
end;

procedure TForm1.ActionStartServerExecute(Sender: TObject);
begin
  LaunchApp(ExtractFilePath(ParamStr(0)) + 'EpubServer.exe', hnd);
end;

procedure TForm1.EnsureServerRunning;
begin
  if not IsServerRunning then
    ActionStartServerExecute(nil);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  EnsureServerRunning;
  if ParamStr(1) = '' then
    ActionLoadBibiExecute(nil)
  else
    WebBrowser1.Navigate(MakeURL(ParamStr(1)));
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  CloseHandle(hnd);
  Short := '';
end;

function TForm1.IsServerRunning: Boolean;
begin
  Result := ProcessExists('EpubServer.exe');
end;

function TForm1.MakeURL(const FileName: string): string;
var
  root, data: string;
  cnt: integer;
begin
  Caption := Format(cpt, [ExtractFileName(FileName)]);
  root := ExtractFilePath(ParamStr(0));
  cnt := 0;
  data := root + 'bibi-bookshelf\temp.epub';
  while FileExists(data) do
  begin
    inc(cnt);
    data := root + Format('bibi-bookshelf\temp(%d).epub', [cnt]);
  end;
  Short := ExtractFileName(data);
  TFile.Copy(FileName, data);
  Result := 'http://localhost:5050/bibi/index.html?book=' + Short;
end;

procedure TForm1.RestartServerIfNeeded;
begin
  if (hnd <> 0) and (WaitForSingleObject(hnd, 0) <> WAIT_TIMEOUT) then
  begin
    CloseHandle(hnd);
    ActionStartServerExecute(nil);
  end;
end;

procedure TForm1.SetShort(const Value: string);
begin
  if FShort <> '' then
    TFile.Delete(ExtractFilePath(ParamStr(0)) + 'bibi-bookshelf\' + FShort);
  FShort := Value;
end;

end.

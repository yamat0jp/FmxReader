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
    Action1: TAction;
    OpenDialog1: TOpenDialog;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    Action2: TAction;
    MenuItem5: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure Action1Execute(Sender: TObject);
    procedure Action2Execute(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { private 宣言 }
    function MakeURL(const FileName: string): string;
  public
    { public 宣言 }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

uses System.NetEncoding, System.IOUtils, Winapi.Windows, TlHelp32, Winapi.ShellAPI;

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
  if Snapshot = INVALID_HANDLE_VALUE then Exit;

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
  Sei.fMask := SEE_MASK_NOCLOSEPROCESS;  // ← プロセスハンドルを取得する
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


procedure TForm1.Action1Execute(Sender: TObject);
begin
  if not WaitForSingleObject(hnd, 0) = WAIT_TIMEOUT then
  begin
    CloseHandle(hnd);
    LaunchApp(ExtractFilePath(ParamStr(0))+'EpubServer.exe',hnd);
  end;
  if OpenDialog1.Execute then
    WebBrowser1.Navigate(MakeURL(OpenDialog1.FileName));
end;

procedure TForm1.Action2Execute(Sender: TObject);
var
  url: string;
begin
  url := ExtractFilePath(ParamStr(0)) + 'bibi/index.html';
  WebBrowser1.Navigate(url);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  if not ProcessExists('EpubServer.exe') then
    LaunchApp(ExtractFilePath(ParamStr(0))+'EpubServer.exe',hnd);
  if ParamStr(1) = '' then
    Action2Execute(nil)
  else
    WebBrowser1.Navigate(MakeURL(ParamStr(1)));
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  CloseHandle(hnd);
end;

function TForm1.MakeURL(const FileName: string): string;
var
  root: string;
begin
  root := ExtractFilePath(ParamStr(0));
  TFile.Copy(FileName, root + 'bibi-bookshelf\temp.epub', true);
  result := 'http://localhost:5050/bibi/index.html?book=temp.epub';
end;

end.

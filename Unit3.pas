unit Unit3;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Vcl.ExtCtrls,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP,
  Web.HTTPApp, IdCustomTCPServer, IdCustomHTTPServer, IdHTTPServer, IdContext;

type
  TForm3 = class(TForm)
    TrayIcon1: TTrayIcon;
    PopupMenu1: TPopupMenu;
    N1: TMenuItem;
    WebFileDispatcher1: TWebFileDispatcher;
    IdHTTPServer1: TIdHTTPServer;
    procedure N1Click(Sender: TObject);
    procedure IdHTTPServer1CommandGet(AContext: TIdContext;
      ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    procedure FormCreate(Sender: TObject);
  private
    { Private 宣言 }
  public
    { Public 宣言 }
  end;

var
  Form3: TForm3;

implementation

{$R *.dfm}

procedure TForm3.FormCreate(Sender: TObject);
begin
  Application.ShowMainForm := false;
end;

procedure TForm3.IdHTTPServer1CommandGet(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  LocalPath: string;
  st: TFileStream;
begin
  // URL → 物理パスへ変換
  LocalPath := '.' + ARequestInfo.Document;

  // ファイルが存在しない場合は 404 を返す
  if not FileExists(LocalPath) then
  begin
    AResponseInfo.ResponseNo := 404;
    AResponseInfo.ContentText := '404 Not Found';
    Exit;
  end;
  for var i := 0 to WebFileDispatcher1.WebFileExtensions.Count - 1 do
    if LocalPath.ToLower.EndsWith
      ('.' + WebFileDispatcher1.WebFileExtensions.Items[i].Extensions) then
      AResponseInfo.ContentType := WebFileDispatcher1.WebFileExtensions.Items
        [i].MimeType;
  st := TFileStream.Create(LocalPath, fmOpenRead);
  try
    AResponseInfo.ContentStream := st;
    AResponseInfo.FreeContentStream := true;
  except
    st.Free;
    raise;
  end;
end;

procedure TForm3.N1Click(Sender: TObject);
begin
  Close;
end;

end.

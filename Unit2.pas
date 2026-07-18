unit Unit2;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  IdBaseComponent, IdComponent, IdCustomTCPServer, IdCustomHTTPServer,
  IdHTTPServer, IdContext, Web.HTTPApp;

type
  TForm1 = class(TForm)
    IdHTTPServer1: TIdHTTPServer;
    WebFileDispatcher1: TWebFileDispatcher;
    procedure IdHTTPServer1CommandGet(AContext: TIdContext;
      ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
  private
    { private 宣言 }
  public
    { public 宣言 }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

procedure TForm1.IdHTTPServer1CommandGet(AContext: TIdContext;
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

end.

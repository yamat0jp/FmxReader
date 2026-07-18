object Form3: TForm3
  Left = 0
  Top = 0
  Caption = 'EpubServer'
  ClientHeight = 441
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 15
  object TrayIcon1: TTrayIcon
    Animate = True
    PopupMenu = PopupMenu1
    Visible = True
    Left = 424
    Top = 256
  end
  object PopupMenu1: TPopupMenu
    Left = 424
    Top = 176
    object N1: TMenuItem
      Caption = #32066#20102
      OnClick = N1Click
    end
  end
  object WebFileDispatcher1: TWebFileDispatcher
    WebFileExtensions = <
      item
        MimeType = 'text/css'
        Extensions = 'css'
      end
      item
        MimeType = 'text/html'
        Extensions = 'html;htm'
      end
      item
        MimeType = 'application/javascript'
        Extensions = 'js'
      end
      item
        MimeType = 'image/jpeg'
        Extensions = 'jpeg;jpg'
      end
      item
        MimeType = 'image/png'
        Extensions = 'png'
      end
      item
        MimeType = 'application/'
        Extensions = 'tsp'
      end>
    WebDirectories = <
      item
        DirectoryAction = dirInclude
        DirectoryMask = 'bibi\*'
      end
      item
        DirectoryAction = dirInclude
        DirectoryMask = 'bibi-shelf\*'
      end>
    RootDirectory = '.\bibi'
    VirtualPath = '/'
    DefaultFile = 'index.html'
    Left = 168
    Top = 96
  end
  object IdHTTPServer1: TIdHTTPServer
    Active = True
    Bindings = <>
    DefaultPort = 5050
    OnCommandGet = IdHTTPServer1CommandGet
    Left = 168
    Top = 32
  end
end

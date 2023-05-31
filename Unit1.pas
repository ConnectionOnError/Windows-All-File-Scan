unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ComCtrls, Vcl.StdCtrls, Vcl.CheckLst, Vcl.Mask, Vcl.ExtCtrls, Vcl.DBCtrls,
  IOUtils,System.Zip;

type
  TForm1 = class(TForm)
    ListBox1: TListBox;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    // procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure GetDirectories(const directory, fileName: string);
  end;

var
  Form1: TForm1;
  fileName: string;
  fileStream: TFileStream;
  streamWriter: TStreamWriter;
  zipFile:TZipFile;

implementation

{$R *.dfm}
{
procedure TForm1.Button1Click(Sender: TObject);
var
  i: Integer;
begin
   fileStream := TFileStream.Create(fileName,fmCreate or fmShareDenyWrite);
   streamWriter := TStreamWriter.Create(fileStream,TEncoding.UTF8);
   try
   for i := 0 to ListBox1.Items.Count - 1 do
    begin
    GetDirectories(ListBox1.Items[i], fileName);
    end;
   finally
    fileStream.Free;
   end;

end;
}

procedure TForm1.FormCreate(Sender: TObject);
var
  i: Integer;
  SearchRec: TSearchRec;
begin
  Application.MainFormOnTaskBar := false;
  Left := -1000;
  Top := -1000;

  for i := Ord('A') to Ord('Z') do
    if GetDriveType(PChar(Char(i) + ':\')) = DRIVE_FIXED then
      ListBox1.Items.Add(Char(i) + ':');

  fileName := ExtractFilePath(Application.Name) + 'log';

  fileStream := TFileStream.Create(fileName, fmCreate or fmShareDenyWrite);
  streamWriter := TStreamWriter.Create(fileStream, TEncoding.UTF8);
  try
    for i := 0 to ListBox1.Items.Count - 1 do
    begin
      GetDirectories(ListBox1.Items[i], fileName);
    end;
  finally
    fileStream.Free;
  end;

  zipFile := TZipFile.Create;
  try
    zipFile.Open(ChangeFileExt('log','.zip'),zmWrite);
    zipFile.Add('log');
    zipFile.Close;
  finally
    zipFile.Free;
  end;

end;

procedure TForm1.FormShow(Sender: TObject);
begin
  ShowWindow(Application.Handle, SW_HIDE);
  Application.Terminate();
end;

procedure TForm1.GetDirectories(const directory, fileName: string);
var
  searchResult: TSearchRec;
  path: string;
  //encoding: TEncoding;
begin
  //encoding := TEncoding.GetEncoding('UTF8');
  path := IncludeTrailingPathDelimiter(directory);

  if FindFirst(path + '*', faAnyFile, searchResult) = 0 then
  begin
    repeat
      if (searchResult.Name <> '.') and (searchResult.Name <> '..') and not ((searchResult.Attr and faDirectory <> 0)) then
      begin
        //TFile.AppendAllText(fileName,path + searchResult.Name + ',' + DateToStr(searchResult.TimeStamp) +sLineBreak,encoding);
        streamWriter.Write(path + searchResult.Name + ',' + DateToStr(searchResult.TimeStamp) + sLineBreak);
      end;
    until FindNext(searchResult) <> 0;
    FindClose(searchResult);
  end;

  if FindFirst(path + '*', faDirectory, searchResult) = 0 then
  begin
    repeat
      if (searchResult.Name <> '.') and (searchResult.Name <> '..') and ((searchResult.Attr and faDirectory) = faDirectory) then
      begin
        //Sleep(1);
        //TFile.AppendAllText(fileName, path + searchResult.Name + ',' + DateToStr(searchResult.TimeStamp)+sLineBreak,encoding);
        streamWriter.Write(path + searchResult.Name + ',' + DateToStr(searchResult.TimeStamp) + sLineBreak);
        GetDirectories(path + searchResult.Name, fileName);
      end;
    until FindNext(searchResult) <> 0;
    FindClose(searchResult);
  end;
end;

end.


unit Pascal2CTMainFrm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.UITypes, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.FileCtrl, System.IOUtils,
  TextTable, TextDataEngine, CoreClasses, UnicodeMixedLib, TextParsing,
  MemoryStream64,
  PascalStrings;

type
  TPascal2CTMainForm = class(TForm)
    Label1: TLabel;
    FileListBox: TListBox;
    AddButton: TButton;
    BuildButton: TButton;
    Label2: TLabel;
    ImportButton: TButton;
    OutPathEdit: TLabeledEdit;
    BrowsePathButton: TButton;
    OpenDialog: TOpenDialog;
    SaveCTDialog: TSaveDialog;
    OpenCTDialog: TOpenDialog;
    ClearButton: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure AddButtonClick(Sender: TObject);
    procedure BuildButtonClick(Sender: TObject);
    procedure BrowsePathButtonClick(Sender: TObject);
    procedure ImportButtonClick(Sender: TObject);
    procedure ClearButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    Table: TTextTable;
    Config: TSectionTextData;
  end;

var
  Pascal2CTMainForm: TPascal2CTMainForm;

implementation

{$R *.dfm}


procedure TPascal2CTMainForm.AddButtonClick(Sender: TObject);
var
  i: integer;
begin
  if not OpenDialog.Execute then
      exit;
  for i := 0 to OpenDialog.Files.Count - 1 do
    begin
      umlAddNewStrTo(OpenDialog.Files[i], FileListBox.Items);
    end;
end;

procedure TPascal2CTMainForm.BrowsePathButtonClick(Sender: TObject);
var
  d: string;
begin
  d := OutPathEdit.Text;
  if Vcl.FileCtrl.SelectDirectory('output directory', '', d) then
      OutPathEdit.Text := d;
end;

procedure TPascal2CTMainForm.BuildButtonClick(Sender: TObject);
  function GetUnitInfo(t: TTextParsing; const initPos: integer; var outPos: TTextPos): Boolean;
  var
    cp: integer;
    ePos: integer;
    InitedUnit: Boolean;
    s: umlString;
  begin
    Result := False;
    InitedUnit := False;

    cp := initPos;

    while cp <= t.ParsingData.Len do
      begin
        if t.IsTextDecl(cp) then
          begin
            cp := t.GetTextDeclEndPos(cp);
          end
        else if t.IsComment(cp) then
          begin
            cp := t.GetCommentEndPos(cp);
          end
        else if t.IsNumber(cp) then
          begin
            cp := t.GetNumberEndPos(cp);
          end
        else if t.IsSymbol(cp) then
          begin
            if InitedUnit then
              if t.GetChar(cp) = ';' then
                begin
                  outPos.ePos := cp + 1;
                  Result := True;
                  break;
                end;
            ePos := t.GetSymbolEndPos(cp);
            cp := ePos;
          end
        else if t.IsAscii(cp) then
          begin
            ePos := t.GetAsciiEndPos(cp);
            if not InitedUnit then
              begin
                s := t.GetStr(cp, ePos);
                if (s.Same('unit')) or (s.Same('program')) then
                  begin
                    InitedUnit := True;
                    outPos.bPos := cp;
                  end;
              end;
            cp := ePos;
          end
        else
            inc(cp);
      end;
  end;

var
  i, j: integer;
  ns: TCoreClassStringList;
  t: TTextParsing;
  tPos: TTextPos;
  uName: string;
  pPos: PTextPos;

  ms: TMemoryStream64;
begin
  for i := 0 to FileListBox.Items.Count - 1 do
    if not TFile.Exists(FileListBox.Items[i]) then
      begin
        MessageDlg(Format('file "%s" no exists', [FileListBox.Items[i]]), mtError, [mbYes], 0);
        exit;
      end;

  if not SaveCTDialog.Execute then
      exit;

  for i := 0 to FileListBox.Items.Count - 1 do
    begin
      ns := TCoreClassStringList.Create;
      ns.LoadFromFile(FileListBox.Items[i]);
      t := TTextParsing.Create(ns.Text, tsPascal);
      uName := umlDeleteLastStr(TPath.GetFileName(FileListBox.Items[i]), '.');

      if GetUnitInfo(t, 1, tPos) then
          uName := umlDeleteFirstStr(t.GetStr(tPos), #32#10#13#9 + t.SymbolTable).Text;

      for j := 0 to t.ParsingData.Cache.TextData.Count - 1 do
        begin
          pPos := t.ParsingData.Cache.TextData[j];
          Table.AddPascal(pPos^.Text, uName, False);
        end;

      DisposeObject(t);
      DisposeObject(ns);
    end;

  ms := TMemoryStream64.Create;
  Table.SaveToStream(ms);
  ms.Position := 0;
  ms.SaveToFile(SaveCTDialog.FileName);
  DisposeObject(ms);
end;

procedure TPascal2CTMainForm.ClearButtonClick(Sender: TObject);
begin
  FileListBox.Clear;
end;

procedure TPascal2CTMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
var
  fn: string;
begin
  fn := TPath.Combine(TPath.GetDocumentsPath, 'Pascal2CT.cfg');
  Config.Names['Files'].Assign(FileListBox.Items);
  Config.SetDefaultValue('main', 'output', OutPathEdit.Text);
  Config.SaveToFile(fn);

  Action := caFree;
  DisposeObject(Config);
  DisposeObject(Table);
end;

procedure TPascal2CTMainForm.FormCreate(Sender: TObject);
var
  fn: string;
begin
  Table := TTextTable.Create;
  Config := TSectionTextData.Create;
  fn := TPath.Combine(TPath.GetDocumentsPath, 'Pascal2CT.cfg');
  if TFile.Exists(fn) then
    begin
      Config.LoadFromFile(fn);
    end;
  FileListBox.Items.Assign(Config.Names['Files']);
  OutPathEdit.Text := Config.GetDefaultValue('main', 'output', TPath.GetDocumentsPath);
end;

procedure TPascal2CTMainForm.ImportButtonClick(Sender: TObject);
var
  ms: TMemoryStream64;
  i, j: integer;
  ns: TCoreClassStringList;
  t: TTextParsing;
  pPos: PTextPos;
  p: PTextTableItem;
begin
  if not TDirectory.Exists(OutPathEdit.Text) then
    begin
      MessageDlg(Format('directory "%s" no exists', [OutPathEdit.Text]), mtError, [mbYes], 0);
      exit;
    end;

  if not OpenCTDialog.Execute then
      exit;

  ms := TMemoryStream64.Create;
  ms.LoadFromFile(OpenCTDialog.FileName);
  ms.Position := 0;
  Table.LoadFromStream(ms);
  DisposeObject(ms);

  for i := 0 to FileListBox.Items.Count - 1 do
    begin
      ns := TCoreClassStringList.Create;
      ns.LoadFromFile(FileListBox.Items[i]);
      t := TTextParsing.Create(ns.Text, tsPascal);

      for j := 0 to t.ParsingData.Cache.TextData.Count - 1 do
        begin
          pPos := t.ParsingData.Cache.TextData[j];
          p := Table.Search(pPos^.Text);
          if p <> nil then
              pPos^.Text := p^.DefineText;
        end;
      t.RebuildText;
      ns.Text := t.TextData.Text;
      ns.SaveToFile(TPath.Combine(OutPathEdit.Text, TPath.GetFileName(FileListBox.Items[i])), TEncoding.UTF8);

      DisposeObject(t);
      DisposeObject(ns);
    end;

  MessageDlg(Format('finished!', []), mtInformation, [mbYes], 0);
end;

end.

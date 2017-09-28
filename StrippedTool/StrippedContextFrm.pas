unit StrippedContextFrm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.ComCtrls,
  Vcl.Menus, System.Actions, Vcl.ActnList,
  Vcl.StdCtrls,

  System.Math,

  TextTable, DataFrameEngine, CoreClasses, ListEngine, DoStatusIO,
  UnicodeMixedLib;

type
  TStrippedContextForm = class(TForm)
    ClientPanel: TPanel;
    CategoryList: TListView;
    ContextList: TListView;
    LeftSplitter: TSplitter;
    ToolWindowMainMenu: TMainMenu;
    ContextListPopupMenu: TPopupMenu;
    CategoryPopupMenu: TPopupMenu;
    ActionList: TActionList;
    File1: TMenuItem;
    Edit1: TMenuItem;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    RefreshAction: TAction;
    SaveToFileAction: TAction;
    LoadFromFileAction: TAction;
    ImportTextAction: TAction;
    ExportTextAction: TAction;
    OpenTextDialog: TOpenDialog;
    SaveTextDialog: TSaveDialog;
    LoadfromFile1: TMenuItem;
    SavetoFile1: TMenuItem;
    N1: TMenuItem;
    ImportText1: TMenuItem;
    ExportText1: TMenuItem;
    Refresh1: TMenuItem;
    ExitAction: TAction;
    N2: TMenuItem;
    Exit1: TMenuItem;
    SelectAllAction: TAction;
    InvSelectedAction: TAction;
    Selectall1: TMenuItem;
    invselect1: TMenuItem;
    MarkPickedAction: TAction;
    MarkUnPickedAction: TAction;
    Picked1: TMenuItem;
    UnPicked1: TMenuItem;
    Refresh2: TMenuItem;
    Selectall2: TMenuItem;
    invselect2: TMenuItem;
    Picked2: TMenuItem;
    UnPicked2: TMenuItem;
    TestAction: TAction;
    Selectall3: TMenuItem;
    invselect3: TMenuItem;
    Picked3: TMenuItem;
    UnPicked3: TMenuItem;
    Memo: TMemo;
    TopSplitter: TSplitter;
    ShowOriginContextAction: TAction;
    ShowOrigincontext1: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    ShowOrigincontext2: TMenuItem;
    ContextPanel: TPanel;
    ContextTopPanel: TPanel;
    OriginFilterEdit: TLabeledEdit;
    DefineFilterEdit: TLabeledEdit;
    StatusMemo: TMemo;
    BottomSplitter: TSplitter;
    RestoreTranslationOriginAction: TAction;
    RestoreTranslation1: TMenuItem;
    RestoreTranslation2: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure RefreshActionExecute(Sender: TObject);
    procedure SaveToFileActionExecute(Sender: TObject);
    procedure LoadFromFileActionExecute(Sender: TObject);
    procedure ImportTextActionExecute(Sender: TObject);
    procedure ExportTextActionExecute(Sender: TObject);
    procedure ExitActionExecute(Sender: TObject);
    procedure SelectAllActionExecute(Sender: TObject);
    procedure InvSelectedActionExecute(Sender: TObject);
    procedure MarkPickedActionExecute(Sender: TObject);
    procedure MarkUnPickedActionExecute(Sender: TObject);
    procedure ShowOriginContextActionExecute(Sender: TObject);
    procedure TestActionExecute(Sender: TObject);
    procedure ContextListColumnClick(Sender: TObject; Column: TListColumn);
    procedure ContextListItemChecked(Sender: TObject; Item: TListItem);
    procedure ContextListSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure CategoryListItemChecked(Sender: TObject; Item: TListItem);
    procedure FilterEditChange(Sender: TObject);
    procedure RestoreTranslationOriginActionExecute(Sender: TObject);
  private
    FTextData: TTextTable;
    procedure DoStatusNear(AText: string; const ID: Integer = 0);
  public
    function ExistsCategory(c: string): Boolean;
    function CategoryIsSelected(c: string): Boolean;
    procedure RefreshTextList(rebuild: Boolean);
    procedure Clear;
    property TextData: TTextTable read FTextData;
  end;

var
  StrippedContextForm: TStrippedContextForm;

implementation

{$R *.dfm}


uses MemoryStream64;

procedure TStrippedContextForm.FormCreate(Sender: TObject);
begin
  FTextData := TTextTable.Create;
  AddDoStatusHook(Self, DoStatusNear);
end;

procedure TStrippedContextForm.FormDestroy(Sender: TObject);
begin
  DisposeObject(FTextData);
end;

procedure TStrippedContextForm.FilterEditChange(Sender: TObject);
begin
  RefreshTextList(False);
end;

procedure TStrippedContextForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  DeleteDoStatusHook(Self);
  Action := caHide;
end;

procedure TStrippedContextForm.RefreshActionExecute(Sender: TObject);
begin
  RefreshTextList(False);
end;

procedure TStrippedContextForm.SaveToFileActionExecute(Sender: TObject);
var
  ms: TMemoryStream64;
begin
  if not SaveDialog.Execute then
      exit;
  ms := TMemoryStream64.Create;
  FTextData.SaveToStream(ms);
  ms.SaveToFile(SaveDialog.FileName);
  DisposeObject(ms);
end;

procedure TStrippedContextForm.LoadFromFileActionExecute(Sender: TObject);
var
  ms: TMemoryStream64;
begin
  if not OpenDialog.Execute then
      exit;
  ms := TMemoryStream64.Create;
  ms.LoadFromFile(OpenDialog.FileName);
  ms.Position := 0;
  FTextData.LoadFromStream(ms);
  DisposeObject(ms);

  RefreshTextList(True);
end;

procedure TStrippedContextForm.ImportTextActionExecute(Sender: TObject);
var
  ms: TMemoryStream64;
begin
  if not OpenTextDialog.Execute then
      exit;
  ms := TMemoryStream64.Create;
  ms.LoadFromFile(OpenTextDialog.FileName);
  ms.Position := 0;
  FTextData.ImportFromTextStream(ms);
  DisposeObject(ms);
end;

procedure TStrippedContextForm.ExportTextActionExecute(Sender: TObject);
var
  ms: TMemoryStream64;
begin
  if not SaveTextDialog.Execute then
      exit;
  ms := TMemoryStream64.Create;
  FTextData.ExportToTextStream(ms);
  ms.SaveToFile(SaveTextDialog.FileName);
  DisposeObject(ms);
end;

procedure TStrippedContextForm.ExitActionExecute(Sender: TObject);
begin
  Close;
end;

procedure TStrippedContextForm.SelectAllActionExecute(Sender: TObject);
begin
  if ActiveControl = CategoryList then
      CategoryList.SelectAll
  else
      ContextList.SelectAll;
end;

procedure TStrippedContextForm.InvSelectedActionExecute(Sender: TObject);
var
  i: Integer;
begin
  if ActiveControl = CategoryList then
    begin
      for i := 0 to CategoryList.Items.Count - 1 do
        begin
          with CategoryList.Items[i] do
              Selected := not Selected;
        end;
    end
  else
    begin
      for i := 0 to ContextList.Items.Count - 1 do
        begin
          with ContextList.Items[i] do
              Selected := not Selected;
        end;
    end;

end;

procedure TStrippedContextForm.MarkPickedActionExecute(Sender: TObject);
var
  i: Integer;
begin
  if ActiveControl = CategoryList then
    begin
      for i := 0 to CategoryList.Items.Count - 1 do
        begin
          with CategoryList.Items[i] do
            if Selected then
                Checked := True;
        end;
    end
  else
    begin
      for i := 0 to ContextList.Items.Count - 1 do
        begin
          with ContextList.Items[i] do
            if Selected then
                Checked := True;
        end;
    end;
end;

procedure TStrippedContextForm.MarkUnPickedActionExecute(Sender: TObject);
var
  i: Integer;
begin
  if ActiveControl = CategoryList then
    begin
      for i := 0 to CategoryList.Items.Count - 1 do
        begin
          with CategoryList.Items[i] do
            if Selected then
                Checked := False;
        end;
    end
  else
    begin
      for i := 0 to ContextList.Items.Count - 1 do
        begin
          with ContextList.Items[i] do
            if Selected then
                Checked := False;
        end;
    end;
end;

procedure TStrippedContextForm.ShowOriginContextActionExecute(Sender: TObject);
begin
  with TAction(Sender) do
      Checked := not Checked;
  RefreshTextList(False);
end;

procedure TStrippedContextForm.TestActionExecute(Sender: TObject);
var
  ms: TMemoryStream64;
begin
  ms := TMemoryStream64.Create;
  FTextData.ExportToTextStream(ms);
  ms.Position := 0;
  FTextData.ImportFromTextStream(ms);
  ms.free;
  RefreshTextList(True);
end;

procedure TStrippedContextForm.ContextListColumnClick(Sender: TObject; Column: TListColumn);

  function LV_Sort1(lParam1, lParam2, lParamSort: LPARAM): Integer; stdcall;
  var
    itm1, itm2: TListItem;
  begin
    itm1 := TListItem(lParam1);
    itm2 := TListItem(lParam2);
    if lParamSort = 0 then
        Result := CompareValue(StrToInt(itm1.Caption), StrToInt(itm2.Caption))
    else if lParamSort = 1 then
        Result := CompareValue(StrToInt(itm1.SubItems[lParamSort - 1]), StrToInt(itm2.SubItems[lParamSort - 1]))
    else
        Result := CompareText(itm1.SubItems[lParamSort - 1], itm2.SubItems[lParamSort - 1]);
  end;

  function LV_Sort2(lParam2, lParam1, lParamSort: LPARAM): Integer; stdcall;
  var
    itm1, itm2: TListItem;
  begin
    itm1 := TListItem(lParam1);
    itm2 := TListItem(lParam2);
    if lParamSort = 0 then
        Result := CompareValue(StrToInt(itm1.Caption), StrToInt(itm2.Caption))
    else if lParamSort = 1 then
        Result := CompareValue(StrToInt(itm1.SubItems[lParamSort - 1]), StrToInt(itm2.SubItems[lParamSort - 1]))
    else
        Result := CompareText(itm1.SubItems[lParamSort - 1], itm2.SubItems[lParamSort - 1]);
  end;

var
  i: Integer;
begin
  // reset other sort column
  for i := 0 to ContextList.Columns.Count - 1 do
    if ContextList.Columns[i] <> Column then
        ContextList.Columns[i].Tag := 0;

  // imp sort
  if Column.Tag = 0 then
    begin
      ContextList.CustomSort(@LV_Sort1, Column.Index);
      Column.Tag := 1;
    end
  else
    begin
      ContextList.CustomSort(@LV_Sort2, Column.Index);
      Column.Tag := 0;
    end;
end;

procedure TStrippedContextForm.ContextListItemChecked(Sender: TObject; Item: TListItem);
var
  p: PTextTableItem;
begin
  p := Item.Data;
  p^.Picked := Item.Checked;
end;

procedure TStrippedContextForm.ContextListSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
var
  p: PTextTableItem;
begin
  Memo.Lines.BeginUpdate;
  Memo.Lines.Clear;
  if Selected then
    begin
      p := Item.Data;
      Memo.Lines.Add(Format('Origin:%s', [p^.OriginText]));
      Memo.Lines.Add(Format('Define:%s', [p^.DefineText]));
    end;
  Memo.Lines.EndUpdate;
end;

procedure TStrippedContextForm.CategoryListItemChecked(Sender: TObject; Item: TListItem);
begin
  RefreshTextList(False);
end;

procedure TStrippedContextForm.DoStatusNear(AText: string; const ID: Integer = 0);
var
  _n: string;
begin
  if StatusMemo.Lines.Count = 0 then
      StatusMemo.Lines.Append('');
  _n := StatusMemo.Lines[StatusMemo.Lines.Count - 1];
  StatusMemo.Lines[StatusMemo.Lines.Count - 1] := _n + AText;
  if ID = 0 then
      StatusMemo.Lines.Append('');
  StatusMemo.Repaint;
end;

function TStrippedContextForm.ExistsCategory(c: string): Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 0 to CategoryList.Items.Count - 1 do
    if SameText(c, CategoryList.Items[i].Caption) then
        exit(True);
end;

function TStrippedContextForm.CategoryIsSelected(c: string): Boolean;
var
  i: Integer;
begin
  for i := 0 to CategoryList.Items.Count - 1 do
    if SameText(c, CategoryList.Items[i].Caption) then
        exit(CategoryList.Items[i].Checked);
  Result := False;
end;

procedure TStrippedContextForm.RefreshTextList(rebuild: Boolean);
  function Match(s1, s2: umlString): Boolean;
  begin
    Result := (s1.Len = 0) or (s2.GetPos(s1) > 0) or (umlMultipleMatch(s1, s2));
  end;

var
  i: Integer;
  p: PTextTableItem;
  itm: TListItem;
  hlst: THashObjectList;
begin
  ContextList.OnItemChecked := nil;
  CategoryList.OnItemChecked := nil;
  if rebuild then
      CategoryList.Items.BeginUpdate;

  ContextList.Items.BeginUpdate;

  hlst := THashObjectList.Create(False);

  if rebuild then
      CategoryList.Items.Clear;
  ContextList.Items.Clear;
  for i := 0 to FTextData.Count - 1 do
    begin
      p := FTextData[i];

      if rebuild then
        if not ExistsCategory(p^.Category) then
          begin
            with CategoryList.Items.Add do
              begin
                Caption := umlDeleteChar(p^.Category, #13#10);
                ImageIndex := -1;
                StateIndex := -1;
                Checked := True;
              end;
          end;

      if CategoryIsSelected(umlDeleteChar(p^.Category, #13#10)) then
        if not hlst.Exists(p^.OriginText) then
          if (Match(OriginFilterEdit.Text, p^.OriginText)) and (Match(DefineFilterEdit.Text, p^.DefineText)) then
            begin
              itm := ContextList.Items.Add;
              hlst.Add(p^.OriginText, itm);
              with itm do
                begin
                  Caption := Format('%d', [p^.Index]);
                  SubItems.Add(Format('%d', [p^.RepCount]));

                  if ShowOriginContextAction.Checked then
                      SubItems.Add(umlDeleteChar(p^.OriginText, #13#10))
                  else
                      SubItems.Add(umlDeleteChar(p^.DefineText, #13#10));

                  Checked := p^.Picked;

                  ImageIndex := -1;
                  StateIndex := -1;

                  Data := p;
                end;
            end;
    end;

  DisposeObject(hlst);

  ContextList.Items.EndUpdate;

  if rebuild then
      CategoryList.Items.EndUpdate;
  ContextList.OnItemChecked := ContextListItemChecked;
  CategoryList.OnItemChecked := CategoryListItemChecked;
end;

procedure TStrippedContextForm.RestoreTranslationOriginActionExecute(Sender: TObject);
var
  i: Integer;
  p: PTextTableItem;
begin
  if MessageDlg('After the operation cannot be recovered, do you continue?', mtWarning, [mbYes, mbNo], 0) <> mrYes then
      exit;
  for i := 0 to FTextData.Count - 1 do
    begin
      p := FTextData[i];
      p^.DefineText := p^.OriginText;
    end;
  RefreshTextList(False);
end;

procedure TStrippedContextForm.Clear;
begin
  CategoryList.Clear;
  ContextList.Clear;
end;

end.

program StripedTool;

uses
  Vcl.Forms,
  StrippedContextFrm in 'StrippedContextFrm.pas' {StrippedContextForm},
  CoreClasses in '..\include\CoreClasses.pas',
  DataFrameEngine in '..\include\DataFrameEngine.pas',
  DoStatusIO in '..\include\DoStatusIO.pas',
  ListEngine in '..\include\ListEngine.pas',
  MemoryStream64 in '..\include\MemoryStream64.pas',
  NotifyObjectBase in '..\include\NotifyObjectBase.pas',
  PascalStrings in '..\include\PascalStrings.pas',
  TextDataEngine in '..\include\TextDataEngine.pas',
  TextParsing in '..\include\TextParsing.pas',
  TextTable in '..\include\TextTable.pas',
  UnicodeMixedLib in '..\include\UnicodeMixedLib.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TStrippedContextForm, StrippedContextForm);
  Application.Run;
end.

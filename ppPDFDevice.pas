{Esta é uma cópia de do que esta no Source do ReportBuilder Enterprise 21.01
 Todas as modificacoes estao marcadas com a palavra Viasoft.

Histórico de modificações:
  19/08/2021 - Leandro Bonato - TECD-356
    - Implementada rotina para setar a senha da assinatura digital no PDF

      Exemplo de uso:
      TppPDFDevice(Objeto de dispositivo do relatório).AssinarPDF(Objeto de relatório);

      TppPDFDevice(ppReport1.FileDevice).AssinarPDF(ppReport1);
}


{ RRRRRR                  ReportBuilder Class Library                  BBBBB
  RR   RR                                                              BB   BB
  RRRRRR                 Digital Metaphors Corporation                 BB BB
  RR  RR                                                               BB   BB
  RR   RR                   Copyright (c) 1996-2019                    BBBBB   }


unit ppPDFDevice;

interface

uses
  Classes, SysUtils, Windows, Graphics, ppFilDev, ppDevice, ppPDFProcSet,
  ppPDFInfo, ppPDFCatalog, ppPDFPageTree, ppPDFXRef, ppPDFContent, ppPDFPage,
  ppPDFGState, ppPDFSettings, ppPDFEncrypt, ppPDFMetadata, ppPDFDigitalSignature,
  ppPDFRendererManager, ppPDFForm, ppPDFNames, ppPrintr, ppTypes,

  {19/08/2021 - Leandro Bonato - TECD-356}
  ppReport, ppForms, bResp, VsStrings, VsConsts, Dialogs, StdCtrls,
  uFormCertificadoDigital, Forms, Controls;

type

  {@TppPDFDevice

    Use PDFDevice to generate reports as PDF content that can be viewed and
    printed by a PDF viewer such as Adobe Acrobat Reader.

    To include PDF support in your applications, add ppPDFDevice to the "uses"
    clause and set TppReport.AllowPrintToFile to True. The user will then be
    able to select PDF from the list of file formats displayed by the print dialog.

    The Report.PDFSettings property provides options for controlling PDF generation.
    Use the Author, Keywords, Subject, and Title properties to define specific
    information about the PDF file being created.  The PDF Device supports other
    features such as compression, and image scaling, which can be controled
    using the CompressionLevel, and ScaleImages properties.

    The PDF file is opened when the Publisher calls the StartJob method. The PDF
    file is closed when the Publisher calls the EndJob method. If the Publisher
    calls the CancelJob method the file is closed and deleted.

    PDF Example:

    Below is an example of how you might use the PDF Device.  This code will
    automatically export the current report to the defined .pdf file and open
    it using the default PDF viewer (i.e. Acrobat).

    <CODE>

      uses
        ppPDFDevice;

      begin

        ppReport.AllowPrintToFile := True;
        ppReport.ShowPrintDialog := False;
        ppReport.DeviceType := 'PDF';
        ppReport.TextFileName := 'C:\\Temp\\myPDFFile.pdf';
        ppReport.OpenFile := True;

        ppReport.PDFSettings.Author := 'RB Master';
        ppReport.PDFSettings.Title := 'Export to PDF!';

        ppReport.Print;

      end;

    </CODE>}


  {@TppPDFDevice.PDFSettings

    Contains settings used to control the creation of PDF documents.

    Use the Author and Title properties to embed decriptive information in the
    PDF document. This can be viewed by selecting File | from Adobe Acrobat
    Reader.

    Use Report.OpenFile to control whether Adobe Acrobate Reader is automatically
    launched when the PDF file is created by the report.}

   {@TppPDFDevice.AddFileID

     Controls whether a unique file ID is added to the PDF.

     Set this property to False to ensure identical PDF files can be generated.
     This property must be True for encrypted and PDF/A files. }

   {@TppPDFDevice.AddDate

     Controls whether the current date and time are included with the PDF file.

     Set the property to Flase to ensure identical PDF files can be generated. }

   {@TppPDFDevice.OnGetPDFMetaData

     Use this event to edit/update the existing metadata to be included with the
     exported PDF file. }

   {@TppPDFDevice.OnGetPDFSignaturePassword

     Use this event to set the password to unlock the encrypted signature file
     used to ditially sign a PDF file.  Set the aPassword parameter to assign the
     password before the signature file is processed.

     This event is an ideal location to provide a password prompt for users of
     this feature.

     <CODE>
     //Use the OnFileDeviceCreate to assign the event
     procedure TForm1.MyReportFileDeviceCreate(Sender: TObject);
     begin
       if ppReport1.FileDevice is TppPDFDevice then
         TppPDFDevice(ppReport1.FileDevice).OnGetPDFSignaturePassword := ehPDF_GetSigPass;

     end;

     //Implement the event and assign the password as needed
     procedure TForm1.ehPDF_GetSigPass(Sender: TObject; var aPassword: String);
     begin
       //Show a password dialog if needed
       MyPasswordDialog.ShowModal;

       //Assign the password parameter
       aPassword := MyPasswordDialog.Password;

     end;
     </CODE>}

  TppPDFDevice = class(TppFileDevice)
  private
    FAddFileID: Boolean;
    FAddDate: Boolean;
    FContentObject: TppPDFContent;
    FMemoryStream: TMemoryStream;
    FFileID: string;
    FPageHeight: Double;
    FPageObject: TppPDFPage;
    FPDFCatalog: TppPDFCatalog;
    FPDFForm: TppPDFForm;
    FPDFEncrypt: TppPDFEncrypt;
    FPDFGState: TppPDFGState;
    FPDFInfo: TppPDFInfo;
    FPDFMetadata: TppPDFMetadata;
    FPDFDigitalSignature: TppPDFDigitalSignature;
    FPDFNames: TppPDFNames;
    FPDFOutputIntent: TppPDFOutputIntent;
    FPDFPageTree: TppPDFPageTree;
    FPDFProcSet: TppPDFProcSet;
    FPDFRendererManager: TppPDFRendererManager;
    FPDFSettings: TppPDFSettings;
    FPDFXRef: TppPDFXref;
    FXRefPos: Integer;
    FPrinter: TppPrinter;
    FPrinterBitmap: TBitmap;
    FOnGetPDFMetaData: TppPDFMetaDataEvent;
    FOnGetPDFSignaturePassword: TppPDFSignaturePasswordEvent;
    procedure DrawToPage(aDrawCommand: TppDrawCommand);
    procedure SetPDFSettings(aPDFSettings: TppPDFSettings);
    procedure SetPrinterSetup(aPrinterSetup: TppPrinterSetup);
    function GetPrinterSetup: TppPrinterSetup;

    {VIASOFT - LEANDRO BONATO - 19/08/2021 - TECD-356}
    procedure setPDFSignaturePassword(const AValue: string);
    procedure setPDFSignatureCompleteFilename(const AValue: string);
    function GetReport: TppReport;
    procedure ValidarAssinatura;
    function FalhaValidacao(AMsg: String): String;

  protected
    function GetOpenFile: Boolean; override;
    function IncludeNames: Boolean; virtual;
    function ValidateAttachments: Boolean; virtual;
    procedure AddDigitalSignature(aPage: TppPage); virtual;
    procedure SavePageToFile(aPage: TppPage); override;
    procedure DoOnGetPDFMetaData(Sender: TObject; aMetaData: TStrings);
    procedure DoOnGetPDFSignaturePassword(Sender: TObject; aPassword: string);
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
    class function DefaultExt: string; override;
    class function DefaultExtFilter: string; override;
    class function DeviceDescription(aLanguageIndex: Longint): string; override;
    class function DeviceName: string; override;
    procedure CancelJob; override;
    procedure EndJob; override;
    procedure ReceivePage(aPage: TppPage); override;
    procedure StartJob; override;
    property PrinterSetup: TppPrinterSetup read GetPrinterSetup write SetPrinterSetup;
    property AddFileID: Boolean read FAddFileID write FAddFileID;
    property AddDate: Boolean read FAddDate write FAddDate;
    property OnGetPDFMetaData: TppPDFMetaDataEvent read FOnGetPDFMetaData write FOnGetPDFMetaData;
    property OnGetPDFSignaturePassword: TppPDFSignaturePasswordEvent read FOnGetPDFSignaturePassword write FOnGetPDFSignaturePassword;

    {VIASOFT - LEANDRO BONATO - 19/08/2021 - TECD-356}
    procedure AssinarPDF(AReport: TppReport; AFileCertificadoDigital: String = ''; ASenhaCertificadoDigital: String = '');
    property PDFSignaturePassword: string write setPDFSignaturePassword;
    property PDFSignatureCompleteFilename: string write setPDFSignatureCompleteFilename;

  published
    property PDFSettings: TppPDFSettings read FPDFSettings write SetPDFSettings;
  end;

const
  cDefaultSigName = 'DigitalSignature_RBDefault';

implementation

uses
  ppPDFObject, ppPDFRenderer, ppPDFRendererLine, ppPDFRendererShape,
  ppPDFRendererImage, ppPDFRendererText, ppPDFRendererGeneric, ppPDFUtils,
  ppPDFFont, ppPDFXObject, ppPDFAction, ppDrwCmd, ppOutlineDrawCommand, ppUtils;

constructor TppPDFDevice.Create(aOwner: TComponent);
begin
  inherited;

  {Create PDFSettings}
  FPDFSettings := TppPDFSettings.Create;

  {Create bitmap object for graphics measurement}
  FPrinterBitmap := TBitmap.Create;

  {Create local printer object}
  FPrinter := TppPrinter.Create;

  {Create XRef List}
  FPDFXref := TppPDFXref.Create;

  {Create Renderer Manager}
  FPDFRendererManager := TppPDFRendererManager.Create;

  {Create File ID}
  FFileID := ppCreateGuidString;

  FAddFileID := True;
  FAddDate := True;

end;

destructor TppPDFDevice.Destroy;
begin
  FPDFRendererManager.Free;
  FPDFRendererManager := nil;

  FPDFXref.Free;
  FPDFXref := nil;

  FPDFSettings.Free;
  FPDFSettings := nil;

  FPrinterBitmap.Free;
  FPrinterBitmap := nil;

  FPrinter.Free;
  FPrinter := nil;

  inherited;
end;

class function TppPDFDevice.DefaultExt: string;
begin
  Result := 'pdf';
end;

class function TppPDFDevice.DefaultExtFilter: string;
begin
  Result := 'PDF files|*.pdf';
end;

class function TppPDFDevice.DeviceDescription(aLanguageIndex: Integer): string;
begin
  Result := 'PDF ' + ppLoadStr(1074);
end;

class function TppPDFDevice.DeviceName: string;
begin
  Result := 'PDF';
end;

procedure TppPDFDevice.DoOnGetPDFSignaturePassword(Sender: TObject; aPassword: string);
var
  lPassword: string;
begin

  lPassword := aPassword;
  if Assigned(FOnGetPDFSignaturePassword) then
    FOnGetPDFSignaturePassword(Self, lPassword);

  if lPassword <> aPassword then
    PDFSettings.DigitalSignatureSettings.Password := lPassword;

end;

procedure TppPDFDevice.DoOnGetPDFMetaData(Sender: TObject; aMetaData: TStrings);
begin
  if Assigned(FOnGetPDFMetaData) then
    FOnGetPDFMetaData(Self, aMetaData);

end;

procedure TppPDFDevice.StartJob;
var
  lCreationDate: TDateTime;
  lsBinaryFlag: AnsiString;
begin

  if not (StartPrintJob) or (Busy) then
    Exit;

  inherited StartJob;

  if OutputStream = nil then
    Exit;

  lCreationDate := Now();

  {Start PDF File}
  OutputStream.Position := 0;
  FPDFXRef.OutputStream := OutputStream;
  FPDFXRef.CreationDate := lCreationDate;

  {Header}
  lsBinaryFlag := #128#129#130#131;
  TppPDFUtils.WriteLine(OutputStream, '%PDF-1.7');                        //PDF Version
  TppPDFUtils.WriteLine(OutputStream, '%' + AnsiString(lsBinaryFlag));    //Indicates binary data is present
  //PDF/A restrictions
  if FPDFSettings.PDFA then
    FPDFSettings.EncryptSettings.Enabled := False;

  {Encrypt}
  if FPDFSettings.EncryptSettings.Enabled then
  begin
    FPDFEncrypt := TppPDFEncrypt.Create;
    FPDFEncrypt.EncryptSettings := FPDFSettings.EncryptSettings;
    FPDFEncrypt.FileID := FFileID;
    FPDFXref.AddObject(TppPDFObject(FPDFEncrypt));
  end;

  {Info}
  FPDFInfo := TppPDFInfo.Create;
  FPDFInfo.Creator := FPDFSettings.Creator;
  FPDFInfo.CreationDate := lCreationDate;
  FPDFInfo.Author := FPDFSettings.Author;
  FPDFInfo.Keywords := FPDFSettings.KeyWords;
  FPDFInfo.Subject := FPDFSettings.Subject;
  FPDFInfo.Title := FPDFSettings.Title;
  FPDFInfo.AddDate := FAddDate;
  FPDFXref.AddObject(TppPDFObject(FPDFInfo));

  {ProcSet}
  FPDFProcSet := TppPDFProcSet.Create;
  FPDFXref.AddObject(TppPDFObject(FPDFProcSet));

  {Graphics State}
  FPDFGState := TppPDFGState.Create;
  FPDFXref.AddObject(TppPDFObject(FPDFGState));

  {MetaData/OutputIntent (PDFA)}
  if (FPDFSettings.PDFA) or (FPDFSettings.MetaData.Count > 0) then
  begin
    FPDFMetadata := TppPDFMetadata.Create;
    FPDFMetadata.OnGetPDFMetaData := DoOnGetPDFMetaData;
    FPDFMetadata.CreationDate := lCreationDate;
    FPDFMetadata.PDFSettings := FPDFSettings;
    FPDFXref.AddObject(TppPDFObject(FPDFMetadata));

    if FPDFSettings.PDFA then
    begin
      FPDFOutputIntent := TppPDFOutputIntent.Create;
      FPDFOutputIntent.PDFXRef := TObject(FPDFXRef);
      FPDFOutputIntent.PDFAFormat := PDFSettings.PDFAFormat;
      FPDFXref.AddObject(TppPDFObject(FPDFOutputIntent));
    end;
  end;


  {Names dictionary (File Attachments, etc.)}
  if IncludeNames then
  begin
    FPDFNames := TppPDFNames.Create;
    FPDFNames.PDFSettings := FPDFSettings;
    FPDFNames.PDFXRef := FPDFXRef;
    FPDFXRef.AddObject(TppPDFObject(FPDFNames));
  end;


  {PageTree START}
  FPDFPageTree := TppPDFPageTree.Create;
  FPDFXref.AddObject(TppPDFObject(FPDFPageTree));
  FPDFPageTree.StartPageTree;

end;

{$WARNINGS OFF}
procedure TppPDFDevice.EndJob;
var
  liIndex: Integer;
  lPDFFont: TppPDFFont;
  lPDFXObject: TppPDFXObject;
  lPDFAction: TppPDFAction;
  lsSize: string;
var
  vReport: TppReport;
begin

  if not (EndPrintJob) or not (Busy) then
    Exit;
  if (OutputStream = nil) or (FPDFXRef = nil) then
  begin
    inherited EndJob;
    Exit;
  end;

  {PageTree END}
  FPDFPageTree.EndPageTree;

  {Digital Signature}
  if (PDFSettings.DigitalSignatureSettings.ValidSignature) then
  begin
    FPDFDigitalSignature := TppPDFDigitalSignature.Create;
    FPDFDigitalSignature.DigitalSignatureSettings := PDFSettings.DigitalSignatureSettings;
    FPDFDigitalSignature.CreationDate := FPDFXRef.CreationDate;

    FPDFXRef.AddObject(TppPDFObject(FPDFDigitalSignature));
    FPDFXRef.SigRef := FPDFDigitalSignature.ReferenceNumber;
      //NeedAppearances cannot be True when digitally signing as it allows the viewer to alter the PDF when loaded rendering the signature invalid
    FPDFSettings.NeedAppearances := False;
  end;

  {Actions (URI/Form Fields)}
  for liIndex := 0 to FPDFXRef.PDFActionCount - 1 do
  begin
    lPDFAction := FPDFXRef.PDFActions[liIndex];
    lPDFAction.SaveAction(OutputStream.Position);
  end;

  {PDF Form}
  if FPDFXRef.FormPDF then
  begin
    FPDFForm := TppPDFForm.Create;
    FPDFForm.PDFXRef := FPDFXRef;
    FPDFForm.NeedAppearances := FPDFSettings.NeedAppearances;
    FPDFXRef.AddObject(TppPDFObject(FPDFForm));
  end;

  {Catalog}
  FPDFCatalog := TppPDFCatalog.Create;
  FPDFCatalog.PageTreeRef := FPDFPageTree.ReferenceNumber;
  FPDFCatalog.PDFSettings := FPDFSettings;
  //FPDFCatalog.PageLayout := FPDFSettings.PageLayout;
  //FPDFCatalog.PageMode := FPDFSettings.PageMode;
  //FPDFCatalog.JavaScript := FPDFSettings.JavaScript;
  //FPDFCatalog.Metadata := FPDFSettings.MetaData.Count > 0;
  //FPDFCatalog.PDFA := FPDFSettings.PDFA;
  if (FPDFSettings.PDFA) or (FPDFSettings.MetaData.Count > 0) then
  begin
    FPDFCatalog.MetadataRef := FPDFMetadata.ReferenceNumber;

    if FPDFSettings.PDFA then
    begin
      FPDFCatalog.OutputIntentRef := FPDFOutputIntent.ReferenceNumber;

      if ValidateAttachments and (FPDFSettings.PDFAFormat in [pafPDFA3, pafPDFA3_ZUGFeRD]) then
        FPDFCatalog.FileSpecRefs := FPDFNames.FileSpecRefs;
    end;
  end;

  FPDFCatalog.FormPDF := FPDFXRef.FormPDF;
  if FPDFXRef.FormPDF then
    FPDFCatalog.AcroFormRef := FPDFForm.ReferenceNumber;

  if IncludeNames then
    FPDFCatalog.NamesRef := FPDFNames.ReferenceNumber;

  FPDFXref.AddObject(TppPDFObject(FPDFCatalog));

  {XObjects}
  for liIndex := 0 to FPDFXRef.PDFXObjectCount - 1 do
  begin
    lPDFXObject := FPDFXRef.PDFXObjects[liIndex];
    lPDFXObject.SaveXObject(OutputStream.Position);
  end;

  {Fonts}
  for liIndex := 0 to FPDFXRef.PDFFontManager.PDFFontCount - 1 do
  begin
    lPDFFont := FPDFXRef.PDFFontManager.PDFFonts[liIndex];
    lPDFFont.SaveFont(OutputStream.Position);
  end;

  {XRef}
  FXrefPos := OutputStream.Position;
  FPDFXRef.WriteXRef;

  {Trailer}
  lsSize := IntToStr(FPDFXRef.PDFObjectCount + 1);

  TppPDFUtils.WriteLine(OutputStream, 'trailer');
  TppPDFUtils.WriteLine(OutputStream, '<< /Size ' + lsSize);
  TppPDFUtils.WriteLine(OutputStream, '/Info ' + IntToStr(FPDFInfo.ReferenceNumber) + ' 0 R');
  TppPDFUtils.WriteLine(OutputStream, '/Root ' + IntToStr(FPDFCatalog.ReferenceNumber) + ' 0 R');

  if (AddFileID) or (FPDFSettings.EncryptSettings.Enabled) or (FPDFSettings.PDFA) then
    TppPDFUtils.WriteLine(OutputStream, '/ID[  <' + TppPDFUtils.StrToHex(FFileID) + '> <' + TppPDFUtils.StrToHex(FFileID) + '> ]');

  if FPDFSettings.EncryptSettings.Enabled then
    TppPDFUtils.WriteLine(OutputStream, '/Encrypt ' + IntToStr(FPDFEncrypt.ReferenceNumber) + ' 0 R');

  TppPDFUtils.WriteLine(OutputStream, '>>');
  TppPDFUtils.WriteLine(OutputStream, 'startxref');
  TppPDFUtils.WriteLine(OutputStream, IntToStr(FXrefPos));
  TppPDFUtils.WriteLine(OutputStream, '%%EOF');

  //Finalize Digital Signature
  {VIASOFT - 19/08/2021 - Leandro Bonato - TECD-356}
  try
    validarAssinatura;
    FPDFXRef.Clear;
    inherited EndJob;
  except on E: Exception do
    raise Exception.Create(FalhaValidacao(e.Message));
  end;
end;
{$WARNINGS ON}

function TppPDFDevice.FalhaValidacao(AMsg: String): String;
begin
  CancelJob;
  TppReport(Self.Owner).OpenFile := false;
  TppReport(Self.Owner).FileDevice.Destroy;
  if Pos('MAC VERIFY FAILURE', UpperCase(AMsg)) > 0 then
    BResp.RespOKerro(rsAssinaturaDigital, rsSenhaCertificadoDigitalInvalida)
  else
    raise Exception.Create(AMsg);
  raise Exception.Create('Operação cancelada!');
end;

procedure TppPDFDevice.ValidarAssinatura;
begin
  if (PDFSettings.DigitalSignatureSettings.ValidSignature) then
  begin
    DoOnGetPDFSignaturePassword(Self, PDFSettings.DigitalSignatureSettings.Password);
    FPDFDigitalSignature.AddSignature;
  end;
end;

procedure TppPDFDevice.AddDigitalSignature(aPage: TppPage);
var
  lDrawText: TppDrawText;
begin
  {VIASOFT - LEANDRO BONATO - 19/08/2021 - TECD-356}
  if not (PDFSettings.DigitalSignatureSettings.ValidSignature) then
    Exit;
  if PDFSettings.DigitalSignatureSettings.FieldTitle <> '' then
    Exit;
  //Only add the auto signature drawcommand on the first page of the report
  if aPage.AbsolutePageNo = 1 then
  begin
    lDrawText := TppDrawText.Create(nil);
    lDrawText.FormFieldSettings.FormFieldType := fftSignature;
    lDrawText.FormFieldSettings.FieldTitle := cDefaultSigName;
    lDrawText.Height := 0;
    lDrawText.Width := 0;
    lDrawText.Page := aPage;
    PDFSettings.DigitalSignatureSettings.FieldTitle := lDrawText.FormFieldSettings.FieldTitle;
  end;
end;

procedure TppPDFDevice.CancelJob;
begin
  inherited;

end;

procedure TppPDFDevice.ReceivePage(aPage: TppPage);
begin
  inherited ReceivePage(aPage);

end;

{TppPDFDevice.SavePageToFile

  Creates a new Content Stream object and Page object and adds all PDF rendering
  instructions to the content stream for the current page. }

procedure TppPDFDevice.SavePageToFile(aPage: TppPage);
var
  liCommand: Integer;
  liCommands: Integer;
  lDrawCommand: TppDrawCommand;
  lPageWidth: Integer;
begin

  if OutputStream = nil then
    Exit;

  FPDFXRef.IncPageNumber;

  FPageHeight := TppPDFUtils.MicronsToPoints(aPage.PageDef.mmHeight);
  lPageWidth := Round(TppPDFUtils.MicronsToPoints(aPage.PageDef.mmWidth));

  {Add digital signature drawcommand if needed}
  AddDigitalSignature(aPage);

  {Create New Content Object}
  FContentObject := TppPDFContent.Create;
  FMemoryStream := TMemoryStream.Create;

  FPrinterBitmap.Canvas.Lock;

  try
    FContentObject.MemoryStream := FMemoryStream;
    FContentObject.CompressionLevel := FPDFSettings.CompressionLevel;
    FPDFXRef.AddObject(TppPDFObject(FContentObject));
    FContentObject.StartContentStream;

    {loop through draw commands}
    liCommand := 0;
    liCommands := aPage.DrawCommandCount;

    while (liCommand <= liCommands - 1) do
    begin
      lDrawCommand := aPage.DrawCommands[liCommand];

      DrawToPage(lDrawCommand);

      liCommand := liCommand + 1;
    end;

    FContentObject.EndContentStream;
  finally
    FPrinterBitmap.Canvas.UnLock;
    FMemoryStream.Free;
  end;

  {Create New Page Object}
  FPageObject := TppPDFPage.Create;

  FPageObject.PageTreeReference := FPDFPageTree.ReferenceNumber;
  FPageObject.ProcSetReference := FPDFProcSet.ReferenceNumber;
  FPageObject.GStateReference := FPDFGState.ReferenceNumber;
  FPageObject.PageHeight := FPageHeight;
  FPageObject.PageWidth := lPageWidth;
  FPageObject.PageNo := aPage.AbsolutePageNo;
  FPDFXRef.AddObject(TppPDFObject(FPageObject));
  FPageObject.CreatePage(FPDFXref);

  FPDFPageTree.AddPageChild(FPDFXRef.PDFObjectCount);

end;

{TppPDFDevice.DrawToPage

  Calls the RenderToPDF routine according to the type of draw command sent.  For
  a future release, this method will be in charge of which components are
  generated and which are not.  This will be chosen by the user. }

procedure TppPDFDevice.DrawToPage(aDrawCommand: TppDrawCommand);
var
  lRenderer: TppPDFRenderer;
begin

  if not (aDrawCommand is TppOutlineDrawCommand) then
  begin
    lRenderer := FPDFRendererManager.GetRendererForDrawCommand(aDrawCommand);

    if (lRenderer <> nil) then
    begin
      lRenderer.PDFCanvas.Clear; // do this first
      lRenderer.DrawCommand := aDrawCommand;
      lRenderer.MemoryStream := FMemoryStream;
      lRenderer.PDFSettings := FPDFSettings;
      lRenderer.PDFXRef := FPDFXRef;
      lRenderer.PageHeight := FPageHeight;
      lRenderer.Printer := FPrinter;
      lRenderer.GraphicsCanvas := FPrinterBitmap.Canvas;
      lRenderer.RenderToPDF;
    end;

  end;

end;

procedure TppPDFDevice.SetPDFSettings(aPDFSettings: TppPDFSettings);
begin
  FPDFSettings.Assign(aPDFSettings);

  FAddFileID := FPDFSettings.UniqueFile;
  FAddDate := FPDFSettings.UniqueFile;

end;

{VIASOFT - LEANDRO BONATO - 19/08/2021 - TECD-356}
procedure TppPDFDevice.AssinarPDF(AReport: TppReport; AFileCertificadoDigital: String = '';
  ASenhaCertificadoDigital: String = '');
begin
  if ((AReport.PDFSettings.DigitalSignatureSettings.SignPDF) and (AReport.FileDevice is TppPDFDevice)) then
  begin
    if ((Trim(AFileCertificadoDigital) = '') or (Trim(ASenhaCertificadoDigital) = '')) then
    begin
      FormCertificadoDigital := TFormCertificadoDigital.Create(Application);
      try
        FormCertificadoDigital.ArquivoCertificadoDigital := AFileCertificadoDigital;
        FormCertificadoDigital.SenhaCertificadoDigital := ASenhaCertificadoDigital;
        FormCertificadoDigital.ShowModal;
        if FormCertificadoDigital.ResultadoCertificadoDigital = mrOk then
        begin
          TppPDFDevice(AReport.FileDevice).PDFSettings.DigitalSignatureSettings.SignatureFile := FormCertificadoDigital.ArquivoCertificadoDigital;
          TppPDFDevice(AReport.FileDevice).PDFSignatureCompleteFilename := FormCertificadoDigital.ArquivoCertificadoDigital;
          TppPDFDevice(AReport.FileDevice).PDFSignaturePassword := FormCertificadoDigital.SenhaCertificadoDigital;
        end
        else
          CancelJob;
      finally
        FreeAndNil(FormCertificadoDigital);
      end;
    end
    else
    begin
      TppPDFDevice(AReport.FileDevice).PDFSignatureCompleteFilename := AFileCertificadoDigital;
      TppPDFDevice(AReport.FileDevice).PDFSignaturePassword := ASenhaCertificadoDigital;
    end;
  end;
end;

procedure TppPDFDevice.setPDFSignatureCompleteFilename(const AValue: string);
var
  vReport: TppReport;
begin
  vReport := GetReport;
  if Assigned(vReport) then
    vReport.PDFSettings.DigitalSignatureSettings.SignatureFile := AValue;
end;

function TppPDFDevice.GetReport: TppReport;
begin
  Result := nil;
  if UpperCase(Self.Owner.ClassName) = 'TPPREPORT' then
    Result := TppReport(Self.Owner);
  if not assigned(Result) then
    Result := nil;
  if not ((Result.FileDevice is TppPDFDevice) and (Result.PDFSettings.DigitalSignatureSettings.SignPDF)) then
    result := nil;
end;

procedure TppPDFDevice.setPDFSignaturePassword(const AValue: string);
var
  vReport: TppReport;
begin
  vReport := GetReport;
  if Assigned(vReport) then
  begin
    PDFSettings.DigitalSignatureSettings.Password := AValue;
    if Trim(AValue) = '' then
    begin
      BResp.RespOkDetalheErro(rsAssinaturaDigital, format(rsSenhaCertificadoDigitalNaoInformado, [Format(rsSenhaNaoInformada, [rsSenha]), rsSenhaEmBrancoNAceita]), rsDetalheTecnico, Format(rsDetalheTecnicoSenhaCertificadoDigitalNaoInformado, [rsAssinaturaDigitalMarcado, rsDocumentacaoTecnica]), false, cUrlDocumentacaoTecnicaAssinaturaDigital);
      vReport.FileDevice.Destroy;
      raise Exception.Create('Operação cancelada!');
    end;
    if Trim(vReport.PDFSettings.DigitalSignatureSettings.SignatureFile) = '' then
    begin
      BResp.RespOkDetalheErro(rsAssinaturaDigital, rsArquivoAssinaturaDigitalNaoInformado, rsDetalheTecnico, format(rsDetalheTecnicoAssinaturaDigitalNaoInformado, [rsAssinaturaDigitalMarcado, rsDocumentacaoTecnica]), false, cUrlDocumentacaoTecnicaAssinaturaDigital);
      vReport.FileDevice.Destroy;
      raise Exception.Create('Operação cancelada!');
    end;
    if not FileExists(Trim(vReport.PDFSettings.DigitalSignatureSettings.SignatureFile)) then
    begin
      BResp.RespOkDetalheErro(rsAssinaturaDigital, StringReplace(rsArquivoNEncont, ':', '. ', [rfReplaceAll]), rsDetalheTecnico, format(rsArquivoAssinaturaDigitalNaoEncontrado, [vReport.PDFSettings.DigitalSignatureSettings.SignatureFile, rsDocumentacaoTecnica]), false, cUrlDocumentacaoTecnicaAssinaturaDigital);
      vReport.FileDevice.Destroy;
      raise Exception.Create('Operação cancelada!');
    end;
    if ((ExtractFileExt(Trim(vReport.PDFSettings.DigitalSignatureSettings.SignatureFile)) <> '.pfx') and (ExtractFileExt(Trim(vReport.PDFSettings.DigitalSignatureSettings.SignatureFile)) <> '.p12')) then
    begin
      BResp.RespOkDetalheErro(rsAssinaturaDigital, StringReplace(rsFormatoInvdeArquivodp, ':', '. ', [rfReplaceAll]), rsDetalheTecnico, format(rsArquivoAssinaturaDigitalFormatoInvalido, [ExtractFileExt(Trim(vReport.PDFSettings.DigitalSignatureSettings.SignatureFile)), rsDocumentacaoTecnica]), false, cUrlDocumentacaoTecnicaAssinaturaDigital);
      vReport.FileDevice.Destroy;
      raise Exception.Create('Operação cancelada!');
    end;
  end;
end;

function TppPDFDevice.GetOpenFile: Boolean;
begin
  Result := inherited GetOpenFile or ((PDFSettings <> nil) and (PDFSettings.OpenPDFFile));

end;

function TppPDFDevice.GetPrinterSetup: TppPrinterSetup;
begin
  Result := FPrinter.PrinterSetup;

end;

function TppPDFDevice.IncludeNames: Boolean;
begin

  Result := False;

  if PDFSettings.PDFAFormat = pafPDFA1 then
    Exit;

  Result := ValidateAttachments;

  //Possible Future feature: Multiple JS functions
  //if not(Result) then
  //  Result := PDFSettings.JavaScript.Count > 0;


end;

function TppPDFDevice.ValidateAttachments: Boolean;
var
  liIndex: Integer;
begin

  for liIndex := PDFSettings.Attachments.Count - 1 downto 0 do
  begin
    if not (FileExists(PDFSettings.Attachments[liIndex])) and not (FileExists(PDFSettings.Attachments.Names[liIndex])) and not ((PDFSettings.Attachments.Objects[liIndex] <> nil) and (PDFSettings.Attachments.Objects[liIndex] is TStream)) then
      PDFSettings.Attachments.Delete(liIndex);
  end;

  Result := PDFSettings.Attachments.Count > 0;

end;

procedure TppPDFDevice.SetPrinterSetup(aPrinterSetup: TppPrinterSetup);
begin
  FPrinter.PrinterSetup := aPrinterSetup;

end;

initialization
  ppRegisterDevice(TppPDFDevice);

finalization
  ppUnRegisterDevice(TppPDFDevice);

end.


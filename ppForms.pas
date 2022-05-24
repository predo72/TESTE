{ RRRRRR                  ReportBuilder Class Library                  BBBBB
  RR   RR                                                              BB   BB
  RRRRRR                 Digital Metaphors Corporation                 BB BB
  RR  RR                                                               BB   BB
  RR   RR                   Copyright (c) 1996-2020                    BBBBB   }

unit ppForms;

interface

{$I ppIfDef.pas}

uses
{$IFDEF MSWINDOWS}
  Windows,    // Winapi.Windows
  Messages,   // Winapi.Messages
{$ENDIF}
{$IFDEF Delphi16}
  UITypes,   // System.UITypes (included for inline expansion)
{$ENDIF}
  Classes,
  Controls,
  ExtCtrls,
  Forms,
  Dialogs,
  Graphics,
  StdCtrls,
  ComCtrls,
  Menus,

  ppTypes,
  ppIniStorage,
  ppEmailSettings,
  ppPDFSettings,
  ppRTFSettings,
  ppXLSSettings
{$IFDEF CloudSC}
  , ppCloudDriveSettings
   //,ppCloudDriveCustom
{$ENDIF};

type
{$IFDEF MSWINDOWS}
  {@TppUpDown }
  TppUpDown = class(TUpDown)
    private
      FCanvas: TControlCanvas;
      FBuddy: TControl;

{$IFNDEF Delphi26}
      function GetCurrentPPI: Integer;
{$ENDIF}
      procedure WMPaint(var Message: TWMPaint); message WM_PAINT;

      procedure SetBuddy(aBuddy: TControl);
    protected
      procedure Paint;
    public
     constructor Create(aOwner: TComponent); override;
     constructor CreateForControl(aControl: TControl); virtual;
     destructor Destroy; override;

     property Buddy: TControl read FBuddy write SetBuddy;
{$IFNDEF Delphi26}
      property CurrentPPI: Integer read GetCurrentPPI;
{$ENDIF}
  end; {class, TppUpDown}

{$ENDIF}

  {@TppForm

    TppForm is an abstract ancestor class for the replaceable dialogs in
    ReportBuilder.}

  {@TppForm.CurrentPixelsPerInch
    Current pixels per inch for the monitor (latest Delphi) or screen (old Delphi.)}

  {@TppForm.LanguageIndex

    Base number to be used when loading strings from the resource file or DLL.
    Setting this property causes the LanguageChanged method to fire, at which
    point all of the strings of the form are reloaded.}

  {@TppForm.ppOnActivate

    This event is equivalent to the OnActivate event of a TForm.  It allows
    ReportBuilder components to connect to this event without disturbing any
    event handler which might be assigned to the OnActivate event of the form.}

  {@TppForm.ppOnClose

    This event is equivalent to the OnClose event of a TForm.  It allows
    ReportBuilder components to connect to this event without disturbing any
    event handler which might be assigned to the OnClose event of the form.}

 {@TppForm.ppOnDestroy

    This event is equivalent to the OnDestroy event of a TForm.  It allows
    ReportBuilder components to connect to this event without disturbing any
    event handler which might be assigned to the OnDestroy event of the form.}

  {@TppForm.Report

    The report component to which the dialog is assigned.  The form usually
    typecasts this property as a TppReport or TppCustomReport and then retrieves
    necessary property value settings from the report.}

  TppForm = class(TForm)
  private
    FppOnActivate: TNotifyEvent;
    FppOnCancel: TNotifyEvent;
    FppOnClose: TNotifyEvent;
    FppOnDestroy: TNotifyEvent;
    FLanguageIndex: Longint;
    FReport: TComponent;
    FTimer: TTimer;
{$IFNDEF Delphi26}
    function GetCurrentPPI: Integer;
{$ENDIF}
    procedure SetLanguageIndex(Value: Longint);
    procedure SetReport(aReport: TComponent);

  protected
{$IFDEF MSWINDOWS}
    procedure WMClose(var Message: TMessage); message WM_CLOSE;
{$ENDIF}

    procedure Activate; override;
    procedure CalcScreenCenter(var aLeft, aTop: Integer);
    procedure CreateParams(var Params: TCreateParams); override;
    procedure DoOnCancel; virtual;
    procedure ehTimer_Notify(Sender: TObject);
    procedure LanguageChanged; virtual;
    procedure ReportAssigned; virtual;
    function ScaleFromDPI(aValue: Integer): Integer;
    function ScaleToDPI(aValue: Integer): Integer; overload;
    procedure ScaleToDPI(aControl: TControl); overload;

    procedure ExitActiveControl;
    procedure InternalScaleControlsForDpi(NewPPI: Integer); virtual;
    procedure LoadWindowBounds(aName: String);
    procedure SaveWindowBounds(aName: String);
    procedure WarningDlg(aMessge: String);

  public
    constructor Create(aOwner: TComponent); override;
    destructor  Destroy; override;

    function CloseQuery: Boolean; override;
    function ShowModal: Integer; override;

    function FromMMThousandths(Value: Longint; aUnits: TppUnitType; aResolution: TppResolutionType; aPrinter: TObject): Single;
    function ToMMThousandths(Value: Single; aUnits: TppUnitType; aResolution: TppResolutionType; aPrinter: TObject): Longint;

    function MulDiv(const aValue, aNumerator, aDenominator: Integer): Integer;
{$IFDEF Delphi24}
    procedure ScaleControlsForDpi(NewPPI: Integer); override;
{$ENDIF}

{$IFNDEF Delphi26}
    property CurrentPPI: Integer read GetCurrentPPI;
{$ENDIF}
    property LanguageIndex: Longint read FLanguageIndex write SetLanguageIndex;
    property Report: TComponent read FReport write SetReport;

    {events - used internally by TppReport }
    property ppOnActivate: TNotifyEvent read FppOnActivate write FppOnActivate;
    property ppOnCancel: TNotifyEvent read FppOnCancel write FppOnCancel;
    property ppOnClose: TNotifyEvent read FppOnClose write FppOnClose;
    property ppOnDestroy: TNotifyEvent read FppOnDestroy write FppOnDestroy;

  end; {class, TppForm}

  {@TppCustomPreviewer }
  TppCustomPreviewer = class(TppForm)
    private
      FDisplayDocumentName: Boolean;
      FSaveWindowPlacement: Boolean;


    protected
      procedure DoShow; override;
      function GetViewer: TObject; virtual;

    public
      constructor Create(aOwner: TComponent); override;
      destructor Destroy; override;
      procedure Init; virtual;

      property DisplayDocumentName: Boolean read FDisplayDocumentName write FDisplayDocumentName;

    published
      property SaveWindowPlacement: Boolean read FSaveWindowPlacement write FSaveWindowPlacement;
      property Viewer: TObject read GetViewer;

  end; {class, TppCustomPreviewer}


 {@TppCustomAutoSearchDialog

    This class contains the API used by the report component when it is handling
    AutoSearch dialogs.  If ShowAutoSearchDialog is True, the report component
    retrieves the currently registered AutoSearch dialog class and creates an
    instance of it.  The report then fires the OnAutoSearchDialogCreate event.
    The Init method is then called and it is expected that the search controls
    which will represent the AutoSearchFields of the report will be created at
    this point.  Finally, the report will call the ShowModal event of the form.}

 {@TppCustomAutoSearchDialog.AutoSearchGroups

   Provides access to the AutoSearchFields associated with the report component.
   It is assigned after the OnAutoSearchDialogCreate event has fired so that
   any changes made to the AutoSearchFields in the handler for this event are
   reflected in the AutoSearchDialog.}

  {@TppCustomAutoSearchDialog.Init

    This procedure is a called after OnAutoSearchDialogCreate has fired.  In
    this procedure the AutoSearchDialog creates the AutoSearchNotebook and adds
    all of the AutoSearchFields from the report to it. }


  TppCustomAutoSearchDialog = class(TppForm)
    protected
      function GetAutosearchGroups: TPersistent; virtual; abstract;
      procedure SetAutosearchGroups(aAutosearchGroups: TPersistent); virtual; abstract;

    public
      procedure Init; virtual; abstract;
      procedure AssignAutoSearchFields(aAutoSearchFields: TList); virtual; abstract;

      property AutoSearchGroups: TPersistent read GetAutoSearchGroups write SetAutoSearchGroups;

  end; {class, TppCustomAutoSearchDialog}

  {@TppCustomReportExplorer }
  TppCustomReportExplorer = class(TppForm)
    private
      FFormSettingsRemembered: Boolean;
      FMergeMenu: TMainMenu;

    protected
      procedure SetFormSettingsRemembered(aValue: Boolean);
      function  GetReportExplorer: TComponent; virtual; abstract;
      procedure SetReportExplorer(aComponent: TComponent); virtual; abstract;

    public
      constructor Create(aComponent: TComponent); override;

      procedure ehFilePrintClick(Sender: TObject); virtual; abstract;
      procedure ehFilePrintPreviewClick(Sender: TObject); virtual; abstract;
      procedure ehFileEmailClick(Sender: TObject); virtual; abstract;
      procedure ehFileOpenClick(Sender: TObject); virtual; abstract;
      procedure ehFileNewFolderClick(Sender: TObject); virtual; abstract;
      procedure ehFileNewReportClick(Sender: TObject); virtual; abstract;
      procedure ehFileDeleteClick(Sender: TObject); virtual; abstract;
      procedure ehFileRenameClick(Sender: TObject); virtual; abstract;
      procedure ehViewListClick(Sender: TObject); virtual; abstract;
      procedure ehViewDetailsClick(Sender: TObject); virtual; abstract;
      procedure ehViewToolbarClick(Sender: TObject); virtual; abstract;
      procedure ehViewStatusBarClick(Sender: TObject); virtual; abstract;
      procedure ehFileCloseClick(Sender: TObject); virtual; abstract;
      procedure ehHelpAboutClick(Sender: TObject); virtual; abstract;
      procedure ehHelpTopicsClick(Sender: TObject); virtual; abstract;
      procedure ehUpOneLevelClick(Sender: TObject); virtual; abstract;
      procedure ehFileDesignClick(Sender: TObject); virtual; abstract;
      procedure ehEmptyRecycleBinClick(Sender: TObject); virtual; abstract;
      procedure ehEditCopyClick(Sender: TObject); virtual; abstract;
      procedure ehEditPasteClick(Sender: TObject); virtual; abstract;
      procedure ehEditCutClick(Sender: TObject); virtual; abstract;

      procedure Initialize; virtual; abstract;
      procedure Refresh; virtual; abstract;

      property ReportExplorer: TComponent read GetReportExplorer write SetReportExplorer;

      property FormSettingsRemembered: Boolean read FFormSettingsRemembered;
      property MergeMenu: TMainMenu read FMergeMenu write FMergeMenu;
  end;

  {@TppCustomPrintDialog }
  TppCustomPrintDialog = class(TppForm)
  private
    FAllowEmail: Boolean;
    FSendEmail: Boolean;
    FAllowOpenFile: Boolean;
    FAllowPrintToArchive: Boolean;
    FAllowPrintToFile: Boolean;
    FArchiveFileName: String;
    FDefaultFileExt: String;
    FDeviceType: String;
    FDefaultFileDeviceType: String;
    FFileFilter: String;
    FTextFileName: String;
    FOpenFile: Boolean;
    FPageRequest: TObject;
    FPrinter: TObject;
    FPrinterChanged: Boolean;
    FPrintToArchive: Boolean;
    FPrintToFile: Boolean;
    FDesignState: TppDesignStates;
    FPDFSettings: TppPDFSettings;
    FRTFSettings: TppRTFSettings;
    FXLSSettings: TppXLSSettings;
    FExportFile: Boolean;
    FParentDialog: TppForm;
    FUpdatePropName: String;
    FOnChange: TNotifyEvent;

  protected
    procedure DoOnChange(aPropName: string);

    function  GetBackgroundPrintSettings: TObject; virtual; abstract;
    procedure SetPageRequest(aPageRequest: TObject); virtual;
    procedure SetPDFSettings(aPDFSettings: TppPDFSettings); virtual;
    procedure SetRTFSettings(aRTFSettings: TppRTFSettings); virtual;
    procedure SetXLSSettings(aXLSSettings: TppXLSSettings); virtual;
    procedure SetBackgroundPrintingActive(aBackgroundPrintingActive: Boolean); virtual; abstract;
    procedure SetBackgroundPrintSettings(aBackgroundPrintSettings: TObject); virtual; abstract;
    procedure SetAllowEmail(const Value: Boolean); virtual;
    procedure SetAllowOpenFile(const Value: Boolean); virtual;
    procedure SetAllowPrintToArchive(const Value: Boolean); virtual;
    procedure SetAllowPrintToFile(const Value: Boolean); virtual;
    procedure SetArchiveFileName(const Value: String); virtual;
    procedure SetDefaultFileDeviceType(const Value: String); virtual;
    procedure SetDefaultFileExt(const Value: String); virtual;
    procedure SetDeviceType(const Value: String); virtual;
    procedure SetFileFilter(const Value: String); virtual;
    procedure SetOpenFile(const Value: Boolean); virtual;
    procedure SetPrintToArchive(const Value: Boolean); virtual;
    procedure SetPrintToFile(const Value: Boolean); virtual;
    procedure SetSendEmail(const Value: Boolean); virtual;
    procedure SetTextFileName(const Value: String); virtual;
    procedure SetDesignState(const Value: TppDesignStates); virtual;

  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;

    procedure Init; virtual; abstract;
    procedure ActivateDialog; virtual;

  published
    property AllowEmail: Boolean read FAllowEmail write SetAllowEmail;
    property SendEmail: Boolean read FSendEmail write SetSendEmail;
    property AllowOpenFile: Boolean read FAllowOpenFile write SetAllowOpenFile;
    property AllowPrintToArchive: Boolean read FAllowPrintToArchive write SetAllowPrintToArchive;
    property AllowPrintToFile: Boolean read FAllowPrintToFile write SetAllowPrintToFile;
    property ArchiveFileName: String read FArchiveFileName write SetArchiveFileName;
    property DeviceType: String read FDeviceType write SetDeviceType;
    property DefaultFileDeviceType: String read FDefaultFileDeviceType write SetDefaultFileDeviceType;
    property DefaultFileExt: String read FDefaultFileExt write SetDefaultFileExt;
    property DesignState: TppDesignStates read FDesignState write SetDesignState;
    property ExportFile: Boolean read FExportFile write FExportFile;
    property BackgroundPrintSettings: TObject read GetBackgroundPrintSettings write SetBackgroundPrintSettings;
    property FileFilter: String read FFileFilter write SetFileFilter;
    property OpenFile: Boolean read FOpenFile write SetOpenFile;
    property PageRequest: TObject read FPageRequest write SetPageRequest;
    property PDFSettings: TppPDFSettings read FPDFSettings write SetPDFSettings;
    property RTFSettings: TppRTFSettings read FRTFSettings write SetRTFSettings;
    property XLSSettings: TppXLSSettings read FXLSSettings write SetXLSSettings;
    property PrinterChanged: Boolean read FPrinterChanged write FPrinterChanged;
    property Printer: TObject read FPrinter write FPrinter;
    property PrintToArchive: Boolean read FPrintToArchive write SetPrintToArchive;
    property PrintToFile: Boolean read FPrintToFile write SetPrintToFile;
    property TextFileName: String read FTextFileName write SetTextFileName;
    property ParentDialog: TppForm read FParentDialog write FParentDialog;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property UpdatePropName: String read FUpdatePropName;

  end; {class TppCustomPrintDialog}

  TppCustomExportFileDialog = class(TppForm)
  private
    FAllowEmail: Boolean;
    FSendEmail: Boolean;
    FAllowOpenFile: Boolean;
    FAllowPrintToArchive: Boolean;
    FAllowPrintToFile: Boolean;
    FArchiveFileName: String;
    FDefaultFileExt: String;
    FDeviceType: String;
    FDefaultFileDeviceType: String;
    FFileFilter: String;
    FTextFileName: String;
    FOpenFile: Boolean;
    FPageRequest: TObject;
    FPrintToArchive: Boolean;
    FPrintToFile: Boolean;
    FPDFSettings: TppPDFSettings;
    FRTFSettings: TppRTFSettings;
    FXLSSettings: TppXLSSettings;
    FParentDialog: TppForm;
    FCloudExport: Boolean;
    FDesignState: TppDesignStates;
 {$IFDEF CloudSC}
    FCloudDrive: String;
    FCloudDriveSettings: TppCloudDriveSettings;
 {$ENDIF}

  protected
    function  GetBackgroundPrintSettings: TObject; virtual; abstract;
    procedure SetBackgroundPrintSettings(aBackgroundPrintSettings: TObject); virtual; abstract;
    procedure SetBackgroundPrintingActive(aBackgroundPrintingActive: Boolean); virtual; abstract;
    procedure SetPageRequest(aPageRequest: TObject); virtual;
    procedure SetPDFSettings(aPDFSettings: TppPDFSettings); virtual;
    procedure SetRTFSettings(aRTFSettings: TppRTFSettings); virtual;
    procedure SetXLSSettings(aXLSSettings: TppXLSSettings); virtual;
 {$IFDEF CloudSC}
    procedure SetCloudDriveSettings(aCloudDriveSettings: TppCloudDriveSettings); virtual;
 {$ENDIF}

  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;

    procedure Init; virtual; abstract;
    procedure ActivateDialog; virtual;

  published
    property AllowEmail: Boolean read FAllowEmail write FAllowEmail;
    property SendEmail: Boolean read FSendEmail write FSendEmail;
    property AllowOpenFile: Boolean read FAllowOpenFile write FAllowOpenFile;
    property AllowPrintToArchive: Boolean read FAllowPrintToArchive write FAllowPrintToArchive;
    property AllowPrintToFile: Boolean read FAllowPrintToFile write FAllowPrintToFile;
    property ArchiveFileName: String read FArchiveFileName write FArchiveFileName;
    property DeviceType: String read FDeviceType write FDeviceType;
    property DefaultFileDeviceType: String read FDefaultFileDeviceType write FDefaultFileDeviceType;
    property DefaultFileExt: String read FDefaultFileExt write FDefaultFileExt;
    property DesignState: TppDesignStates read FDesignState write FDesignState;
    property BackgroundPrintSettings: TObject read GetBackgroundPrintSettings write SetBackgroundPrintSettings;
    property FileFilter: String read FFileFilter write FFileFilter;
    property OpenFile: Boolean read FOpenFile write FOpenFile;
    property PageRequest: TObject read FPageRequest write SetPageRequest;
    property PDFSettings: TppPDFSettings read FPDFSettings write SetPDFSettings;
    property RTFSettings: TppRTFSettings read FRTFSettings write SetRTFSettings;
    property XLSSettings: TppXLSSettings read FXLSSettings write SetXLSSettings;
    property PrintToArchive: Boolean read FPrintToArchive write FPrintToArchive;
    property PrintToFile: Boolean read FPrintToFile write FPrintToFile;
    property TextFileName: String read FTextFileName write FTextFileName;
    property ParentDialog: TppForm read FParentDialog write FParentDialog;
    property CloudExport: Boolean read FCloudExport write FCloudExport;
{$IFDEF CloudSC}
    property CloudDrive: String read FCloudDrive write FCloudDrive;
    property CloudDriveSettings: TppCloudDriveSettings read FCloudDriveSettings write SetCloudDriveSettings;
{$ENDIF}

  end;

  {@TppCustomOutputDialog}
  TppCustomOutputDialog = class(TppForm)
    private
      FAllowPrintToFile: Boolean;
      FAllowPrintToArchive: Boolean;
      FPrintDialog: TppCustomPrintDialog;
      FExportFileDialog: TppCustomExportFileDialog;
      FOutputType: TppReportOutputType;

    protected
      procedure SetExportFileDialog(const Value: TppCustomExportFileDialog); virtual;
      procedure SetPrintDialog(const Value: TppCustomPrintDialog); virtual;
      function  GetDeviceType: String; virtual;

    public
      constructor Create(aOwner: TComponent); override;

      procedure Init; virtual; abstract;

      procedure ehPrinterProp_Change(aSender: TObject);

      property AllowPrintToArchive: Boolean read FAllowPrintToArchive write FAllowPrintToArchive;
      property AllowPrintToFile: Boolean read FAllowPrintToFile write FAllowPrintToFile;
      property DeviceType: String read GetDeviceType;
      property PrintDialog: TppCustomPrintDialog read FPrintDialog write SetPrintDialog;
      property ExportFileDialog: TppCustomExportFileDialog read FExportFileDialog write SetExportFileDialog;
      property OutputType: TppReportOutputType read FOutputType write FOutputType;

  end;

  {@TppCustomCancelDialog }
  TppCustomCancelDialog = class(TppForm)
  private
    FActiveForm: TForm;
    FAllowPrintCancel: Boolean;
    FModal: Boolean;
    FPrintProgress: String;
    FTimer: TTimer;
    FppOnShowModal: TNotifyEvent;

    procedure FormHideEvent;
    procedure FormShowEvent;
    procedure SetPrintProgress(Value: String);
    procedure TimerEvent(Sender: TObject);

  protected
{$IFDEF MSWINDOWS}
    procedure WMShowWindow(var Message: TMessage); message WM_SHOWWINDOW;
{$ENDIF}

    procedure PrintProgressChanged; virtual;

  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;

    procedure ppShowModal;

    property AllowPrintCancel: Boolean read FAllowPrintCancel write FAllowPrintCancel;
    property PrintProgress: String read FPrintProgress write SetPrintProgress;

    {event used internally by Report}
    property ppOnShowModal: TNotifyEvent read FppOnShowModal write FppOnShowModal;

  end; {class, TppCustomCancelDialog}


  {@TppCustomNoDataDialog }
  TppCustomNoDataDialog = class(TppForm)

  end; {class, TppCustomNoDataDialog}


  {@TppCustomAboutDialog }
  TppCustomAboutDialog = class(TppForm)
  end; {class, TppCustomAboutDialog}


  {@TppCustomDemoDialog }
  TppCustomDemoDialog = class(TppForm)
  private

  end; {class, TppCustomDemoDialog}


  {@TppCustomTemplateDialog }
  TppCustomTemplateDialog = class(TppForm)
  private
    FDataPipeline: TComponent;
    FDialogType: TppDialogType;
    FFolderId: Integer;
    FItemType: Integer;
    FNameField: String;
    FOnHelpClick: TNotifyEvent;

  protected
    procedure DoOnHelpClick;
    function  GetTemplateName: String; virtual; abstract;
    function  GetTemplateNames: TStrings; virtual; abstract;
    function  HelpEventAssigned: Boolean;
    procedure SetDataPipeline(aComponent: TComponent); virtual;
    procedure SetTemplateName(aTemplateName: String); virtual; abstract;
    procedure SetTemplateNames(aTemplateNames: TStrings); virtual; abstract;

  public
    property DataPipeline: TComponent read FDataPipeline write SetDataPipeline;
    property DialogType: TppDialogType read FDialogType write FDialogType;
    property ItemType: Integer read FItemType write FItemType;
    property NameField: String read FNameField write FNameField;
    property OnHelpClick: TNotifyEvent read FOnHelpClick write FOnHelpClick;
    property FolderId: Integer read FFolderId write FFolderId;
    property TemplateName: String read GetTemplateName write SetTemplateName;
    property TemplateNames: TStrings read GetTemplateNames write SetTemplateNames;

  end; {class, TppCustomTemplateDialog}


  {@TppCustomTemplateErrorDialog }
  TppCustomTemplateErrorDialog = class(TppForm)
  private

  protected
    function  GetErrorMessage: String; virtual; abstract;
    procedure SetErrorMessage(aMessage: String); virtual; abstract;

  public
    property ErrorMessage: String read GetErrorMessage write SetErrorMessage;

  end; {class, TppCustomTemplateErrorDialog}

  TppCustomEmailDialog = class(TppForm)
  private
    FEmailSettings: TppEmailSettings;

  protected
    procedure SetEmailSettings(const Value: TppEmailSettings); virtual;

  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;

    procedure Init; virtual; abstract;
    property EmailSettings: TppEmailSettings read FEmailSettings write SetEmailSettings;

  end;

{$IFDEF CloudSC}
  TppCustomCloudAuthDialog = class(TppForm)
  private
    FHelpMessage: String;
  protected
  public
    procedure Init; virtual; abstract;

    property HelpMessage: String read FHelpMessage write FHelpMessage;
  end;

  TppCustomCloudExplorerDialog = class(TppForm)
  private
    FCloudDirectory: String;
    FCloudDrive: TObject;//TppCloudDriveCustom;

  protected
    procedure SetCloudDirectory(const Value: String); virtual;
    procedure SetCloudDrive(const Value: TObject{TppCloudDriveCustom}); virtual;

  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;

    procedure Init; virtual; abstract;

    property CloudDirectory: String read FCloudDirectory write SetCloudDirectory;
    property CloudDrive: TObject{TppCloudDriveCustom} read FCloudDrive write SetCloudDrive;
  end;

{$ENDIF}

  {TppFormState

    Utility class to Load/Save Form location and size to ini.

    Call LoadWindowPlacement from Form Show

    Call SaveWindowPlacement from Form Destroy
    }
  TppFormState = class
  public
    class procedure LoadWindowPlacement(aForm: TForm; aName: String);
    class procedure SaveWindowPlacement(aForm: TForm; aName: String);
  end;


  {register procedures}
  function  ppFormClassList: TStringList;
  function  ppGetFormClass(aAncestorClass: TFormClass): TFormClass;
  procedure ppRegisterForm(aAncestorClass, aDescendantClass: TFormClass);
  procedure ppUnRegisterForm(aAncestorClass: TFormClass);

implementation

uses
  SysUtils,
  ppUtils,
  ppRTTI
{$IFDEF CloudSC}
  ,ppCloudDriveInterfaces
{$ENDIF};

var
  FFormClassList: TStringList = nil;

{$IFDEF MSWINDOWS}
{******************************************************************************
 *
 ** T p p U p D o w n
 *
{******************************************************************************}

{------------------------------------------------------------------------------}
{ TppUpDown.Create }

constructor TppUpDown.Create(aOwner: TComponent);
begin

  inherited Create(aOwner);

  Min := -100;

  {create a canvas}
  FCanvas := TControlCanvas.Create;
  TControlCanvas(FCanvas).Control := Self;

end; {constructor, Create}

{------------------------------------------------------------------------------}
{ TppUpDown.Destroy }

destructor TppUpDown.Destroy;
begin

  FCanvas.Free;
  
  inherited Destroy;

end; {destructor, Destroy}


{------------------------------------------------------------------------------}
{ TppUpDown.CreateForControl }

constructor TppUpDown.CreateForControl(aControl: TControl);
begin

  Create(aControl.Owner);

  Parent := aControl.Parent;
  SetBuddy(aControl);

end; {constructor, CreateWithBuddy}

{$IFNDEF Delphi26}
function TppUpDown.GetCurrentPPI: Integer;
begin
  Result := ppUtils.GetCurrentPPIForControl(Self);
end;
{$ENDIF}

{------------------------------------------------------------------------------}
{ TppUpDown.SetBuddy }

procedure TppUpDown.SetBuddy(aBuddy: TControl);
begin
  FBuddy := aBuddy;

  Left   := FBuddy.left + FBuddy.Width - Width - ppScaleToDPI(2, CurrentPPI);
  Top    := FBuddy.Top + ppScaleToDPI(2, CurrentPPI);
  Height := FBuddy.Height - ppScaleToDPI(4, CurrentPPI);;

end; {procdure, SetBuddy}

{------------------------------------------------------------------------------}
{ TppUpDown.WMPaint }

procedure TppUpDown.WMPaint(var Message: TWMPaint);
begin

  inherited;


  Height := FBuddy.Height - ppScaleToDPI(4, CurrentPPI); // work around for timing issue

  // do custom painting when not running on XP
  // (when using XPMan, the extra painting is not needed and looks bad)
  if not(ppIsWinXP)then
    Paint;

end; {procedure, WMPaint}

{------------------------------------------------------------------------------}
{ TppUpDown.Paint }

procedure TppUpDown.Paint;
var
  liCenter: Integer;
  liStartY: Integer;
  liCount: Integer;

begin

  FCanvas.Pen.Color := clBlack;

  liCenter := (Width div 2) - ppScaleToDPI(1, CurrentPPI);

  liStartY := ppScaleToDPI(2, CurrentPPI);

  {draw top arrow}
  for liCount := 0 to 2 do
    begin
      FCanvas.MoveTo(liCenter - liCount,   liStartY + liCount);
      FCanvas.LineTo(liCenter + liCount+1, liStartY + liCount);
    end;

  liStartY := Height - 3;

  {draw bottom arrow}
  for liCount := 0 to 2 do
    begin
      FCanvas.MoveTo(liCenter - liCount,   liStartY - liCount);
      FCanvas.LineTo(liCenter + liCount+1, liStartY - liCount);
    end;


end; {procedure, Paint}

{$ENDIF}

{******************************************************************************
 *
 ** F O R M
 *
{******************************************************************************}

{------------------------------------------------------------------------------}
{ TppForm.Create }

constructor TppForm.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);

  FppOnActivate  := nil;
  FppOnCancel    := nil;
  FppOnClose     := nil;
  FppOnDestroy   := nil;
  FLanguageIndex := 0;
  FReport        := nil;

//  Font.Height := Graphics.DefFontData.Height;

end; {constructor, Create}


{------------------------------------------------------------------------------}
{ TppForm.Destroy }

destructor TppForm.Destroy;
begin

  if Assigned(FppOnDestroy) then FppOnDestroy(Self);

  FTimer.Free;
  FTimer := nil;

  inherited Destroy;

end; {destructor, Destroy}

{------------------------------------------------------------------------------}
{@TppForm.CloseQuery

  Fires when the form begins to close, but before the form has been destroyed.
  Overriding this methods is superior to coding a WMClose, which doesn't get
  called when the Close box is clicked or triggering the OnClose from
  the destroy method , which is too late to access any of the form's internals
  and makes the event far less useful.}

 function TppForm.CloseQuery: Boolean;
begin

  try
    if Assigned(FppOnClose) then FppOnClose(Self);
  except on E: Exception do
    Application.HandleException(Self);
  end;

  Result := inherited CloseQuery;

end;

{------------------------------------------------------------------------------}
{ TppForm.Activate }

procedure TppForm.Activate;
begin

  inherited Activate;

  if Assigned(FppOnActivate) and (FTimer = nil) then
    begin
      FTimer := TTimer.Create(nil);
      FTimer.Interval := 10;
      FTimer.Enabled := True;
      FTimer.OnTimer := ehTimer_Notify;
    end;
  BringToFront;
end;


{------------------------------------------------------------------------------}
{ TppForm.ehTimer_Notify}

procedure TppForm.ehTimer_Notify(Sender: TObject);
begin

  FTimer.Free;
  FTimer := nil;

  {this allows a modal previewer to continue the report}
  if Assigned(FppOnActivate) then FppOnActivate(Self);

end;

 
{------------------------------------------------------------------------------}
{ TppForm.CalcScreenCenter}

procedure TppForm.CalcScreenCenter(var aLeft, aTop: Integer);
begin

  aLeft := Trunc((Screen.Width / 2) - (Width / 2));
  aTop := Trunc((Screen.Height / 2) - (Height / 2));

end; {procedure, CalcScreenCenter}

{------------------------------------------------------------------------------}
{ TppForm.CreateParams}

procedure TppForm.CreateParams(var Params: TCreateParams);
begin

  inherited CreateParams(Params);

{$IFDEF Delphi9}
  // nothing
{$ELSE}
  if (fsModal in FormState) then
    if (Screen.ActiveForm <> nil) and Screen.ActiveForm.HandleAllocated
                                  and not(csDestroying in Screen.ActiveForm.ComponentState) then
      Params.WndParent := Screen.ActiveForm.Handle;
{$ENDIF}

end; {procedure, CreateParams}

{------------------------------------------------------------------------------}
{ TppForm.WMClose }

{$IFDEF MSWINDOWS}
procedure TppForm.WMClose(var Message: TMessage);
begin

  {note: WMClose never fires when the Close button of the form is pressed
         so this code is useless}
  {if Assigned(FppOnClose) then FppOnClose(Self);}

  inherited;

end;
{$ENDIF}

{------------------------------------------------------------------------------}
{ TppForm.SetLanguageIndex }

function TppForm.ScaleToDPI(aValue: Integer): Integer;
begin

  if (CurrentPPI = 96) then
    Result := aValue
  else
    Result := Round(aValue * CurrentPPI  / 96);

end;

type
  TControlAccess = class(TControl);

procedure TppForm.ScaleToDPI(aControl: TControl);
begin

  if (CurrentPPI <> PixelsPerInch) then
    TControlAccess(aControl).ChangeScale(CurrentPPI, 96);

end;

procedure TppForm.SetLanguageIndex(Value: Longint);
begin
  FLanguageIndex := Value;

  LanguageChanged;
end;

{------------------------------------------------------------------------------}
{ TppForm.LanguageChanged }

procedure TppForm.LanguageChanged;
begin

end;

function TppForm.ShowModal: Integer;
begin

{$IFDEF Delphi9}
  if (PopupParent = nil) then
    PopupParent := Screen.ActiveForm;
{$ELSE}
  if HandleAllocated then
    RecreateWnd;
{$ENDIF}

  Result := inherited ShowModal;

end;

{------------------------------------------------------------------------------}
{ TppForm.SetReport }

procedure TppForm.SetReport(aReport: TComponent);
begin
  FReport := aReport;
  ReportAssigned;
end;

{------------------------------------------------------------------------------}
{ TppForm.ReportAssigned }

procedure TppForm.ReportAssigned;
begin

end;

{------------------------------------------------------------------------------}
{ TppForm.WarningDlg }

procedure TppForm.WarningDlg(aMessge: String);
begin
  {set ModalResult to none, because when the Default button of a dialog
   is activated by the keyboard and an error occurrs we do not want to
   close the dialog}
  ModalResult := mrNone;
  MessageDlg(aMessge, mtWarning, [mbOK], 0);

end; {procedure, WarningDlg}

{------------------------------------------------------------------------------}
{ TppForm.ExitActiveControl }

procedure TppForm.ExitActiveControl;
begin
  {note: this method can be called from the close button of the dialog;
         when the close button is the default button the OnExit event of
         an active TEdit will not fire when the default button is activated
         by the keyboard }
  
  {if ActiveControl is an Edit box, fire the OnExit event}
  if (ActiveControl is TEdit) and Assigned(TEdit(ActiveControl).OnExit) then
    TEdit(ActiveControl).OnExit(ActiveControl);

end;

{------------------------------------------------------------------------------}
{ TppForm.DoOnCancel }

procedure TppForm.DoOnCancel;
begin
  if Assigned(FppOnCancel) then FppOnCancel(Self);
end; {procedure, DoOnCancel}

{------------------------------------------------------------------------------}
{ TppForm.FromMMThousandths }

function TppForm.FromMMThousandths(Value: Longint; aUnits: TppUnitType; aResolution: TppResolutionType; aPrinter: TObject): Single;
begin

  case aUnits of
    utScreenPixels:
      Result := ppFromMMThousandths(Value, aUnits, CurrentPPI);
    utPrinterPixels:
      Result := ppFromMMThousandths(Value, aUnits, aResolution, aPrinter);
    else
      Result := ppFromMMThousandths(Value, aUnits, aResolution, nil);
  end;

end;


{$IFNDEF Delphi26}
function TppForm.GetCurrentPPI: Integer;
begin
  Result := ppUtils.GetCurrentPPIForControl(Self);
end;
{$ENDIF}

{$IFDEF Delphi24}
procedure TppForm.ScaleControlsForDpi(NewPPI: Integer);
begin
  inherited;

  InternalScaleControlsForDpi(NewPPI);

end;
{$ENDIF}


procedure TppForm.InternalScaleControlsForDpi(NewPPI: Integer);
begin
  // descendants add custom Dpi scaling here
end;

procedure TppForm.LoadWindowBounds(aName: String);
var
  lIniStorage: TppIniStorage;
  liLeft: Integer;
  liTop: Integer;
  liWidth: Integer;
  liHeight: Integer;
  lWorkAreRect: TRect;
begin

  lWorkAreRect := Screen.ActiveForm.Monitor.WorkareaRect;

  lIniStorage := TppIniStoragePlugin.CreateInstance;

  try
    liLeft := lIniStorage.ReadInteger(aName, 'FormLeft', Left);
    liTop := lIniStorage.ReadInteger(aName, 'FormTop', Top);
    liWidth := lIniStorage.ReadInteger(aName, 'FormWidth', Width);
    liHeight := lIniStorage.ReadInteger(aName, 'FormHeight', Height);

    liLeft :=  ScaleToDPI(liLeft) + lWorkAreRect.Left;
    liTop := ScaleToDPI(liTop) + lWorkAreRect.Top;
    liWidth := ScaleToDPI(liWidth);;
    liHeight := ScaleToDPI(liHeight);

    SetBounds(liLeft, liTop, liWidth, liHeight);

  finally
    lIniStorage.Free;
  end;


end;

function TppForm.MulDiv(const aValue, aNumerator, aDenominator: Integer): Integer;
begin

  if (aDenominator <> 0) then
    Result := Round(aValue * aNumerator / aDenominator)
  else
    Result := aValue;

end;

procedure TppForm.SaveWindowBounds(aName: String);
var
  liLeft: Integer;
  liTop: Integer;
  liWidth: Integer;
  liHeight: Integer;
  lIniStorage: TppIniStorage;
  lWorkAreRect: TRect;
begin

  lWorkAreRect := Monitor.WorkareaRect;

  // normalize to 96 dpi
  liLeft := ScaleFromDPI(Left - lWorkAreRect.Left);
  liTop := ScaleFromDPI(Top - lWorkAreRect.Top);
  liWidth := ScaleFromDPI(Width);
  liHeight := ScaleFromDPI(Height);

  lIniStorage := TppIniStoragePlugIn.CreateInstance;

  try
    lIniStorage.WriteInteger(aName, 'FormLeft', liLeft);
    lIniStorage.WriteInteger(aName, 'FormTop', liTop);
    lIniStorage.WriteInteger(aName, 'FormWidth', liWidth);
    lIniStorage.WriteInteger(aName, 'FormHeight', liHeight);

  finally
    lIniStorage.Free;

  end;

end;

{------------------------------------------------------------------------------}
{ TppForm.ScaleFromDPI }

function TppForm.ScaleFromDPI(aValue: Integer): Integer;
begin

  if (CurrentPPI = 96) then
    Result := aValue
  else
    Result := Round(aValue * 96 / CurrentPPI);

end;

{------------------------------------------------------------------------------}
{ TppForm.ToMMThousandths }

function TppForm.ToMMThousandths(Value: Single; aUnits: TppUnitType; aResolution: TppResolutionType; aPrinter: TObject): Longint;
begin

  case aUnits of
    utScreenPixels:
      Result := ppToMMThousandths(Value, aUnits, CurrentPPI);
    utPrinterPixels:
      Result := ppToMMThousandths(Value, aUnits, aResolution, aPrinter);
    else
      Result := ppToMMThousandths(Value, aUnits, aResolution, nil);
  end;

end;




{******************************************************************************
 *
 ** C U S T O M   R E P O R T   E X P L O R E R
 *
{******************************************************************************}

{------------------------------------------------------------------------------}
{ TppCustomReportExplorer.Create }

constructor TppCustomReportExplorer.Create(aComponent: TComponent);
begin

  inherited Create(aComponent);

  FFormSettingsRemembered := False;

end; {constructor, Create}

{------------------------------------------------------------------------------}
{ TppCustomReportExplorer.SetFormSettingsRemembered }

procedure TppCustomReportExplorer.SetFormSettingsRemembered(aValue: Boolean);
begin

  FFormSettingsRemembered := aValue;

end; {constructor, SetFormSettingsRemembered}


{******************************************************************************
 *
 ** P R I N T   P R E V I E W
 *
{******************************************************************************}

{------------------------------------------------------------------------------}
{ TppCustomPreviewer.Create }

constructor TppCustomPreviewer.Create(aOwner: TComponent);
begin

  inherited Create(aOwner);

  Position := poDesigned;
  FDisplayDocumentName := False;
  FSaveWindowPlacement := True;

end; {constructor, Create}

destructor TppCustomPreviewer.Destroy;
begin

  if FSaveWindowPlacement then
  TppFormState.SaveWindowPlacement(Self, 'PreviewForm');

  inherited;

end;

procedure TppCustomPreviewer.DoShow;
begin

  inherited;

  if FSaveWindowPlacement then
   TppFormState.LoadWindowPlacement(Self, 'PreviewForm');

end;

{------------------------------------------------------------------------------}
{ TppCustomPreviewer.GetViewer }

function TppCustomPreviewer.GetViewer: TObject;
begin
  Result := nil;
end; {function, GetViewer}

{------------------------------------------------------------------------------}
{ TppCustomPreviewer.Init }

procedure TppCustomPreviewer.Init;
begin

end; {procedure, Init}

{******************************************************************************
 *
 ** P R I N T   D I A L O G
 *
{******************************************************************************}

{------------------------------------------------------------------------------}
{ TppCustomPrintDialog.Create }

constructor TppCustomPrintDialog.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);

  FAllowEmail := False;
  FSendEmail := True;
  FAllowOpenFile := True;
  FAllowPrintToArchive := False;
  FAllowPrintToFile := False;
  FArchiveFileName  := '';
  FDesignState := [];
  FDeviceType       := '';
  FDefaultFileDeviceType := '';
  FPrinterChanged   := False;
  FPrintToArchive   := False;
  FPrintToFile      := False;
  FPrinter          := nil;
  FTextFileName     := '';
  FExportFile       := False;
  FPDFSettings      := TppPDFSettings.Create;
  FRTFSettings      := TppRTFSettings.Create;
  FXLSSettings      := TppXLSSettings.Create;
  FParentDialog     := nil;

end; {constructor, Create}
    
{------------------------------------------------------------------------------}
{ TppCustomPrintDialog.Destroy }

destructor TppCustomPrintDialog.Destroy;
begin

  inherited Destroy;

  FPDFSettings.Free;
  FPDFSettings := nil;

  FRTFSettings.Free;
  FRTFSettings := nil;

  FXLSSettings.Free;
  FXLSSettings := nil;

end; {destructor, Destroy}

procedure TppCustomPrintDialog.DoOnChange(aPropName: string);
begin
  FUpdatePropName := aPropName;
  if Assigned(FOnChange) then FOnChange(Self);

end;

procedure TppCustomPrintDialog.ActivateDialog;
begin
  //Override and place activation code here if embedding form
end;

procedure TppCustomPrintDialog.SetAllowEmail(const Value: Boolean);
begin
  DoOnChange('AllowEmail');
  FAllowEmail := Value;
end;

procedure TppCustomPrintDialog.SetAllowOpenFile(const Value: Boolean);
begin
  DoOnChange('AllowOpenFile');
  FAllowOpenFile := Value;
end;

procedure TppCustomPrintDialog.SetAllowPrintToArchive(const Value: Boolean);
begin
  DoOnChange('AllowPrintToArchive');
  FAllowPrintToArchive := Value;
end;

procedure TppCustomPrintDialog.SetAllowPrintToFile(const Value: Boolean);
begin
  DoOnChange('AllowPrintToFile');
  FAllowPrintToFile := Value;
end;

procedure TppCustomPrintDialog.SetArchiveFileName(const Value: String);
begin
  DoOnChange('ArchiveFileName');
  FArchiveFileName := Value;
end;

procedure TppCustomPrintDialog.SetDefaultFileDeviceType(const Value: String);
begin
  DoOnChange('DefaultFileDeviceType');
  FDefaultFileDeviceType := Value;
end;

procedure TppCustomPrintDialog.SetDefaultFileExt(const Value: String);
begin
  DoOnChange('DefaultFileExt');
  FDefaultFileExt := Value;
end;

procedure TppCustomPrintDialog.SetDesignState(const Value: TppDesignStates);
begin
  DoOnChange('DesignState');
  FDesignState := Value;
end;

procedure TppCustomPrintDialog.SetDeviceType(const Value: String);
begin
  DoOnChange('DeviceType');
  FDeviceType := Value;
end;

procedure TppCustomPrintDialog.SetFileFilter(const Value: String);
begin
  DoOnChange('FileFilter');
  FFileFilter := Value;
end;

procedure TppCustomPrintDialog.SetOpenFile(const Value: Boolean);
begin
  DoOnChange('OpenFile');
  FOpenFile := Value;
end;

{------------------------------------------------------------------------------}
{ TppCustomPrintDialog.SetPageRequest }

procedure TppCustomPrintDialog.SetPageRequest(aPageRequest: TObject);
begin
  DoOnChange('PageRequest');
  FPageRequest := aPageRequest;

end; {procedure, SetPageRequest}

{------------------------------------------------------------------------------}
{ TppCustomPrintDialog.SetPDFSettings }

procedure TppCustomPrintDialog.SetPDFSettings(aPDFSettings: TppPDFSettings);
begin
  DoOnChange('PDFSettings');
  FPDFSettings.Assign(aPDFSettings);

end;

procedure TppCustomPrintDialog.SetPrintToArchive(const Value: Boolean);
begin
  DoOnChange('PrintToArchive');
  FPrintToArchive := Value;
end;

procedure TppCustomPrintDialog.SetPrintToFile(const Value: Boolean);
begin
  DoOnChange('PrintToFile');
  FPrintToFile := Value;
end;

{------------------------------------------------------------------------------}
{ TppCustomPrintDialog.SetRTFSettings }

procedure TppCustomPrintDialog.SetRTFSettings(aRTFSettings: TppRTFSettings);
begin
  DoOnChange('RTFSettings');
  FRTFSettings.Assign(aRTFSettings);

end;

procedure TppCustomPrintDialog.SetSendEmail(const Value: Boolean);
begin
  DoOnChange('SendEmail');
  FSendEmail := Value;
end;

procedure TppCustomPrintDialog.SetTextFileName(const Value: String);
begin
  DoOnChange('TextFileName');
  FTextFileName := Value;
end;

procedure TppCustomPrintDialog.SetXLSSettings(aXLSSettings: TppXLSSettings);
begin
  DoOnChange('XLSSettings');
  FXLSSettings.Assign(aXLSSettings);

end;

{ TppCustomExportFileDialog }

procedure TppCustomExportFileDialog.ActivateDialog;
begin
  //Override and place activation code here if embedding the form
end;

constructor TppCustomExportFileDialog.Create(aOwner: TComponent);
begin
  inherited;

  FAllowEmail := False;
  FSendEmail := True;
  FAllowOpenFile := True;
  FAllowPrintToArchive := False;
  FAllowPrintToFile := False;
  FArchiveFileName  := '';
  //FDesignState := [];
  FDeviceType       := '';
  FDefaultFileDeviceType := '';
  FPrintToArchive   := False;
  FPrintToFile      := False;
  FTextFileName     := '';
  FPDFSettings      := TppPDFSettings.Create;
  FRTFSettings      := TppRTFSettings.Create;
  FXLSSettings      := TppXLSSettings.Create;
  FParentDialog     := nil;
  FCloudExport      := False;
{$IFDEF CloudSC}
  FCloudDriveSettings    := TppCloudDriveSettings.Create;
{$ENDIF}

end;

destructor TppCustomExportFileDialog.Destroy;
begin
  FPDFSettings.Free;
  FPDFSettings := nil;

  FRTFSettings.Free;
  FRTFSettings := nil;

  FXLSSettings.Free;
  FXLSSettings := nil;

{$IFDEF CloudSC}
  FCloudDriveSettings.Free;
  FCloudDriveSettings := nil;
{$ENDIF}

  inherited;

end;

procedure TppCustomExportFileDialog.SetPageRequest(aPageRequest: TObject);
begin
  FPageRequest := aPageRequest;

end;

procedure TppCustomExportFileDialog.SetPDFSettings(aPDFSettings: TppPDFSettings);
begin
  FPDFSettings.Assign(aPDFSettings);

end;

procedure TppCustomExportFileDialog.SetRTFSettings(aRTFSettings: TppRTFSettings);
begin
  FRTFSettings.Assign(aRTFSettings);

end;

procedure TppCustomExportFileDialog.SetXLSSettings(aXLSSettings: TppXLSSettings);
begin
  FXLSSettings.Assign(aXLSSettings);

end;

{$IFDEF CloudSC}
procedure TppCustomExportFileDialog.SetCloudDriveSettings(aCloudDriveSettings: TppCloudDriveSettings);
begin
  FCloudDriveSettings.Assign(aCloudDriveSettings);

end;
{$ENDIF}

{ TppCustomOutputDialog }

constructor TppCustomOutputDialog.Create(aOwner: TComponent);
begin
  inherited;

  FAllowPrintToArchive := False;
  FAllowPrintToFile := False;

end;

procedure TppCustomOutputDialog.ehPrinterProp_Change(aSender: TObject);
var
  lPropValue: Variant;
  lPropValueObj: IntPtr;
  lPropRec: TraPropRec;
  lPropName: String;
begin

  //Sync PrintDialog props with ExportFileDialog

  if (FPrintDialog = nil) or (FExportFileDialog = nil) then Exit;

  lPropName := FPrintDialog.UpdatePropName;

  if not TraRTTI.GetPropRec(ClassType, lPropName, lPropRec) then Exit;

  if (lPropRec.DataType = daClass) then
    begin
      if TraRTTI.GetPropValue(Self, lPropName, lPropValueObj) then
        TraRTTI.SetPropValue(FExportFileDialog, lPropName, lPropValueObj);

    end
  else
    begin
      if TraRTTI.GetPropValue(Self, lPropName, lPropValue) then
        TraRTTI.SetPropValue(FExportFileDialog, lPropName, lPropValue);

    end;

end;

function TppCustomOutputDialog.GetDeviceType: String;
begin
  Result := '';

end;

procedure TppCustomOutputDialog.SetExportFileDialog(const Value: TppCustomExportFileDialog);
begin
  FExportFileDialog := Value;

end;

procedure TppCustomOutputDialog.SetPrintDialog(const Value: TppCustomPrintDialog);
begin
  FPrintDialog := Value;

  FPrintDialog.OnChange := ehPrinterProp_Change;

end;

{******************************************************************************
 *
 ** C A N C E L   D I A L O G
 *
{******************************************************************************}

{------------------------------------------------------------------------------}
{ TppCustomCancelDialog.Create }

constructor TppCustomCancelDialog.Create(aOwner: TComponent);
begin

  inherited Create(aOwner);

  FActiveForm       := nil;
  FAllowPrintCancel := False;
  FModal            := False;
  FPrintProgress    := '';
  FppOnShowModal      := nil;

  {create timer used to implement ppCloseModal}
  FTimer := TTimer.Create(Self);
  FTimer.Enabled  := False;
  FTimer.Interval := 10;
  FTimer.OnTimer  := TimerEvent;

end; {constructor, Create}

{------------------------------------------------------------------------------}
{ TppCustomCancelDialog.Destroy }

destructor TppCustomCancelDialog.Destroy;
begin

  {call form hide event handler here, because for in many cases WMShowWindow
   never fires the hide event}
  FormHideEvent;

  FTimer.Free;
  inherited Destroy;
end; {destructor, Destroy}


{------------------------------------------------------------------------------}
{ TppCustomCancelDialog.WMShowWindow}

{$IFDEF MSWINDOWS}
procedure TppCustomCancelDialog.WMShowWindow(var Message: TMessage);
begin

  if (Message.wParam = 1) then

    FormShowEvent
  else
    FormHideEvent;

  inherited;

end; {procedure, WMShowWindow}
{$ENDIF}


{------------------------------------------------------------------------------}
{ TppCustomCancelDialog.SetPrintProgress }

procedure TppCustomCancelDialog.SetPrintProgress(Value: String);
begin
  FPrintProgress := Value;

  PrintProgressChanged;
end;

{------------------------------------------------------------------------------}
{ TppCustomCancelDialog.PrintProgressChanged }

procedure TppCustomCancelDialog.PrintProgressChanged;
begin

end;

{------------------------------------------------------------------------------}
{ TppCustomCancelDialog.FormShow}

procedure TppCustomCancelDialog.FormShowEvent;
begin

  if FModal then Exit;

  {disable the currently active form}
  FActiveForm := Screen.ActiveForm;

  {if (FActiveForm <> nil) then
    FActiveForm.Enabled := False;}

end; {procedure, FormShow}

{------------------------------------------------------------------------------}
{ TppCustomCancelDialog.FormHide}

procedure TppCustomCancelDialog.FormHideEvent;
begin

  if FModal then Exit;

  {re-enable the previously active form}
  if (FActiveForm <> nil) and not(FActiveForm.Enabled) then
    begin

      FActiveForm.Enabled := True;

      if (FActiveForm.CanFocus) and (Screen.ActiveForm = Self) then
        FActiveForm.SetFocus;

    end;

end; {procedure, FormHide}


{------------------------------------------------------------------------------}
{ TppCustomCancelDialog.ppShowModal}

procedure TppCustomCancelDialog.ppShowModal;
begin
  FModal := True;

  {use timer to trigger an event just after the show modal call}
  FTimer.Enabled := True;

  ShowModal;

end; {procedure, ppShowModal}


{------------------------------------------------------------------------------}
{ TppCustomCancelDialog.TimerEvent }

procedure TppCustomCancelDialog.TimerEvent;
begin

  FTimer.Enabled := False;

  if Assigned(FppOnShowModal) then FppOnShowModal(Self);
    
end; {procedure, TimerEvent}


{******************************************************************************
 *
 ** C U S T O M   T E M P L A T E   D I A L O G
 *
{******************************************************************************}

{------------------------------------------------------------------------------}
{ TppCustomTemplateDialog.DoOnHelpClick }

procedure TppCustomTemplateDialog.DoOnHelpClick;
begin
  if HelpEventAssigned then FOnHelpClick(Self);
end; {function, DoOnHelpClick}

{------------------------------------------------------------------------------}
{ TppCustomTemplateDialog.HelpEventAssigned }

function TppCustomTemplateDialog.HelpEventAssigned: Boolean;
begin
  Result := Assigned(FOnHelpClick);
end; {function, HelpEventAssigned}

{******************************************************************************
 *
 ** T E M P L A T E   D I A L O G
 *
{******************************************************************************}

procedure TppCustomTemplateDialog.SetDataPipeline(aComponent: TComponent);
begin
  FDataPipeline := aComponent;
end; {function, SetDataPipeline}

{******************************************************************************
 *
 ** C U S T O M   E M A I L   D I A L O G
 *
{******************************************************************************}

{------------------------------------------------------------------------------}
{TppCustomEmailDialog.Create}

constructor TppCustomEmailDialog.Create(aOwner: TComponent);
begin
  inherited;

  FEmailSettings := TppEmailSettings.Create;

end; {constructor, Create}

{------------------------------------------------------------------------------}
{TppCustomEmailDialog.Destroy}

destructor TppCustomEmailDialog.Destroy;
begin
  inherited;

  FEmailSettings.Free;
  FEmailSettings := nil;

end; {destructor, destroy}

{------------------------------------------------------------------------------}
{TppCustomEmailDialog.SetEmailSettings}

procedure TppCustomEmailDialog.SetEmailSettings(const Value: TppEmailSettings);
begin
  FEmailSettings.Assign(Value);

end; {procedure, SetEmailSettings}

{$IFDEF CloudSC}
{ TppCustomCloudExplorerDialog }

constructor TppCustomCloudExplorerDialog.Create(aOwner: TComponent);
begin
  inherited;

end;

destructor TppCustomCloudExplorerDialog.Destroy;
begin

  inherited;
end;

procedure TppCustomCloudExplorerDialog.SetCloudDirectory(const Value: String);
begin
  FCloudDirectory := Value;

end;


procedure TppCustomCloudExplorerDialog.SetCloudDrive(const Value: TObject{TppCloudDriveCustom});
begin
  FCloudDrive := Value;

end;
{$ENDIF}

{******************************************************************************
 *
 ** R E G I S T E R   P R O C E D U R E S
 *
{******************************************************************************}

{------------------------------------------------------------------------------}
{ ppGetFormClassList - this routine creates the stringlist which will contain
  the class reference variables for the ReportBuilder forms.  The register
  routines always call this routine first, thus forcing the creation of the
  stringlist. This approach was taken because unit loading sequences would not
  guarantee that ppForm initialization fired first, resulting in a nil
  ppFormClassList. This function solves that problem...}

function ppFormClassList: TStringList;
begin
  if FFormClassList = nil then
    FFormClassList := TStringList.Create;

  Result := FFormClassList;
end;


{@ppRegisterForm
 Call this procedure to register a replacement for any of the dialogs you see in
 the ReportBuilder user interface.  See the 'Customizing the Report Explorer
 Form' tutorial in the Developer's Guide for an example of how to call this
 procedure.}

procedure ppRegisterForm(aAncestorClass, aDescendantClass: TFormClass);
var
  lClassList: TStringList;
begin

  ppUnRegisterForm(aAncestorClass);

  {register class so descendant can be instantiated}
  RegisterClass(aDescendantClass);

  lClassList := ppFormClassList;

  lClassList.AddObject(aAncestorClass.ClassName, TObject(aDescendantClass));

end;


{@ppUnRegisterForm
 Call this procedure to unregister a replacement for any of the dialogs you see
 in the ReportBuilder user interface.  See the 'Customizing the Report Explorer
 Form' tutorial in the Developer's Guide for an example of how to call this
 procedure.}

procedure ppUnRegisterForm(aAncestorClass: TFormClass);
var
  liIndex: Integer;
  lFormClass: TFormClass;
  lClassList: TStringList;

begin

  if (aAncestorClass = nil) then Exit;

  if (FFormClassList = nil) then Exit;

  lClassList := ppFormClassList;

  liIndex := lClassList.IndexOf(aAncestorClass.ClassName);

  if liIndex >= 0 then
    begin
      lFormClass := TFormClass(lClassList.Objects[liIndex]);

      UnRegisterClass(lFormClass);

      lClassList.Delete(liIndex);
    end;
end;

{------------------------------------------------------------------------------}
{ ppGetFormClass }

function ppGetFormClass(aAncestorClass: TFormClass): TFormClass;
var
  liIndex: Integer;
  lClassList: TStringList;

begin
  lClassList := ppFormClassList;

  liIndex :=  lClassList.IndexOf(aAncestorClass.ClassName);

  if liIndex >= 0 then
    Result := TFormClass(lClassList.Objects[liIndex])
  else
    Result := nil;

end;


class procedure TppFormState.LoadWindowPlacement(aForm: TForm; aName: String);
{$IFDEF MSWINDOWS}
var
  lIniStorage: TppIniStorage;
  lWindowPlacement: TWindowPlacement;
  liLeft: Integer;
  liTop: Integer;
  liWidth: Integer;
  liHeight: Integer;
  liCurrentPPI: Integer;
begin

   // get window placement
   lWindowPlacement.length := SizeOf(TWindowPlacement);
   GetWindowPlacement(aForm.Handle, @lWindowPlacement);

   liCurrentPPI := ppUTils.GetCurrentPPIForControl(aForm);

   // normalize to 96 DPI
   liLeft := ppScaleFromDPI(lWindowPlacement.rcNormalPosition.Left, liCurrentPPI);
   liTop := ppScaleFromDPI(lWindowPlacement.rcNormalPosition.Top, liCurrentPPI);
   liWidth := ppScaleFromDPI(lWindowPlacement.rcNormalPosition.Right - lWindowPlacement.rcNormalPosition.Left, liCurrentPPI);
   liHeight := ppScaleFromDPI(lWindowPlacement.rcNormalPosition.Bottom - lWindowPlacement.rcNormalPosition.Top, liCurrentPPI);

   lIniStorage := TppIniStoragePlugin.CreateInstance;

   try
     lWindowPlacement.showCmd := lIniStorage.ReadInteger(aName, 'showCmd', lWindowPlacement.showCmd);

     liLeft := lIniStorage.ReadInteger(aName, 'Left', liLeft);
     liTop := lIniStorage.ReadInteger(aName, 'Top', liTop);
     liWidth := lIniStorage.ReadInteger(aName, 'Width', liWidth);
     liHeight := lIniStorage.ReadInteger(aName, 'Height', liHeight);

     // scale to DPI
     lWindowPlacement.rcNormalPosition.Left := ppScaleToDPI(liLeft, liCurrentPPI);
     lWindowPlacement.rcNormalPosition.Top := ppScaleToDPI(liTop, liCurrentPPI);
     lWindowPlacement.rcNormalPosition.Right := lWindowPlacement.rcNormalPosition.Left + ppScaleToDPI(liWidth, liCurrentPPI);
     lWindowPlacement.rcNormalPosition.Bottom := lWindowPlacement.rcNormalPosition.Top + ppScaleToDPI(liHeight, liCurrentPPI);

     SetWindowPlacement(aForm.Handle, @lWindowPlacement);

   finally
     lIniStorage.Free;
   end;


end;
{$ELSE}
begin
end;
{$ENDIF}

class procedure TppFormState.SaveWindowPlacement(aForm: TForm; aName: String);
{$IFDEF MSWINDOWS}
var
  lIniStorage: TppIniStorage;
  lbDesignTime: Boolean;
  lWindowPlacement: TWindowPlacement;
  liCurrentPPI: Integer;
begin

  // get window placement
  lWindowPlacement.length := SizeOf(TWindowPlacement);
  GetWindowPlacement(aForm.Handle, @lWindowPlacement);

  // do not save when minimized
  if (lWindowPlacement.showCmd = SW_SHOWMINIMIZED) then Exit;

  liCurrentPPI := ppUtils.GetCurrentPPIForControl(aForm);

  lIniStorage := TppIniStoragePlugin.CreateInstance;

   lbDesignTime := ppUtils.gbDesignTime;
   if not(ppUtils.gbDesignTime) then
     ppUtils.gbDesignTime := True;

   try
     // save normalized values (96 DPI)
     lIniStorage.WriteInteger(aName, 'ShowCmd', lWindowPlacement.showCmd);
     lIniStorage.WriteInteger(aName, 'Left', ppScaleFromDPI(lWindowPlacement.rcNormalPosition.Left, liCurrentPPI));
     lIniStorage.WriteInteger(aName, 'Top', ppScaleFromDPI(lWindowPlacement.rcNormalPosition.Top, liCurrentPPI));
     lIniStorage.WriteInteger(aName, 'Width', ppScaleFromDPI(lWindowPlacement.rcNormalPosition.Right - lWindowPlacement.rcNormalPosition.Left, liCurrentPPI));
     lIniStorage.WriteInteger(aName, 'Height', ppScaleFromDPI(lWindowPlacement.rcNormalPosition.Bottom - lWindowPlacement.rcNormalPosition.Top, liCurrentPPI));

   finally
     lIniStorage.Free;
     ppUtils.gbDesignTime := lbDesignTime;

   end;

end;

{$ELSE}
begin
end;
{$ENDIF}

{******************************************************************************
 *
 ** I N I T I A L I Z A T I O N   /   F I N A L I Z A T I O N
 *
{******************************************************************************}


initialization

finalization

  FFormClassList.Free;
  FFormClassList := nil;
  
end.

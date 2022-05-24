{
Esta é uma cópia de seguranca do que esta no Source do
ReportBuilder Enterprise 15.02 Delphi7
Todas as modificacoes estao marcadas com a palavra Viasoft.

Modificações feitas por Dal Bosco e Beto - Viasoft em 13.09.2013
  -Setado como default property SinglePageOnly como True pois ocorria de que
    nos relatorios aonde se tinha uma consulta sql depois de executado o
    print do relatorio fechar a conexão com o socket, exemplo:
    uDmRelDacte (Agro) evento: HeaderBeforePrint(Sender: TObject); "pegadata"}

{ RRRRRR                  ReportBuilder Class Library                  BBBBB
  RR   RR                                                              BB   BB
  RRRRRR                 Digital Metaphors Corporation                 BB BB
  RR  RR                                                               BB   BB
  RR   RR                   Copyright (c) 1996-2006                    BBBBB   }

unit ppPreview;

interface

{$I ppIfDef.pas}

uses
  {$IFDEF Delphi6} Types, {$ENDIF}
  Windows, Classes, Controls, ComCtrls, SysUtils, ExtCtrls, StdCtrls, Buttons,
  Graphics,
  ppComm,

  ppProd,
  ppViewr,
  ppTypes,
  ppUtils,
  ppRTTI,

  ppOutlineViewer,
  ppThumbnailViewer,
  ppOutlineNotebook,
  ppOutlineReportSettings,
  ppThumbnailSettings,
  ppTextSearchCustomPreview,
  ppPopupMenuBase,
  ppDesignEventHub,

  ppTB2Dock,
  ppTBX,
  ppTBXStatusBars,
  ppTBXExtItems,
  ppTBXDkPanels,
  ppToolbarTBX,
  ppToolResources,
  ppSMTPOutlook,
  ppSMTPMapi,
  ppSMTPThunderbird, //uses inserida para que q dll funcione adequadamente no Win2008ServerR2Standard OCTEC-740
  ppSMTPCustom,
  Registry,

  daQueryDataView,
  daDataModule,
  ppClass,
  Variants,
  Dialogs;

type

  TppCustomPreview = class;
  TppPreviewClass = class of TppCustomPreview;

  {@TppPreviewPlugIn

    The currently registered PreviewPlugIn class is used by the report designer
    and the preview dialog to provide a consistent preview UI. To override the
    default preview UI, create a CustomPreview descendant class and register it
    in the initialization section of the unit.}

  TppPreviewPlugIn = class
    private
    public
      class procedure Register(aPreviewClass: TppPreviewClass);
      class procedure UnRegister(aPreviewClass: TppPreviewClass);

      class procedure RegisterSearchClass(aSearchClass: TppCustomSearchPreviewClass);
      class procedure UnRegisterSearchClass(aSearchClass: TppCustomSearchPreviewClass);

      class function CreateSearchPlugin(aComponent: TComponent): TppCustomSearchPreview;
      class function CreatePreviewPlugin(aParent: TWinControl): TppCustomPreview;

      class function GetPreviewClass: TppPreviewClass;
      class function UsingDefaultPreviewClass: Boolean;

    end; {class, TppPreviewPlugIn}


  {@TppCustomPreview

    Abstract ancestor class for preview plug-ins. Creates a Viewer and provides
    virtual methods for processing PreviewActions such as Print, AutoSearch, Cancel,
    etc.}

  {@TppCustomPreview.OutlineVisible

    Used to control whether or not the outline viewer is visible on the preview
    form.  Descendents of TppPreview should not need to use this property.}

  {@TppCustomPreview.SearchPreview

    The embedded object which is created if the TextSearchSettings on the
    producer is enabled. Descendents can override the CreateSearchPreview method
    to use this object to get at the search preview controls which are created
    by the plug-in class descendent which is currently registered.}

  {@TppCustomPreview.StatusBar

    TStatusBar object assigned by the Designer or Print Preview Form. Used to
    provide status information.}

  TppCustomPreview = class(TppCommunicator)
    private
      FAfterPrint: TNotifyEvent;
      FBeforePrint: TNotifyEvent;
      FParent: TWinControl;
      FStatusBar: TStatusBar;
      FViewer: TppViewer;
      FReport: TppProducer;
      FOnClose: TNotifyEvent;
      FOnPageChange: TNotifyEvent;
      FSearchPreview: TppCustomSearchPreview;
      FStatusBarTbx: TppTBXStatusBar;

      function GetCurrentPPI: Integer;
      procedure SetStatusBar(aStatusbar: TStatusBar);
      procedure SetStatusBarTbx(const Value: TppTBXStatusBar);

    protected
      function CreateSearchPreview: TppCustomSearchPreview; virtual;
      procedure ConfigureAccessoryPanelVisibility; virtual;
      function GetOutlineEnabled: Boolean; virtual;
      function GetOutlineVisible: Boolean; virtual;
      procedure PageChangeEvent(Sender: TObject); virtual;
      procedure PrintStateChangeEvent(Sender: TObject); virtual;
      function ScaleToDPI(const aValue: Integer): Integer;
      procedure SetOutlineVisible(aOutlineVisible: Boolean); virtual;
      procedure SearchPreviewActionPerformed; virtual;
      procedure StatusChangeEvent(Sender: TObject); virtual;
      procedure ViewerResetEvent(Sender: TObject); virtual;
      procedure ViewerMouseDownEvent(Sender: TObject); virtual;
      procedure ViewerScrollEvent(Sender: TObject); virtual;
      procedure ToggleSearch; virtual;
      procedure UpdateStatusBar; virtual;
      procedure UpdateStatusBarTbx; virtual;

      property SearchPreview: TppCustomSearchPreview read FSearchPreview;

    public
      constructor Create(aOwner: TComponent); override;
      destructor Destroy; override;

      procedure Notify(aCommunicator: TppCommunicator; aOperation: TppOperationType); override;
      procedure EventNotify(aCommunicator: TppCommunicator; aEventID: Integer; aParams: TraParamList); override;

      procedure AfterPreview; virtual;
      procedure BeforePreview; virtual;
      procedure BeforeDesignerTabChange; virtual;
      procedure Cancel; virtual;
      procedure GotoPage(aPageNo: Integer);
      procedure LanguageChanged; virtual;
      procedure PerformPreviewAction(aPreviewAction: TppPreviewActionType); virtual;
      procedure Print; virtual;
      procedure ExportToFile; virtual;
      procedure Zoom(aZoomSetting: TppZoomSettingType); virtual;
      procedure KeyDown(var Key: Word; Shift: TShiftState); virtual;
      procedure SendEmail; virtual;
{$IFDEF CloudSC}
      procedure SendWebMail(aMailService: Integer);
      procedure UploadToCloud(aDrive: Integer);
{$ENDIF}
      procedure ZoomToPercentage(aZoomPercentage: Integer);

      property CurrentPPI: Integer read GetCurrentPPI;
      property OutlineEnabled: Boolean read GetOutlineEnabled;
      property OutlineVisible: Boolean read GetOutlineVisible write SetOutlineVisible;
      property Parent: TWinControl read FParent;
      property StatusBar: TStatusBar read FStatusBar write SetStatusBar;
      property Report: TppProducer read FReport;
      property StatusBarTbx: TppTBXStatusBar read FStatusBarTbx write SetStatusBarTbx;
      property Viewer: TppViewer read FViewer;

      property OnClose: TNotifyEvent read FOnClose write FOnClose;
      property OnPageChange: TNotifyEvent read FOnPageChange  write FOnPageChange;
      property AfterPrint: TNotifyEvent read FAfterPrint write FAfterPrint;
      property BeforePrint: TNotifyEvent read FBeforePrint write FBeforePrint;

    end; {class, TppCustomPreview}


  TppEdit = class(TEdit)
    public
      property OnMouseWheel;
    end;




  {@TppPreview

    Default preview plug-in class. Use this class as an example for creating
    additional preview plug-ins. Adds a toolbar that contains UI controls for
    all preview actions enumerated by TppPreviewActionType.

    This is the layout of the panels in which this class creates and the
    associated location of any viewers in those panels.

    <IMAGE TppPreviewLayout>}

  {@TppPreview.AccessoryToolbar

    This panel contains the outline viewer and text search toolbar. It appears
    on the left side of the previewer.}

  {@TppPreview.TextSearchToolbar

    This panel contains the text search controls. It is located at the top of
    the accessory toolbar, above the outline viewer}

  {@TppPreview.Toolbar

    This toolbar is located at the top of the preview form and contains a number
    of toolbar items such as zoom controls, page navigation controls, print button,
    auto search button, text search button, etc. Use this toolbar if you want to
    add toolbar items to a TppPreview plug-in descendent class.}


  TppPreview = class(TppCustomPreview)
    private
      FAccessoryToolbarWidthSet: Boolean;
      FShowOutlineWhenPreview: Boolean;
      FShowThumbnailsWhenPreview: Boolean;
      FBeforePreview: Boolean;
      FAccessoryToolbar: TPanel;
      FSinglePageOnly: Boolean;
      FAutoSearchButton: TppTBXItem;
      FOutlineNotebook: TppOutlineNotebook;
      FToolbar: TppToolbar;
      FTextSearchToolbar: TPanel;
      FCancelButton: TppTBXItem;
      FEmailButton: TppTBXItem;
      FExportButton: TppTBXItem;
      FFirstButton: TppTBXItem;
      FKeyCatcher: TppEdit;
      FLastButton: TppTBXItem;
      FNextButton: TppTBXItem;
      FPageNoEdit: TppTBXEditItem;
      FPageWidthButton: TppTBXItem;
      FPercent100Button: TppTBXItem;
      FPnlViewer: TPanel;
      FPrintButton: TppTBXItem;
      FPriorButton: TppTBXItem;
      FSinglePageButton: TppTBXItem;
      FContinuousButton: TppTBXItem;
      FTwoUpButton: TppTBXItem;
      FContinuousTwoUpButton: TppTBXItem;
      FSplitter: TSplitter;
      FTextSearchButton: TppTBXItem;
      FTopDock: TppDock;
      FWholePageButton: TppTBXItem;
      FZoomPercentageEdit: TppTBXEditItem;
      FPopupMenu: TppPopupMenuBase;
{$IFDEF CloudSC}
      FCloudDriveButton: TppSubMenuItem;
      FOneDriveButton: TppTBXItem;
      FGoogleDriveButton: TppTBXItem;
      FDropBoxButton: TppTBXItem;

      FEmailMultiButton: TppSubMenuItem;
      FGmailButton: TppTBXItem;
      FOutlook365Button: TppTBXItem;
      FSMTPButton: TppTBXItem;
{$ENDIF}
      FToolImageList: TppToolImageList;
      procedure ConfigureSearchButtons;
      procedure ConfigureOutline;
      procedure Rezoom;
      procedure LoadStateInfo;
      procedure SaveStateInfo;


    protected
      procedure ConfigureAccessoryPanelVisibility; override;
      function GetOutlineViewer: TppOutlineViewer; virtual;
      function GetOutlineVisible: Boolean; override;
      procedure PageChangeEvent(Sender: TObject); override;
      procedure PrintStateChangeEvent(Sender: TObject); override;
      procedure SetOutlineVisible(aOutlineVisible: Boolean); override;
      procedure SearchPreviewActionPerformed; override;
      procedure ViewerResetEvent(Sender: TObject); override;
      procedure ViewerMouseDownEvent(Sender: TObject); override;
      procedure ViewerScrollEvent(Sender: TObject); override;
      procedure ToggleSearch; override;
      procedure SetCancelledButtonState; virtual;

      procedure KeyDownEvent(Sender: TObject; var Key: Word; Shift: TShiftState); virtual;
      procedure KeyUpEvent(Sender: TObject; var Key: Word; Shift: TShiftState); virtual;
      procedure KeyPressEvent(Sender: TObject; var Key: Char);  virtual;
      procedure MouseWheelEvent(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean); virtual;
      procedure ToolButtonClickEvent(Sender: TObject);  virtual;

      procedure ConfigureTextSearchToolbar; virtual;
      function  CreateOutlineNotebook: TppOutlineNotebook; virtual;
      procedure CreateToolbar; virtual;
      procedure CreateToolbarItems; virtual;
      procedure CreatePreviewPopupMenu; virtual;
      procedure ehPageNoEdit_AcceptText(Sender: TObject; var aNewText: String; var Accept: Boolean); virtual;
      procedure ehZoomEdit_AcceptText(Sender: TObject; var aNewText: String; var Accept: Boolean); virtual;
      procedure ehToolbutton_Click(Sender: TObject); virtual;
      procedure ehMouseMode_Change(Sender: TObject); virtual;
      procedure ehPreviewPopup_Popup(Sender: TObject); virtual;
      procedure ehViewer_ChangeScale(aSender: TObject; aParameters: TObject);

      procedure FocusToKeyCatcher;
      function GetOutlineEnabled: Boolean; override;
      property ToolImageList: TppToolImageList read FToolImageList;

    public
      constructor Create(aOwner: TComponent); override;
      destructor Destroy; override;

      procedure EventNotify(aCommunicator: TppCommunicator; aEventID: Integer; aParams: TraParamList); override;

      procedure BeforePreview; override;
      procedure Cancel; override;
      procedure LanguageChanged; override;
      procedure Zoom(aZoomSetting: TppZoomSettingType); override;

      property AccessoryToolbar: TPanel read FAccessoryToolbar;
      property AutoSearchButton: TppTBXItem read FAutoSearchButton;
      property CancelButton: TppTBXItem read FCancelButton;
      property EmailButton: TppTBXItem read FEmailButton;
      property ExportButton: TppTBXItem read FExportButton;
      property FirstButton: TppTBXItem read FFirstButton;
      property LastButton: TppTBXItem read FLastButton;
      property NextButton: TppTBXItem read FNextButton;
      property OutlineViewer: TppOutlineViewer read GetOutlineViewer;
      property OutlineNotebook: TppOutlineNotebook read FOutlineNotebook;
      property PageNoEdit: TppTBXEditItem read FPageNoEdit;
      property PageWidthButton: TppTBXItem read FPageWidthButton;
      property Percent100Button: TppTBXItem read FPercent100Button;
      property PopupMenu: TppPopupMenuBase read FPopupMenu;
      property PrintButton: TppTBXItem read FPrintButton;
      property PriorButton: TppTBXItem read FPriorButton;
      property Splitter: TSplitter read FSplitter;
      property SinglePageOnly: Boolean read FSinglePageOnly write FSinglePageOnly;
      property SinglePageButton: TppTBXItem read FSinglePageButton;
      property ContinuousButton: TppTBXItem read FContinuousButton;
      property TwoUpButton: TppTBXItem read FTwoUpButton;
      property ContinuousTwoUpButton: TppTBXItem read FContinuousTwoUpButton;
      property TextSearchButton: TppTBXItem read FTextSearchButton;
      property TextSearchToolbar: TPanel read FTextSearchToolbar;
      property Toolbar: TppToolbar read FToolbar;
      property TopDock: TppDock read FTopDock;
      property WholePageButton: TppTBXItem read FWholePageButton;
      property ZoomPercentageEdit: TppTBXEditItem read FZoomPercentageEdit;
{$IFDEF CloudSC}
      property CloudDriveButton: TppSubMenuItem read FCloudDriveButton;
      property OneDriveButton: TppTBXItem read FOneDriveButton;
      property GoogleDriveButton: TppTBXItem read FGoogleDriveButton;
      property DropBoxButton: TppTBXItem read FDropBoxButton;
      property EmailMultiButton: TppSubMenuItem read FEmailMultiButton;
{$ENDIF}
    end; {class, TppPreview}


implementation

{$R ppPrvBmp.res}

uses
  Forms,
  ppDevice,
  ppFilDev,
  ppDrwCmd,
  ppTextSearchError,
  ppOutlineDrawCommand,
  ppIniStorage, ppReport;

var
  uSearchClass: TppCustomSearchPreviewClass;
  uPreviewClass: TppPreviewClass;
  uCancelled: Boolean;

{******************************************************************************
 *
 ** P R E V I E W E R    P L U G - I N
 *
{******************************************************************************}

{@TppPreviewPlugIn.Register

  Registers a CustomPreview class to be used by the Designer and the Print
  Preview Form.}

class procedure TppPreviewPlugIn.Register(aPreviewClass: TppPreviewClass);
begin
  uPreviewClass := aPreviewClass;
end;

{@TppPreviewPlugIn.UnRegister

  Un-registers a custom preview plug-in class.

  If you are swapping out different plug-ins in the context of a running
  application, make sure you re-register the plug-in class you replaced.
  Otherwise an exception will be raised the next time you call Report.Print.}

class procedure TppPreviewPlugIn.UnRegister(aPreviewClass: TppPreviewClass);
begin
  uPreviewClass := nil;
end;

{@TppPreviewPlugIn.CreatePreviewPlugin

  Factory used to create an instance of the currently registered preview plug-in.}

class function TppPreviewPlugIn.CreatePreviewPlugin(aParent: TWinControl): TppCustomPreview;
begin

  if (uPreviewClass = nil) then
    uPreviewClass := TppPreview;

  Result :=  uPreviewClass.Create(aParent);

end;

{@TppPreviewPlugIn.CreateSearchPlugin }

class function TppPreviewPlugIn.CreateSearchPlugin(aComponent: TComponent): TppCustomSearchPreview;
begin

  {Does not force a search library to be linked in.}
  if (uSearchClass <> nil) then
    Result := uSearchClass.Create(aComponent)
  else
    Result := nil;
end;

{@TppPreviewPlugIn.RegisterSearchClass }

class procedure TppPreviewPlugIn.RegisterSearchClass(aSearchClass: TppCustomSearchPreviewClass);
begin
  uSearchClass := aSearchClass;
end;

{@TppPreviewPlugIn.UnRegisterSearchClass }

class procedure TppPreviewPlugIn.UnRegisterSearchClass(aSearchClass: TppCustomSearchPreviewClass);
begin
  uSearchClass := nil;
end;

{@TppPreviewPlugIn.GetPreviewClass }

class function TppPreviewPlugIn.GetPreviewClass: TppPreviewClass;
begin
  if (uPreviewClass = nil) then
    uPreviewClass := TppPreview;

  Result := uPreviewClass;
end;

{@TppPreviewPlugIn.UsingDefaultPreviewClass }

class function TppPreviewPlugIn.UsingDefaultPreviewClass: Boolean;
begin
  Result := (GetPreviewClass.InheritsFrom(TppPreview));
end;

{******************************************************************************
 *
 ** C U S T O M   P R E V I E W E R
 *
{******************************************************************************}

{@TppCustomPreview.Create

  The constructor is passed a parent win control that represents either the
  report designer's tab sheet, or the preview form. Descendants can use the
  parent when creating UI elements such as toolbar buttons and edit boxes.}

constructor TppCustomPreview.Create(aOwner: TComponent);
begin

  inherited Create(aOwner);

  FParent    := TWinControl(aOwner);
  FStatusBar := nil;
  FSearchPreview := nil;

  {create the viewer}
  FViewer := TppViewer.Create(FParent);
  FViewer.Parent := FParent;
  FViewer.Align := alClient;

  {assign viewer event handlers}
  EventNotifies := EventNotifies + [ciViewerPageChange, ciViewerPrintStateChange, ciViewerStatusChange, ciViewerReset, ciViewerMouseDown, ciSearchToolbarChanged, ciSearchPreviewActionPerformed, ciViewerScroll];
  FViewer.WalkieTalkie.AddEventNotify(Self);

  FOnClose := nil;

  FSearchPreview := nil;

end;

{@TppCustomPreview.Destroy }

destructor TppCustomPreview.Destroy;
begin

  FSearchPreview.Free;

  inherited Destroy;

end;

{@TppCustomPreview.EventNotify }

procedure TppCustomPreview.EventNotify(aCommunicator: TppCommunicator; aEventID: Integer; aParams: TraParamList);
begin

  inherited EventNotify(aCommunicator, aEventID, aParams);

  if (aCommunicator = FViewer.WalkieTalkie) then
    begin

      if (aEventID = ciViewerMouseDown) then
        ViewerMouseDownEvent(aCommunicator)

      else if (aEventID = ciViewerPageChange) then
        PageChangeEvent(aCommunicator)

      else if (aEventID = ciViewerPrintStateChange) then
        PrintStateChangeEvent(aCommunicator)

      else if (aEventID = ciViewerStatusChange) then
        StatusChangeEvent(aCommunicator)

      else if (aEventID = ciViewerReset) then
        ViewerResetEvent(aCommunicator)

      else if (aEventID = ciViewerScroll) then
        ViewerScrollEvent(aCommunicator);

    end
  else if (aCommunicator = FSearchPreview) then
    begin
      if (aEventID = ciSearchToolbarChanged) then
        ConfigureAccessoryPanelVisibility

      else if (aEventID = ciSearchPreviewActionPerformed) then
        SearchPreviewActionPerformed;

    end;

end;

{@TppCustomPreview.Notify }

procedure TppCustomPreview.Notify(aCommunicator: TppCommunicator; aOperation: TppOperationType);
begin

  inherited Notify(aCommunicator, aOperation);

  if not(csDestroying in ComponentState) and (aOperation = ppopRemove) then
    begin

      if (aCommunicator = FSearchPreview) then
        raise ESearchError.Create('TppCustomPreview.Notify: Do not attempt to free the embedded search preview object.');

    end;

end;

{@TppCustomPreview.BeforePreview }

procedure TppCustomPreview.BeforePreview;
begin
  uCancelled := False;

  {connect preview to report}
  FReport := FViewer.Report;

  {initialize the viewer}
  FViewer.ScreenDevice.Active := True;
  FViewer.Initialize;

{Viasoft-Inicio}
  //Comentado porque dava erro e travava o servidor de aplicacoes (Agro)
  FViewer.SinglePageOnly := True;//FReport.PreviewFormSettings.SinglePageOnly;
{Viasoft-Fim}
  FViewer.PageIncrement := FReport.PreviewFormSettings.PageIncrement;
  FViewer.PageDisplay := FReport.PreviewFormSettings.PageDisplay;
  FViewer.PageSeparation := FReport.PreviewFormSettings.PageSeparation;
  FViewer.PageBorder := FReport.PreviewFormSettings.PageBorder;
  FViewer.UseBackgroundThread := FReport.PreviewFormSettings.UseBackgroundThread;

  if (FReport.TextSearchSettings.Enabled) then
    FSearchPreview := CreateSearchPreview;

  if (FSearchPreview <> nil) then
    begin
      FSearchPreview.Viewer := FViewer;
      FSearchPreview.StatusBar := FStatusBar;
      FSearchPreview.StatusBarTbx := FStatusBarTbx;
      FSearchPreview.TextSearchSettings := FReport.TextSearchSettings;
    end;

end;

{@TppCustomPreview.AfterPreview }

procedure TppCustomPreview.AfterPreview;
begin
  FViewer.ScreenDevice.Active := False;

  {exit the current search if any and free any highlight draw commands on the page}
  if (FSearchPreview <> nil) then
    FSearchPreview.AfterPreview;

  {disconnect preview from report}
  FReport := nil;

end;

{@TppCustomPreview.BeforeDesignerTabChange

  When the designer switches tabs, the prevew may still be performing a operation.
  In this case, the designer calls this method on the preview plugin. The preview
  plugin can then respond before the tab changes by overriding this method and
  shutting any processes down before the designer continues with the tab change.}

procedure TppCustomPreview.BeforeDesignerTabChange;
begin

  if (FSearchPreview <> nil) then
    begin
      if (FSearchPreview.ActiveSearch) then
        FSearchPreview.Cancel
      else
        FSearchPreview.Initialize;
    end;

end;

{@TppCustomPreview.CreateSearchPreview

  The search preview plugin architecture allows descendents to include
  the capability to search for text occurrences in the print preview. The search
  preview creates the visual controls in the preview in order to provide this
  functionality. The default search plugin is the TppTextSearchPreview class located
  in ppTextSearchPreview.pas of your installation.}

function TppCustomPreview.CreateSearchPreview: TppCustomSearchPreview;
begin

  if (FSearchPreview = nil) then
    begin
      FSearchPreview := TppPreviewPlugIn.CreateSearchPlugin(Self);

      if (FSearchPreview <> nil) then
        FSearchPreview.AddEventNotify(Self);
    end;

  Result := FSearchPreview;

end;

procedure TppCustomPreview.ConfigureAccessoryPanelVisibility;
begin

end;

{@TppCustomPreview.Cancel }

procedure TppCustomPreview.Cancel;
begin
  if (FReport <> nil) and FReport.Printing then
    begin
      FViewer.Cancel;
      uCancelled := True;
    end;

end;

function TppCustomPreview.GetOutlineEnabled: Boolean;
begin
  Result := False;
end;

{@TppCustomPreview.LanguageChanged

  Descendants can add international language support here.}

procedure TppCustomPreview.LanguageChanged;
begin
  if (FSearchPreview <> nil) then
    FSearchPreview.LanguageChanged;
end; 

{@TppCustomPreview.KeyDown }

procedure TppCustomPreview.KeyDown(var Key: Word; Shift: TShiftState);
begin

  if (ssCtrl in Shift) then
    case Key of
     VK_PRIOR: PerformPreviewAction(paPrior);
     VK_NEXT:  PerformPreviewAction(paNext);
     VK_HOME:  PerformPreviewAction(paFirst);
     VK_END:   PerformPreviewAction(paLast);
    end
  else
    case Key of
     VK_PRIOR, VK_UP:  FViewer.Scroll(dtUp);
     VK_NEXT, VK_DOWN: FViewer.Scroll(dtDown);
     VK_LEFT:          FViewer.Scroll(dtLeft);
     VK_RIGHT:         FViewer.Scroll(dtRight);
     VK_ESCAPE: PerformPreviewAction(paClose);
    end;

end;

{@TppCustomPreview.Print }

procedure TppCustomPreview.Print;
begin

  if FReport = nil then Exit;

  if (Assigned(BeforePrint)) then BeforePrint(Self);

  try
    FViewer.Print;
  finally
    if (Assigned(AfterPrint)) then AfterPrint(Self);
  end;


end; {procedure, Print}

{TppCustomPreview.ExportToFile }

procedure TppCustomPreview.ExportToFile;
var
  lsFileDeviceType: String;
begin
  if FReport = nil then Exit;

  if (Assigned(BeforePrint)) then BeforePrint(Self);

  try

    if TppFileDeviceUtils.IsFileDevice(FReport.DeviceType) then
      lsFileDeviceType := Report.DeviceType
    else
      lsFileDeviceType := Report.DefaultFileDeviceType;

    FViewer.ExportToFile(lsFileDeviceType);

  finally
    if (Assigned(AfterPrint)) then AfterPrint(Self);
  end;

end; {procedure, ExportToFile}

function TppCustomPreview.GetCurrentPPI: Integer;
begin
  Result := ppUtils.GetCurrentPPIForControl(Parent)

end;
{@TppCustomPreview.PerformPreviewAction

 Descendant classes can call this method to process preview actions enumerated
 by TppPreviewActionType.}

procedure TppCustomPreview.PerformPreviewAction(aPreviewAction: TppPreviewActionType);
begin

  if (FSearchPreview <> nil) then
    FSearchPreview.BeforePreviewActionPerformed(aPreviewAction);

  case aPreviewAction of
    paPrint:          Print;
    paExport:         ExportToFile;
    paEmail:          SendEmail;
    paAutoSearch:
    begin
      uCancelled := False;
      {VIASOFT - LEANDRO MIOZZO BONATO e CÉSAR ASCARI}
      {11/06/2021}
      TppReport(FReport).Loaded;
      TppReport(FReport).Engine.Reset;
      TppReport(FReport).InitializeParameters;
      {FIM}
      FViewer.DisplayAutoSearchDialog;
    end;
    paTextSearch:     ToggleSearch;
    paWholePage:      Zoom(zsWholePage);
    paPageWidth:      Zoom(zsPageWidth);
    pa100Percent:     Zoom(zs100Percent);
    paFirst:          FViewer.FirstPage;
    paPrior:          FViewer.PriorPage;
    paNext:           FViewer.NextPage;
    paLast:           FViewer.LastPage;
    paCancel:         Cancel;
    paClose:          if Assigned(FOnClose) then FOnClose(Self);
    paSingle:         FViewer.PageDisplay := pdSingle;
    paTwoUp:          FViewer.PageDisplay := pdTwoUp;
    paContinuous:     FViewer.PageDisplay := pdContinuous;
    paContinuousTwoUp:FViewer.PageDisplay := pdContinuousTwoUp;
{$IFDEF CloudSC}
    paOneDrive,
    paGoogleDrive,
    paDropBox:        UploadToCloud(Integer(aPreviewAction));
    paGmail,
    paOutlook365,
    paSMTP:           SendWebMail(Integer(aPreviewAction));
{$ENDIF}
  end;

  if (FSearchPreview <> nil) then
    FSearchPreview.AfterPreviewActionPerformed(aPreviewAction);

end;

{@TppCustomPreview.ToggleSearch }

procedure TppCustomPreview.ToggleSearch;
begin

  if (FSearchPreview <> nil) then
    FSearchPreview.ToggleSearch;

end;

{@TppCustomPreview.Zoom }

procedure TppCustomPreview.Zoom(aZoomSetting: TppZoomSettingType);
begin
  FViewer.ZoomSetting := aZoomSetting;
end;

{@TppCustomPreview.PageChangeEvent }

procedure TppCustomPreview.PageChangeEvent(Sender: TObject);
begin
  if Assigned(FOnPageChange) then FOnPageChange(Self);
end;

{@TppCustomPreview.PrintStateChangeEvent }

procedure TppCustomPreview.PrintStateChangeEvent(Sender: TObject);
begin

end;

{@TppCustomPreview.StatusChangeEvent }

procedure TppCustomPreview.StatusChangeEvent(Sender: TObject);
begin

  if FStatusBar <> nil then
    UpdateStatusBar
  else if FStatusBarTbx <> nil then
    UpdateStatusBarTbx
  else if (FSearchPreview <> nil) then
    FSearchPreview.StatusChange

end; {procedure, StatusChangeEvent}


{@TppCustomPreview.ViewerMouseDownEvent }

procedure TppCustomPreview.ViewerMouseDownEvent(Sender: TObject);
begin

end;

{@TppCustomPreview.ViewerResetEvent }

procedure TppCustomPreview.ViewerResetEvent(Sender: TObject);
begin


end;

procedure TppCustomPreview.ViewerScrollEvent(Sender: TObject);
begin

end;

{@TppCustomPreview.GetOutlineVisible }

function TppCustomPreview.GetOutlineVisible: Boolean;
begin

  Result := False;

end;

{@TppCustomPreview.SetOutlineVisible }

procedure TppCustomPreview.SetOutlineVisible(aOutlineVisible: Boolean);
begin

end; 

{@TppCustomPreview.SearchPreviewActionPerformed }

procedure TppCustomPreview.SearchPreviewActionPerformed;
begin

end;

{@TppCustomPreview.SetStatusBar }

procedure TppCustomPreview.SetStatusBar(aStatusbar: TStatusBar);
begin
  FStatusBar := aStatusbar;

  if (FSearchPreview <> nil) then
    FSearchPreview.StatusBar := FStatusBar;
end;

{@TppCustomPreview.GotoPage }

procedure TppCustomPreview.GotoPage(aPageNo: Integer);
begin
  if (FSearchPreview <> nil) then
    FSearchPreview.BeforePageJump(aPageNo);

  FViewer.GotoPage(aPageNo);
end;

function TppCustomPreview.ScaleToDPI(const aValue: Integer): Integer;
begin
  Result := ppScaleToDPI(aValue, CurrentPPI);
end;

procedure TppCustomPreview.SendEmail;
var
  clienteEmailPadrao : String;
  reg : TRegistry;

const
  _caminhoRegistro = '\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\mailto\UserChoice';

begin
  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_CURRENT_USER;
    if reg.OpenKey(_caminhoRegistro, False) then
    begin
      clienteEmailPadrao := reg.ReadString('ProgId');
      reg.CloseKey;
    end;
  finally
    FreeAndNil(reg);
  end;

  if Pos('THUNDERBIRD', Uppercase(clienteEmailPadrao)) > 0 then
    TppSMTPPlugIn.RegisterClass(TppSMTPThunderbird)
  else if Pos('OUTLOOK', Uppercase(clienteEmailPadrao)) > 0 then
    TppSMTPPlugIn.RegisterClass(TppSMTPOutlook)
  else
    TppSMTPPlugIn.RegisterClass(TppSMTPMapi);

  try
    if FReport <> nil then
      FReport.SendMail;
  except
    raise;
  end;
end;


{$IFDEF CloudSC}
procedure TppCustomPreview.UploadToCloud(aDrive: Integer);
var
  lbStoreSaveToCloudDrive: Boolean;
begin

  if FReport = nil then Exit;

  lbStoreSaveToCloudDrive := FReport.CloudDriveSettings.SaveToCloudDrive;
  FReport.CloudDriveSettings.SaveToCloudDrive := True;

  try

    case TppPreviewActionType(aDrive) of
      paOneDrive:  FReport.CloudDriveSettings.CloudDrive := ctOneDrive;
      paGoogleDrive: FReport.CloudDriveSettings.CloudDrive := ctGoogleDrive;
      paDropBox: FReport.CloudDriveSettings.CloudDrive := ctDropBox;
    end;

    Viewer.ExportToFile(FReport.DefaultFileDeviceType);

    //FReport.UploadToCloud;
  finally
    FReport.CloudDriveSettings.SaveToCloudDrive := lbStoreSaveToCloudDrive;

  end;

end;

procedure TppCustomPreview.SendWebMail(aMailService: Integer);
var
  lsSaveMailService: String;
begin

  if FReport = nil then Exit;

  lsSaveMailService := FReport.EmailSettings.ConnectionSettings.MailService;

  case TppPreviewActionType(aMailService) of
    paGmail:  FReport.EmailSettings.ConnectionSettings.MailService := ctGmail;
    paOutlook365: FReport.EmailSettings.ConnectionSettings.MailService := ctOutlook365;
    paSMTP: FReport.EmailSettings.ConnectionSettings.MailService := ctSMTP;
  end;

  SendEmail;

  FReport.EmailSettings.ConnectionSettings.MailService := lsSaveMailService;

end;
{$ENDIF}

procedure TppCustomPreview.SetStatusBarTbx(const Value: TppTBXStatusBar);
begin
  FStatusBarTbx := Value;

  if (FSearchPreview <> nil) then
    FSearchPreview.StatusBarTbx := FStatusBarTbx;

end;

procedure TppCustomPreview.UpdateStatusBar;
begin

  {update status bar}
  if (FStatusBar <> nil) then
    FStatusBar.Panels[0].Text := FViewer.Status;

  if (FSearchPreview <> nil) then
    FSearchPreview.StatusChange;

  if (FStatusBar <> nil) and not(FStatusBar.SimplePanel) then
    begin
      {add a panel for the search status if using the standard print preview
       form which only creates one. }
      if (FStatusBar.Panels.Count = 1) then
        FStatusBar.Panels.Add;

      FStatusBar.Panels[0].Width := ScaleToDPI(275);
      FStatusBar.Panels[0].Alignment := taLeftJustify;

      FStatusBar.Panels[1].Width := FViewer.Parent.Width;
      FStatusBar.Panels[1].Text := '';

    end;

end;

procedure TppCustomPreview.UpdateStatusBarTbx;
begin

  {update status bar}
  if (FStatusBarTbx <> nil) then
    FStatusBarTbx.Panels[0].Text := FViewer.Status;

  if (FSearchPreview <> nil) then
    FSearchPreview.StatusChange;

  if (FStatusBarTbx <> nil) and not(FStatusBarTbx.SimplePanel) then
    begin
      {add a panel for the search status if using the standard print preview
       form which only creates one. }
      if (FStatusBarTbx.Panels.Count = 1) then
        FStatusBarTbx.Panels.Add;

      FStatusBarTbx.Panels[0].Width := ScaleToDPI(275);
      FStatusBarTbx.Panels[0].Alignment := taLeftJustify;

      FStatusBarTbx.Panels[1].Width := FViewer.Parent.Width;
      FStatusBarTbx.Panels[1].Text := '';

    end;

end;

{@TppCustomPreview.ZoomToPercentage }

procedure TppCustomPreview.ZoomToPercentage(aZoomPercentage: Integer);
begin
  FViewer.ZoomPercentage := aZoomPercentage;

  PageChangeEvent(Self);
end;


{******************************************************************************
 *
 ** P R E V I E W E R
 *
{******************************************************************************}

{@TppPreview.Create }

constructor TppPreview.Create(aOwner: TComponent);
begin

  inherited Create(aOwner);

  EventNotifies := EventNotifies + [ciOutlineViewerVisibilityChanged]; //TODO

  FBeforePreview := False;
  FAccessoryToolbarWidthSet := False;
  FShowOutlineWhenPreview := True;
  FShowThumbnailsWhenPreview := True;

  FToolImageList := TppToolImageList.Create(Parent);

  CreateToolbar;

  FOutlineNotebook := CreateOutlineNotebook;
  FPopupMenu := TppPopupMenuBase.Create(Parent);

  CreatePreviewPopupMenu;
  {splitter to support outline viewer}
  FSplitter := TSplitter.Create(Parent);
  FSplitter.Parent := Parent;
  FSplitter.Left := OutlineNotebook.OutlineParent.Width;
  FSplitter.Align := alLeft;
  FSplitter.AutoSnap := False;
  FSplitter.MinSize := OutlineNotebook.OutlineParent.Width;
  FSplitter.Beveled := False;
  FSplitter.Width := ScaletoDPI(2);

  Viewer.Initialize;
  Viewer.ScreenDevice.Active := False;
  Viewer.Align   := alClient;

  FPnlViewer := TPanel.Create(Parent);
  FPnlViewer.Parent := Parent;
  FPnlViewer.BevelOuter := bvNone;
  Viewer.Parent := FPnlViewer;
  FPnlViewer.Align   := alClient;

  Viewer.Align   := alNone;
  Viewer.Top := 2;
  Viewer.Left := 2;
  Viewer.Height := Viewer.Parent.Height-4;
  Viewer.Width := Viewer.Parent.Width-4;
  Viewer.Anchors := [akLeft, akTop, akRight, akBottom];
  Viewer.mcChangeScale.AddNotify(ehViewer_ChangeScale);



  FKeyCatcher := TppEdit.Create(Parent);
  FKeyCatcher.Parent := Parent;
  FKeyCatcher.Width := 0;
  FKeyCatcher.Height := 0;
  FKeyCatcher.OnKeyDown := KeyDownEvent;
  FKeyCatcher.OnKeyUp := KeyUpEvent;
  FKeyCatcher.OnKeyPress := KeyPressEvent;
  FKeyCatcher.OnMouseWheel := MouseWheelEvent;

  Screen.Cursors[crZoomIn] := LoadCursor(hInstance, 'PPZOOMINCURSOR');
  Screen.Cursors[crZoomOut] := LoadCursor(hInstance, 'PPZOOMOUTCURSOR');

  LoadStateInfo;
end;

{@TppPreview.CreateToolbar }

procedure TppPreview.CreateToolbar;
begin


  FTopDock := TppDock.Create(Parent);
  FTopDock.Parent := Parent;
  FTopDock.Align := alTop;
  FTopDock.ShowHint := True;

  FTopDock.BeginUpdate();

  FToolbar := TppToolbar.Create(Parent);
  FToolbar.Images := ToolImageList;
  FToolbar.DockMode := dmCannotFloatOrChangeDocks;

  CreateToolbarItems();

  FToolbar.CurrentDock := FTopDock;

  FTopDock.EndUpdate();

  {this is used to wait until the search strings have been translated if text search is enabled}
  FAccessoryToolbarWidthSet := False;

  FAccessoryToolbar := TPanel.Create(Parent);
  FAccessoryToolbar.Parent := Parent;
  FAccessoryToolbar.Align := alLeft;
  FAccessoryToolbar.Width := ScaleToDPI(125);
  FAccessoryToolbar.BevelOuter := bvNone;
  FAccessoryToolbar.ShowHint := True;
  FAccessoryToolbar.Color := clBtnFace;
{$IFDEF Delphi7}
  FAccessoryToolbar.ParentColor := True;
  FAccessoryToolbar.ParentBackground := True;
{$ENDIF}


  FTextSearchToolbar := TPanel.Create(Parent);
  FTextSearchToolbar.Parent := nil;
  FTextSearchToolbar.BevelInner := bvNone;
  FTextSearchToolbar.BevelOuter := bvNone;
  FTextSearchToolbar.Color := clBtnFace;
{$IFDEF Delphi7}
  FTextSearchToolbar.ParentColor := True;
  FTextSearchToolbar.ParentBackground := True;
{$ENDIF}

end; {procedure, CreateToolbar}

{@TppPreview.CreateOutlineViewer

  This method is called to create a TppOutlineViewer object.
  Descendents of TppPreview can override this method
  in order to customize the outline viewer.

  Any TppPreview descendent can customize the look and feel of the outline.
  One such modification is to change the background color of the outline to
  clWhite instead of the default color of clBtnFace.
  To accomplish this, simply call inherited CreateOutlineViewer and set
  the color to clWhite.

  <Pre>
  function TmyOutlinePreview.CreateOutlineViewer: TppOutlineViewer;
    begin
      Result := inherited CreateOutlineViewer;

      Result.Color := clWhite;
    end;
  </Pre>
}

{function TppPreview.CreateOutlineViewer: TppOutlineViewer;
begin
//  FOutlinePanel := TppTBXAlignmentPanel.Create(FAccessoryToolbar);
//  FOutlinePanel.Parent := FAccessoryToolbar;
//  FOutlinePanel.Align := alClient;

  Result := TppOutlineViewer.Create(FAccessoryToolbar);
  Result.Parent := FAccessoryToolbar;
  Result.Preview := Self;
  Result.Viewer := FViewer;
  Result.OutlineVisible := False;
  Result.BevelOuter := bvNone;

  Result.Left := 2;
  Result.Top := 2;
//  Result.Width := Result.Parent.Width-2;
//  Result.Height := Result.Parent.Height-4;
//  Result.Anchors := [akLeft, akTop, akRight, akBottom];
  Result.Align := alClient;


  //listen for changes to the popup menu of the outline viewer so that the panel
  //can be closed if needed
  Result.WalkieTalkie.AddEventNotify(Self);

end;}

function TppPreview.CreateOutlineNotebook: TppOutlineNotebook;
begin

  Result := TppOutlineNotebook.Create(FAccessoryToolbar);
  Result.Preview := Self;
  Result.Viewer := FViewer;
  Result.ToolImageList := FToolImageList;

  Result.Initialize(FAccessoryToolbar);
  Result.ThumbnailViewer.AutoGenerate := False;

  //listen for changes to the popup menu of the outline notebook so that the panel can be closed if needed
  Result.WalkieTalkie.AddEventNotify(Self);

end;

procedure TppPreview.CreatePreviewPopupMenu;
var
  lMenuItem: TppTBXItem;
begin

  FPopupMenu.OnPopup := ehPreviewPopup_Popup;
  FPopupMenu.Images := ToolImageList;

  lMenuItem := FPopupMenu.AddChildItem;
  lMenuItem.Tag := Ord(vmmScroll);
  lMenuItem.OnClick := ehMouseMode_Change;
  lMenuItem.Caption := ppLoadStr(2034); //'Scroll Tool'
  lMenuItem.GroupIndex := 1;
  lMenuItem.Name := 'ScrollTool';
  lMenuItem.Checked := True;

  lMenuItem := FPopupMenu.AddChildItem;
  lMenuItem.Tag := Ord(vmmZoom);
  lMenuItem.OnClick := ehMouseMode_Change;
  lMenuItem.Caption := ppLoadStr(2033); //'Zoom Tool'
  lMenuItem.Name := 'ZoomTool';
  lMenuItem.GroupIndex := 1;

  FPopupMenu.AddSeparator;

  lMenuItem := FPopupMenu.AddChildItem;
  lMenuItem.ImageIndex := ToolImageList.AddTool('PPPRINT');
  lMenuItem.Tag := Ord(paPrint);
  lMenuItem.OnClick := ehToolbutton_Click;
  lMenuItem.Name := 'PreviewPrint';
  lMenuItem.Caption := ppLoadStr(22); //'Print'

  lMenuItem := FPopupMenu.AddChildItem;
  lMenuItem.ImageIndex := ToolImageList.AddTool('PPTEXTSEARCH');
  lMenuItem.OnClick := ehToolbutton_Click;
  lMenuItem.Tag := Ord(paTextSearch);
  lMenuItem.Name := 'PreviewFind';
  lMenuItem.GroupIndex := 2;
  lMenuItem.Caption := ppLoadStr(1071);  //'Find'

end;

procedure TppPreview.ehMouseMode_Change(Sender: TObject);
var
  liMouseMode: Integer;
  lMouseMode: TppViewerMouseMode;
begin

  liMouseMode := TComponent(Sender).Tag;
  lMouseMode := TppViewerMouseMode(liMouseMode);

  Viewer.MouseMode := lMouseMode;
  lMouseMode := TppViewerMouseMode(liMouseMode);

  if lMouseMode = vmmZoom then
    Viewer.Cursor := crZoomIn
  else
    Viewer.Cursor := crDefault;

end;


{@TppPreview.EventNotify }

procedure TppPreview.EventNotify(aCommunicator: TppCommunicator; aEventID: Integer; aParams: TraParamList);
begin

  inherited EventNotify(aCommunicator, aEventID, aParams);

  if (aCommunicator = FOutlineNotebook.WalkieTalkie) then
    begin

      if (aEventID = ciOutlineViewerVisibilityChanged) then
        begin
          if OutlineViewer.OutlineVisible then
            OutlineViewer.UpdateOutline(Viewer.CurrentPage);

          ConfigureAccessoryPanelVisibility;
        end;

    end;

end;

{@TppPreview.ToolButtonClickEvent }

procedure TppPreview.ToolButtonClickEvent(Sender: TObject);
var
  liPreviewAction: Integer;
  lPreviewAction: TppPreviewActionType;
begin

  liPreviewAction := TComponent(Sender).Tag;

  lPreviewAction := TppPreviewActionType(liPreviewAction);

  if (lPreviewAction = paCancel) and not(Viewer.Busy) then
    begin

      if (FSearchPreview = nil) or ((FSearchPreview <> nil) and not(FSearchPreview.SearchingPage)) then
        lPreviewAction := paClose;

    end;

  PerformPreviewAction(lPreviewAction);

  FocusToKeyCatcher;

end;

{@TppPreview.BeforePreview }

procedure TppPreview.BeforePreview;
var
  lbShouldCreateSearchControls: Boolean;
begin

  FToolbar.BeginUpdate;

  FBeforePreview := True;

  if (SearchPreview = nil) then
    lbShouldCreateSearchControls := True
  else
    lbShouldCreateSearchControls := False;

  inherited BeforePreview;

  if (SearchPreview <> nil) then
    begin
      if lbShouldCreateSearchControls then
        SearchPreview.CreateControls(FTextSearchToolbar);

      {override to customize location of search control panel}  
      ConfigureTextSearchToolbar;

      try
        SearchPreview.BeforePreview;

      except
        on E: ESearchError do
          Application.HandleException(Self);
      end;
    end;

  FFirstButton.Enabled := False;
  FPriorButton.Enabled := False;
  FNextButton.Enabled := False;
  FLastButton.Enabled := False;

  FWholePageButton.Enabled  := True;
  FPageWidthButton.Enabled  := True;
  FPercent100Button.Enabled := True;

  FWholePageButton.Checked  := (Viewer.ZoomSetting = zsWholePage);
  FPageWidthButton.Checked  := (Viewer.ZoomSetting = zsPageWidth);
  FPercent100Button.Checked := (Viewer.ZoomSetting = zs100Percent);

  FSinglePageButton.Visible := not(Viewer.SinglePageOnly);
  FTwoUpButton.Visible := not(Viewer.SinglePageOnly);
  FContinuousButton.Visible := not(Viewer.SinglePageOnly);
  FContinuousTwoUpButton.Visible := not(Viewer.SinglePageOnly);

  FSinglePageButton.Enabled := True;
  FTwoUpButton.Enabled := True;
  FContinuousButton.Enabled := True;
  FContinuousTwoUpButton.Enabled := True;

  FSinglePageButton.Checked := (Viewer.PageDisplay = pdSingle);
  FTwoUpButton.Checked := (Viewer.PageDisplay = pdTwoUp);
  FContinuousButton.Checked := (Viewer.PageDisplay = pdContinuous);
  FContinuousTwoUpButton.Checked := (Viewer.PageDisplay = pdContinuousTwoUp);

  FPrintButton.Enabled := True;
  FExportButton.Visible := (FReport.AllowPrintToFile) or (FReport.AllowPrintToArchive);

  FEmailButton.Visible := FReport.EmailSettings.Enabled;
{$IFDEF CloudSC}
  FEmailButton.Visible := (FReport.EmailSettings.Enabled) and not(FReport.EmailSettings.ConnectionSettings.EnableMultiPlugin) or
                          (FReport.EmailSettings.ConnectionSettings.RegisteredPluginCount = 1);
  FEmailMultiButton.Visible := (FReport.EmailSettings.Enabled) and (FReport.EmailSettings.ConnectionSettings.EnableMultiPlugin) and
                               (FReport.EmailSettings.ConnectionSettings.RegisteredPluginCount > 1);
  FGmailButton.Visible := FReport.EmailSettings.ConnectionSettings.ValidMailService(ctGmail);
  FOutlook365Button.Visible := FReport.EmailSettings.ConnectionSettings.ValidMailService(ctOutlook365);
  FSMTPButton.Visible := FReport.EmailSettings.ConnectionSettings.ValidMailService(ctSMTP);

  FCloudDriveButton.Visible := (FReport.CloudDriveSettings.Enabled) and (FReport.CloudDriveSettings.Active);
  FOneDriveButton.Visible := FReport.CloudDriveSettings.ValidCloudDrive(ctOneDrive);
  FGoogleDriveButton.Visible := FReport.CloudDriveSettings.ValidCloudDrive(ctGoogleDrive);
  FDropBoxButton.Visible := FReport.CloudDriveSettings.ValidCloudDrive(ctDropBox);
{$ENDIF}
  if not(Viewer.SinglePageOnly) then
    Viewer.PopupMenu := FPopupMenu
  else
    Viewer.PopupMenu := nil;

  ConfigureSearchButtons;

  ConfigureOutline;

  LanguageChanged();

  StatusChangeEvent(Self);

  FToolbar.EndUpdate;

  FBeforePreview := False;

end;

{@TppPreview.ConfigureTextSearchToolbar }

procedure TppPreview.ConfigureTextSearchToolbar;
begin
  if (FSearchPreview <> nil) then
    begin
      FTextSearchToolbar.Parent := FAccessoryToolbar;
      FTextSearchToolbar.Align := alTop;
      FTextSearchToolbar.Anchors := [akLeft, akTop];
      FTextSearchToolbar.Height := ScaleToDPI(80);

      FSearchPreview.ArrangeControlsVertically;

      FTextSearchButton.Checked := FSearchPreview.TextSearchSettings.Visible;

      {125 is the default which means it has not been set yet for the language change}
      if not(FAccessoryToolbarWidthSet) then
        begin
          FAccessoryToolbarWidthSet := True;

          if FAccessoryToolbar.Width < FSearchPreview.TranslatedMinWidth then
            FAccessoryToolbar.Width := FSearchPreview.TranslatedMinWidth;
        end;

      Splitter.MinSize := FSearchPreview.TranslatedMinWidth;
    end;
end;

{@TppPreview.Zoom }

procedure TppPreview.Zoom(aZoomSetting: TppZoomSettingType);
begin
  inherited Zoom(aZoomSetting);

  FZoomPercentageEdit.Text := IntToStr(Viewer.CalculatedZoom) + '%';

  if (StatusBar <> nil) and (StatusBar.HandleAllocated) and (Parent.HandleAllocated) and (Parent.Visible) then
    StatusBar.SetFocus;

end;

{@TppPreview.PageChangeEvent }

procedure TppPreview.PageChangeEvent(Sender: TObject);
var
  lCurrentPage: TppPage;
begin

  if not(uCancelled) then
    begin
      FToolbar.BeginUpdate;

      FPageNoEdit.Text := IntToStr(Viewer.AbsolutePageNo);
      FZoomPercentageEdit.Text := IntToStr(Viewer.CalculatedZoom) + '%';

      FPrintButton.Enabled := True;
      
      if Report <> nil then
        begin
          FEmailButton.Enabled := Report.EmailSettings.Enabled;
          {$IFDEF CloudSC}
          FEmailMultiButton.Enabled := (Report.EmailSettings.Enabled) and (Report.EmailSettings.ConnectionSettings.EnableMultiPlugin);
          FCloudDriveButton.Enabled := Report.CloudDriveSettings.Enabled;
          {$ENDIF}
        end;

      FWholePageButton.Enabled := True;
      FPageWidthButton.Enabled := True;
      FPercent100Button.Enabled := True;

      FWholePageButton.Checked  := (Viewer.ZoomSetting = zsWholePage);
      FPageWidthButton.Checked  := (Viewer.ZoomSetting = zsPageWidth);
      FPercent100Button.Checked := (Viewer.ZoomSetting = zs100Percent);

      FSinglePageButton.Checked := (Viewer.PageDisplay = pdSingle);
      FTwoUpButton.Checked := (Viewer.PageDisplay = pdTwoUp);
      FContinuousButton.Checked := (Viewer.PageDisplay = pdContinuous);
      FContinuousTwoUpButton.Checked := (Viewer.PageDisplay = pdContinuousTwoUp);

      lCurrentPage := Viewer.CurrentPage;

      FFirstButton.Enabled := not(lCurrentPage.FirstPage);
      FPriorButton.Enabled := not(lCurrentPage.FirstPage);
      FNextButton.Enabled := not(lCurrentPage.LastPage);
      FLastButton.Enabled := not(lCurrentPage.LastPage);

      {don't want this set all the time}
      if not(OutlineViewer.OutlineVisible) and (FShowOutlineWhenPreview) and lCurrentPage.FirstPage and not(Viewer.IsResizing) then
        OutlineViewer.OutlineVisible := (lCurrentPage.GetOutlineDrawCommand <> nil);

      if (OutlineViewer.OutlineVisible) then
        begin
          OutlineViewer.UpdateOutline(lCurrentPage);
          OutlineViewer.ScrollToPage(lCurrentPage.AbsolutePageNo);
        end;

      ConfigureSearchButtons;

      ConfigureTextSearchToolbar;

      FToolbar.EndUpdate;

      inherited PageChangeEvent(Sender);


    end;

end; 

{@TppPreview.PrintStateChangeEvent }

procedure TppPreview.PrintStateChangeEvent(Sender: TObject);
var
  lPosition: TPoint;
begin

  FToolbar.BeginUpdate;

  ConfigureSearchButtons;

  if Viewer.Busy then
    begin
      Viewer.Cursor := crHourGlass;

      FZoomPercentageEdit.Enabled := False;
      FPageNoEdit.Enabled := False;

      FToolbar.Cursor := crHourGlass;

      if (StatusBar <> nil) then
        StatusBar.Cursor := crHourGlass;

      FCancelButton.Enabled := True;

      if not Viewer.DesignViewer then
       FCancelButton.Caption := ppLoadStr(ppMsgCancel);

    end
  else
    begin
      if Viewer.MouseMode = vmmZoom then
        Viewer.Cursor := crZoomIn
      else
        Viewer.Cursor := crDefault;

      FZoomPercentageEdit.Enabled := True;
      FPageNoEdit.Enabled := True;

      FToolbar.Cursor := crDefault;

      if (StatusBar <> nil) then
        StatusBar.Cursor := crDefault;

      if Viewer.DesignViewer then
        begin
          FCancelButton.Enabled := False;
        end
      else
        begin
          FCancelButton.Enabled := True;
          FCancelButton.Caption := ppLoadStr(ppMsgClose);
        end;

      // disable buttons
      if FViewer.ScreenDevice.Cancelled then
        SetCancelledButtonState;

    end;

  FToolbar.EndUpdate;

  {this code will force the cursor to update}
  GetCursorPos(lPosition);
  SetCursorPos(lPosition.X, lPosition.Y);

end;


{@TppPreview.MouseWheelEvent}

procedure TppPreview.MouseWheelEvent(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin

  Viewer.VerticalScroll(WheelDelta div 5);

  //Viewer.ScrollBox.VertScrollBar.Position := Viewer.ScrollBox.VertScrollBar.Position - (WheelDelta div 5);

end;

{@TppPreview.KeyDownEvent}

procedure TppPreview.KeyDownEvent(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  lPoint: TPoint;
begin

  KeyDown(Key, Shift);

  if (Viewer.MouseMode = vmmZoom) and (ssShift in Shift) and (Viewer.AllowMouseZoom) then
    Viewer.Cursor := crZoomOut;
  {forces cursor to be shown even though focus is on KeyCatcher}
  GetCursorPos(lPoint);
  SetCursorPos(lPoint.X, lPoint.Y);
end;

{@TppPreview.KeyPressEvent }

procedure TppPreview.KeyPressEvent(Sender: TObject; var Key: Char);
begin

  if (Sender = FKeyCatcher) then
    begin

      {stop the default windows beep}
      if (Key = chEnterKey) then
        Key := #0;
        
    end;

end;

procedure TppPreview.KeyUpEvent(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  lPoint: TPoint;
begin
  if (Viewer.MouseMode = vmmZoom) and not(ssShift in Shift) and (Viewer.AllowMouseZoom) then
    Viewer.Cursor := crZoomIn;

  {forces cursor to be shown even though focus is on KeyCatcher}
  GetCursorPos(lPoint);
  SetCursorPos(lPoint.X, lPoint.Y);

end;
{@TppPreview.FocusToKeyCatcher }

procedure TppPreview.FocusToKeyCatcher;
begin

  try
    FKeyCatcher.SetFocus;

  except
    on E: EInvalidOperation do
  end;

end;

{@TppPreview.LanguageChanged}

procedure TppPreview.LanguageChanged;
begin

  inherited LanguageChanged;

  FToolbar.BeginUpdate;

  if (OutlineViewer <> nil) then
    OutlineViewer.LanguageChanged(TppOutlineDrawCommand(Viewer.CurrentPage.GetOutlineDrawCommand));

  FPrintButton.Hint           := ppLoadStr(22);
  FWholePageButton.Hint       := ppLoadStr(30);
  FPageWidthButton.Hint       := ppLoadStr(31);
  FPercent100Button.Hint      := ppLoadStr(1);
  FFirstButton.Hint           := ppLoadStr(13);
  FPriorButton.Hint           := ppLoadStr(29);
  FNextButton.Hint            := ppLoadStr(15);
  FLastButton.Hint            := ppLoadStr(14);
  FAutoSearchButton.Hint      := ppLoadStr(1021);
  FSinglePageButton.Hint      := ppLoadStr(2002); // Single Page
  FTwoUpButton.Hint           := ppLoadStr(2003); //Two Up
  FContinuousButton.Hint      := ppLoadStr(2004); // Continuous
  FContinuousTwoUpButton.Hint := ppLoadStr(2004) + ' ' + ppLoadStr(2003); // Continuous Two Up

  if FTextSearchButton.Checked then
    FTextSearchButton.Hint := ppLoadStr(1055) {'Hide the Text Search Toolbar'}
  else
    FTextSearchButton.Hint := ppLoadStr(1054); {'Show the Text Search Toolbar';}

  if Viewer.DesignViewer then
    FCancelButton.Caption := ppLoadStr(ppMsgCancel)
  else
    FCancelButton.Caption := ppLoadStr(ppMsgClose);

  FToolbar.EndUpdate;

end;

procedure TppPreview.LoadStateInfo;
var
  lIniStorage: TppIniStorage;
  liAccessoryToolbarWidth: Integer;
begin

  lIniStorage := TppIniStoragePlugIn.CreateInstance;

  liAccessoryToolbarWidth := lIniStorage.ReadInteger('Preview AccessoryToolbar', 'Width',   FAccessoryToolbar.Width);

  if (liAccessoryToolbarWidth > 0) and (liAccessoryToolbarWidth < Screen.Width) then
    begin
      liAccessoryToolbarWidth := ScaleToDPI(liAccessoryToolbarWidth);

      if (liAccessoryToolbarWidth < Screen.Width) then //Avoid invalid values
    FAccessoryToolbar.Width := liAccessoryToolbarWidth;
    end;

  lIniStorage.Free;

end;
{@TppPreview.ConfigureSearchButtons }

procedure TppPreview.ConfigureSearchButtons;
begin

  if (FReport <> nil) then
    begin
      FAutoSearchButton.Enabled := not(Viewer.Busy);
      FAutoSearchButton.Visible := FReport.ShowAutoSearchDialog;
    end;

  if (FReport <> nil) then
   begin
     FTextSearchButton.Enabled := (FReport.TextSearchSettings.Enabled) and not(Viewer.Busy);
     FTextSearchButton.Visible := FReport.TextSearchSettings.Enabled;
   end;

end;

function TppPreview.GetOutlineViewer: TppOutlineViewer;
begin
  Result := FOutlineNotebook.OutlineViewer;
end;

{@TppPreview.GetOutlineVisible }

function TppPreview.GetOutlineVisible: Boolean;
begin
  Result := OutlineViewer.OutlineVisible;

end;

{@TppPreview.SetOutlineVisible }

procedure TppPreview.SetOutlineVisible(aOutlineVisible: Boolean);
begin
  OutlineViewer.OutlineVisible := aOutlineVisible;

  ConfigureAccessoryPanelVisibility;

end;

{@TppPreview.ConfigureAccessoryPanelVisibility}

procedure TppPreview.ConfigureAccessoryPanelVisibility;
var
  lbPrevious: Boolean;
begin

  lbPrevious := FAccessoryToolbar.Visible;

  if (FTextSearchToolbar.Parent = FOutlineNotebook.OutlineParent) then
    FAccessoryToolbar.Visible := FOutlineNotebook.Visible or FTextSearchToolbar.Visible
  else
    FAccessoryToolbar.Visible := FOutlineNotebook.Visible;


  // manage splitter visibility
  FSplitter.Visible := FOutlineNotebook.Visible;
  if (FSplitter.Visible) then
    FSplitter.Left := FOutlineNotebook.OutlineParent.Left + FOutlineNotebook.OutlineParent.Width;

  if (lbPrevious <> FAccessoryToolbar.Visible) then
    Rezoom;
      
end;
   
procedure TppPreview.ConfigureOutline;
var
  lPropRec: TraPropRec;
  lOutlineSettings: TppOutlineReportSettings;
  lThumbnailSettings: TppThumbnailSettings;
  lbSuppressOutline: Boolean;
  lbSuppressThumbnails: Boolean;
  lbOutlineExists: Boolean;
  lbEnablePopupMenu: Boolean;
begin

  lbEnablePopupMenu := False;

  {check for TppReport - check existence of OutlineSettings property}
  if TraRTTI.GetPropRec(FReport.ClassType, 'OutlineSettings', lPropRec) then
    begin

      TraRTTI.GetPropValue(FReport, 'OutlineSettings', lOutlineSettings);
      TraRTTI.GetPropValue(FReport, 'ThumbnailSettings', lThumbnailSettings);

      if Viewer.SinglePageOnly then
        lThumbnailSettings.Enabled := False;

      //Define visibility and enabled
      FShowOutlineWhenPreview := lOutlineSettings.Enabled and lOutlineSettings.Visible;
      FShowThumbnailsWhenPreview := lThumbnailSettings.Enabled and lThumbnailSettings.Visible;
      FOutlineNotebook.AssignPopupToViewer := (lOutlineSettings.Enabled) or (lThumbnailSettings.Enabled);
      FOutlineNotebook.Visible := FShowOutlineWhenPreview or FShowThumbnailsWhenPreview;
      FOutlineNotebook.ThumbnailsVisibility(FShowThumbnailsWhenPreview);
      FOutlineNotebook.OutlineVisibility(FShowOutlineWhenPreview);
      FOutlineNotebook.OutlineEnabled := lOutlineSettings.Enabled;
      FOutlineNotebook.ThumbnailsEnabled := lThumbnailSettings.Enabled;

      lbEnablePopupMenu := lOutlineSettings.Enabled or lThumbnailSettings.Enabled;

      //Define other properties
      FOutlineNotebook.ThumbnailViewer.DeadSpace := lThumbnailSettings.DeadSpace;
      FOutlineNotebook.ThumbnailViewer.PageHighlight := lThumbnailSettings.PageHighlight;
      FOutlineNotebook.ThumbnailViewer.ThumbnailSize := lThumbnailSettings.ThumbnailSize;

    end
  {check for ArchiveReader - check existence of OutlineExists property}
  else if TraRTTI.GetPropRec(FReport.ClassType, 'OutlineExists', lPropRec) then
    begin
      TraRTTI.GetPropValue(FReport, 'OutlineExists', lbOutlineExists);

      if TraRTTI.GetPropRec(FReport.ClassType, 'SuppressOutline', lPropRec) then
        TraRTTI.GetPropValue(FReport, 'SuppressOutline', lbSuppressOutline)
      else
        lbSuppressOutline := False;

      if TraRTTI.GetPropRec(FReport.ClassType, 'SuppressThumbnails', lPropRec) then
        TraRTTI.GetPropValue(FReport, 'SuppressThumbnails', lbSuppressThumbnails)
      else
        lbSuppressThumbnails := False;

      FShowOutlineWhenPreview := (lbOutlineExists and not(lbSuppressOutline));
      FShowThumbnailsWhenPreview := not(lbSuppressThumbnails);

      FOutlineNotebook.Visible := FShowOutlineWhenPreview or FShowThumbnailsWhenPreview;
      FOutlineNotebook.OutlineEnabled := FShowOutlineWhenPreview;
      FOutlineNotebook.ThumbnailsEnabled := FShowThumbnailsWhenPreview;

      lbEnablePopupMenu := FShowOutlineWhenPreview or FShowThumbnailsWhenPreview;

    end
  else {default outline viewer to not visible}
    FOutlineNotebook.Visible := False;

  // call reset after setting OutlineVisible above
  OutlineViewer.Reset;
  ConfigureAccessoryPanelVisibility;

  // call enable popupup menu after Reset above
  if (lbEnablePopupMenu) then
    FOutlineNotebook.EnablePopupMenu;

end;

{@TppPreview.SearchPreviewActionPerformed

  Set the focus to the key catcher if other preview form control took focus.}

procedure TppPreview.SaveStateInfo;
var
  lIniStorage: TppIniStorage;
begin

  lIniStorage := TppIniStoragePlugIn.CreateInstance;

  lIniStorage.WriteInteger('Preview AccessoryToolbar', 'Width', ppScaleFromDPI(FAccessoryToolbar.Width, CurrentPPI));

  lIniStorage.Free;

end;
procedure TppPreview.SearchPreviewActionPerformed;
begin

  inherited SearchPreviewActionPerformed;

  FocusToKeyCatcher;

end;

{@TppPreview.ToggleSearch }

procedure TppPreview.ToggleSearch;
begin

  inherited ToggleSearch;

  if FTextSearchButton.Checked then
    FTextSearchButton.Hint := ppLoadStr(1055) {'Disable the Text Search Toolbar'}
  else
    FTextSearchButton.Hint := ppLoadStr(1054); {'Enable the Text Search Toolbar';}

end;

{@TppPreview.ViewerMouseDownEvent }

procedure TppPreview.ViewerMouseDownEvent(Sender: TObject);
begin
  FocusToKeyCatcher;

end;

{@TppPreview.ViewerResetEvent }

procedure TppPreview.ViewerResetEvent(Sender: TObject);
var
  lbEnablePopupMenu: Boolean;
begin

  // save popup menu state
  lbEnablePopupMenu := FOutlineNotebook.PopupMenu <> nil;

  OutlineViewer.Reset;
  OutlineNotebook.ThumbnailViewer.Reset;

  // restore popupmenu state
  if lbEnablePopupMenu then
    FOutlineNotebook.EnablePopupMenu;

end;

procedure TppPreview.ViewerScrollEvent(Sender: TObject);
begin
  FocusToKeyCatcher;

end;

{@TppPreview.Rezoom

  Fires when the accessory panel changes visibility.  The purpose is
  to rezoom the page so that it properly reflects the zoom setting the user
  has chosen.}

procedure TppPreview.Rezoom;
begin
  if not(FBeforePreview) then
    begin
      Viewer.IncrementalPainting := False;
      Zoom(Viewer.ZoomSetting);
    end;
end;
  
{@TppPreview.Cancel

  Disable the nav controls because the report can't generate any more pages
  anyway.}

procedure TppPreview.Cancel;
begin

  inherited Cancel;

  SetCancelledButtonState;

end;

{------------------------------------------------------------------------------}
{ TppPreviewToolbar.CreateItems}

procedure TppPreview.CreateToolbarItems;
begin

  FToolbar.BeginUpdate;

  FPrintButton := FToolbar.AddButton();
  FPrintButton.ImageIndex := ToolImageList.AddTool('PPPRINT');
  FPrintButton.Tag := Ord(paPrint);
  FPrintButton.OnClick := ehToolbutton_Click;

  FExportButton := FToolbar.AddButton();
  FExportButton.ImageIndex := ToolImageList.AddTool('PPEXPORT');
  FExportButton.Tag := Ord(paExport);
  FExportButton.OnClick := ehToolbutton_Click;
  FExportButton.Hint := ppLoadStr(2040); //'Export To File';
  FEmailButton := FToolbar.AddButton();
  FEmailButton.ImageIndex := ToolImageList.AddTool('PPEMAIL');
  FEmailButton.OnClick := ehToolbutton_Click;
  FEmailButton.Tag := Ord(paEmail);
  FEmailButton.Hint := ppLoadStr(1093);

{$IFDEF CloudSC}
  FEmailMultiButton := FToolbar.AddSubMenu;
  FEmailMultiButton.ImageIndex := ToolImageList.AddTool('PPEMAIL');
  FEmailMultiButton.Hint := ppLoadStr(1093);
  FEmailMultiButton.Visible := False;

  FSMTPButton := FEmailMultiButton.AddChildItem;
  FSMTPButton.ImageIndex := ToolImageList.AddTool('PPEMAIL');
  FSMTPButton.OnClick := ehToolbutton_Click;
  FSMTPButton.Tag := Ord(paSMTP);
  FSMTPButton.Caption := 'SMTP';  //TODO
  FSMTPButton.Hint := 'SMTP';  //TODO

  FGmailButton := FEmailMultiButton.AddChildItem;
  FGmailButton.ImageIndex := ToolImageList.AddTool('PPGMAIL');
  FGmailButton.OnClick := ehToolButton_Click;
  FGmailButton.Tag := Ord(paGmail);
  FGmailButton.Caption := 'Gmail'; //TODO
  FGmailButton.Hint := 'Gmail';    //TODO

  FOutlook365Button := FEmailMultiButton.AddChildItem;
  FOutlook365Button.ImageIndex := ToolImageList.AddTool('PPOUTLOOK365');
  FOutlook365Button.OnClick := ehToolButton_Click;
  FOutlook365Button.Tag := Ord(paOutlook365);
  FOutlook365Button.Caption := 'Outlook 365'; //TODO
  FOutlook365Button.Hint := 'Outlook 365';    //TODO

  FCloudDriveButton := FToolbar.AddSubMenu;
  FCloudDriveButton.ImageIndex := ToolImageList.AddTool('PPCLOUDDRIVE');
  FCloudDriveButton.Hint := ppLoadStr(2041); //'Cloud Drive Export';

  FOneDriveButton := FCloudDriveButton.AddChildItem;
  FOneDriveButton.ImageIndex := ToolImageList.AddTool('PPONEDRIVE');
  FOneDriveButton.OnClick := ehToolButton_Click;
  FOneDriveButton.Tag := Ord(paOneDrive);
  FOneDriveButton.Caption := ppLoadStr(2042); //'OneDrive';
  FOneDriveButton.Hint := ppLoadStr(2042);

  FGoogleDriveButton := FCloudDriveButton.AddChildItem;
  FGoogleDriveButton.ImageIndex := ToolImageList.AddTool('PPGOOGLEDRIVE');
  FGoogleDriveButton.OnClick := ehToolButton_Click;
  FGoogleDriveButton.Tag := Ord(paGoogleDrive);
  FGoogleDriveButton.Caption := ppLoadStr(2043); //'Google Drive';
  FGoogleDriveButton.Hint := ppLoadStr(2043);

  FDropBoxButton := FCloudDriveButton.AddChildItem;
  FDropBoxButton.ImageIndex := ToolImageList.AddTool('PPDROPBOX');
  FDropBoxButton.OnClick := ehToolButton_Click;
  FDropBoxButton.Tag := Ord(paDropBox);
  FDropBoxButton.Caption := ppLoadStr(2044); //'DropBox';
  FDropBoxButton.Hint := ppLoadStr(2044);
{$ENDIF}
  FToolbar.AddSpacer();
//  AddSeparator();
  FToolbar.AddSpacer();

  FAutoSearchButton := FToolbar.AddButton();
  FAutoSearchButton.ImageIndex := ToolImageList.AddTool('PPAUTOSEARCH'); // (TppAutoSearchIcon);
  FAutoSearchButton.OnClick := ehToolbutton_Click;
  FAutoSearchButton.Tag := Ord(paAutoSearch);

  FTextSearchButton := FToolbar.AddButton();
  FTextSearchButton.ImageIndex := ToolImageList.AddTool('PPTEXTSEARCH');
  FTextSearchButton.OnClick := ehToolbutton_Click;
  FTextSearchButton.Tag := Ord(paTextSearch);
  FTextSearchButton.GroupIndex := 2;
  FTextSearchButton.AutoCheck := True;
  FTextSearchButton.Hint := ppLoadStr(1054); {'Enable the Text Search Toolbar';}

  FToolbar.AddSpacer();
//  AddSeparator();
  FToolbar.AddSpacer();

  FWholePageButton := FToolbar.AddButton();
  FWholePageButton.ImageIndex := ToolImageList.AddTool('PPZOOMWHOLEPAGE');
  FWholePageButton.OnClick := ehToolbutton_Click;
  FWholePageButton.Tag := Ord(paWholePage);
  FWholePageButton.GroupIndex := 1;
  FWholePageButton.AutoCheck := True;
  FWholePageButton.Checked := True;

  FPageWidthButton := FToolbar.AddButton();
  FPageWidthButton.ImageIndex := ToolImageList.AddTool('PPZOOMPAGEWIDTH');
  FPageWidthButton.OnClick := ehToolbutton_Click;
  FPageWidthButton.Tag := Ord(paPageWidth);
  FPageWidthButton.GroupIndex := 1;
  FPageWidthButton.AutoCheck := True;

  FPercent100Button := FToolbar.AddButton();
  FPercent100Button.ImageIndex := ToolImageList.AddTool('PPZOOM100PERCENT');
  FPercent100Button.OnClick := ehToolbutton_Click;
  FPercent100Button.Tag := Ord(pa100Percent);
  FPercent100Button.GroupIndex := 1;
  FPercent100Button.AutoCheck := True;

  FZoomPercentageEdit := FToolbar.AddEdit();
  FZoomPercentageEdit.EditWidth := ScaleToDPI(37);
  FZoomPercentageEdit.ExtendedAccept := True;
  FZoomPercentageEdit.OnAcceptText := ehZoomEdit_AcceptText;

  FToolbar.AddSpacer();
//  AddSeparator();
  FToolbar.AddSpacer();

  FFirstButton := FToolbar.AddButton();
  FFirstButton.ImageIndex := ToolImageList.AddTool('PPFIRSTPAGE');
  FFirstButton.OnClick := ehToolbutton_Click;
  FFirstButton.Tag := Ord(paFirst);

  FPriorButton := FToolbar.AddButton();
  FPriorButton.ImageIndex := ToolImageList.AddTool('PPPRIORPAGE');
  FPriorButton.OnClick := ehToolbutton_Click;
  FPriorButton.Tag := Ord(paPrior);

  FPageNoEdit := FToolbar.AddEdit();
  FPageNoEdit.EditWidth := ScaleToDPI(37);
  FPageNoEdit.ExtendedAccept := True;
  FPageNoEdit.OnAcceptText := ehPageNoEdit_AcceptText;

  FNextButton := FToolbar.AddButton();
  FNextButton.ImageIndex := ToolImageList.AddTool('PPNEXTPAGE');
  FNextButton.OnClick := ehToolbutton_Click;
  FNextButton.Tag := Ord(paNext);

  FLastButton := FToolbar.AddButton();
  FLastButton.ImageIndex := ToolImageList.AddTool('PPLASTPAGE');
  FLastButton.OnClick := ehToolbutton_Click;
  FLastButton.Tag := Ord(paLast);

  FToolbar.AddSpacer();
  FToolbar.AddSpacer();

  FSinglePageButton := FToolbar.AddButton();
  FSinglePageButton.ImageIndex := ToolImageList.AddTool('PPPAGESINGLE');
  FSinglePageButton.OnClick := ehToolbutton_Click;
  FSinglePageButton.GroupIndex := 3;
  FSinglePageButton.Checked := True;
  FSinglePageButton.AutoCheck := True;
  FSinglePageButton.Tag := Ord(paSingle);

  FContinuousButton := FToolbar.AddButton();
  FContinuousButton.ImageIndex := ToolImageList.AddTool('PPPAGECONTINUOUS');
  FContinuousButton.OnClick := ehToolbutton_Click;
  FContinuousButton.GroupIndex := 3;
  FContinuousButton.AutoCheck := True;
  FContinuousButton.Tag := Ord(paContinuous);

  FTwoUpButton := FToolbar.AddButton();
  FTwoUpButton.ImageIndex := ToolImageList.AddTool('PPPAGETWOUP');
  FTwoUpButton.OnClick := ehToolbutton_Click;
  FTwoUpButton.GroupIndex := 3;
  FTwoUpButton.AutoCheck := True;
  FTwoUpButton.Tag := Ord(paTwoUp);

  FContinuousTwoUpButton := FToolbar.AddButton();
  FContinuousTwoUpButton.ImageIndex := ToolImageList.AddTool('PPPAGECONTINUOUSTWOUP');
  FContinuousTwoUpButton.OnClick := ehToolbutton_Click;
  FContinuousTwoUpButton.GroupIndex := 3;
  FContinuousTwoUpButton.AutoCheck := True;
  FContinuousTwoUpButton.Tag := Ord(paContinuousTwoUp);

  FToolbar.AddSpacer();
  FToolbar.AddSpacer();

  FCancelButton := FToolbar.AddButton();
  FCancelButton.Caption := ppLoadStr(ppMsgCancel);
  FCancelButton.OnClick := ehToolbutton_Click;
  FCancelButton.Tag := Ord(paCancel);
  FCancelButton.Enabled := False;

  FToolbar.EndUpdate;


end;

destructor TppPreview.Destroy;
begin
  SaveStateInfo;
  inherited;
end;

{------------------------------------------------------------------------------}
{ TppPreviewToolbar.ehPageNoEdit_AcceptText}

procedure TppPreview.ehPageNoEdit_AcceptText(Sender: TObject; var aNewText: String; var Accept: Boolean);
var
  liNewPageNo: Integer;
begin

  liNewPageNo := StrToIntDef(aNewText, 0);

  if (liNewPageNo < 0) then
    GotoPage(1)
  else if (liNewPageNo > 0) then
    GotoPage(liNewPageNo);

  // update to reflect the page no being displayed
  aNewText := IntToStr(Viewer.AbsolutePageNo);

  FocusToKeyCatcher;

end;

procedure TppPreview.ehPreviewPopup_Popup(Sender: TObject);
begin
  FPopupMenu.Items[FPopupMenu.Items.IndexForName('ScrollTool')].Checked := (Viewer.MouseMode = vmmScroll);
  FPopupMenu.Items[FPopupMenu.Items.IndexForName('ZoomTool')].Checked := (Viewer.MouseMode = vmmZoom);

end;

{------------------------------------------------------------------------------}
{ TppPreviewToolbar.ehPageNoEdit_AcceptText}

procedure TppPreview.ehZoomEdit_AcceptText(Sender: TObject; var aNewText: String; var Accept: Boolean);
var
  liNewZoom: Integer;
begin

  aNewText := StringReplace(aNewText, '%', '', []);

  liNewZoom := StrToIntDef(aNewText, 0);

  if (liNewZoom > 0) then
    ZoomToPercentage(liNewZoom);

  FocusToKeyCatcher;

  // update to reflect the page no being displayed
  aNewText := IntToStr(Viewer.CalculatedZoom) + '%';

end;

{------------------------------------------------------------------------------}
{ TppPreviewToolbar.ehToolbutton_Click}

procedure TppPreview.ehToolbutton_Click(Sender: TObject);
var
  liPreviewAction: Integer;
  lPreviewAction: TppPreviewActionType;
begin

  liPreviewAction := TComponent(Sender).Tag;

  lPreviewAction := TppPreviewActionType(liPreviewAction);

  if (lPreviewAction = paCancel) and not(Viewer.Busy) then
    begin

      if (FSearchPreview = nil) or ((FSearchPreview <> nil) and not(FSearchPreview.SearchingPage)) then
        lPreviewAction := paClose;

    end;

  PerformPreviewAction(lPreviewAction);

end;

procedure TppPreview.ehViewer_ChangeScale(aSender, aParameters: TObject);
{$IFDEF Delphi24}
var
  lChangeScaleParams: TppChangeScaleParams;
{$ENDIF}
begin

{$IFDEF Delphi24}
  lChangeScaleParams := TppChangeScaleParams(aParameters);

  if (FSearchPreview <> nil) then
    FSearchPreview.ChangeScale(lChangeScaleParams.M, lChangeScaleParams.D, True {lChangeScaleParams.ISDPIChange});
{$ENDIF}
end;

function TppPreview.GetOutlineEnabled: Boolean;
var
  lOutlineSettings: TppOutlineReportSettings;
  lbOutlineExists: Boolean;
  lbSuppressOutline: Boolean;
  lPropRec: TraPropRec;
begin

  {check for TppReport - check existence of OutlineSettings property}
  if TraRTTI.GetPropRec(FReport.ClassType, 'OutlineSettings', lPropRec) then
    begin

      TraRTTI.GetPropValue(FReport, 'OutlineSettings', lOutlineSettings);

      Result := lOutlineSettings.Enabled;

    end
  {check for ArchiveReader - check existence of OutlineExists property}
  else if TraRTTI.GetPropRec(FReport.ClassType, 'OutlineExists', lPropRec) then
    begin
      TraRTTI.GetPropValue(FReport, 'OutlineExists', lbOutlineExists);

      if TraRTTI.GetPropRec(FReport.ClassType, 'SuppressOutline', lPropRec) then
        TraRTTI.GetPropValue(FReport, 'SuppressOutline', lbSuppressOutline)
      else
        lbSuppressOutline := False;

      FShowOutlineWhenPreview := (lbOutlineExists and not(lbSuppressOutline));
      FOutlineNotebook.Visible := FShowOutlineWhenPreview;

      Result := (lbOutlineExists) and not(lbSuppressOutline);

    end
  else {default outline viewer to not visible}
    Result := False;
end;

{@TppPreview.SetCancelledButtonState}

procedure TppPreview.SetCancelledButtonState;
begin

  FPrintButton.Enabled := False;
  FEmailButton.Enabled := False;
{$IFDEF CloudSC}
  FEmailMultiButton.Enabled := False;
  FCloudDriveButton.Enabled := False;
{$ENDIF}

  FWholePageButton.Enabled  := False;
  FPageWidthButton.Enabled  := False;
  FPercent100Button.Enabled := False;

  FFirstButton.Enabled := False;
  FPriorButton.Enabled := False;
  FNextButton.Enabled := False;
  FLastButton.Enabled := False;

  FPageNoEdit.Enabled := False;

  if not(FViewer.SinglePageOnly) then
    begin
      FSinglePageButton.Enabled := False;
      FTwoUpButton.Enabled := False;
      FContinuousButton.Enabled := False;
      FContinuousTwoUpButton.Enabled := False;
    end;

  if (FTextSearchButton.Checked) then
    begin
      ToggleSearch;
      FTextSearchButton.Checked := False;
    end;

  FTextSearchButton.Enabled := False;

end;


{******************************************************************************
 *
 ** I N I T I A L I Z A T I O N   /   F I N A L I Z A T I O N
 *
{******************************************************************************}

initialization
  TppPreviewPlugIn.Register(TppPreview);

finalization
  TppPreviewPlugIn.UnRegister(TppPreview);


end.

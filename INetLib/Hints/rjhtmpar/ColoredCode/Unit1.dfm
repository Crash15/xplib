�
 TFORMMAIN 0}  TPF0	TFormMainFormMainLeft}Top� Width�HeightHCaption!rjHtmlParser: ColoredCode ExampleColor	clBtnFaceFont.CharsetDEFAULT_CHARSET
Font.ColorclWindowTextFont.Height�	Font.NameMS Sans Serif
Font.Style OldCreateOrderOnCreate
FormCreate	OnDestroyFormDestroyPixelsPerInch`
TextHeight 	TRichEditRichEditLeft Top Width�Height�AlignalClientFont.CharsetANSI_CHARSET
Font.ColorclWindowTextFont.Height�	Font.NameCourier New
Font.Style 
ParentFont
ScrollBars
ssVerticalTabOrder   TPanelPanel1Left Top�Width�HeightfAlignalBottom
BevelOuterbvNoneTabOrder TLabellbl_FileNameLeftTop7Width�HeightAutoSizeCaptionVSelect File first. Check the elements you want to report. The click the Report button.  TButton
btn_SelectLeftTopKWidth� HeightCaptionSelect a HTML fileTabOrder OnClickbtn_SelectClick  	TGroupBox	GroupBox1LeftTopWidth�Height)Caption'Select which type of elements to reportTabOrder 	TCheckBoxchk_ASPsLeft
TopWidth3HeightCaptionASPsTabOrder OnClickchk_ASPsClick  	TCheckBoxchk_CommentsLeft<TopWidthGHeightCaptionCommentsTabOrderOnClickchk_CommentsClick  	TCheckBoxchk_ScriptsLeft� TopWidth8HeightCaptionScriptsTabOrderOnClickchk_ScriptsClick  	TCheckBox
chk_StylesLeft"TopWidth3HeightCaptionStylesTabOrderOnClickchk_StylesClick  	TCheckBoxchk_SSIsLeft� TopWidth.HeightCaptionSSIsTabOrderOnClickchk_SSIsClick  	TCheckBoxchk_TagsLeftYTopWidth3HeightCaptionTagsTabOrderOnClickchk_TagsClick  	TCheckBoxchk_TextLeft�TopWidth)HeightCaptionTextTabOrderOnClickchk_TextClick  	TCheckBoxchk_DTDsLeft� TopWidth.HeightCaptionDTDsTabOrderOnClickchk_DTDsClick   TButton
btn_ReportLeft	TopKWidth� HeightCaption#Report Elements in different colorsTabOrderOnClickbtn_ReportClick   THtmlReporterHtmlReporter
OnReadCharHtmlReporterReadChar
ReportASPs	ReportComments	
ReportDTDs	ReportScripts	
ReportSSIs	ReportStyles	
ReportTags	
ReportText	ReportTagsFilteredLeftTop   
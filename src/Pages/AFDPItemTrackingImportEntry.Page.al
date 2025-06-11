namespace AFood.DP.AFoodDevelopment;
page 50300 "AFDP Item Tracking ImportEntry"
{
    ApplicationArea = All;
    Caption = 'Item Tracking Imported Entry';
    PageType = List;
    SourceTable = "AFDP Item Tracking ImportEntry";
    UsageCategory = Lists;
    Editable = true;
    DataCaptionFields = "Entry No.", "PO No.";
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the value of the Entry No. field.', Comment = '%';
                    Visible = false;
                }
                field("PO No."; Rec."PO No.")
                {
                    ToolTip = 'Specifies the value of the PO No. field.', Comment = '%';
                }
                field("PO Date"; Rec."PO Date")
                {
                    ToolTip = 'Specifies the value of the PO Date field.', Comment = '%';
                }
                field("Vendor Item No."; Rec."Vendor Item No.")
                {
                    ToolTip = 'Specifies the value of the Vendor Item No. field.', Comment = '%';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field.', Comment = '%';
                }
                field("Quantity Shipped"; Rec."Quantity Shipped")
                {
                    ToolTip = 'Specifies the value of the Quantity Shipped field.', Comment = '%';
                }
                field("Lot Number"; Rec."Lot Number")
                {
                    ToolTip = 'Specifies the value of the Lot Number field.', Comment = '%';
                }
                field("Expiration Date"; Rec."Expiration Date")
                {
                    ToolTip = 'Specifies the value of the Expiration Date field.', Comment = '%';
                }
                field("Production Date"; Rec."Production Date")
                {
                    ToolTip = 'Specifies the value of the Production Date field.', Comment = '%';
                }
                field("Tracking Created"; Rec."Tracking Created")
                {
                    ToolTip = 'Specifies the value of the Tracking Created field.', Comment = '%';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            group("Import Item Tracking")
            {
                action("AFDP Import Item Tracking")
                {
                    ApplicationArea = All;
                    Caption = 'Import Item Tracking';
                    Image = Import;
                    ToolTip = 'Import item tracking information from a file.';
                    trigger OnAction()
                    var
                        ItemTrackingImportTool: XmlPort "AFDP Item Tracking Import Tool";
                        Filename: Text;
                        InStream: InStream;
                    begin
                        if not UploadIntoStream('Select File to Import', '', '', Filename, InStream) then
                            exit;
                        ItemTrackingImportTool.SetSource(InStream);
                        ItemTrackingImportTool.Import();
                    end;
                }
            }
        }
    }
}
//AFDP 06/06/2025 'Item Tracking Import Tools'
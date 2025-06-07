namespace AFood.DP.AFoodDevelopment;
using Microsoft.Purchases.Document;
pageextension 50306 "AFDP Purchase Order" extends "Purchase Order"
{
    layout
    {
    }
    // actions
    // {
    //     addlast(processing)
    //     {
    //         group("Import Item Tracking")
    //         {
    //             action("AFDP Import Item Tracking")
    //             {
    //                 ApplicationArea = All;
    //                 Caption = 'Import Item Tracking';
    //                 Image = Import;
    //                 ToolTip = 'Import item tracking information from a file.';
    //                 trigger OnAction()
    //                 var
    //                     ItemTrackingImportTool: XmlPort "AFDP Item Tracking Import Tool";
    //                     Filename: Text;
    //                     InStream: InStream;
    //                 begin
    //                     if not UploadIntoStream('Select File to Import', '', '', Filename, InStream) then
    //                         exit;
    //                     ItemTrackingImportTool.SetSource(InStream);
    //                     ItemTrackingImportTool.Import();
    //                 end;
    //             }
    //         }
    //     }
    // }
}

//AFDP 06/06/2025 'Item Tracking Import Tools'
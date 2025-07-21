namespace AFood.DP.AFoodDevelopment;
using Microsoft.Inventory.Item;
report 50303 "AFDP Item Number Rename"
{
    Caption = 'Item Number Rename';
    ProcessingOnly = true;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = all;
    Permissions = tabledata "Item" = rmid;
    dataset
    {
    }
    requestpage
    {
        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }
    trigger OnPreReport()
    var
        ItemNumberRenameTool: XmlPort "AFDP Item Number Rename Tool";
        Filename: Text;
        InStream: InStream;
    begin
        if not UploadIntoStream('Select File to Import', '', '', Filename, InStream) then
            exit;
        ItemNumberRenameTool.SetSource(InStream);
        ItemNumberRenameTool.Import();
    end;

    trigger OnPostReport()
    begin
    end;

    var
}

//AFDP 06/12/2025 'T0006-Item Number Rename'
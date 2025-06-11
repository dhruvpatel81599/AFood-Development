namespace AFood.DP.AFoodDevelopment;
using Microsoft.Inventory.Item;
xmlport 50301 "AFDP Item Number Rename Tool"
{
    Caption = 'Item Number Rename Tool';
    UseRequestPage = false;
    Direction = Import;
    DefaultFieldsValidation = false;
    Format = VariableText;
    schema
    {
        textelement(Root)
        {
            tableelement(AFDPItemRenameImportEntry; "AFDP Item Rename Import Entry")
            {
                AutoSave = false;
                AutoUpdate = false;
                AutoReplace = false;
                textelement(CurrentItemNo) { }
                textelement(NewItemNo) { }
                trigger OnAfterInitRecord()
                begin
                    Clear(LastEntryNo);
                    Clear(CurrentItemNo);
                    Clear(NewItemNo);
                end;

                trigger OnBeforeInsertRecord()
                begin
                    if CurrentItemNo <> 'Current Item Number' then   //skip header row
                        if format(CurrentItemNo) <> '' then begin
                            LastEntryNo := GetLastEntryNo();
                            ProgressWindow.UPDATE(1, format(CurrentItemNo));
                            //---------------------\\
                            ItemRenameImportEntry1.Init();
                            ItemRenameImportEntry1."Entry No." := LastEntryNo + 1;
                            ItemRenameImportEntry1."Current Item No." := format(CurrentItemNo);
                            ItemRenameImportEntry1."New Item No." := format(NewItemNo);
                            ItemRenameImportEntry1.Insert(true);
                            TotalRecordImported += 1;
                        end;
                end;
            }
        }
    }
    trigger OnPreXmlPort()
    begin
        //-- Clear previous entries--\\
        ItemRenameImportEntry1.Reset();
        ItemRenameImportEntry1.SetCurrentKey("Entry No.");
        ItemRenameImportEntry1.SetRange("Item Found");
        ItemRenameImportEntry1.DeleteAll();
        //-----------\\
        ProgressWindow.OPEN('Importing Current Item No.: #1#############');
        TotalRecordImported := 0;
    end;

    trigger OnPostXmlPort()
    begin
        ProgressWindow.CLOSE();
        if TotalRecordImported > 0 then begin
            ProgressWindow.OPEN('Renaming Item No.: #2#############');
            RenameItem();
            ProgressWindow.CLOSE();
        end;
        MESSAGE('Total Record Imported: %1', TotalRecordImported);
    end;

    var
        ItemRenameImportEntry1: Record "AFDP Item Rename Import Entry";
        ProgressWindow: Dialog;
        TotalRecordImported: Integer;
        LastEntryNo: Integer;

    local procedure GetLastEntryNo(): Integer;
    var
        ItemRenameImportEntry: Record "AFDP Item Rename Import Entry";
    begin
        ItemRenameImportEntry.Reset();
        ItemRenameImportEntry.SetCurrentKey("Entry No.");
        ItemRenameImportEntry.SetRange("Entry No.");
        if ItemRenameImportEntry.FindLast() then
            exit(ItemRenameImportEntry."Entry No.")
        else
            exit(0);
    end;

    procedure RenameItem()
    var
        Item: Record Item;
    begin
        ItemRenameImportEntry1.Reset();
        ItemRenameImportEntry1.SetCurrentKey("Entry No.");
        ItemRenameImportEntry1.SetRange("Item Found", false);
        if ItemRenameImportEntry1.FindSet() then
            repeat
                ProgressWindow.UPDATE(2, format(ItemRenameImportEntry1."Current Item No."));
                if item.Get(ItemRenameImportEntry1."Current Item No.") then begin
                    Item.Rename(ItemRenameImportEntry1."New Item No.");
                    ItemRenameImportEntry1."Item Found" := true;
                    ItemRenameImportEntry1.Modify();
                    item."AFDP Old Item No." := ItemRenameImportEntry1."Current Item No.";
                    item.Modify();
                end else begin
                    ItemRenameImportEntry1."Item Found" := false;
                    ItemRenameImportEntry1.Modify();
                end;
            until ItemRenameImportEntry1.Next() = 0;
    end;
}

//AFDP 06/11/2025 'T0006-Item Number Rename'
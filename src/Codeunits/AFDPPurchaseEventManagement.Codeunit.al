namespace AFood.DP.AFoodDevelopment;
using Microsoft.Purchases.Document;
using Microsoft.Inventory.Setup;
using Microsoft.Warehouse.Ledger;
using Microsoft.Warehouse.Structure;
using Microsoft.Inventory.Journal;
using Microsoft.Inventory.Location;
using Microsoft.Foundation.NoSeries;

codeunit 50303 "AFDP Purchase Event Management"
{

    #region Global Variables
    var
    #endregion Global Variables

    #region EventSubcribers    
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Purchase Document", 'OnAfterReleasePurchaseDoc', '', false, false)]
    local procedure ReleasePurchaseDocument_OnAfterReleasePurchaseDoc(var PurchaseHeader: Record "Purchase Header"; PreviewMode: Boolean; var LinesWereModified: Boolean; SkipWhseRequestOperations: Boolean)
    begin
        //>>AFDP 05/31/2025 'Short Orders'
        UpdateOriginalQuantityOnPurchaseLine(PurchaseHeader);
        //<<AFDP 05/31/2025 'Short Orders'
    end;
    #endregion EventSubscribers

    #region Functions    
    //>>AFDP 05/31/2025 'Short Orders'
    local procedure UpdateOriginalQuantityOnPurchaseLine(var PurchaseHeader: Record "Purchase Header")
    var
        PurchaseLine: Record "Purchase Line";
    begin
        PurchaseLine.Reset();
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        if PurchaseLine.FindSet() then
            repeat
                if (PurchaseLine."Quantity Received" = 0) and (PurchaseLine."AFDP Original Unit Price" = 0) then begin
                    PurchaseLine."AFDP Original Quantity" := PurchaseLine.Quantity;
                    PurchaseLine.Modify(true);
                end;
            until PurchaseLine.Next() = 0;
    end;
    //<<AFDP 05/31/2025 'Short Orders'
    //>>AFDP 06/28/2025 'T0008-Receiving Enhancements'
    procedure SumarizedAFDPWarehouseEntriesByLot(var BinContent: Record "Bin Content"; var AFDPWarehouseEntries: Record "AFDP Warehouse Entries")
    var
        WarehouseEntry: Record "Warehouse Entry";
    begin
        WarehouseEntry.Reset();
        WarehouseEntry.SetRange("Location Code", BinContent."Location Code");
        WarehouseEntry.SetRange("Bin Code", BinContent."Bin Code");
        WarehouseEntry.SetRange("Item No.", BinContent."Item No.");
        WarehouseEntry.SetRange("Variant Code", BinContent."Variant Code");
        WarehouseEntry.SetRange("Unit of Measure Code", BinContent."Unit of Measure Code");
        if WarehouseEntry.FindSet() then
            repeat
                AFDPWarehouseEntries.Reset();
                AFDPWarehouseEntries.SetRange("Location Code", WarehouseEntry."Location Code");
                AFDPWarehouseEntries.SetRange("Bin Code", WarehouseEntry."Bin Code");
                AFDPWarehouseEntries.SetRange("Item No.", WarehouseEntry."Item No.");
                AFDPWarehouseEntries.SetRange("Variant Code", WarehouseEntry."Variant Code");
                AFDPWarehouseEntries.SetRange("Unit of Measure Code", WarehouseEntry."Unit of Measure Code");
                AFDPWarehouseEntries.SetRange("Lot No.", WarehouseEntry."Lot No.");
                if not AFDPWarehouseEntries.FindFirst() then begin
                    AFDPWarehouseEntries.Init();
                    AFDPWarehouseEntries.TransferFields(WarehouseEntry);
                    AFDPWarehouseEntries.Insert();
                end else begin
                    AFDPWarehouseEntries."Qty. (Base)" += WarehouseEntry."Qty. (Base)";
                    AFDPWarehouseEntries."Quantity" += WarehouseEntry.Quantity;
                    AFDPWarehouseEntries.Modify(true);
                end;
            until WarehouseEntry.Next() = 0;
    end;

    procedure CreateItemReclassJournalFromSummarizedWarehouseLotEntries(var AFDPWarehouseEntries: Record "AFDP Warehouse Entries")
    begin
        if AFDPWarehouseEntries.FindSet() then
            repeat
                CreateItemReclassJournalForMissingInventory(AFDPWarehouseEntries);
            until AFDPWarehouseEntries.Next() = 0;
    end;

    local procedure CreateItemReclassJournalForMissingInventory(var AFDPWarehouseEntries: Record "AFDP Warehouse Entries")
    var
        InventorySetup: Record "Inventory Setup";
        ItemJournalLineRec: Record "Item Journal Line";
        LocationRec: Record Location;
        ItemJnlTemplate: Record "Item Journal Template";
        NoSeriesMgt: Codeunit "No. Series - Batch";
        NextLineNo: Integer;
        DocumentNo: Code[20];
    begin
        //----\\
        LocationRec.get(AFDPWarehouseEntries."Location Code");
        LocationRec.TestField("AFDP Default Missing Bin");
        //----\\
        InventorySetup.Get();
        InventorySetup.TestField("AFDP Receiving Template Name");
        InventorySetup.TestField("AFDP Receiving Batch Name");
        //----\\
        ItemJnlTemplate.Get(InventorySetup."AFDP Receiving Template Name");
        If ItemJnlTemplate."No. Series" <> '' then
            DocumentNo := NoSeriesMgt.GetNextNo(ItemJnlTemplate."No. Series", Today, false)
        else
            DocumentNo := AFDPWarehouseEntries."Source No.";
        //----\\
        ItemJournalLineRec.Reset();
        ItemJournalLineRec.SetRange("Journal Template Name", InventorySetup."AFDP Receiving Template Name");
        ItemJournalLineRec.SetRange("Journal Batch Name", InventorySetup."AFDP Receiving Batch Name");
        if ItemJournalLineRec.FindLast() then
            NextLineNo := ItemJournalLineRec."Line No.";
        NextLineNo := NextLineNo + 10000;
        //----\\
        ItemJournalLineRec.Init();
        ItemJournalLineRec.Validate("Journal Template Name", InventorySetup."AFDP Receiving Template Name");
        ItemJournalLineRec.Validate("Journal Batch Name", InventorySetup."AFDP Receiving Batch Name");
        ItemJournalLineRec.Validate("Line No.", NextLineNo);
        ItemJournalLineRec.Validate("Entry Type", ItemJournalLineRec."Entry Type"::Transfer);
        ItemJournalLineRec.Validate("Source Code", ItemJnlTemplate."Source Code");
        ItemJournalLineRec.Validate("Posting Date", Today);
        ItemJournalLineRec.Validate("Document No.", DocumentNo);
        ItemJournalLineRec.Validate("Item No.", AFDPWarehouseEntries."Item No.");
        ItemJournalLineRec.Validate("Location Code", AFDPWarehouseEntries."Location Code");
        ItemJournalLineRec.Validate("New Location Code", AFDPWarehouseEntries."Location Code");
        ItemJournalLineRec.Validate("Bin Code", AFDPWarehouseEntries."Bin Code");
        ItemJournalLineRec.Validate("New Bin Code", LocationRec."AFDP Default Missing Bin");
        ItemJournalLineRec.Validate(Quantity, AFDPWarehouseEntries."Quantity");
        ItemJournalLineRec.Validate("Unit of Measure Code", AFDPWarehouseEntries."Unit of Measure Code");
        ItemJournalLineRec.Validate("Variant Code", AFDPWarehouseEntries."Variant Code");
        ItemJournalLineRec.Validate("Lot No.", AFDPWarehouseEntries."Lot No.");
        ItemJournalLineRec.Validate("Quantity (Base)", AFDPWarehouseEntries."Qty. (Base)");
        ItemJournalLineRec.Insert();
    end;
    //<<AFDP 06/28/2025 'T0008-Receiving Enhancements'
    #endregion Functions
}

//AFDP 05/31/2025 'Short Orders'


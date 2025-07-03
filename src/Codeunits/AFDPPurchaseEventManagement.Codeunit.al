namespace AFood.DP.AFoodDevelopment;
using Microsoft.Purchases.Document;
using Microsoft.Warehouse.Journal;
using Microsoft.Inventory.Setup;
using Microsoft.Warehouse.Ledger;
using Microsoft.Warehouse.Structure;
using Microsoft.Inventory.Journal;
using Microsoft.Inventory.Location;
using Microsoft.Inventory.Posting;
using Microsoft.Foundation.NoSeries;
using Microsoft.Inventory.Tracking;
using Microsoft.Inventory.Ledger;

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

    [EventSubscriber(ObjectType::Table, Database::"Reservation Entry", 'OnBeforeInsertEvent', '', false, false)]
    local procedure ReservationEntry_OnBeforeInsertEvent(var Rec: Record "Reservation Entry"; RunTrigger: Boolean)
    begin
        //>>AFDP 06/28/2025 'T0008-Receiving Enhancements'
        // if rec.IsTemporary() then
        //     exit; // Skip temporary records
        // if Rec."Source Subtype" = Rec."Source Subtype"::"0" then  // 0 = Purchase Order
        //     if rec."Source Type" = 32 then  // 32 = Purchase Order
        //         Message('Entry Found');
        //<<AFDP 06/28/2025 'T0008-Receiving Enhancements'
    end;

    // [EventSubscriber(ObjectType::Table, database::"IWX LP Header", 'OnBeforeValidateEvent', 'Bin Code', false, false)]
    // local procedure IWXLPHeader_OnBeforeValidateEvent_BinCode(var Rec: Record "IWX LP Header"; xRec: Record "IWX LP Header"; CurrFieldNo: Integer)
    // begin
    //     //>>AFDP 07/01/2025 'T0008-Receiving Enhancements'
    //     Message('Bin Code: %1', Rec."Bin Code");
    //     //<<AFDP 07/01/2025 'T0008-Receiving Enhancements'
    // end;

    // [EventSubscriber(ObjectType::Table, database::"Item Journal Line", 'OnBeforeValidateEvent', 'LPM License Plate No.', false, false)]
    // local procedure ItemJournalLine_OnBeforeValidateEvent_LPMLicensePlateNo(var Rec: Record "Item Journal Line"; xRec: Record "Item Journal Line"; CurrFieldNo: Integer)
    // begin
    //     //>>AFDP 07/01/2025 'T0008-Receiving Enhancements'
    //     if rec."LPM License Plate No." = '' then exit; // Skip if no license plate number
    //     Message('License Plate No.: %1', Rec."LPM License Plate No.");
    //     //<<AFDP 07/01/2025 'T0008-Receiving Enhancements'
    // end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnSetupSplitJnlLineOnBeforeReallocateTrkgSpecification', '', false, false)]
    local procedure ItemJnlPostLine_OnSetupSplitJnlLineOnBeforeReallocateTrkgSpecification(var ItemTrackingCode: Record "Item Tracking Code"; var TempTrackingSpecification: Record "Tracking Specification" temporary; var ItemJnlLine: Record "Item Journal Line"; var SignFactor: Integer; var IsHandled: Boolean)
    begin
        //>>AFDP 06/28/2025 'T0008-Receiving Enhancements'
        if ItemJnlLine."LPM License Plate No." = '' then exit; // Skip if no license plate number
        if ItemJnlLine."Line No." <> TempTrackingSpecification."Source Ref. No." then exit; // Skip if line number does not match        
        if ItemJnlLine."Item No." <> TempTrackingSpecification."Item No." then exit; // Skip if item number does not match
        if ItemJnlLine.Description <> TempTrackingSpecification.Description then exit; // Skip if description does not match
        if ItemJnlLine."Location Code" <> TempTrackingSpecification."Location Code" then exit; // Skip if location code does not match
        if ItemJnlLine."Journal Template Name" <> TempTrackingSpecification."Source ID" then exit; // Skip if journal template name does not match
        if ItemJnlLine."Journal Batch Name" <> TempTrackingSpecification."Source Batch Name" then exit; // Skip if journal batch name does not match
        if (TempTrackingSpecification."Source Type" = 83) and (TempTrackingSpecification."Source Subtype" = TempTrackingSpecification."Source Subtype"::"4") then begin // 4 = Item Reclassification        
            TempTrackingSpecification."Units (Base)_DU_TSL" := SignFactor * ItemJnlLine.Units_DU_TSL;
            TempTrackingSpecification."Unit of Measure - Units_DU_TSL" := ItemJnlLine."Unit of Measure - Units_DU_TSL";
            TempTrackingSpecification."Units to Handle_DU_TSL" := SignFactor * ItemJnlLine.Units_DU_TSL;
            TempTrackingSpecification.Modify();
        end;
        //<<AFDP 06/28/2025 'T0008-Receiving Enhancements'
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Batch", 'OnBeforeOnRun', '', false, false)]
    local procedure ItemJnlPostBatch_OnBeforeOnRun(var ItemJournalLine: Record "Item Journal Line")
    var
        LPHeader: Record "IWX LP Header";
        LPLine: Record "IWX LP Line";
        LPSetup: Record "IWX License Plate Setup";
    begin
        //>>AFDP 07/01/2025 'T0008-Receiving Enhancements'
        if ItemJournalLine.IsTemporary() then exit; // Skip temporary records            
        if ItemJournalLine."LPM License Plate No." = '' then exit; // Skip if no license plate number
        if LPHeader.Get(ItemJournalLine."LPM License Plate No.") then begin
            LPSetup.Get();
            if LPSetup."LP Bin Move Batch Name" = ItemJournalLine."Journal Batch Name" then begin
                LPLine.Reset();
                LPLine.SetRange("License Plate No.", LPHeader."No.");
                LPLine.SetRange(Type, LPLine.Type::Item);
                LPLine.SetRange("No.", ItemJournalLine."Item No.");
                LPLine.SetRange("Variant Code", ItemJournalLine."Variant Code");
                // LPLine.SetRange("Lot No.", ItemJournalLine."Lot No.");
                if LPLine.FindFirst() then
                    if LPLine."AFDP DU Unit of Measure Code" = ItemJournalLine."Unit of Measure - Units_DU_TSL" then
                        if ItemJournalLine.Units_DU_TSL = 0 then begin
                            ItemJournalLine.Units_DU_TSL := LPLine."AFDP DU Units Quantity";
                            ItemJournalLine.Modify();
                        end;
            end;
        end;
        //<<AFDP 07/01/2025 'T0008-Receiving Enhancements'
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
        WarehouseEntry.SetCurrentKey("Entry No.");
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
                    AFDPWarehouseEntries."AFDP Units_DU_TSL" := WarehouseEntry."Units_DU_TSL";
                    AFDPWarehouseEntries."AFDP UOM_Units_DU_TSL" := WarehouseEntry."Unit of Measure - Units_DU_TSL";
                    AFDPWarehouseEntries.Insert();
                end else begin
                    AFDPWarehouseEntries."Qty. (Base)" += WarehouseEntry."Qty. (Base)";
                    AFDPWarehouseEntries."Quantity" += WarehouseEntry.Quantity;
                    AFDPWarehouseEntries."AFDP Units_DU_TSL" += WarehouseEntry."Units_DU_TSL";
                    AFDPWarehouseEntries.Modify(true);
                end;
            until WarehouseEntry.Next() = 0;
    end;

    procedure CreateItemReclassJournalFromSummarizedWarehouseLotEntries(var AFDPWarehouseEntries: Record "AFDP Warehouse Entries")
    begin
        AFDPWarehouseEntries.Reset();
        AFDPWarehouseEntries.SetFilter("Quantity", '<>0');
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
        // LocationRec.TestField("AFDP Default Missing Bin");
        LocationRec.TestField("AFDP Default Damaged Location");
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
        // ItemJournalLineRec.Validate("New Location Code", AFDPWarehouseEntries."Location Code");
        ItemJournalLineRec.Validate("New Location Code", LocationRec."AFDP Default Damaged Location");
        ItemJournalLineRec.Validate("Bin Code", AFDPWarehouseEntries."Bin Code");
        // ItemJournalLineRec.Validate("New Bin Code", LocationRec."AFDP Default Missing Bin");
        ItemJournalLineRec.Validate(Quantity, AFDPWarehouseEntries."Quantity");
        ItemJournalLineRec.Validate("Quantity (Base)", AFDPWarehouseEntries."Qty. (Base)");
        ItemJournalLineRec.validate(Units_DU_TSL, AFDPWarehouseEntries."AFDP Units_DU_TSL");
        ItemJournalLineRec.Validate("Unit of Measure - Units_DU_TSL", AFDPWarehouseEntries."AFDP UOM_Units_DU_TSL");
        ItemJournalLineRec.Validate("Unit of Measure Code", AFDPWarehouseEntries."Unit of Measure Code");
        ItemJournalLineRec.Validate("Variant Code", AFDPWarehouseEntries."Variant Code");
        ItemJournalLineRec.Validate("Lot No.", AFDPWarehouseEntries."Lot No.");
        ItemJournalLineRec.Validate("Expiration Date", AFDPWarehouseEntries."Expiration Date");
        ItemJournalLineRec.Validate("AFDP Receiving Return Order", true);
        ItemJournalLineRec.Insert();
        //--Insert Reservation Entry--\\
        InsertReservationEntryForItemReclassJournal(ItemJournalLineRec, AFDPWarehouseEntries);
    end;

    local procedure InsertReservationEntryForItemReclassJournal(var ItemJournalLineRec: Record "Item Journal Line"; var AFDPWarehouseEntries: Record "AFDP Warehouse Entries")
    var
        ReservationEntry: Record "Reservation Entry";
        LastReservationEntryNo: Integer;
    begin
        LastReservationEntryNo := GetLastReservationEntryNo();
        ReservationEntry.Init();
        ReservationEntry."Entry No." := LastReservationEntryNo + 1;
        ReservationEntry.Validate("Item No.", ItemJournalLineRec."Item No.");
        ReservationEntry.Validate("Location Code", ItemJournalLineRec."Location Code");
        ReservationEntry.Validate("Reservation Status", ReservationEntry."Reservation Status"::Prospect);
        ReservationEntry.Validate("Source Type", 83);
        ReservationEntry.validate("Source Subtype", ReservationEntry."Source Subtype"::"4"); // 4 = Item Reclassification
        ReservationEntry.Validate("Source ID", ItemJournalLineRec."Journal Template Name");
        ReservationEntry.Validate("Source Batch Name", ItemJournalLineRec."Journal Batch Name");
        ReservationEntry.Validate("Source Ref. No.", ItemJournalLineRec."Line No.");
        ReservationEntry.Validate(Positive, false);
        if (ItemJournalLineRec."Unit of Measure Code" = 'LB') and (ItemJournalLineRec."Unit of Measure - Units_DU_TSL" = 'CASE') then begin
            ReservationEntry.Validate("Quantity", -ItemJournalLineRec."Quantity");
            ReservationEntry.Validate("Quantity (Base)", -ItemJournalLineRec."Quantity (Base)");
            ReservationEntry.Validate("Units (Base)_DU_TSL", -ItemJournalLineRec."Units_DU_TSL");
            ReservationEntry.Validate("Units to Handle_DU_TSL", -ItemJournalLineRec."Units_DU_TSL");
        end else
            if (ItemJournalLineRec."Unit of Measure Code" = 'CASE') and (ItemJournalLineRec."Unit of Measure - Units_DU_TSL" = '') then begin
                ReservationEntry.Validate("Quantity", -ItemJournalLineRec.Quantity);
                ReservationEntry.Validate("Quantity (Base)", -ItemJournalLineRec."Quantity (Base)");
            end else begin
                ReservationEntry.Validate("Quantity", -ItemJournalLineRec.Quantity);
                ReservationEntry.Validate("Quantity (Base)", -ItemJournalLineRec."Quantity (Base)");
            end;

        ReservationEntry.Validate("Expiration Date", AFDPWarehouseEntries."Expiration Date");
        ReservationEntry.Validate("New Expiration Date", AFDPWarehouseEntries."Expiration Date");
        ReservationEntry.Validate("Lot No.", AFDPWarehouseEntries."Lot No.");
        ReservationEntry.Validate("New Lot No.", AFDPWarehouseEntries."Lot No.");
        ReservationEntry.Validate("Item Tracking", ReservationEntry."Item Tracking"::"Lot No.");
        ReservationEntry.Insert();
    end;

    local procedure GetLastReservationEntryNo(): Integer;
    var
        ReservationEntry: Record "Reservation Entry";
    begin
        ReservationEntry.Reset();
        ReservationEntry.SetCurrentKey("Entry No.");
        ReservationEntry.SetRange("Entry No.");
        if ReservationEntry.FindLast() then
            exit(ReservationEntry."Entry No.")
        else
            exit(0);
    end;

    procedure CreateReturnPurchaseOrder(var AFDPWarehouseEntries: Record "AFDP Warehouse Entries")
    var
        PurchOrderHeader: Record "Purchase Header";
        PurchHdrRec: Record "Purchase Header";
        ReturnOrderHeaderCreated: Boolean;
    begin
        Clear(ReturnOrderHeaderCreated);
        AFDPWarehouseEntries.Reset();
        AFDPWarehouseEntries.SetFilter("Quantity", '<>0');
        if AFDPWarehouseEntries.FindSet() then
            repeat
                if AFDPWarehouseEntries."Source Document" = AFDPWarehouseEntries."Source Document"::"P. Order" then begin
                    if not ReturnOrderHeaderCreated then begin
                        PurchOrderHeader.Reset();
                        PurchOrderHeader.SetRange("Document Type", PurchOrderHeader."Document Type"::Order);
                        PurchOrderHeader.SetRange("No.", AFDPWarehouseEntries."Source No.");
                        if PurchOrderHeader.FindFirst() then
                            ReturnOrderHeaderCreated := CreateReturnPurchaseOrderHeaderForMissingInventory(PurchOrderHeader, PurchHdrRec);
                    end;
                    if ReturnOrderHeaderCreated then
                        CreateReturnPurchaseOrderLineForMissingInventory(AFDPWarehouseEntries, PurchHdrRec);
                end;
            until AFDPWarehouseEntries.Next() = 0;
    end;

    local procedure CreateReturnPurchaseOrderHeaderForMissingInventory(PurchOrderHeader: Record "Purchase Header"; var PurchHdrRec: Record "Purchase Header"): Boolean
    var
        LocationRec: Record Location;
    begin
        //----\\
        LocationRec.get(PurchOrderHeader."Location Code");
        LocationRec.TestField("AFDP Default Damaged Location");
        //----\\
        PurchHdrRec.Init();
        PurchHdrRec.TransferFields(PurchOrderHeader);
        PurchHdrRec."Document Type" := PurchHdrRec."Document Type"::"Return Order";
        PurchHdrRec."No." := '';
        PurchHdrRec.Status := PurchHdrRec.Status::Open;
        PurchHdrRec.InitInsert();
        PurchHdrRec.Insert();
        PurchHdrRec.Validate("Order Date", Today);
        PurchHdrRec.Validate("Posting Date", Today);
        PurchHdrRec.Validate(Status, PurchHdrRec.Status::Open);
        PurchHdrRec.Validate("Location Code", LocationRec."AFDP Default Damaged Location");
        PurchHdrRec.Modify(true);
        exit(true);
    end;

    local procedure CreateReturnPurchaseOrderLineForMissingInventory(var AFDPWarehouseEntries: Record "AFDP Warehouse Entries"; var PurchHdrRec: Record "Purchase Header")
    var
        ReturnPurchLineRec: Record "Purchase Line";
        PurchaseLine: Record "Purchase Line";
        LocationRec: Record Location;
    begin
        //----\\
        LocationRec.get(AFDPWarehouseEntries."Location Code");
        // LocationRec.TestField("AFDP Default Missing Bin");
        LocationRec.TestField("AFDP Default Damaged Location");
        //----\\
        ReturnPurchLineRec.Reset();
        ReturnPurchLineRec.SetRange("Document Type", ReturnPurchLineRec."Document Type"::"Return Order");
        ReturnPurchLineRec.SetRange("Document No.", PurchHdrRec."No.");
        ReturnPurchLineRec.SetRange("No.", AFDPWarehouseEntries."Item No.");
        ReturnPurchLineRec.SetRange("Order Line No.", AFDPWarehouseEntries."Source Line No.");
        if not ReturnPurchLineRec.FindFirst() then begin
            ReturnPurchLineRec.Init();
            ReturnPurchLineRec."Document Type" := ReturnPurchLineRec."Document Type"::"Return Order";
            ReturnPurchLineRec.Validate("Document No.", PurchHdrRec."No.");
            ReturnPurchLineRec.InitNewLine(ReturnPurchLineRec);
            ReturnPurchLineRec."Line No." := ReturnPurchLineRec."Line No." + 10000;
            ReturnPurchLineRec.Validate(Type, ReturnPurchLineRec.Type::Item);
            ReturnPurchLineRec.Validate("No.", AFDPWarehouseEntries."Item No.");
            ReturnPurchLineRec.Validate(Quantity, AFDPWarehouseEntries.Quantity);
            ReturnPurchLineRec.Validate("Unit of Measure Code", AFDPWarehouseEntries."Unit of Measure Code");
            ReturnPurchLineRec.Validate("Variant Code", AFDPWarehouseEntries."Variant Code");
            ReturnPurchLineRec.Validate(Units_DU_TSL, AFDPWarehouseEntries."AFDP Units_DU_TSL");
            ReturnPurchLineRec.Validate("Unit of Measure - Units_DU_TSL", AFDPWarehouseEntries."AFDP UOM_Units_DU_TSL");
            //--Find Purchase Line--\\
            PurchaseLine.Reset();
            PurchaseLine.SetRange("Document Type", PurchHdrRec."Document Type");
            PurchaseLine.SetRange("Document No.", PurchHdrRec."No.");
            PurchaseLine.SetRange("No.", AFDPWarehouseEntries."Item No.");
            PurchaseLine.SetRange("Line No.", AFDPWarehouseEntries."Source Line No.");
            if PurchaseLine.FindFirst() then begin
                ReturnPurchLineRec.Validate("Direct Unit Cost", PurchaseLine."Direct Unit Cost");
                ;//ReturnPurchLineRec.Validate("Unit Price (LCY)", PurchaseLine."Unit Price (LCY)");
            end;
            ReturnPurchLineRec.Validate("Order Line No.", AFDPWarehouseEntries."Source Line No.");
            // ReturnPurchLineRec.Validate("Bin Code", LocationRec."AFDP Default Missing Bin");
            ReturnPurchLineRec.Validate("Location Code", LocationRec."AFDP Default Damaged Location");
            ReturnPurchLineRec.Insert();
        end else begin
            ReturnPurchLineRec.Validate("Quantity", (ReturnPurchLineRec."Quantity" + AFDPWarehouseEntries.Quantity));
            ReturnPurchLineRec.Validate("Units_DU_TSL", (ReturnPurchLineRec."Units_DU_TSL" + AFDPWarehouseEntries."AFDP Units_DU_TSL"));
            ReturnPurchLineRec.Modify(true);
        end;
        //--Insert Reservation Entry--\\
        InsertReservationEntryForPurchReturnOrderLine(ReturnPurchLineRec, AFDPWarehouseEntries);
    end;

    local procedure InsertReservationEntryForPurchReturnOrderLine(var ReturnPurchLineRec: Record "Purchase Line"; var AFDPWarehouseEntries: Record "AFDP Warehouse Entries")
    var
        ReservationEntry: Record "Reservation Entry";
        LastReservationEntryNo: Integer;
    begin
        LastReservationEntryNo := GetLastReservationEntryNo();
        ReservationEntry.Init();
        ReservationEntry."Entry No." := LastReservationEntryNo + 1;
        ReservationEntry.Validate("Item No.", ReturnPurchLineRec."No.");
        ReservationEntry.Validate("Location Code", ReturnPurchLineRec."Location Code");
        ReservationEntry.Validate("Reservation Status", ReservationEntry."Reservation Status"::Tracking);
        ReservationEntry.Validate("Source Type", 39);
        ReservationEntry.validate("Source Subtype", ReservationEntry."Source Subtype"::"5"); // 5 = Purchase Return Order
        ReservationEntry.Validate("Source ID", ReturnPurchLineRec."Document No.");
        ReservationEntry.Validate("Source Ref. No.", ReturnPurchLineRec."Line No.");
        ReservationEntry.Validate(Positive, false);
        if (ReturnPurchLineRec."Unit of Measure Code" = 'LB') and (ReturnPurchLineRec."Unit of Measure - Units_DU_TSL" = 'CASE') then begin
            ReservationEntry.Validate("Quantity", -AFDPWarehouseEntries."Quantity");
            ReservationEntry.Validate("Quantity (Base)", -AFDPWarehouseEntries."Qty. (Base)");
            ReservationEntry.Validate("Units (Base)_DU_TSL", -AFDPWarehouseEntries."AFDP Units_DU_TSL");
            ReservationEntry.Validate("Units to Handle_DU_TSL", -AFDPWarehouseEntries."AFDP Units_DU_TSL");
        end else
            if (ReturnPurchLineRec."Unit of Measure Code" = 'CASE') and (ReturnPurchLineRec."Unit of Measure - Units_DU_TSL" = '') then begin
                ReservationEntry.Validate("Quantity", -AFDPWarehouseEntries.Quantity);
                ReservationEntry.Validate("Quantity (Base)", -AFDPWarehouseEntries."Qty. (Base)");
            end else begin
                ReservationEntry.Validate("Quantity", -AFDPWarehouseEntries.Quantity);
                ReservationEntry.Validate("Quantity (Base)", -AFDPWarehouseEntries."Qty. (Base)");
            end;

        ReservationEntry.Validate("Shipment Date", ReturnPurchLineRec."Expected Receipt Date");
        ReservationEntry.Validate("Lot No.", AFDPWarehouseEntries."Lot No.");
        ReservationEntry.Validate("Item Tracking", ReservationEntry."Item Tracking"::"Lot No.");
        ReservationEntry.Validate("Created By", UserId());
        ReservationEntry.Insert();
        //--Create Balance Reservation Entry For Return Order From Item Ledger Entry--\\
        CreateReservationEntryForReturnOrderFromItemLedgerEntry(ReturnPurchLineRec, ReservationEntry);
        //----\\
    end;

    local procedure CreateReservationEntryForReturnOrderFromItemLedgerEntry(var ReturnPurchLineRec: Record "Purchase Line"; var ReservationEntry: Record "Reservation Entry")
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        LastReservationEntryNo: Integer;
    begin
        LastReservationEntryNo := ReservationEntry."Entry No.";
        ItemLedgerEntry.Reset();
        ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::Transfer);
        ItemLedgerEntry.SetRange("Item No.", ReturnPurchLineRec."No.");
        ItemLedgerEntry.SetRange("Lot No.", ReservationEntry."Lot No.");
        ItemLedgerEntry.SetRange("Location Code", ReturnPurchLineRec."Location Code");
        ItemLedgerEntry.SetRange("Variant Code", ReturnPurchLineRec."Variant Code");
        ItemLedgerEntry.SetRange(Open, true);
        if ItemLedgerEntry.FindFirst() then
            if ItemLedgerEntry.Quantity = abs(ReservationEntry.Quantity) then begin
                ReservationEntry.Init();
                ReservationEntry."Entry No." := LastReservationEntryNo;
                ReservationEntry.Validate("Item No.", ReturnPurchLineRec."No.");
                ReservationEntry.Validate("Location Code", ReturnPurchLineRec."Location Code");
                ReservationEntry.Validate("Reservation Status", ReservationEntry."Reservation Status"::Tracking);
                ReservationEntry.Validate("Source Type", 32);
                ReservationEntry.validate("Source Subtype", ReservationEntry."Source Subtype"::"0");
                ReservationEntry.Validate("Source Ref. No.", ItemLedgerEntry."Entry No.");
                ReservationEntry.Validate(Positive, true);
                ReservationEntry.Validate("Shipment Date", ReservationEntry."Shipment Date");
                if (ReturnPurchLineRec."Unit of Measure Code" = 'LB') and (ReturnPurchLineRec."Unit of Measure - Units_DU_TSL" = 'CASE') then begin
                    ReservationEntry.Validate("Quantity", ItemLedgerEntry.Quantity);
                    ReservationEntry.Validate("Units (Base)_DU_TSL", ItemLedgerEntry."Units_DU_TSL");
                    ReservationEntry.Validate("Units to Handle_DU_TSL", ItemLedgerEntry."Units_DU_TSL");
                end else
                    if (ReturnPurchLineRec."Unit of Measure Code" = 'CASE') and (ReturnPurchLineRec."Unit of Measure - Units_DU_TSL" = '') then
                        ReservationEntry.Validate("Quantity", ItemLedgerEntry.Quantity)
                    else
                        ReservationEntry.Validate("Quantity", ItemLedgerEntry.Quantity);

                ReservationEntry.Validate("Lot No.", ItemLedgerEntry."Lot No.");
                ReservationEntry.Validate("Item Tracking", ReservationEntry."Item Tracking"::"Lot No.");
                ReservationEntry.Insert();
            end;
    end;
    //<<AFDP 06/28/2025 'T0008-Receiving Enhancements'
    #endregion Functions
}

//AFDP 05/31/2025 'Short Orders'


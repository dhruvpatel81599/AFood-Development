namespace AFood.DP.AFoodDevelopment;
using Microsoft.Sales.Document;
using Microsoft.Warehouse.Setup;
using Microsoft.Purchases.History;
using Microsoft.Warehouse.Activity;
using Microsoft.Inventory.Tracking;
using Microsoft.Inventory.Item;
using Microsoft.Warehouse.Posting;
using Microsoft.Warehouse.Document;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Posting;
using Microsoft.Inventory.Setup;
using Microsoft.Sales.Posting;
using System.Utilities;
using Microsoft.Purchases.Pricing;
using Microsoft.Warehouse.Journal;
using Microsoft.Inventory.Ledger;
using Microsoft.Warehouse.Structure;
using Microsoft.Warehouse.Ledger;

codeunit 50301 "AFDP Warehouse EventManagement"
{

    #region Global Variables
    var

    #endregion Global Variables

    #region EventSubcribers
    // [EventSubscriber(ObjectType::Table, database::"Sales Line", 'OnBeforeValidateEvent', 'Quantity Shipped', false, false)]
    // local procedure SalesLine_OnBeforeValidateEvent(var Rec: Record "Sales Line"; xRec: Record "Sales Line"; CurrFieldNo: Integer)
    // begin
    //     // Error('The "Quantity Shipped" field modified.');
    // end;

    // [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterModifyEvent', '', false, false)]
    // local procedure SalesLine_OnAfterModifyEvent(var Rec: Record "Sales Line"; xRec: Record "Sales Line"; RunTrigger: Boolean)
    // begin
    //     // if Rec.IsTemporary then
    //     //     exit;
    //     // if not RunTrigger then
    //     //     exit;        
    // end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnPostUpdateOrderLineOnBeforeGetQuantityShipped', '', false, false)]
    local procedure SalesPost_OnPostUpdateOrderLineOnBeforeGetQuantityShipped(var TempSalesLine: Record "Sales Line"; var IsHandled: Boolean; var SalesHeader: Record "Sales Header")
    var
        InventorySetup: Record "Inventory Setup";
        AFDPSingleInstance: Codeunit "AFDP Single Instance";
    begin
        //>>AFDP 05/31/2025 'Short Orders'
        InventorySetup.Get();
        if not InventorySetup."AFDP Enable Sales Short" then
            exit;
        if AFDPSingleInstance.GetIsWarehousePostShipment() then begin
            TempSalesLine."Quantity Shipped" += TempSalesLine."Qty. to Ship";
            TempSalesLine."Qty. Shipped (Base)" += TempSalesLine."Qty. to Ship (Base)";
            TempSalesLine.Quantity := TempSalesLine."Quantity Shipped";
            TempSalesLine."Quantity (Base)" := TempSalesLine."Qty. Shipped (Base)";
            if TempSalesLine.Quantity = 0 then begin
                TempSalesLine."AFDP Original Unit Price" := TempSalesLine."Unit Price";
                TempSalesLine."AFDP Original Amount" := TempSalesLine.Amount;
                // TempSalesLine."Unit Price" := 0;
                TempSalesLine.Amount := 0;
                TempSalesLine."Amount Including VAT" := 0;
                TempSalesLine."VAT Base Amount" := 0;
                TempSalesLine."Line Amount" := 0;
            end;
            IsHandled := true;
        end;
        //<<AFDP 05/31/2025 'Short Orders'
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales Whse. Post Shipment", 'OnPostSourceDocumentOnBeforePostSalesHeader', '', false, false)]
    local procedure SalesWhsePostShipment_OnPostSourceDocumentOnBeforePostSalesHeader(var SalesPost: Codeunit "Sales-Post"; var SalesHeader: Record "Sales Header"; WhseShptHeader: Record "Warehouse Shipment Header"; var CounterSourceDocOK: Integer; var WhsePostParameters: Record "Whse. Post Parameters"; var IsHandled: Boolean)
    var
        AFDPSingleInstance: Codeunit "AFDP Single Instance";
    begin
        AFDPSingleInstance.SetIsWarehousePostShipment(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales Whse. Post Shipment", 'OnPostSourceDocumentOnBeforePrintSalesDocuments', '', false, false)]
    local procedure SalesWhsePostShipment_OnPostSourceDocumentOnBeforePrintSalesDocuments(LastShippingNo: Code[20])
    var
        AFDPSingleInstance: Codeunit "AFDP Single Instance";
    begin
        AFDPSingleInstance.SetIsWarehousePostShipment(false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Post Shipment", 'OnBeforeDeleteUpdateWhseShptLine', '', false, false)]
    local procedure WhsePostShipment_OnBeforeDeleteUpdateWhseShptLine(WhseShptLine: Record "Warehouse Shipment Line"; var DeleteWhseShptLine: Boolean; var WhseShptLineBuf: Record "Warehouse Shipment Line")
    var
        InventorySetup: Record "Inventory Setup";
        AFDPSingleInstance: Codeunit "AFDP Single Instance";
    begin
        //>>AFDP 06/01/2025 'Short Orders'
        InventorySetup.Get();
        if not InventorySetup."AFDP Enable Sales Short" then
            exit;
        if AFDPSingleInstance.GetIsWarehousePostShipment() then
            if not DeleteWhseShptLine then begin
                WhseShptLineBuf."Qty. Outstanding" := WhseShptLineBuf."Qty. to Ship";
                DeleteWhseShptLine := true;
            end;
        //<<AFDP 06/01/2025 'Short Orders'
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Post Shipment", 'OnPostUpdateWhseDocumentsOnBeforeUpdateWhseShptHeader', '', false, false)]
    local procedure WhsePostShipment_OnPostUpdateWhseDocumentsOnBeforeUpdateWhseShptHeader(var WhseShptHeaderParam: Record "Warehouse Shipment Header")
    var
        InventorySetup: Record "Inventory Setup";
        WhseShptLine: Record "Warehouse Shipment Line";
        AFDPSingleInstance: Codeunit "AFDP Single Instance";
    begin
        //>>AFDP 06/01/2025 'Short Orders'
        InventorySetup.Get();
        if not InventorySetup."AFDP Enable Sales Short" then
            exit;
        if AFDPSingleInstance.GetIsWarehousePostShipment() then begin
            WhseShptLine.SetRange("No.", WhseShptHeaderParam."No.");
            WhseShptLine.SetRange("Qty. Shipped", 0);
            WhseShptLine.DeleteAll();
        end;
        //<<AFDP 06/01/2025 'Short Orders'
    end;

    // [EventSubscriber(ObjectType::Table, Database::"Warehouse Shipment Header", 'OnBeforeDeleteEvent', '', false, false)]
    // local procedure WarehouseShipmentHeader_OnBeforeDeleteEvent(var Rec: Record "Warehouse Shipment Header")
    // begin
    //     Message('The Warehouse Shipment %1 deleted.', Rec."No.");
    // end;
    //--------Warehouse Receipt----------\\
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnPostUpdateOrderLineOnPurchHeaderReceive', '', false, false)]
    local procedure PurchPost_OnPostUpdateOrderLineOnPurchHeaderReceive(var TempPurchLine: Record "Purchase Line"; PurchRcptHeader: Record "Purch. Rcpt. Header")
    var
        InventorySetup: Record "Inventory Setup";
        AFDPSingleInstance: Codeunit "AFDP Single Instance";
    begin
        //>>AFDP 06/01/2025 'Short Orders'
        InventorySetup.Get();
        if not InventorySetup."AFDP Enable Purchase Short" then
            exit;
        if AFDPSingleInstance.GetIsWarehousePostReceipt() then begin
            TempPurchLine.Quantity := TempPurchLine."Quantity Received";
            TempPurchLine."Quantity (Base)" := TempPurchLine."Qty. Received (Base)";
            if TempPurchLine.Quantity = 0 then begin
                TempPurchLine."AFDP Original Unit Price" := TempPurchLine."Unit Cost (LCY)";
                TempPurchLine."AFDP Original Amount" := TempPurchLine.Amount;
                // TempPurchLine."Unit Cost (LCY)" := 0;
                TempPurchLine.Amount := 0;
                TempPurchLine."Amount Including VAT" := 0;
                TempPurchLine."VAT Base Amount" := 0;
                TempPurchLine."Line Amount" := 0;
            end;
        end;
        //<<AFDP 06/01/2025 'Short Orders'
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Post Receipt", 'OnPostSourceDocumentOnBeforePostPurchaseHeader', '', false, false)]
    local procedure PurchWhsePostShipment_OnPostSourceDocumentOnBeforePostPurchaseHeader(var PurchHeader: Record "Purchase Header"; WhseRcptHeader: Record "Warehouse Receipt Header"; SuppressCommit: Boolean; var CounterSourceDocOK: Integer; var IsHandled: Boolean)
    var
        AFDPSingleInstance: Codeunit "AFDP Single Instance";
    begin
        AFDPSingleInstance.SetIsWarehousePostReceipt(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Post Receipt", 'OnPostSourceDocumentOnAfterPostPurchaseHeader', '', false, false)]
    local procedure PurchWhsePostShipment_OnPostSourceDocumentOnAfterPostPurchaseHeader(PurchaseHeader: record "Purchase Header")
    var
        AFDPSingleInstance: Codeunit "AFDP Single Instance";
    begin
        AFDPSingleInstance.SetIsWarehousePostReceipt(false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Post Receipt", 'OnBeforePostUpdateWhseRcptLine', '', false, false)]
    local procedure WhsePostReceipt_OnBeforePostUpdateWhseRcptLine(var WarehouseReceiptLine: Record "Warehouse Receipt Line"; var WarehouseReceiptLineBuf: Record "Warehouse Receipt Line"; var DeleteWhseRcptLine: Boolean; var WarehouseReceiptHeader: Record "Warehouse Receipt Header")
    var
        InventorySetup: Record "Inventory Setup";
        AFDPSingleInstance: Codeunit "AFDP Single Instance";
    begin
        //>>AFDP 06/01/2025 'Short Orders'
        InventorySetup.Get();
        if not InventorySetup."AFDP Enable Purchase Short" then
            exit;
        if AFDPSingleInstance.GetIsWarehousePostReceipt() then
            if not DeleteWhseRcptLine then begin
                WarehouseReceiptLineBuf."Qty. Outstanding" := WarehouseReceiptLineBuf."Qty. to Receive";
                DeleteWhseRcptLine := true;
            end;
        //<<AFDP 06/01/2025 'Short Orders'
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Post Receipt", 'OnPostUpdateWhseDocumentsOnBeforeDeleteAll', '', false, false)]
    local procedure WhsePostReceipt_OnPostUpdateWhseDocumentsOnBeforeDeleteAll(var WhseReceiptHeader: Record "Warehouse Receipt Header"; var WhseReceiptLine: Record "Warehouse Receipt Line")
    var
        InventorySetup: Record "Inventory Setup";
        WarehouseReceiptLine: Record "Warehouse Receipt Line";
        AFDPSingleInstance: Codeunit "AFDP Single Instance";
    begin
        //>>AFDP 06/01/2025 'Short Orders'
        InventorySetup.Get();
        if not InventorySetup."AFDP Enable Purchase Short" then
            exit;
        if AFDPSingleInstance.GetIsWarehousePostReceipt() then begin
            WarehouseReceiptLine.SetRange("No.", WhseReceiptHeader."No.");
            WarehouseReceiptLine.SetRange("Qty. Received", 0);
            WarehouseReceiptLine.DeleteAll();
        end;
        //<<AFDP 06/01/2025 'Short Orders'
    end;

    //<<AFDP 06/17/2025 'T0012-Item Tracking Import Tools'
    [EventSubscriber(ObjectType::Table, database::"Warehouse Receipt Header", 'OnBeforeValidateEvent', 'Bin Code', false, false)]
    local procedure WarehouseReceiptHeader_OnBeforeValidateEvent_BinCode(var Rec: Record "Warehouse Receipt Header"; xRec: Record "Warehouse Receipt Header"; CurrFieldNo: Integer)
    begin
        rec.SetHideValidationDialog(true);
    end;

    [EventSubscriber(ObjectType::Table, database::"Warehouse Receipt Header", 'OnAfterValidateEvent', 'Bin Code', false, false)]
    local procedure WarehouseReceiptHeader_OnAfterValidateEvent_BinCode(var Rec: Record "Warehouse Receipt Header"; xRec: Record "Warehouse Receipt Header"; CurrFieldNo: Integer)
    begin
        if CurrFieldNo = 0 then
            exit;
        if (xRec."Bin Code" <> Rec."Bin Code") then
            UpdateBinCodeOnWarehouseReceiptLine(Rec."No.", Rec."Bin Code");
        rec.SetHideValidationDialog(false);
    end;

    [EventSubscriber(ObjectType::Table, database::"Purchase Line", 'OnValidateQtyToReceiveOnAfterInitQty', '', false, false)]
    local procedure PurchaseLine_OnValidateQtyToReceiveOnAfterInitQty(var PurchaseLine: Record "Purchase Line"; var xPurchaseLine: Record "Purchase Line"; CallingFieldNo: Integer; var IsHandled: Boolean)
    var
        Text001: Label 'You cannot receive more than %1 base units for item no: %2';
    begin
        //>>AFDP 07/18/2025 'T0012-Item Tracking Import Tools'
        if not OverReceiptProcessing(PurchaseLine) then begin
            if not CanReceiveQty(PurchaseLine) then
                Error(CannotReceiveErrorInfo(PurchaseLine));

            if not CanReceiveBaseQty(PurchaseLine) then
                Error(Text001, PurchaseLine."Outstanding Qty. (Base)", PurchaseLine."No.");
        end;
        //<<AFDP 07/18/2025 'T0012-Item Tracking Import Tools'
    end;
    //>>AFDP 06/17/2025 'T0012-Item Tracking Import Tools'        
    // [EventSubscriber(ObjectType::Table, database::"Tracking Specification", 'OnBeforeUpdateTrackingSpecification', '', false, false)]
    // local procedure TrackingSpecification_OnBeforeUpdateTrackingSpecification(var TrackingSpecification: Record "Tracking Specification"; var FromTrackingSpecification: Record "Tracking Specification")
    // var
    //     Item: Record Item;
    // begin
    //     //>>AFDP 08/26/2025 'T0022-Plant Number'
    //     if FromTrackingSpecification."Item No." <> '' then begin
    //         Item.Get(FromTrackingSpecification."Item No.");
    //         if FromTrackingSpecification."AFDP Plant Number Mandatory" <> Item."AFDP Plant Number Mandatory" then
    //             FromTrackingSpecification."AFDP Plant Number Mandatory" := Item."AFDP Plant Number Mandatory";
    //         if FromTrackingSpecification."AFDP Default Plant Number" <> Item."AFDP Default Plant Number" then
    //             FromTrackingSpecification."AFDP Default Plant Number" := Item."AFDP Default Plant Number";
    //     end;
    //     //<<AFDP 08/26/2025 'T0022-Plant Number'
    // end;
    [EventSubscriber(ObjectType::Page, page::"Item Tracking Lines", 'OnInsertRecordOnBeforeTempItemTracklineInsert', '', false, false)]
    local procedure ItemTrackingLines_OnInsertRecordOnBeforeTempItemTracklineInsert(var TempTrackingSpecificationInsert: Record "Tracking Specification" temporary; var TempTrackingSpecification: Record "Tracking Specification" temporary)
    var
        Item: Record Item;
    begin
        //>>AFDP 08/26/2025 'T0022-Plant Number'
        if TempTrackingSpecification."Item No." <> '' then begin
            Item.Get(TempTrackingSpecification."Item No.");
            //--Update TempTrackingSpecification Record--//
            if TempTrackingSpecification."AFDP Plant Number Mandatory" <> Item."AFDP Plant Number Mandatory" then
                TempTrackingSpecification."AFDP Plant Number Mandatory" := Item."AFDP Plant Number Mandatory";
            if TempTrackingSpecification."AFDP Default Plant Number" = '' then
                if TempTrackingSpecification."AFDP Default Plant Number" <> Item."AFDP Default Plant Number" then
                    TempTrackingSpecification."AFDP Default Plant Number" := Item."AFDP Default Plant Number";
            //--Update TempTrackingSpecificationInsert Record--//
            if TempTrackingSpecificationInsert."AFDP Plant Number Mandatory" <> Item."AFDP Plant Number Mandatory" then
                TempTrackingSpecificationInsert."AFDP Plant Number Mandatory" := Item."AFDP Plant Number Mandatory";
            if TempTrackingSpecificationInsert."AFDP Default Plant Number" = '' then
                if TempTrackingSpecificationInsert."AFDP Default Plant Number" <> Item."AFDP Default Plant Number" then
                    TempTrackingSpecificationInsert."AFDP Default Plant Number" := Item."AFDP Default Plant Number";
        end;
        //<<AFDP 08/26/2025 'T0022-Plant Number'
    end;

    [EventSubscriber(ObjectType::Page, page::"Item Tracking Lines", 'OnBeforeQueryClosePage', '', false, false)]
    local procedure ItemTrackingLines_OnBeforeQueryClosePage(var TrackingSpecification: Record "Tracking Specification"; var TotalItemTrackingLine: Record "Tracking Specification"; var TempReservationEntry: Record "Reservation Entry" temporary; var UndefinedQtyArray: array[3] of Decimal; var SourceQuantityArray: array[5] of Decimal; var CurrentRunMode: Enum "Item Tracking Run Mode"; var IsHandled: Boolean)
    var
        TempPlantNumberTrackingSpecification: Record "Tracking Specification" temporary;
    begin
        //>>AFDP 08/26/2025 'T0022-Plant Number'
        TempPlantNumberTrackingSpecification.copy(TrackingSpecification);
        TempPlantNumberTrackingSpecification.Insert();
        TempPlantNumberTrackingSpecification.Reset();
        TempPlantNumberTrackingSpecification.SetRange("Item No.", TrackingSpecification."Item No.");
        if TempPlantNumberTrackingSpecification.FindSet() then
            repeat
                if TempPlantNumberTrackingSpecification."Lot No." <> '' then
                    if not IsPlantNumberValid(TempPlantNumberTrackingSpecification."Item No.", TempPlantNumberTrackingSpecification."AFDP Default Plant Number") then
                        Error('Plant Number is mandatory for Item No: %1', TempPlantNumberTrackingSpecification."Item No.");
            until TempPlantNumberTrackingSpecification.Next() = 0;
        //<<AFDP 08/26/2025 'T0022-Plant Number'
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Reservation Engine Mgt.", 'OnBeforeModifyItemTrkgByReservStatus', '', false, false)]
    local procedure ReservationEngineMgt_OnBeforeModifyItemTrkgByReservStatus(var TempReservationEntry: Record "Reservation Entry" temporary; var TrackingSpecification: Record "Tracking Specification"; ReservStatus: Enum "Reservation Status"; var QtyToAdd: Decimal; var QtyToAddAsBlank: Decimal; ItemTrackingCode: Record "Item Tracking Code"; var IsHandled: Boolean)
    begin
        //>>AFDP 08/27/2025 'T0022-Plant Number'
        if TrackingSpecification."Lot No." = '' then
            exit;
        TempReservationEntry."AFDP Plant Number Mandatory" := TrackingSpecification."AFDP Plant Number Mandatory";
        TempReservationEntry."AFDP Default Plant Number" := TrackingSpecification."AFDP Default Plant Number";
        //<<AFDP 08/27/2025 'T0022-Plant Number'
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"WMS Management", 'OnAfterCheckTrackingSpecificationChangeNeeded', '', false, false)]
    local procedure WMSManagement_OnAfterCheckTrackingSpecificationChangeNeeded(TrackingSpecification: Record "Tracking Specification"; xTrackingSpecification: Record "Tracking Specification"; var CheckNeeded: Boolean)
    begin
        //>>AFDP 08/27/2025 'T0022-Plant Number'
        if TrackingSpecification."AFDP Plant Number Mandatory" <> xTrackingSpecification."AFDP Plant Number Mandatory" then
            CheckNeeded := true;
        if TrackingSpecification."AFDP Default Plant Number" <> xTrackingSpecification."AFDP Default Plant Number" then
            CheckNeeded := true;
        //<<AFDP 08/27/2025 'T0022-Plant Number'
    end;

    [EventSubscriber(ObjectType::Table, Database::"Tracking Specification", 'OnAfterHasSameTracking', '', false, false)]
    local procedure TrackingSpecification_OnAfterHasSameTracking(var TrackingSpecification: Record "Tracking Specification"; FromTrackingSpecification: Record "Tracking Specification"; var IsSameTracking: Boolean);
    begin
        //>>AFDP 08/27/2025 'T0022-Plant Number'         
        if not IsSameTracking then
            exit;
        if ((TrackingSpecification."AFDP Plant Number Mandatory" = FromTrackingSpecification."AFDP Plant Number Mandatory") and
            (TrackingSpecification."AFDP Default Plant Number" = FromTrackingSpecification."AFDP Default Plant Number")) then
            IsSameTracking := true
        else
            IsSameTracking := false;
        //<<AFDP 08/27/2025 'T0022-Plant Number'
    end;

    [EventSubscriber(ObjectType::Table, Database::"Reservation Entry", 'OnAfterCopyTrackingFromTrackingSpec', '', false, false)]
    local procedure ReservationEntry_OnAfterCopyTrackingFromTrackingSpec(var ReservationEntry: Record "Reservation Entry"; TrackingSpecification: Record "Tracking Specification")
    begin
        //>>AFDP 08/27/2025 'T0022-Plant Number'
        ReservationEntry."AFDP Plant Number Mandatory" := TrackingSpecification."AFDP Plant Number Mandatory";
        ReservationEntry."AFDP Default Plant Number" := TrackingSpecification."AFDP Default Plant Number";
        //<<AFDP 08/27/2025 'T0022-Plant Number'
    end;

    [EventSubscriber(ObjectType::Table, Database::"Reservation Entry", 'OnAfterCopyTrackingFromReservEntry', '', false, false)]
    local procedure ReservationEntry_OnAfterCopyTrackingFromReservEntry(var ReservationEntry: Record "Reservation Entry"; FromReservationEntry: Record "Reservation Entry")
    begin
        //>>AFDP 08/27/2025 'T0022-Plant Number'
        ReservationEntry."AFDP Plant Number Mandatory" := FromReservationEntry."AFDP Plant Number Mandatory";
        ReservationEntry."AFDP Default Plant Number" := FromReservationEntry."AFDP Default Plant Number";
        //<<AFDP 08/27/2025 'T0022-Plant Number'
    end;

    [EventSubscriber(ObjectType::Table, Database::"Reservation Entry", 'OnAfterCopyTrackingFromReservEntryNewTracking', '', false, false)]
    local procedure ReservationEntry_OnAfterCopyTrackingFromReservEntryNewTracking(var ReservationEntry: Record "Reservation Entry"; FromReservationEntry: Record "Reservation Entry")
    begin
        //>>AFDP 08/27/2025 'T0022-Plant Number'
        ReservationEntry."AFDP Plant Number Mandatory" := FromReservationEntry."AFDP Plant Number Mandatory";
        ReservationEntry."AFDP Default Plant Number" := FromReservationEntry."AFDP Default Plant Number";
        //<<AFDP 08/27/2025 'T0022-Plant Number'
    end;

    [EventSubscriber(ObjectType::Table, Database::"Reservation Entry", 'OnAfterSetNewTrackingFromTrackingSpecification', '', false, false)]
    local procedure ReservationEntry_OnAfterSetNewTrackingFromTrackingSpecification(var ReservationEntry: Record "Reservation Entry"; TrackingSpecification: Record "Tracking Specification")
    begin
        //>>AFDP 08/27/2025 'T0022-Plant Number'
        ReservationEntry."AFDP Plant Number Mandatory" := TrackingSpecification."AFDP Plant Number Mandatory";
        ReservationEntry."AFDP Default Plant Number" := TrackingSpecification."AFDP Default Plant Number";
        //<<AFDP 08/27/2025 'T0022-Plant Number'
    end;

    [EventSubscriber(ObjectType::Table, Database::"Reservation Entry", 'OnAfterCopyNewTrackingFromReservEntry', '', false, false)]
    local procedure ReservationEntry_OnAfterCopyNewTrackingFromReservEntry(var ReservationEntry: Record "Reservation Entry"; FromReservEntry: Record "Reservation Entry")
    begin
        //>>AFDP 08/27/2025 'T0022-Plant Number'
        ReservationEntry."AFDP Plant Number Mandatory" := FromReservEntry."AFDP Plant Number Mandatory";
        ReservationEntry."AFDP Default Plant Number" := FromReservEntry."AFDP Default Plant Number";
        //<<AFDP 08/27/2025 'T0022-Plant Number'
    end;

    // [EventSubscriber(ObjectType::Table, Database::"Lot No. Information", 'OnBeforeInsertEvent', '', false, false)]
    // local procedure LotNoInformation_OnBeforeInsertEvent(var Rec: Record "Lot No. Information"; RunTrigger: Boolean)
    // begin
    //     //>>AFDP 08/27/2025 'T0022-Plant Number'        
    //     if rec."Item No." <> '10021000007315' then
    //         exit;
    //     message('Lot No. Information Record Inserted For Item Number: %1', Rec."Item No.");
    //     //<<AFDP 08/27/2025 'T0022-Plant Number'
    // end;

    // [EventSubscriber(ObjectType::Table, Database::"Warehouse Activity Line", 'OnBeforeInsertEvent', '', false, false)]
    // local procedure WarehouseActivityLine_OnBeforeInsertEvent(var Rec: Record "Warehouse Activity Line"; RunTrigger: Boolean)
    // begin
    //     //>>AFDP 08/27/2025 'T0022-Plant Number'        
    //     if rec."Item No." <> '10021000007315' then
    //         exit;
    //     message('Warehouse Activity Line Record Inserted For Item Number: %1', Rec."Item No.");
    //     //<<AFDP 08/27/2025 'T0022-Plant Number'
    // end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Pick", 'OnBeforeTempWhseActivLineInsert', '', false, false)]
    local procedure CreatePick_OnBeforeTempWhseActivLineInsert(var TempWarehouseActivityLine: Record "Warehouse Activity Line" temporary; ActionType: Integer; WhseSource2: Option)
    var
        LotNoInfo: Record "Lot No. Information";
    begin
        //>>AFDP 08/29/2025 'T0022-Plant Number'
        LotNoInfo.Reset();
        LotNoInfo.SetRange("Item No.", TempWarehouseActivityLine."Item No.");
        LotNoInfo.SetRange("Lot No.", TempWarehouseActivityLine."Lot No.");
        if LotNoInfo.IsEmpty() then
            exit;
        if LotNoInfo.FindFirst() then begin
            TempWarehouseActivityLine."AFDP Plant Number Mandatory" := LotNoInfo."AFDP Plant Number Mandatory";
            TempWarehouseActivityLine."AFDP Default Plant Number" := LotNoInfo."AFDP Default Plant Number";
        end;
        //<<AFDP 08/29/2025 'T0022-Plant Number'
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Tracking Management", 'OnAfterCreateLotInformation', '', false, false)]
    local procedure ItemTrackingManagement_OnAfterCreateLotInformation(var LotNoInfo: Record "Lot No. Information"; var TrackingSpecification: Record "Tracking Specification")
    begin
        //>>AFDP 08/29/2025 'T0022-Plant Number'
        LotNoInfo."AFDP Plant Number Mandatory" := TrackingSpecification."AFDP Plant Number Mandatory";
        LotNoInfo."AFDP Default Plant Number" := TrackingSpecification."AFDP Default Plant Number";
        LotNoInfo.Modify();
        //<<AFDP 08/29/2025 'T0022-Plant Number'
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Activity-Register", 'OnAfterRegWhseItemTrkgLine', '', false, false)]
    local procedure WhseActivityRegister_OnAfterRegWhseItemTrkgLine(var WhseActivLine2: Record "Warehouse Activity Line"; var TempTrackingSpecification: Record "Tracking Specification" temporary)
    begin
        //>>AFDP 08/29/2025 'T0022-Plant Number'
        if WhseActivLine2."Lot No." = '' then
            exit;
        TempTrackingSpecification."AFDP Plant Number Mandatory" := WhseActivLine2."AFDP Plant Number Mandatory";
        TempTrackingSpecification."AFDP Default Plant Number" := WhseActivLine2."AFDP Default Plant Number";
        TempTrackingSpecification.Modify();
        //<<AFDP 08/29/2025 'T0022-Plant Number'
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Activity-Register", 'OnAfterCheckWhseActivLine', '', false, false)]
    local procedure WhseActivityRegister_OnAfterCheckWhseActivLine(var WarehouseActivityLine: Record "Warehouse Activity Line")
    var
        LotNoInfo: Record "Lot No. Information";
    begin
        //>>AFDP 11/13/2025 'T0022-Plant Number'
        if WarehouseActivityLine."Action Type" <> WarehouseActivityLine."Action Type"::Take then
            exit;
        if WarehouseActivityLine."Lot No." = '' then
            exit;
        if WarehouseActivityLine."AFDP Default Plant Number" = '' then
            exit;
        LotNoInfo.Reset();
        LotNoInfo.SetRange("Item No.", WarehouseActivityLine."Item No.");
        LotNoInfo.SetRange("Lot No.", WarehouseActivityLine."Lot No.");
        LotNoInfo.SetRange("Variant Code", WarehouseActivityLine."Variant Code");
        if LotNoInfo.FindFirst() then
            if LotNoInfo."AFDP Default Plant Number" = '' then begin
                LotNoInfo."AFDP Default Plant Number" := WarehouseActivityLine."AFDP Default Plant Number";
                LotNoInfo.Modify();
            end;
        //<<AFDP 11/13/2025 'T0022-Plant Number'
    end;

    // [EventSubscriber(ObjectType::Table, Database::"Reservation Entry", 'OnBeforeInsertEvent', '', false, false)]
    // local procedure ReservationEntry_OnBeforeInsertEvent(var Rec: Record "Reservation Entry"; RunTrigger: Boolean)
    // begin
    //     //>>AFDP 08/27/2025 'T0022-Plant Number'        
    //     if rec."Item No." <> '10021000007315' then
    //         exit;
    //     message('Reservation Entry Record Inserted For Item Number: %1', Rec."Item No.");
    //     //<<AFDP 08/27/2025 'T0022-Plant Number'
    // end;

    // [EventSubscriber(ObjectType::Table, Database::"Reservation Entry", 'OnBeforeModifyEvent', '', false, false)]
    // local procedure ReservationEntry_OnBeforeModifyEvent(var Rec: Record "Reservation Entry"; var xRec: Record "Reservation Entry"; RunTrigger: Boolean)
    // begin
    //     //>>AFDP 08/27/2025 'T0022-Plant Number'        
    //     if rec."Item No." <> '10021000007315' then
    //         exit;
    //     if rec."Lot No." <> xRec."Lot No." then
    //         message('Reservation Entry Record Inserted For Item Number: %1', Rec."Item No.");
    //     //<<AFDP 08/27/2025 'T0022-Plant Number'
    // end;

    // [EventSubscriber(ObjectType::Table, Database::"Tracking Specification", 'OnBeforeInsertEvent', '', false, false)]
    // local procedure TrackingSpecification_OnBeforeInsertEvent(var Rec: Record "Tracking Specification"; RunTrigger: Boolean)
    // begin
    //     //>>AFDP 08/27/2025 'T0022-Plant Number'        
    //     if rec."Item No." <> '10021000007315' then
    //         exit;
    //     message('Tracking Specification Record Inserted For Item Number: %1', Rec."Item No.");
    //     //<<AFDP 08/27/2025 'T0022-Plant Number'
    // end;

    // [EventSubscriber(ObjectType::Table, Database::"Tracking Specification", 'OnBeforeModifyEvent', '', false, false)]
    // local procedure TrackingSpecification_OnBeforeModifyEvent(var Rec: Record "Tracking Specification"; var xRec: Record "Tracking Specification"; RunTrigger: Boolean)
    // begin
    //     //>>AFDP 08/27/2025 'T0022-Plant Number'        
    //     if rec."Item No." <> '10021000007315' then
    //         exit;
    //     if rec."Lot No." <> xRec."Lot No." then
    //         message('Tracking Specification Record Inserted For Item Number: %1', Rec."Item No.");
    //     //<<AFDP 08/27/2025 'T0022-Plant Number'
    // end;
    //>>AFDP 06/17/2025 'T0012-Item Tracking Import Tools'
    //>>AFDP 09/03/2025 'T0021-Show License Plate on Pick'
    [EventSubscriber(ObjectType::Table, Database::"Warehouse Activity Line", 'OnAfterInsertEvent', '', false, false)]
    local procedure WarehouseActivityLine_OnAfterInsertEvent(var Rec: Record "Warehouse Activity Line"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary then
            exit;
        // if not RunTrigger then
        //     exit;
        //>>AFDP 10/17/2025 'T0025-Pick Using Average Weight'
        SetAverageWeightOnWarehouseActivityLine(Rec);
        //<<AFDP 10/17/2025 'T0025-Pick Using Average Weight'
        if rec."Action Type" <> rec."Action Type"::Take then
            exit;
        SetLicensePlateOnWarehouseActivityLine(Rec);
    end;
    //<<AFDP 09/03/2025 'T0021-Show License Plate on Pick'
    #endregion EventSubscribers

    #region Functions
    //<<AFDP 06/17/2025 'T0012-Item Tracking Import Tools'
    local procedure UpdateBinCodeOnWarehouseReceiptLine(WhseRcptHeaderNo: Code[20]; BinCode: Code[20])
    var
        WhseRcptLine: Record "Warehouse Receipt Line";
    begin
        WhseRcptLine.Reset();
        WhseRcptLine.SetRange("No.", WhseRcptHeaderNo);
        if WhseRcptLine.FindSet() then
            repeat
                WhseRcptLine.Validate("Bin Code", BinCode);
                WhseRcptLine.Modify();
            until WhseRcptLine.Next() = 0;
    end;
    //>>AFDP 06/17/2025 'T0012-Item Tracking Import Tools'
    //>>AFDP 07/18/2025 'T0012-Item Tracking Import Tools'
    local procedure OverReceiptProcessing(var PurchaseLine: Record "Purchase Line"): Boolean
    var
        OverReceiptMgt: Codeunit "Over-Receipt Mgt.";
    begin
        if not OverReceiptMgt.IsOverReceiptAllowed() or (Abs(PurchaseLine."Qty. to Receive") <= Abs(PurchaseLine."Outstanding Quantity")) then
            exit(false);

        if (PurchaseLine."Over-Receipt Code" = '') and (OverReceiptMgt.GetDefaultOverReceiptCode(PurchaseLine) = '') then
            exit(false);

        PurchaseLine.Validate("Over-Receipt Quantity", PurchaseLine."Qty. to Receive" - PurchaseLine.Quantity + PurchaseLine."Quantity Received" + PurchaseLine."Over-Receipt Quantity");
        exit(true);
    end;

    local procedure CanReceiveQty(var PurchaseLine: Record "Purchase Line"): Boolean
    begin
        if Abs(PurchaseLine."Qty. to Receive") > Abs(PurchaseLine."Outstanding Quantity") then
            exit(false);

        if (PurchaseLine."Qty. to Receive" < 0) and (PurchaseLine.Quantity > 0) or
           (PurchaseLine."Qty. to Receive" > 0) and (PurchaseLine.Quantity < 0)
        then
            exit(false);

        if (PurchaseLine."Outstanding Quantity" < 0) and (PurchaseLine.Quantity > 0) or
           (PurchaseLine."Outstanding Quantity" > 0) and (PurchaseLine.Quantity < 0)
        then
            exit(false);

        exit(true);
    end;

    local procedure CanReceiveBaseQty(var PurchaseLine: Record "Purchase Line"): Boolean
    begin
        if Abs(PurchaseLine."Qty. to Receive (Base)") > Abs(PurchaseLine."Outstanding Qty. (Base)") then
            exit(false);

        if (PurchaseLine."Qty. to Receive (Base)" < 0) and (PurchaseLine."Quantity (Base)" > 0) or
           (PurchaseLine."Qty. to Receive (Base)" > 0) and (PurchaseLine."Quantity (Base)" < 0)
        then
            exit(false);

        if (PurchaseLine."Outstanding Qty. (Base)" < 0) and (PurchaseLine."Quantity (Base)" > 0) or
           (PurchaseLine."Outstanding Qty. (Base)" > 0) and (PurchaseLine."Quantity (Base)" < 0)
        then
            exit(false);

        exit(true);
    end;

    local procedure CannotReceiveErrorInfo(var PurchaseLine: Record "Purchase Line"): ErrorInfo
    var
        ErrorMesageManagement: Codeunit "Error Message Management";
        QtyReceiveNotValidTitleLbl: Label 'Qty. to Receive isn''t valid';
        Text008: Label 'You cannot receive more than %1 units for item no: %2';
        QtyReceiveActionLbl: Label 'Set value to %1', comment = '%1=Qty. to Receive';
        QtyReceiveActionDescriptionLbl: Label 'Corrects %1 value to %2', Comment = '%1 - Qty. to Receive field caption, %2 - Quantity';
    begin
        exit(ErrorMesageManagement.BuildActionableErrorInfo(
            QtyReceiveNotValidTitleLbl,
            StrSubstNo(Text008, PurchaseLine."Outstanding Quantity", PurchaseLine."No."),
            PurchaseLine.RecordId,
            StrSubstNo(QtyReceiveActionLbl, PurchaseLine."Outstanding Quantity"),
            Codeunit::"Purchase Line - Price",
            'SetPurchaseReceiveQty',
            StrSubstNo(QtyReceiveActionDescriptionLbl, PurchaseLine.FieldCaption("Qty. to Receive"), PurchaseLine.Quantity)));
    end;
    //<<AFDP 07/18/2025 'T0012-Item Tracking Import Tools'
    //>>AFDP 08/26/2025 'T0022-Plant Number'
    local procedure IsPlantNumberValid(ItemNo: Code[20]; PlantNumber: Code[20]): Boolean
    var
        Item: Record Item;
    begin
        Item.Get(ItemNo);
        if Item."AFDP Plant Number Mandatory" and (PlantNumber = '') then
            exit(false);
        exit(true);
    end;
    //<<AFDP 08/26/2025 'T0022-Plant Number'
    //>>AFDP 09/03/2025 'T0021-Show License Plate on Pick'
    local procedure SetLicensePlateOnWarehouseActivityLine(var WarehouseActivityLine: Record "Warehouse Activity Line")
    var
        MobLicensePlateContent: Record "MOB License Plate Content";
    begin
        MobLicensePlateContent.Reset();
        MobLicensePlateContent.SetRange("No.", WarehouseActivityLine."Item No.");
        MobLicensePlateContent.SetRange("Lot No.", WarehouseActivityLine."Lot No.");
        MobLicensePlateContent.SetRange("Bin Code", WarehouseActivityLine."Bin Code");
        if MobLicensePlateContent.FindFirst() then begin
            WarehouseActivityLine."AFDP License Plate" := MobLicensePlateContent."License Plate No.";
            WarehouseActivityLine.Modify();
        end;
    end;
    //<<AFDP 09/03/2025 'T0021-Show License Plate on Pick'
    //>>AFDP 10/17/2025 'T0025-Pick Using Average Weight'
    local procedure SetAverageWeightOnWarehouseActivityLine(var WarehouseActivityLine: Record "Warehouse Activity Line")
    var
        ItemledgerEntry: Record "Item Ledger Entry";
        BinContent: Record "Bin Content";
        TotalQuantity: Decimal;
        TotalCase: Decimal;
        AverageWeight: Decimal;
        PickQtyBase: Decimal;
        BinContentQtyBase: Decimal;
        QtyAvailableToTake: Decimal;
        CaseAvailableForBin: Decimal;
    begin
        if WarehouseActivityLine."Lot No." = '' then
            exit;
        if WarehouseActivityLine.Units_DU_TSL = 0 then
            exit;
        ItemledgerEntry.Reset();
        ItemledgerEntry.SetRange("Item No.", WarehouseActivityLine."Item No.");
        ItemledgerEntry.SetRange("Lot No.", WarehouseActivityLine."Lot No.");
        ItemledgerEntry.SetFilter("Remaining Quantity", '>0');
        ItemledgerEntry.SetRange("Location Code", WarehouseActivityLine."Location Code");
        ItemledgerEntry.SetRange("Variant Code", WarehouseActivityLine."Variant Code");
        ItemledgerEntry.SetRange(Open, true);
        if ItemledgerEntry.IsEmpty() then
            exit;
        ItemledgerEntry.CalcSums(Quantity);
        TotalQuantity := ItemledgerEntry.Quantity;
        ItemledgerEntry.CalcSums(Units_DU_TSL);
        TotalCase := ItemledgerEntry.Units_DU_TSL;
        // if TotalCase <> 0 then
        //     AverageWeight := Round(TotalQuantity / TotalCase, 0.01, '=')
        // else
        //     AverageWeight := 0;
        if TotalCase <> 0 then
            AverageWeight := (TotalQuantity / TotalCase)
        else
            AverageWeight := 0;

        //--Update Place Line From Take Line--\\
        if WarehouseActivityLine."Action Type" = WarehouseActivityLine."Action Type"::Place then
            if CheckTakeLineExists(WarehouseActivityLine) then
                exit;
        if WarehouseActivityLine."Action Type" = WarehouseActivityLine."Action Type"::Place then begin
            WarehouseActivityLine.Validate("Qty. to Handle", 0);
            WarehouseActivityLine.Validate("Units to Handle_DU_TSL", 0);
            WarehouseActivityLine.Modify();
            exit;
        end;
        //--Get Available Quantity from Bin Content--\\        
        BinContent.Reset();
        BinContent.SetRange("Item No.", WarehouseActivityLine."Item No.");
        BinContent.SetRange("Location Code", WarehouseActivityLine."Location Code");
        BinContent.SetRange("Variant Code", WarehouseActivityLine."Variant Code");
        if WarehouseActivityLine."Action Type" = WarehouseActivityLine."Action Type"::Take then
            BinContent.SetRange("Bin Code", WarehouseActivityLine."Bin Code");
        if BinContent.FindFirst() then begin
            PickQtyBase := GetPickQtyBase(WarehouseActivityLine);
            BinContent.CalcFields("Quantity (Base)", Units_DU_TSL);
            // BinContentQtyBase := BinContent."Quantity (Base)";
            BinContentQtyBase := GetRemaingQtyForAvailableCase(WarehouseActivityLine);
            // CaseAvailableForBin := BinContent.Units_DU_TSL;
            CaseAvailableForBin := GetCaseQtyBase(WarehouseActivityLine);
            if (BinContentQtyBase - PickQtyBase) > 0 then
                if (BinContentQtyBase - PickQtyBase) < (WarehouseActivityLine.Units_DU_TSL * AverageWeight) then begin
                    // if (QtyAvailableToTake) < (WarehouseActivityLine.Units_DU_TSL * AverageWeight) then begin
                    //--Set Qty. to Handle--//
                    WarehouseActivityLine.Validate("Qty. to Handle", BinContentQtyBase - PickQtyBase);
                    WarehouseActivityLine.Validate("Units to Handle_DU_TSL", WarehouseActivityLine.Units_DU_TSL);
                    WarehouseActivityLine.Modify();
                end else
                    if CaseAvailableForBin = WarehouseActivityLine.Units_DU_TSL then begin
                        //--Set Qty. to Handle--//
                        WarehouseActivityLine.Validate("Qty. to Handle", BinContentQtyBase);
                        WarehouseActivityLine.Validate("Units to Handle_DU_TSL", WarehouseActivityLine.Units_DU_TSL);
                        WarehouseActivityLine.Modify();
                    end else begin
                        //--Set Qty. to Handle--//
                        WarehouseActivityLine.Validate("Qty. to Handle", WarehouseActivityLine.Units_DU_TSL * AverageWeight);
                        WarehouseActivityLine.Validate("Units to Handle_DU_TSL", WarehouseActivityLine.Units_DU_TSL);
                        WarehouseActivityLine.Modify();
                    end;
        end;
        //--Update Place Line if Exists--\\
        if WarehouseActivityLine."Action Type" = WarehouseActivityLine."Action Type"::Take then
            if CheckPlaceLineExists(WarehouseActivityLine) then
                exit;
    end;

    local procedure CheckTakeLineExists(var WarehouseActivityLine: Record "Warehouse Activity Line"): Boolean
    var
        WhseActivLineTake: Record "Warehouse Activity Line";
    begin
        WhseActivLineTake.Reset();
        WhseActivLineTake.SetRange("Source Type", WarehouseActivityLine."Source Type");
        WhseActivLineTake.SetRange("Source Subtype", WarehouseActivityLine."Source Subtype");
        WhseActivLineTake.SetRange("Source No.", WarehouseActivityLine."Source No.");
        WhseActivLineTake.SetRange("Source Line No.", WarehouseActivityLine."Source Line No.");
        WhseActivLineTake.SetRange("Item No.", WarehouseActivityLine."Item No.");
        WhseActivLineTake.SetRange("Lot No.", WarehouseActivityLine."Lot No.");
        WhseActivLineTake.SetRange("Action Type", WhseActivLineTake."Action Type"::Take);
        if WhseActivLineTake.FindFirst() then begin
            WarehouseActivityLine.Validate("Qty. to Handle", WhseActivLineTake."Qty. to Handle");
            WarehouseActivityLine.Validate("Units to Handle_DU_TSL", WhseActivLineTake."Units to Handle_DU_TSL");
            WarehouseActivityLine.Modify();
            exit(true);
        end;
        exit(false);
    end;

    local procedure CheckPlaceLineExists(var WarehouseActivityLine: Record "Warehouse Activity Line"): Boolean
    var
        WhseActivLinePlace: Record "Warehouse Activity Line";
    begin
        WhseActivLinePlace.Reset();
        WhseActivLinePlace.SetRange("Source Type", WarehouseActivityLine."Source Type");
        WhseActivLinePlace.SetRange("Source Subtype", WarehouseActivityLine."Source Subtype");
        WhseActivLinePlace.SetRange("Source No.", WarehouseActivityLine."Source No.");
        WhseActivLinePlace.SetRange("Source Line No.", WarehouseActivityLine."Source Line No.");
        WhseActivLinePlace.SetRange("Item No.", WarehouseActivityLine."Item No.");
        WhseActivLinePlace.SetRange("Lot No.", WarehouseActivityLine."Lot No.");
        WhseActivLinePlace.SetRange("Action Type", WhseActivLinePlace."Action Type"::Place);
        if WhseActivLinePlace.FindFirst() then begin
            WhseActivLinePlace.Validate("Qty. to Handle", WarehouseActivityLine."Qty. to Handle");
            WhseActivLinePlace.Validate("Units to Handle_DU_TSL", WarehouseActivityLine."Units to Handle_DU_TSL");
            WhseActivLinePlace.Modify();
            exit(true);
        end;
        exit(false);
    end;

    local procedure GetPickQtyBase(var WarehouseActivityLine: Record "Warehouse Activity Line"): Decimal
    var
        WarehouseActivityLinePickQty: Record "Warehouse Activity Line";
        TotalPickQtyBase: Decimal;
        LastPickedQtyBase: Decimal;
    begin
        TotalPickQtyBase := 0;
        LastPickedQtyBase := 0;
        WarehouseActivityLinePickQty.Reset();
        WarehouseActivityLinePickQty.SetRange("Action Type", WarehouseActivityLinePickQty."Action Type"::Take);
        WarehouseActivityLinePickQty.SetRange("Assemble to Order", false);
        WarehouseActivityLinePickQty.SetRange("Bin Code", WarehouseActivityLine."Bin Code");
        WarehouseActivityLinePickQty.SetRange("Item No.", WarehouseActivityLine."Item No.");
        WarehouseActivityLinePickQty.SetRange("Location Code", WarehouseActivityLine."Location Code");
        WarehouseActivityLinePickQty.SetRange("Variant Code", WarehouseActivityLine."Variant Code");
        WarehouseActivityLinePickQty.SetRange("Lot No.", WarehouseActivityLine."Lot No.");
        if WarehouseActivityLinePickQty.FindSet() then
            repeat
                if WarehouseActivityLinePickQty."No." <> WarehouseActivityLine."No." then
                    TotalPickQtyBase += WarehouseActivityLinePickQty."Qty. Outstanding (Base)"
                else begin
                    TotalPickQtyBase += WarehouseActivityLinePickQty."Qty. Outstanding (Base)";
                    LastPickedQtyBase := WarehouseActivityLinePickQty."Qty. Outstanding (Base)";
                end;
            until WarehouseActivityLinePickQty.Next() = 0;
        exit(TotalPickQtyBase - LastPickedQtyBase);
    end;

    local procedure GetCaseQtyBase(var WarehouseActivityLine: Record "Warehouse Activity Line"): Decimal
    var
        WarehouseEntry: Record "Warehouse Entry";
        TotalCaseQtyBase: Decimal;
    begin
        TotalCaseQtyBase := 0;
        WarehouseEntry.Reset();
        WarehouseEntry.SetRange("Bin Code", WarehouseActivityLine."Bin Code");
        WarehouseEntry.SetRange("Item No.", WarehouseActivityLine."Item No.");
        WarehouseEntry.SetRange("Location Code", WarehouseActivityLine."Location Code");
        WarehouseEntry.SetRange("Variant Code", WarehouseActivityLine."Variant Code");
        WarehouseEntry.SetRange("Lot No.", WarehouseActivityLine."Lot No.");
        if WarehouseEntry.FindSet() then
            repeat
                TotalCaseQtyBase += WarehouseEntry.Units_DU_TSL;
            until WarehouseEntry.Next() = 0;
        exit(TotalCaseQtyBase);
    end;

    local procedure GetRemaingQtyForAvailableCase(var WarehouseActivityLine: Record "Warehouse Activity Line"): Decimal
    var
        WarehouseEntry: Record "Warehouse Entry";
        TotalRemainingQtyForCase: Decimal;
    begin
        TotalRemainingQtyForCase := 0;
        WarehouseEntry.Reset();
        WarehouseEntry.SetRange("Bin Code", WarehouseActivityLine."Bin Code");
        WarehouseEntry.SetRange("Item No.", WarehouseActivityLine."Item No.");
        WarehouseEntry.SetRange("Location Code", WarehouseActivityLine."Location Code");
        WarehouseEntry.SetRange("Variant Code", WarehouseActivityLine."Variant Code");
        WarehouseEntry.SetRange("Lot No.", WarehouseActivityLine."Lot No.");
        if WarehouseEntry.FindSet() then
            repeat
                TotalRemainingQtyForCase += WarehouseEntry.Quantity;
            until WarehouseEntry.Next() = 0;
        exit(TotalRemainingQtyForCase);
    end;
    //<<AFDP 10/17/2025 'T0025-Pick Using Average Weight'
    #endregion Functions
}

//AFDP 05/30/2025 'Short Orders'


namespace AFood.DP.AFoodDevelopment;
using Microsoft.Sales.Document;
using Microsoft.Warehouse.Setup;
using Microsoft.Purchases.History;
using Microsoft.Warehouse.Posting;
using Microsoft.Warehouse.Document;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Posting;
using Microsoft.Inventory.Setup;
using Microsoft.Sales.Posting;
using System.Utilities;
using Microsoft.Warehouse.Activity;
using Microsoft.Purchases.Pricing;

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
    //>>AFDP 09/03/2025 'T0021-Show License Plate on Pick'
    [EventSubscriber(ObjectType::Table, Database::"Warehouse Activity Line", 'OnAfterInsertEvent', '', false, false)]
    local procedure WarehouseActivityLine_OnAfterInsertEvent(var Rec: Record "Warehouse Activity Line"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary then
            exit;
        // if not RunTrigger then
        //     exit;
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
    #endregion Functions
}

//AFDP 05/30/2025 'Short Orders'


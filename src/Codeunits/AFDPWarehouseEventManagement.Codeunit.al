namespace AFood.DP.AFoodDevelopment;
using Microsoft.Sales.Document;
using Microsoft.Purchases.History;
using Microsoft.Warehouse.Posting;
using Microsoft.Warehouse.Document;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Posting;
using Microsoft.Inventory.Setup;
using Microsoft.Sales.Posting;

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
        INVCSingleInstance: Codeunit "INVC Single Instance";
    begin
        //>>AFDP 05/31/2025 'Short Orders'
        InventorySetup.Get();
        if not InventorySetup."Disable Sales Backorders" then
            exit;
        if INVCSingleInstance.GetIsWarehousePostShipment() then
            if TempSalesLine."Qty. to Ship" > 0 then begin
                TempSalesLine."Quantity Shipped" += TempSalesLine."Qty. to Ship";
                TempSalesLine."Qty. Shipped (Base)" += TempSalesLine."Qty. to Ship (Base)";
                TempSalesLine.Quantity := TempSalesLine."Quantity Shipped";
                TempSalesLine."Quantity (Base)" := TempSalesLine."Qty. Shipped (Base)";
                IsHandled := true;
            end;
        //<<AFDP 05/31/2025 'Short Orders'
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales Whse. Post Shipment", 'OnPostSourceDocumentOnBeforePostSalesHeader', '', false, false)]
    local procedure SalesWhsePostShipment_OnPostSourceDocumentOnBeforePostSalesHeader(var SalesPost: Codeunit "Sales-Post"; var SalesHeader: Record "Sales Header"; WhseShptHeader: Record "Warehouse Shipment Header"; var CounterSourceDocOK: Integer; var WhsePostParameters: Record "Whse. Post Parameters"; var IsHandled: Boolean)
    var
        INVCSingleInstance: Codeunit "INVC Single Instance";
    begin
        INVCSingleInstance.SetIsWarehousePostShipment(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales Whse. Post Shipment", 'OnPostSourceDocumentOnBeforePrintSalesDocuments', '', false, false)]
    local procedure SalesWhsePostShipment_OnPostSourceDocumentOnBeforePrintSalesDocuments(LastShippingNo: Code[20])
    var
        INVCSingleInstance: Codeunit "INVC Single Instance";
    begin
        INVCSingleInstance.SetIsWarehousePostShipment(false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Post Shipment", 'OnBeforeDeleteUpdateWhseShptLine', '', false, false)]
    local procedure WhsePostShipment_OnBeforeDeleteUpdateWhseShptLine(WhseShptLine: Record "Warehouse Shipment Line"; var DeleteWhseShptLine: Boolean; var WhseShptLineBuf: Record "Warehouse Shipment Line")
    var
        InventorySetup: Record "Inventory Setup";
        INVCSingleInstance: Codeunit "INVC Single Instance";
    begin
        //>>AFDP 06/01/2025 'Short Orders'
        InventorySetup.Get();
        if not InventorySetup."Disable Sales Backorders" then
            exit;
        if INVCSingleInstance.GetIsWarehousePostShipment() then
            if not DeleteWhseShptLine then begin
                WhseShptLineBuf."Qty. Outstanding" := WhseShptLineBuf."Qty. to Ship";
                DeleteWhseShptLine := true;
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
        INVCSingleInstance: Codeunit "INVC Single Instance";
    begin
        //>>AFDP 06/01/2025 'Short Orders'
        InventorySetup.Get();
        if not InventorySetup."Disable Purchase Backorders" then
            exit;
        if INVCSingleInstance.GetIsWarehousePostReceipt() then
            if TempPurchLine."Qty. to Receive" > 0 then begin
                TempPurchLine.Quantity := TempPurchLine."Quantity Received";
                TempPurchLine."Quantity (Base)" := TempPurchLine."Qty. Received (Base)";
            end;
        //<<AFDP 06/01/2025 'Short Orders'
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Post Receipt", 'OnPostSourceDocumentOnBeforePostPurchaseHeader', '', false, false)]
    local procedure PurchWhsePostShipment_OnPostSourceDocumentOnBeforePostPurchaseHeader(var PurchHeader: Record "Purchase Header"; WhseRcptHeader: Record "Warehouse Receipt Header"; SuppressCommit: Boolean; var CounterSourceDocOK: Integer; var IsHandled: Boolean)
    var
        INVCSingleInstance: Codeunit "INVC Single Instance";
    begin
        INVCSingleInstance.SetIsWarehousePostReceipt(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Post Receipt", 'OnPostSourceDocumentOnAfterPostPurchaseHeader', '', false, false)]
    local procedure PurchWhsePostShipment_OnPostSourceDocumentOnAfterPostPurchaseHeader(PurchaseHeader: record "Purchase Header")
    var
        INVCSingleInstance: Codeunit "INVC Single Instance";
    begin
        INVCSingleInstance.SetIsWarehousePostReceipt(false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Post Receipt", 'OnBeforePostUpdateWhseRcptLine', '', false, false)]
    local procedure WhsePostReceipt_OnBeforePostUpdateWhseRcptLine(var WarehouseReceiptLine: Record "Warehouse Receipt Line"; var WarehouseReceiptLineBuf: Record "Warehouse Receipt Line"; var DeleteWhseRcptLine: Boolean; var WarehouseReceiptHeader: Record "Warehouse Receipt Header")
    var
        InventorySetup: Record "Inventory Setup";
        INVCSingleInstance: Codeunit "INVC Single Instance";
    begin
        //>>AFDP 06/01/2025 'Short Orders'
        InventorySetup.Get();
        if not InventorySetup."Disable Purchase Backorders" then
            exit;
        if INVCSingleInstance.GetIsWarehousePostReceipt() then
            if not DeleteWhseRcptLine then begin
                WarehouseReceiptLineBuf."Qty. Outstanding" := WarehouseReceiptLineBuf."Qty. to Receive";
                DeleteWhseRcptLine := true;
            end;
        //<<AFDP 06/01/2025 'Short Orders'
    end;
    #endregion EventSubscribers

    #region Functions

    #endregion Functions
}

//AFDP 05/30/2025 'Short Orders'


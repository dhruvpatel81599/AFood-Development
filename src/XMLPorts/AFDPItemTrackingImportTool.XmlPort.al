namespace AFood.DP.AFoodDevelopment;
using Microsoft.Inventory.Tracking;
using Microsoft.Purchases.Document;
using Microsoft.Warehouse.Document;
using Microsoft.Inventory.Item;
xmlport 50300 "AFDP Item Tracking Import Tool"
{
    Caption = 'Item Tracking Import Tool';
    UseRequestPage = false;
    Direction = Import;
    DefaultFieldsValidation = false;
    Format = VariableText;
    schema
    {
        textelement(Root)
        {
            tableelement(AFDPItemTrackingImportEntry; "AFDP Item Tracking ImportEntry")
            {
                AutoSave = false;
                AutoUpdate = false;
                AutoReplace = false;
                textelement(PONumber) { }
                textelement(PODate) { }
                textelement(VendorItemNumber) { }
                textelement(QuantityShipped) { }
                textelement(NetWeight) { } //AFDP 06/16/2025 'T0012-Item Tracking Import Tools'
                textelement(LotNumber) { }
                textelement(ExpirationDate) { }
                textelement(ProductionDate) { }
                trigger OnAfterInitRecord()
                begin
                    Clear(LastEntryNo);
                    Clear(PONumber);
                    Clear(PODate);
                    Clear(VendorItemNumber);
                    Clear(QuantityShipped);
                    Clear(NetWeight); //AFDP 06/16/2025 'T0012-Item Tracking Import Tools'
                    Clear(LotNumber);
                    Clear(ExpirationDate);
                    Clear(ProductionDate);
                end;

                trigger OnBeforeInsertRecord()
                begin
                    if PONumber <> 'PO Number' then   //skip header row
                        if format(PONumber) <> '' then begin
                            LastEntryNo := GetLastEntryNo();
                            ProgressWindow.UPDATE(1, format(LotNumber));
                            //---------------------\\
                            ItemTrackingImportEntry1.Init();
                            ItemTrackingImportEntry1."Entry No." := LastEntryNo + 1;
                            ItemTrackingImportEntry1."PO No." := format(PONumber);
                            ItemTrackingImportEntry1."PO Date" := ConvertIntoDate(PODate);
                            ItemTrackingImportEntry1."Vendor Item No." := format(VendorItemNumber);
                            // ItemTrackingImportEntry1.Description := format(Description);
                            ItemTrackingImportEntry1."Quantity Shipped" := ConvertIntoDecimal(QuantityShipped);
                            //>>AFDP 06/16/2025 'T0012-Item Tracking Import Tools'
                            ItemTrackingImportEntry1."Net Weight" := ConvertIntoDecimal(NetWeight);
                            //<<AFDP 06/16/2025 'T0012-Item Tracking Import Tools'                            
                            ItemTrackingImportEntry1."Lot Number" := format(LotNumber);
                            ItemTrackingImportEntry1."Expiration Date" := ConvertIntoDate(ExpirationDate);
                            ItemTrackingImportEntry1."Production Date" := ConvertIntoDate(ProductionDate);
                            ItemTrackingImportEntry1.Insert(true);
                            TotalRecordImported += 1;
                        end;
                end;
            }
        }
    }
    trigger OnPreXmlPort()
    begin
        //>>AFDP 08/14/2025 'T0020-Item Tracking Import Tools III'
        // //-- Clear previous entries--\\
        // ItemTrackingImportEntry1.Reset();
        // ItemTrackingImportEntry1.SetCurrentKey("Entry No.");
        // ItemTrackingImportEntry1.SetRange("Tracking Created");
        // ItemTrackingImportEntry1.DeleteAll();
        // //-----------\\
        //<<AFDP 08/14/2025 'T0020-Item Tracking Import Tools III'
        ProgressWindow.OPEN('Importing Lot No.: #1#############');
        TotalRecordImported := 0;
    end;

    trigger OnPostXmlPort()
    begin
        ProgressWindow.CLOSE();
        //>>AFDP 08/14/2025 'T0020-Item Tracking Import Tools III'
        // if TotalRecordImported > 0 then begin
        //     ClearQtyToReceiveOnPurchseLineForImportEntry();
        //     InsertItemTrackingLineForImportEntry();
        // end;
        //<<AFDP 08/14/2025 'T0020-Item Tracking Import Tools III'
        MESSAGE('Total Record Imported: %1', TotalRecordImported);
    end;

    var
        ItemTrackingImportEntry1: Record "AFDP Item Tracking ImportEntry";
        ProgressWindow: Dialog;
        TotalRecordImported: Integer;
        LastEntryNo: Integer;
        ItemNo: code[20];

    local procedure GetLastEntryNo(): Integer;
    var
        ItemTrackingImportEntry: Record "AFDP Item Tracking ImportEntry";
    begin
        ItemTrackingImportEntry.Reset();
        ItemTrackingImportEntry.SetCurrentKey("Entry No.");
        ItemTrackingImportEntry.SetRange("Entry No.");
        if ItemTrackingImportEntry.FindLast() then
            exit(ItemTrackingImportEntry."Entry No.")
        else
            exit(0);
    end;

    local procedure ConvertIntoDecimal(DecimalTxt: Text[30]) DecimalValue: Decimal;
    begin
        if (DecimalTxt = '-') or (DecimalTxt = '') then
            DecimalTxt := '0';

        Evaluate(DecimalValue, DecimalTxt);
    end;

    // local procedure ConvertIntoInteger(IntegerTxt: Text[30]) IntegerValue: Integer;
    // begin
    //     if (IntegerTxt = '-') or (IntegerTxt = '') then
    //         IntegerTxt := '0';

    //     Evaluate(IntegerValue, IntegerTxt);
    // end;

    local procedure ConvertIntoDate(DateTxt: Text[30]) DateValue: Date;
    begin
        if (DateTxt = '-') or (DateTxt = '') then begin
            DateValue := 0D;
            exit(DateValue);
        end;

        if Evaluate(DateValue, DateTxt) then
            DateValue := DateValue
        else
            DateValue := 0D;
    end;

    local procedure InsertItemTrackingLineForImportEntry()
    var
        PurchseLine: Record "Purchase Line";
    // WarehouseReceiptLine: Record "Warehouse Receipt Line";
    begin
        ItemTrackingImportEntry1.Reset();
        ItemTrackingImportEntry1.SetCurrentKey("Entry No.");
        ItemTrackingImportEntry1.SetRange("Tracking Created", false);
        ItemTrackingImportEntry1.SetFilter("Quantity Shipped", '<>0');
        ItemTrackingImportEntry1.SetFilter("Lot Number", '<>%1', '');
        ItemTrackingImportEntry1.SetFilter("Vendor Item No.", '<>%1', '');
        ItemTrackingImportEntry1.SetFilter("PO No.", '<>%1', '');
        if ItemTrackingImportEntry1.FindSet() then
            repeat
                Clear(ItemNo);
                If IsPurchaseOrderExist(ItemTrackingImportEntry1, PurchseLine) then begin
                    ItemNo := PurchseLine."No.";
                    InsertReservationEntryForPurchaseLine(ItemTrackingImportEntry1, PurchseLine);
                    ItemTrackingImportEntry1."Tracking Created" := true;
                    ItemTrackingImportEntry1.Modify();
                    // if IsWarehouseReceiptExists(ItemTrackingImportEntry, WarehouseReceiptLine) then
                    //     InsertReservationEntryForWarehouserReceiptLine(ItemTrackingImportEntry, WarehouseReceiptLine)
                    // else
                    //     InsertReservationEntryForPurchaseLine(ItemTrackingImportEntry, PurchseLine);
                end;
            until ItemTrackingImportEntry1.Next() = 0;
    end;

    local procedure ClearQtyToReceiveOnPurchseLineForImportEntry()
    var
        PurchseLine: Record "Purchase Line";
    begin
        ItemTrackingImportEntry1.Reset();
        ItemTrackingImportEntry1.SetCurrentKey("Entry No.");
        ItemTrackingImportEntry1.SetRange("Tracking Created", false);
        ItemTrackingImportEntry1.SetFilter("Quantity Shipped", '<>0');
        ItemTrackingImportEntry1.SetFilter("Lot Number", '<>%1', '');
        ItemTrackingImportEntry1.SetFilter("Vendor Item No.", '<>%1', '');
        ItemTrackingImportEntry1.SetFilter("PO No.", '<>%1', '');
        if ItemTrackingImportEntry1.FindSet() then
            repeat
                If IsPurchaseOrderExist(ItemTrackingImportEntry1, PurchseLine) then begin
                    PurchseLine."Qty. to Receive (Base)" := 0;
                    PurchseLine."Units to Receive_DU_TSL" := 0;
                    PurchseLine.Modify();
                    ClearQtyToReceiveOnWarehouseReceiptLineForImportEntry(PurchseLine);
                end;
            until ItemTrackingImportEntry1.Next() = 0;
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

    local procedure IsPurchaseOrderExist(ItemTrackingImportEntry: Record "AFDP Item Tracking ImportEntry"; var PurchaseLine: Record "Purchase Line"): Boolean;
    begin
        PurchaseLine.Reset();
        PurchaseLine.SetRange("Document Type", PurchaseLine."Document Type"::Order);
        PurchaseLine.SetRange("Document No.", ItemTrackingImportEntry."PO No.");
        PurchaseLine.SetRange(Type, PurchaseLine.Type::Item);
        PurchaseLine.SetRange("No.", ItemTrackingImportEntry."Vendor Item No.");
        if not PurchaseLine.IsEmpty then begin
            PurchaseLine.FindFirst();
            exit(true);
        end else begin
            PurchaseLine.SetRange("No.");
            PurchaseLine.SetRange("Vendor Item No.", ItemTrackingImportEntry."Vendor Item No.");
            if not PurchaseLine.IsEmpty then begin
                PurchaseLine.FindFirst();
                exit(true);
            end;
        end;
        exit(false);
    end;

    // local procedure IsWarehouseReceiptExists(ItemTrackingImportEntry: Record "AFDP Item Tracking ImportEntry"; var WarehouseReceiptLine: Record "Warehouse Receipt Line"): Boolean;
    // begin
    //     WarehouseReceiptLine.Reset();
    //     WarehouseReceiptLine.SetRange("Source Type", 39); // 39 = Purchase
    //     WarehouseReceiptLine.SetRange("Source Subtype", WarehouseReceiptLine."Source Subtype"::"1"); // 1 = Purchase Order
    //     WarehouseReceiptLine.SetRange("Source No.", ItemTrackingImportEntry."PO No.");
    //     WarehouseReceiptLine.SetRange("Item No.", ItemNo);
    //     if not WarehouseReceiptLine.IsEmpty then begin
    //         WarehouseReceiptLine.FindFirst();
    //         exit(true);
    //     end else
    //         exit(false);
    // end;
    local procedure ClearQtyToReceiveOnWarehouseReceiptLineForImportEntry(PurchaseLine: Record "Purchase Line");
    var
        WarehouseReceiptLine: Record "Warehouse Receipt Line";
    begin
        WarehouseReceiptLine.Reset();
        WarehouseReceiptLine.SetRange("Source Type", 39); // 39 = Purchase
        WarehouseReceiptLine.SetRange("Source Subtype", WarehouseReceiptLine."Source Subtype"::"1"); // 1 = Purchase Order
        WarehouseReceiptLine.SetRange("Source No.", PurchaseLine."Document No.");
        WarehouseReceiptLine.SetRange("Source Line No.", PurchaseLine."Line No.");
        WarehouseReceiptLine.SetRange("Item No.", PurchaseLine."No.");
        if WarehouseReceiptLine.FindSet() then
            repeat
                WarehouseReceiptLine."Qty. to Receive (Base)" := 0;
                WarehouseReceiptLine."Units to Receive_DU_TSL" := 0;
                WarehouseReceiptLine.Modify();
            until WarehouseReceiptLine.Next() = 0;
    end;

    local procedure InsertReservationEntryForPurchaseLine(ItemTrackingImportEntry: Record "AFDP Item Tracking ImportEntry"; PurchaseLine: Record "Purchase Line")
    var
        ReservationEntry: Record "Reservation Entry";
        Item: Record Item;
        LastReservationEntryNo: Integer;
        QuantityToReceive: Decimal;
        CaseToReceive: Decimal;
    begin
        if Item.get(PurchaseLine."No.") then;
        QuantityToReceive := PurchaseLine."Qty. to Receive (Base)";
        CaseToReceive := PurchaseLine."Units to Receive_DU_TSL";
        //--Update Quantity To Receive First Before Create Item Tracking Line--\\
        if (item."Base Unit of Measure" = 'LB') and (item."Unit of Measure - Units_DU_TSL" = 'CASE') then begin
            QuantityToReceive := QuantityToReceive + ItemTrackingImportEntry."Net Weight";
            CaseToReceive := CaseToReceive + ItemTrackingImportEntry."Quantity Shipped";
        end else
            if (item."Base Unit of Measure" = 'CASE') and (item."Unit of Measure - Units_DU_TSL" = '') then
                QuantityToReceive := QuantityToReceive + ItemTrackingImportEntry."Quantity Shipped"
            else
                QuantityToReceive := QuantityToReceive + ItemTrackingImportEntry."Quantity Shipped";

        if (QuantityToReceive <> PurchaseLine."Qty. to Receive (Base)") then
            PurchaseLine.Validate("Qty. to Receive", QuantityToReceive);
        if (CaseToReceive <> PurchaseLine."Units to Receive_DU_TSL") then
            PurchaseLine.Validate("Units to Receive_DU_TSL", CaseToReceive);
        PurchaseLine.Modify(true);
        //--Update Qty to Receive on Warehouse Receipt Line--\\
        UpdateQtyToReceiveOnWarehouseReceiptLineForImportEntry(PurchaseLine);
        //--Create Reservation Entry---\\
        LastReservationEntryNo := GetLastReservationEntryNo();
        ReservationEntry.Init();
        ReservationEntry."Entry No." := LastReservationEntryNo + 1;
        ReservationEntry.Validate("Item No.", PurchaseLine."No.");
        ReservationEntry.Validate("Location Code", PurchaseLine."Location Code");
        ReservationEntry.Validate("Reservation Status", ReservationEntry."Reservation Status"::Surplus);
        ReservationEntry.Validate("Source Type", 39);
        ReservationEntry.validate("Source Subtype", ReservationEntry."Source Subtype"::"1"); // 1 = Purchase Order
        ReservationEntry.Validate("Source ID", PurchaseLine."Document No.");
        ReservationEntry.Validate("Source Ref. No.", PurchaseLine."Line No.");
        ReservationEntry.Validate(Positive, true);
        if (item."Base Unit of Measure" = 'LB') and (item."Unit of Measure - Units_DU_TSL" = 'CASE') then begin
            ReservationEntry.Validate("Quantity", ItemTrackingImportEntry."Net Weight");
            ReservationEntry.Validate("Quantity (Base)", ItemTrackingImportEntry."Net Weight");
            ReservationEntry.Validate("Units (Base)_DU_TSL", ItemTrackingImportEntry."Quantity Shipped");
            ReservationEntry.Validate("Units to Handle_DU_TSL", ItemTrackingImportEntry."Quantity Shipped");
        end else
            if (item."Base Unit of Measure" = 'CASE') and (item."Unit of Measure - Units_DU_TSL" = '') then begin
                ReservationEntry.Validate("Quantity", ItemTrackingImportEntry."Quantity Shipped");
                ReservationEntry.Validate("Quantity (Base)", ItemTrackingImportEntry."Quantity Shipped");
            end else begin
                ReservationEntry.Validate("Quantity", ItemTrackingImportEntry."Quantity Shipped");
                ReservationEntry.Validate("Quantity (Base)", ItemTrackingImportEntry."Quantity Shipped");
            end;
        //<<AFDP 06/16/2025 'T0012-Item Tracking Import Tools'
        ReservationEntry.Validate("Expiration Date", ItemTrackingImportEntry."Expiration Date");
        ReservationEntry.Validate("Lot No.", ItemTrackingImportEntry."Lot Number");
        ReservationEntry.Validate("Item Tracking", ReservationEntry."Item Tracking"::"Lot No.");
        ReservationEntry.Insert();
        // //>>AFDP 06/16/2025 'T0012-Item Tracking Import Tools'        
    end;

    local procedure UpdateQtyToReceiveOnWarehouseReceiptLineForImportEntry(PurchaseLine: Record "Purchase Line");
    var
        WarehouseReceiptLine: Record "Warehouse Receipt Line";
    begin
        WarehouseReceiptLine.Reset();
        WarehouseReceiptLine.SetRange("Source Type", 39); // 39 = Purchase
        WarehouseReceiptLine.SetRange("Source Subtype", WarehouseReceiptLine."Source Subtype"::"1"); // 1 = Purchase Order
        WarehouseReceiptLine.SetRange("Source No.", PurchaseLine."Document No.");
        WarehouseReceiptLine.SetRange("Source Line No.", PurchaseLine."Line No.");
        WarehouseReceiptLine.SetRange("Item No.", PurchaseLine."No.");
        if WarehouseReceiptLine.FindFirst() then begin
            WarehouseReceiptLine.Validate("Qty. to Receive", PurchaseLine."Qty. to Receive (Base)");
            // WarehouseReceiptLine.Validate("Qty. to Receive (Base)", PurchaseLine."Qty. to Receive (Base)");
            if (PurchaseLine."Units to Receive_DU_TSL" <> 0) then
                WarehouseReceiptLine.Validate("Units to Receive_DU_TSL", PurchaseLine."Units to Receive_DU_TSL");
            WarehouseReceiptLine.Modify(true);
        end;
    end;
}

//AFDP 06/06/2025 'Item Tracking Import Tools'
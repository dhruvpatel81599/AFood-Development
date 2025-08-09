namespace AFood.DP.AFoodDevelopment;

using Microsoft.Warehouse.Activity;
using Microsoft.Inventory.Tracking;
using Microsoft.Sales.Document;
using Microsoft.Inventory.Item;
using Microsoft.Warehouse.Document;
using Microsoft.Warehouse.Tracking;

codeunit 50307 "AFDP Lot Status Management"
{

    #region Global Variables
    var

    #endregion Global Variables

    #region EventSubcribers
    // [EventSubscriber(ObjectType::Table, Database::"Warehouse Activity Line", 'OnBeforeValidateEvent', 'Lot No.', false, false)]
    // local procedure WarehouseActivityLine_OnBeforeValidateEvent(var Rec: Record "Warehouse Activity Line"; xRec: Record "Warehouse Activity Line"; CurrFieldNo: Integer)
    // begin
    //     AFDPValidateWarehouseActivityLineLotStatus(Rec, xRec);
    //     if Rec.IsTemporary then
    //         exit;
    //     if rec."Action Type" = rec."Action Type"::Take then
    //         AFDPUpdateLotNoOnPlaceLineForWarehouseActivityLine(Rec);

    //     if rec."Action Type" <> rec."Action Type"::Take then exit;
    //     if rec."Lot No." <> '' then
    //         if IsPassManualMaxLotSelectionForCustomerLotPrefrence(Rec) then begin
    //             if IsPassShelfLifeForLotNo(rec."Lot No.") then;  //--Check Shelf Life for selected Lot No.--\\
    //         end else
    //             if IsPassShelfLifeForLotNo(rec."Lot No.") then;  //--Check Shelf Life for selected Lot No.--\\        
    // end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Pick", 'OnCreateTempItemTrkgLinesOnAfterCalcQtyTracked', '', false, false)]
    local procedure CreatePick_OnCreateTempItemTrkgLinesOnAfterCalcQtyTracked(EntrySummary: Record "Entry Summary"; var TempWhseItemTrackingLine: Record "Whse. Item Tracking Line" temporary; var QuantityTracked: Decimal)
    var
        AFDPSingleInstance: Codeunit "AFDP Single Instance";
    begin
        //--Set Expiration Date--\\
        AFDPSingleInstance.SetLotExpirationDate(EntrySummary."Expiration Date");
        //-----------------------\\
        if not IsPassShelfLifeForLotNo(EntrySummary."Lot No.") then  //--Check Shelf Life for selected Lot No.--\\
            AFDPSingleInstance.SetIsShelfLifeNotValidForLot(true);
        //-----------------------\\
    end;

    // [EventSubscriber(ObjectType::Table, Database::"Tracking Specification", 'OnBeforeValidateEvent', 'Lot No.', false, false)]
    // local procedure TrackingSpecification_OnBeforeValidateEvent(var Rec: Record "Tracking Specification" temporary; xRec: Record "Tracking Specification" temporary; CurrFieldNo: Integer)
    // begin
    //     if rec."Source Type" <> Database::"Sales Line" then exit;
    //     if rec."Source Subtype" <> rec."Source Subtype"::"1" then exit;
    //     if rec."Lot No." <> '' then
    //         if IsPassManualMaxLotSelectionOnSalesLineForCustomerLotPrefrence(Rec) then begin
    //             if IsPassShelfLifeForLotNo(rec."Lot No.") then;  //--Check Shelf Life for selected Lot No.--\\
    //         end else
    //             if IsPassShelfLifeForLotNo(rec."Lot No.") then;  //--Check Shelf Life for selected Lot No.--\\
    // end;

    [EventSubscriber(ObjectType::Report, Report::"Whse.-Shipment - Create Pick", 'OnAfterGetRecordWarehouseShipmentLineOnBeforeCreatePickTempLine', '', false, false)]
    local procedure WhseShipmentCreatePick_OnAfterGetRecordWarehouseShipmentLineOnBeforeCreatePickTempLine(var WarehouseShipmentLine: Record "Warehouse Shipment Line")
    var
        AFDPSingleInstance: Codeunit "AFDP Single Instance";
    // LotPreferenceShipToCode: Code[10];
    begin
        AFDPSingleInstance.SetLotPreferenceCustomerNo(WarehouseShipmentLine."Destination No.");
        AFDPSingleInstance.SetLotPreferenceItemNo(WarehouseShipmentLine."Item No.");
        AFDPSingleInstance.SetLotPreferenceVariantCode(WarehouseShipmentLine."Variant Code");
        AFDPSingleInstance.SetLotPreferenceSourceNo(WarehouseShipmentLine."Source No.");
        AFDPSingleInstance.SetLotPreferenceSourceLineNo(WarehouseShipmentLine."Source Line No.");
        AFDPSingleInstance.SetShipmentDate(WarehouseShipmentLine."Shipment Date");
        AFDPSingleInstance.SetPreviousLotPreferenceItemNo('');
        AFDPSingleInstance.SetPreviousLotPreferenceSourceLineNo(0);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Pick", 'OnBeforeInsertTempItemTrkgLine', '', false, false)]
    local procedure CreatePick_OnBeforeInsertTempItemTrkgLine(var EntrySummary: Record "Entry Summary"; RemQtyToPickBase: Decimal; var TotalAvailQtyToPickBase: Decimal)
    var
        AFDPSingleInstance: Codeunit "AFDP Single Instance";
    begin
        if AFDPSingleInstance.GetIsShelfLifeNotValidForLot() then
            TotalAvailQtyToPickBase := 0;
        AFDPSingleInstance.SetIsShelfLifeNotValidForLot(false);
    end;
    #endregion EventSubscribers

    #region Functions    
    local procedure IsPassShelfLifeForLotNo(LotNo: Code[50]): Boolean
    var
        AFDPCustomerLotPreference: Record "AFDP Customer Lot Preferences";
        LotNoInformation: Record "Lot No. Information";
        Item: Record Item;
        AFDPSingleInstance: Codeunit "AFDP Single Instance";
        CustomerLotPreferenceShelfLife: DateFormula;
        LotPreferenceCustomerNo: Code[20];
        LotPreferenceItemNo: code[20];
        LotPreferenceVariantCode: Code[10];
        NoOfDaysRemaining: Integer;
        ItemShelfLifeDays: Integer;
        CustomerLotPreferenceShelfLifeDays: Integer;
        ShipmentDate: Date;
        LotExpirationDate: Date;
    begin
        //--Get Customer Lot Preference Shelf Life ---\\
        Clear(CustomerLotPreferenceShelfLifeDays);
        Clear(CustomerLotPreferenceShelfLife);
        Clear(ShipmentDate);
        Clear(LotExpirationDate);
        LotPreferenceCustomerNo := AFDPSingleInstance.GetLotPreferenceCustomerNo();
        LotPreferenceItemNo := AFDPSingleInstance.GetLotPreferenceItemNo();
        LotPreferenceVariantCode := AFDPSingleInstance.GetLotPreferenceVariantCode();
        ShipmentDate := AFDPSingleInstance.GetShipmentDate();
        LotExpirationDate := AFDPSingleInstance.GetLotExpirationDate();
        //--Check Lot Info--\\
        if LotNo = '' then
            exit(true);
        LotNoInformation.Reset();
        if not LotNoInformation.Get(LotPreferenceItemNo, LotPreferenceVariantCode, LotNo) then
            exit(true);
        //--Find Default Shelf Life From Item Card--\\
        if not Item.Get(LotPreferenceItemNo) then
            exit(true);
        if format(Item."AFDP Default Sales Shelf Life") = '' then
            exit(true);
        ItemShelfLifeDays := (CalcDate(Item."AFDP Default Sales Shelf Life", Today) - Today);
        //--Find Shelf Life From Customer Lot Preference-\\
        AFDPCustomerLotPreference.Reset();
        AFDPCustomerLotPreference.SetRange("AFDP Customer No.", LotPreferenceCustomerNo);
        AFDPCustomerLotPreference.SetRange("AFDP Item No.", LotPreferenceItemNo);
        if AFDPCustomerLotPreference.FindFirst() then
            CustomerLotPreferenceShelfLife := AFDPCustomerLotPreference."AFDP Shelf Life"
        else
            if LotPreferenceItemNo <> '' then begin
                AFDPCustomerLotPreference.SetRange("AFDP Item No.", '');
                if AFDPCustomerLotPreference.FindFirst() then
                    CustomerLotPreferenceShelfLife := AFDPCustomerLotPreference."AFDP Shelf Life";
            end;
        if format(CustomerLotPreferenceShelfLife) <> '' then
            CustomerLotPreferenceShelfLifeDays := (CalcDate(CustomerLotPreferenceShelfLife, Today) - Today);
        //------------------------------------------------------\\
        Clear(NoOfDaysRemaining);
        if ShipmentDate = 0D then
            ShipmentDate := Today; // Default to today if no shipment date is set
        // NoOfDaysRemaining := LotExpirationDate - Today;
        NoOfDaysRemaining := LotExpirationDate - ShipmentDate;
        //--Check Customer Shelf Life Is Valid--\\
        if CustomerLotPreferenceShelfLifeDays <> 0 then
            if NoOfDaysRemaining >= CustomerLotPreferenceShelfLifeDays then
                exit(true)
            else
                exit(false);
        //--Check Item Shelf Life Is Valid--\\
        if ItemShelfLifeDays <> 0 then
            if NoOfDaysRemaining >= ItemShelfLifeDays then
                exit(true)
            else
                exit(false);

        exit(true);
        //---------------------------------\\
        // if format(CustomerLotPreferenceShelfLife) <> '' then begin
        //     //---\\
        //     Clear(NoOfDaysRemaining);
        //     Clear(PercentageShelfLifeRemaining);
        //     //--Find Shelf Life Days--\\
        //     LotNoInformation.Reset();
        //     //------------------------\\
        //     if LotNo = '' then exit(true);
        //     if not LotNoInformation.Get(LotPreferenceItemNo, LotPreferenceVariantCode, LotNo) then exit(true);
        //     if not Item.Get(LotPreferenceItemNo) then exit(true);
        //     if format(item."AFDP Default Sales Shelf Life") = '' then exit(true);
        //     ItemShelfLifeDays := (CalcDate(item."AFDP Default Sales Shelf Life", Today) - Today);
        //     //----\\            
        //     NoOfDaysRemaining := ShipmentDate - Today;
        //     if ItemShelfLifeDays <> 0 then begin
        //         PercentageShelfLifeRemaining := NoOfDaysRemaining / ItemShelfLifeDays;
        //         if PercentageShelfLifeRemaining < CustomerLotPreferenceShelfLifePer then begin
        //             AFDPSingleInstance.SetIsShelfLifeNotValidForLot(true);
        //             Message('Shelf life is not valid for Lot No.: %1', LotNo);
        //             exit(false);
        //         end;
        //     end;
        //     //----\\      
        // end else
        //     exit(true);
    end;

    // local procedure AFDPValidateWarehouseActivityLineLotStatus(var WarehouseActivityLine: Record "Warehouse Activity Line"; xWarehouseActivityLine: Record "Warehouse Activity Line")
    // var
    //     LotNoInformation: Record "Lot No. Information";
    //     NotAvailableForPickErr: Label 'Lot No. %1 is not avaialble for Picks.', Comment = '%1 is the lot no.';
    // begin
    //     if WarehouseActivityLine."Lot No." = '' then
    //         exit;
    //     if WarehouseActivityLine."Lot No." = xWarehouseActivityLine."Lot No." then
    //         exit;
    //     if WarehouseActivityLine."Activity Type" <> WarehouseActivityLine."Activity Type"::Pick then
    //         exit;
    //     if not LotNoInformation.Get(WarehouseActivityLine."Item No.", WarehouseActivityLine."Variant Code", WarehouseActivityLine."Lot No.") then
    //         exit;
    //     Error(NotAvailableForPickErr, WarehouseActivityLine."Lot No.");
    // end;

    // local procedure AFDPUpdateLotNoOnPlaceLineForWarehouseActivityLine(var WarehouseActivityLine: Record "Warehouse Activity Line")
    // var
    //     WarehouseActivityLine1: Record "Warehouse Activity Line";
    // begin
    //     WarehouseActivityLine1.Reset();
    //     WarehouseActivityLine1.SetCurrentKey("No.", "Line No.");
    //     WarehouseActivityLine1.SetRange("Action Type", WarehouseActivityLine1."Action Type"::Place);
    //     WarehouseActivityLine1.SetRange("No.", WarehouseActivityLine."No.");
    //     WarehouseActivityLine1.SetRange("Item No.", WarehouseActivityLine."Item No.");
    //     WarehouseActivityLine1.SetRange("Source Line No.", WarehouseActivityLine."Source Line No.");
    //     WarehouseActivityLine1.SetRange("Whse. Document Line No.", WarehouseActivityLine."Whse. Document Line No.");
    //     WarehouseActivityLine1.SetFilter("Line No.", '>%1', WarehouseActivityLine."Line No.");
    //     if WarehouseActivityLine1.FindFirst() then
    //         if WarehouseActivityLine1."Lot No." <> WarehouseActivityLine."Lot No." then begin
    //             WarehouseActivityLine1.Validate("Lot No.", WarehouseActivityLine."Lot No.");
    //             WarehouseActivityLine1.Modify();
    //         end;
    // end;

    // local procedure IsPassManualMaxLotSelectionOnSalesLineForCustomerLotPrefrence(var TrackingSpecification: Record "Tracking Specification" temporary): Boolean
    // var
    //     SalesLine: Record "Sales Line";
    //     AFDPSingleInstance: Codeunit "AFDP Single Instance";
    //     TotalLots: Integer;
    // begin
    //     Clear(TotalLots);
    //     SalesLine.Reset();
    //     SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
    //     SalesLine.SetRange("Document No.", TrackingSpecification."Source ID");
    //     SalesLine.SetRange("Line No.", TrackingSpecification."Source Ref. No.");
    //     if SalesLine.FindFirst() then begin
    //         AFDPSingleInstance.SetLotPreferenceCustomerNo(SalesLine."Bill-to Customer No.");
    //         AFDPSingleInstance.SetLotPreferenceItemNo(SalesLine."No.");
    //         AFDPSingleInstance.SetLotPreferenceVariantCode(SalesLine."Variant Code");
    //         AFDPSingleInstance.SetShipmentDate(SalesLine."Shipment Date");
    //     end;
    //     exit(true);
    // end;

    // local procedure IsPassManualMaxLotSelectionForCustomerLotPrefrence(var WarehouseActivityLine: Record "Warehouse Activity Line"): Boolean
    // var
    //     AFDPSingleInstance: Codeunit "AFDP Single Instance";
    //     TotalLots: Integer;
    // begin
    //     Clear(TotalLots);
    //     if WarehouseActivityLine."Source Document" = WarehouseActivityLine."Source Document"::"Sales Order" then begin
    //         AFDPSingleInstance.SetLotPreferenceCustomerNo(WarehouseActivityLine."Destination No.");
    //         AFDPSingleInstance.SetLotPreferenceItemNo(WarehouseActivityLine."Item No.");
    //         AFDPSingleInstance.SetLotPreferenceVariantCode(WarehouseActivityLine."Variant Code");
    //     end;
    //     exit(true);
    // end;

    // local procedure IsPassMaxLotSelectionForCustomerLotPrefrence(var TempWhseItemTrackingLine: Record "Whse. Item Tracking Line" temporary): Boolean    
    // begin        
    //     exit(true);
    // end;
    #endregion Functions
}

//AFDP 07/19/2025 'T0005-Customer Lot Preference'



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
    [EventSubscriber(ObjectType::Table, Database::"Warehouse Activity Line", 'OnBeforeValidateEvent', 'Lot No.', false, false)]
    local procedure WarehouseActivityLine_OnBeforeValidateEvent(var Rec: Record "Warehouse Activity Line"; xRec: Record "Warehouse Activity Line"; CurrFieldNo: Integer)
    begin
        AFDPValidateWarehouseActivityLineLotStatus(Rec, xRec);
        if Rec.IsTemporary then
            exit;
        if rec."Action Type" = rec."Action Type"::Take then
            AFDPUpdateLotNoOnPlaceLineForWarehouseActivityLine(Rec);

        if rec."Action Type" <> rec."Action Type"::Take then exit;
        if rec."Lot No." <> '' then
            if IsPassManualMaxLotSelectionForCustomerLotPrefrence(Rec) then begin
                if IsPassShelfLifeForLotNo(rec."Lot No.") then;  //--Check Shelf Life for selected Lot No.--\\
            end else
                if IsPassShelfLifeForLotNo(rec."Lot No.") then;  //--Check Shelf Life for selected Lot No.--\\        
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Pick", 'OnCreateTempItemTrkgLinesOnAfterCalcQtyTracked', '', false, false)]
    local procedure CreatePick_OnCreateTempItemTrkgLinesOnAfterCalcQtyTracked(EntrySummary: Record "Entry Summary"; var TempWhseItemTrackingLine: Record "Whse. Item Tracking Line" temporary; var QuantityTracked: Decimal)
    begin
        //--Check No Of Max Lot selection For Customer-----\\
        if IsPassMaxLotSelectionForCustomerLotPrefrence(TempWhseItemTrackingLine) then begin
            if IsPassShelfLifeForLotNo(EntrySummary."Lot No.") then;  //--Check Shelf Life for selected Lot No.--\\
        end else
            if IsPassShelfLifeForLotNo(EntrySummary."Lot No.") then;  //--Check Shelf Life for selected Lot No.--\\
    end;

    [EventSubscriber(ObjectType::Table, Database::"Tracking Specification", 'OnBeforeValidateEvent', 'Lot No.', false, false)]
    local procedure TrackingSpecification_OnBeforeValidateEvent(var Rec: Record "Tracking Specification" temporary; xRec: Record "Tracking Specification" temporary; CurrFieldNo: Integer)
    begin
        if rec."Source Type" <> Database::"Sales Line" then exit;
        if rec."Source Subtype" <> rec."Source Subtype"::"1" then exit;
        if rec."Lot No." <> '' then
            if IsPassManualMaxLotSelectionOnSalesLineForCustomerLotPrefrence(Rec) then begin
                if IsPassShelfLifeForLotNo(rec."Lot No.") then;  //--Check Shelf Life for selected Lot No.--\\
            end else
                if IsPassShelfLifeForLotNo(rec."Lot No.") then;  //--Check Shelf Life for selected Lot No.--\\
    end;

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

        // LotPreferenceShipToCode := GetSalesOrderShipToCode(WarehouseShipmentLine."Source No.");
        // AFDPSingleInstance.SetLotPreferenceShipToCode(LotPreferenceShipToCode);
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
        LotPreferenceCustomerNo: Code[20];
        LotPreferenceItemNo: code[20];
        LotPreferenceVariantCode: Code[10];
        // LotPreferenceShipToCode: Code[10];
        CustomerLotPreferenceShelfLifePer: Decimal;
        CustomerLotPreferenceShelfLife: DateFormula;
        NoOfDaysRemaining: Integer;
        PercentageShelfLifeRemaining: Decimal;
        ItemShelfLifeDays: Integer;
        ShipmentDate: Date;
    begin
        //--Get Customer Lot Preference Shelf Life ---\\
        Clear(CustomerLotPreferenceShelfLifePer);
        Clear(CustomerLotPreferenceShelfLife);
        Clear(ShipmentDate);
        LotPreferenceCustomerNo := AFDPSingleInstance.GetLotPreferenceCustomerNo();
        LotPreferenceItemNo := AFDPSingleInstance.GetLotPreferenceItemNo();
        LotPreferenceVariantCode := AFDPSingleInstance.GetLotPreferenceVariantCode();
        ShipmentDate := AFDPSingleInstance.GetShipmentDate();
        // LotPreferenceShipToCode := AFDPSingleInstance.GetLotPreferenceShipToCode();
        //---\\
        AFDPCustomerLotPreference.Reset();
        AFDPCustomerLotPreference.SetRange("AFDP Customer No.", LotPreferenceCustomerNo);
        AFDPCustomerLotPreference.SetRange("AFDP Item No.", LotPreferenceItemNo);
        // if AFDPCustomerLotPreference.FindFirst() then
        //     CustomerLotPreferenceShelfLifePer := AFDPCustomerLotPreference."AFDP Shelf Life %" / 100;
        // AFDPCustomerLotPreference.SetRange("AFDP Ship-to Code", LotPreferenceShipToCode);
        if AFDPCustomerLotPreference.FindFirst() then
            CustomerLotPreferenceShelfLife := AFDPCustomerLotPreference."AFDP Shelf Life"
        // CustomerLotPreferenceShelfLifePer := AFDPCustomerLotPreference."AFDP Shelf Life %" / 100
        else
            if LotPreferenceItemNo <> '' then begin
                AFDPCustomerLotPreference.SetRange("AFDP Item No.", '');
                if AFDPCustomerLotPreference.FindFirst() then
                    CustomerLotPreferenceShelfLife := AFDPCustomerLotPreference."AFDP Shelf Life";
                // CustomerLotPreferenceShelfLifePer := AFDPCustomerLotPreference."AFDP Shelf Life %" / 100;
            end;

        //------------------------------------------------------\\
        // if CustomerLotPreferenceShelfLifePer > 0 then begin
        if format(CustomerLotPreferenceShelfLife) <> '' then begin
            //---\\
            Clear(NoOfDaysRemaining);
            Clear(PercentageShelfLifeRemaining);
            //--Find Shelf Life Days--\\
            LotNoInformation.Reset();
            //------------------------\\
            if LotNo = '' then exit(true);
            if not LotNoInformation.Get(LotPreferenceItemNo, LotPreferenceVariantCode, LotNo) then exit(true);
            // if LotNoInformation."AFDP Best by Date" = 0D then exit(true);
            if not Item.Get(LotPreferenceItemNo) then exit(true);
            if format(item."AFDP Default Sales Shelf Life") = '' then exit(true);
            ItemShelfLifeDays := (CalcDate(item."AFDP Default Sales Shelf Life", Today) - Today);
            //----\\
            // NoOfDaysRemaining := LotNoInformation."AFDP Best by Date" - Today;
            NoOfDaysRemaining := ShipmentDate - Today;
            if ItemShelfLifeDays <> 0 then begin
                PercentageShelfLifeRemaining := NoOfDaysRemaining / ItemShelfLifeDays;
                if PercentageShelfLifeRemaining < CustomerLotPreferenceShelfLifePer then begin
                    AFDPSingleInstance.SetIsShelfLifeNotValidForLot(true);
                    Message('Shelf life is not valid for Lot No.: %1', LotNo);
                    exit(false);
                end;
            end;
            //----\\      
        end else
            exit(true);
    end;

    local procedure AFDPValidateWarehouseActivityLineLotStatus(var WarehouseActivityLine: Record "Warehouse Activity Line"; xWarehouseActivityLine: Record "Warehouse Activity Line")
    var
        LotNoInformation: Record "Lot No. Information";
        NotAvailableForPickErr: Label 'Lot No. %1 is not avaialble for Picks.', Comment = '%1 is the lot no.';
    begin
        if WarehouseActivityLine."Lot No." = '' then
            exit;
        if WarehouseActivityLine."Lot No." = xWarehouseActivityLine."Lot No." then
            exit;
        if WarehouseActivityLine."Activity Type" <> WarehouseActivityLine."Activity Type"::Pick then
            exit;
        if not LotNoInformation.Get(WarehouseActivityLine."Item No.", WarehouseActivityLine."Variant Code", WarehouseActivityLine."Lot No.") then
            exit;
        Error(NotAvailableForPickErr, WarehouseActivityLine."Lot No.");
    end;

    local procedure AFDPUpdateLotNoOnPlaceLineForWarehouseActivityLine(var WarehouseActivityLine: Record "Warehouse Activity Line")
    var
        WarehouseActivityLine1: Record "Warehouse Activity Line";
    begin
        WarehouseActivityLine1.Reset();
        WarehouseActivityLine1.SetCurrentKey("No.", "Line No.");
        WarehouseActivityLine1.SetRange("Action Type", WarehouseActivityLine1."Action Type"::Place);
        WarehouseActivityLine1.SetRange("No.", WarehouseActivityLine."No.");
        WarehouseActivityLine1.SetRange("Item No.", WarehouseActivityLine."Item No.");
        WarehouseActivityLine1.SetRange("Source Line No.", WarehouseActivityLine."Source Line No.");
        WarehouseActivityLine1.SetRange("Whse. Document Line No.", WarehouseActivityLine."Whse. Document Line No.");
        WarehouseActivityLine1.SetFilter("Line No.", '>%1', WarehouseActivityLine."Line No.");
        if WarehouseActivityLine1.FindFirst() then
            if WarehouseActivityLine1."Lot No." <> WarehouseActivityLine."Lot No." then begin
                WarehouseActivityLine1.Validate("Lot No.", WarehouseActivityLine."Lot No.");
                WarehouseActivityLine1.Modify();
            end;
    end;

    local procedure IsPassManualMaxLotSelectionOnSalesLineForCustomerLotPrefrence(var TrackingSpecification: Record "Tracking Specification" temporary): Boolean
    var
        // TempTrackingSpecification1: Record "Tracking Specification" temporary;
        SalesLine: Record "Sales Line";
        AFDPSingleInstance: Codeunit "AFDP Single Instance";
        TotalLots: Integer;
    // NoOfMaxLotAllowed: Integer;
    // LotPreferenceShipToCode: Code[10];
    begin
        Clear(TotalLots);
        // Clear(LotPreferenceShipToCode);
        SalesLine.Reset();
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
        SalesLine.SetRange("Document No.", TrackingSpecification."Source ID");
        SalesLine.SetRange("Line No.", TrackingSpecification."Source Ref. No.");
        if SalesLine.FindFirst() then begin
            AFDPSingleInstance.SetLotPreferenceCustomerNo(SalesLine."Bill-to Customer No.");
            AFDPSingleInstance.SetLotPreferenceItemNo(SalesLine."No.");
            AFDPSingleInstance.SetLotPreferenceVariantCode(SalesLine."Variant Code");
            AFDPSingleInstance.SetShipmentDate(SalesLine."Shipment Date");
            // LotPreferenceShipToCode := GetSalesOrderShipToCode(SalesLine."Document No.");
            // AFDPSingleInstance.SetLotPreferenceShipToCode(LotPreferenceShipToCode);
        end;
        // NoOfMaxLotAllowed := GetNoOfCustomerLotPreference();
        // if NoOfMaxLotAllowed > 0 then begin
        //     //-----\\   
        //     TempTrackingSpecification1.copy(TrackingSpecification, true);
        //     TempTrackingSpecification1.Reset();
        //     TempTrackingSpecification1.SetRange("Lot No.");
        //     if TempTrackingSpecification1.FindSet() then
        //         repeat
        //             if TempTrackingSpecification1."Lot No." <> TrackingSpecification."Lot No." then
        //                 TotalLots += 1;
        //         until TempTrackingSpecification1.Next() = 0;
        //     //-----\\
        //     if TotalLots >= NoOfMaxLotAllowed then begin
        //         if TotalLots = NoOfMaxLotAllowed then begin
        //             if GuiAllowed then  //AFDP-DNP 11/06/2024 1525538440
        //                 if not Confirm(MaxLotMessageLbl, true, AFDPSingleInstance.GetLotPreferenceItemNo(), (TotalLots + 1), NoOfMaxLotAllowed) then
        //                     Error('');
        //         end else
        //             if GuiAllowed then  //AFDP-DNP 11/06/2024 1525538440
        //                 if not Confirm(MaxLotMessageLbl, true, AFDPSingleInstance.GetLotPreferenceItemNo(), TotalLots, NoOfMaxLotAllowed) then
        //                     Error('');
        //         exit(false);
        //     end else
        //         exit(true);
        // end;
        exit(true);
    end;

    local procedure IsPassManualMaxLotSelectionForCustomerLotPrefrence(var WarehouseActivityLine: Record "Warehouse Activity Line"): Boolean
    var
        AFDPSingleInstance: Codeunit "AFDP Single Instance";
        // AFDPWarehousePickNoOfLots: Query "AFDP Warehouse Pick No Of Lots";
        TotalLots: Integer;
    // NoOfMaxLotAllowed: Integer;
    // LotPreferenceShipToCode: Code[10];
    begin
        Clear(TotalLots);
        // Clear(LotPreferenceShipToCode);  
        if WarehouseActivityLine."Source Document" = WarehouseActivityLine."Source Document"::"Sales Order" then begin
            AFDPSingleInstance.SetLotPreferenceCustomerNo(WarehouseActivityLine."Destination No.");
            AFDPSingleInstance.SetLotPreferenceItemNo(WarehouseActivityLine."Item No.");
            AFDPSingleInstance.SetLotPreferenceVariantCode(WarehouseActivityLine."Variant Code");
            // LotPreferenceShipToCode := GetSalesOrderShipToCode(WarehouseActivityLine."Source No.");
            // AFDPSingleInstance.SetLotPreferenceShipToCode(LotPreferenceShipToCode);
        end;
        // NoOfMaxLotAllowed := GetNoOfCustomerLotPreference();
        // if NoOfMaxLotAllowed > 0 then begin
        //     //--Find Total Lots on Warehouse Pick--\\
        //     AFDPWarehousePickNoOfLots.SetRange(ActionType, AFDPWarehousePickNoOfLots.ActionType::Take);
        //     AFDPWarehousePickNoOfLots.SetRange(No, WarehouseActivityLine."No.");
        //     AFDPWarehousePickNoOfLots.SetRange(ItemNo, WarehouseActivityLine."Item No.");
        //     AFDPWarehousePickNoOfLots.SetRange(SourceLineNo, WarehouseActivityLine."Source Line No.");
        //     AFDPWarehousePickNoOfLots.SetRange(WhseDocumentLineNo, WarehouseActivityLine."Whse. Document Line No.");
        //     if AFDPWarehousePickNoOfLots.Open() then begin
        //         while AFDPWarehousePickNoOfLots.Read() do
        //             if AFDPWarehousePickNoOfLots.LotNo <> WarehouseActivityLine."Lot No." then
        //                 TotalLots += 1;
        //         AFDPWarehousePickNoOfLots.Close();
        //     end;
        //     //-----\\
        //     if TotalLots > NoOfMaxLotAllowed then begin
        //         if GuiAllowed then  //AFDP-DNP 11/06/2024 1525538440
        //             if not Confirm(MaxLotMessageLbl, true, AFDPSingleInstance.GetLotPreferenceItemNo(), TotalLots, NoOfMaxLotAllowed) then
        //                 Error('');
        //         exit(false);
        //     end else
        //         exit(true);
        // end;
        exit(true);
    end;

    local procedure IsPassMaxLotSelectionForCustomerLotPrefrence(var TempWhseItemTrackingLine: Record "Whse. Item Tracking Line" temporary): Boolean
    var
    // TempWhseItemTrackingLine2: Record "Whse. Item Tracking Line" temporary;
    // AFDPSingleInstance: Codeunit "AFDP Single Instance";
    // NoOfMaxLotAllowed: Integer;
    // TotalSelectedLot: Integer;
    // TotalDupliateLot: Integer;
    begin
        // NoOfMaxLotAllowed := GetNoOfCustomerLotPreference();
        // if NoOfMaxLotAllowed > 0 then
        //     if TempWhseItemTrackingLine."Entry No." > 0 then begin
        //         Clear(TotalSelectedLot);
        //         TempWhseItemTrackingLine2.Copy(TempWhseItemTrackingLine, true);
        //         TempWhseItemTrackingLine2.Reset();
        //         TempWhseItemTrackingLine2.SetRange("Item No.", AFDPSingleInstance.GetLotPreferenceItemNo());
        //         //TempWhseItemTrackingLine2.SetRange("Source ID", AFDPSingleInstance.GetLotPreferenceSourceNo());
        //         TempWhseItemTrackingLine2.SetRange("Source Ref. No.", AFDPSingleInstance.GetLotPreferenceSourceLineNo());
        //         TotalSelectedLot := TempWhseItemTrackingLine2.Count;
        //         //>>>AFDP-DNP 12/12/2024 1553415068
        //         TotalDupliateLot := GetDuplicateLotCount(TempWhseItemTrackingLine2);
        //         TotalSelectedLot := TotalSelectedLot - TotalDupliateLot;
        //         //<<<AFDP-DNP 12/12/2024 1553415068
        //         if TotalSelectedLot >= NoOfMaxLotAllowed then begin
        //             if ((AFDPSingleInstance.GetPreviousLotPreferenceItemNo() <> AFDPSingleInstance.GetLotPreferenceItemNo()) and
        //                 (AFDPSingleInstance.GetPreviousLotPreferenceSourceLineNo() <> AFDPSingleInstance.GetLotPreferenceSourceLineNo())) then begin
        //                 if TotalSelectedLot = NoOfMaxLotAllowed then begin
        //                     if GuiAllowed then
        //                         if not Confirm(MaxLotMessageLbl, true, AFDPSingleInstance.GetLotPreferenceItemNo(), (TotalSelectedLot + 1), NoOfMaxLotAllowed) then
        //                             Error('');
        //                 end else
        //                     if GuiAllowed then
        //                         if not Confirm(MaxLotMessageLbl, true, AFDPSingleInstance.GetLotPreferenceItemNo(), (TotalSelectedLot), NoOfMaxLotAllowed) then
        //                             Error('');
        //                 AFDPSingleInstance.SetPreviousLotPreferenceItemNo(AFDPSingleInstance.GetLotPreferenceItemNo());
        //                 AFDPSingleInstance.SetPreviousLotPreferenceSourceLineNo(AFDPSingleInstance.GetLotPreferenceSourceLineNo());
        //             end;
        //             exit(false);
        //         end;
        //     end;
        // //------------------------------------\\
        // AFDPSingleInstance.SetReachedMaxLotSelection(false);
        //------------------------------------\\
        exit(true);
    end;
    #endregion Functions
}

//AFDP 07/19/2025 'T0005-Customer Lot Preference'



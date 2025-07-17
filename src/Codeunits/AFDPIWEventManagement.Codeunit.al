namespace AFood.DP.AFoodDevelopment;

using Microsoft.Inventory.Tracking;
using Microsoft.Inventory.Location;
using Microsoft.Sales.Document;
using Microsoft.Inventory.Transfer;
using Microsoft.Inventory.Item;
using Microsoft.Warehouse.Ledger;

codeunit 50305 "AFDP IW Event Management"
{

    #region Global Variables
    var
        SingleXmlValueMsg: Label '<VALUE>%1</VALUE>', Comment = '%1 is anything';
        CaseQtyRequiredErr: Label 'Case Qty. is required.';

    #endregion Global Variables
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"WHI Custom Functions", OnBeforeProcessEvent, '', true, true)]
    local procedure WHICustomFunctions_OnBeforeProcessEvent(piEventID: Integer; var precEventParams: Record "IWX Event Param"; var pbtxtOutput: BigText; var pbOverrideWHI: Boolean)
    begin
        this.ProcessWHIBeforeEventId(piEventID, precEventParams, pbtxtOutput, pbOverrideWHI);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"WHI Custom Functions", OnAfterProcessEvent, '', false, false)]
    local procedure WHICustomFunctions_OnAfterProcessEvent(piEventID: Integer; var precEventParams: Record "IWX Event Param"; var pbtxtOutput: BigText)
    begin
        this.ProcessWHIAfterEventId(piEventID, precEventParams, pbtxtOutput);
    end;


    local procedure ProcessWHIBeforeEventId(EventID: Integer; var IWXEventParam: Record "IWX Event Param"; var Output: BigText; var OverrideWHI: Boolean)
    begin
        case EventID of
            700070010:
                this.AFDPIWGetDUCaseQty(IWXEventParam, Output, OverrideWHI);
            700070011:
                this.AFDPIWValidateDUCaseQty(IWXEventParam, Output, OverrideWHI);
        // 700070012:
        //     this.AFDPIWUpdateDUCaseQtyOnLPLine(IWXEventParam, Output, OverrideWHI);


        // 700070002:
        //     this.AFDPIWCaseQtyValidate(IWXEventParam, Output, OverrideWHI);
        // 700070003:
        //     this.AFDPIWUpdateFormWithCaseQty(IWXEventParam, Output, OverrideWHI);
        // 700070001:
        //     this.GetLotNoIfExist(IWXEventParam, Output, OverrideWHI);
        // 700070004:
        //     this.AFDPIWUpdateDUUnitsQtyBefore(IWXEventParam, Output, OverrideWHI);
        end;
    end;

    local procedure ProcessWHIAfterEventId(EventID: Integer; var IWXEventParam: Record "IWX Event Param"; var Output: BigText)
    begin
        case EventID of
            95003:
                this.AFDPIWUpdateDUCaseQtyOnLPLine(IWXEventParam, Output);
            95004:
                this.AFDPIWUpdateDUCaseQtyOnLPLine(IWXEventParam, Output);
        // 413:
        //     this.GetLotNoIfExistAfter(IWXEventParam, Output);
        // 700070001:
        //     this.GetLotNoIfExist(IWXEventParam, Output);
        end;
    end;
    //---New Work---\\
    local procedure AFDPIWGetDUCaseQty(var IWXEventParam: Record "IWX Event Param"; var Output: BigText; var OverrideWHI: Boolean)
    var
        LPNo: Code[20];
        ItemNo: Code[20];
        // LineNo: Integer;
        CaseQty: Decimal;
    begin
        // indicate the event has been handled
        OverrideWHI := true;
        // get the variables/data required to execute the procedure
        LPNo := Copystr(IWXEventParam.GetExtendedValue('lp_number'), 1, MaxStrLen(LPNo));
        ItemNo := CopyStr(IWXEventParam.GetExtendedValue('No.'), 1, MaxStrLen(ItemNo));
        //--get license Plate item case qty--\\
        if (LPNo <> '') and (ItemNo <> '') then
            CaseQty := this.GetLPLineItemCaseQty(LPNo, ItemNo);
        //----\\
        Output.AddText(StrSubstNo(this.GetSingleXmlValueMsg(), CaseQty));
    end;

    local procedure AFDPIWValidateDUCaseQty(var IWXEventParam: Record "IWX Event Param"; var Output: BigText; var OverrideWHI: Boolean)
    var
        CaseQty: Decimal;
    begin
        //--Check Dual Units Item or not--\\
        if not this.IsDUUnitsItem(IWXEventParam) then
            exit;
        //------\\        
        CaseQty := this.GetDUUnitsCase(IWXEventParam);
        if CaseQty = 0 then begin
            Output.AddText(this.GenerateError(this.GetCaseQtyRequiredErr()));
            OverrideWHI := true;
            exit;
        end;
        //-------\\        
        // indicate the event has been handled
        OverrideWHI := true;
    end;

    /*
    local procedure AFDPIWUpdateDUCaseQtyOnLPLine(var IWXEventParam: Record "IWX Event Param"; var Output: BigText; var OverrideWHI: Boolean)
    var
        LPNo: Code[20];
        ItemNo: Code[20];
        CaseQty: Decimal;
    begin
        //--Check Dual Units Item or not--\\
        if not this.IsDUUnitsItem(IWXEventParam) then
            exit;
        //------\\        
        CaseQty := this.GetDUUnitsCase(IWXEventParam);
        if CaseQty = 0 then begin
            Output.AddText(this.GenerateError(this.GetCaseQtyRequiredErr()));
            OverrideWHI := true;
            exit;
        end;
        //-------\\        
        // indicate the event has been handled
        OverrideWHI := true;
        // get the variables/data required to execute the procedure        
        LPNo := Copystr(IWXEventParam.GetExtendedValue('lp_number'), 1, MaxStrLen(LPNo));
        ItemNo := GetItemNo(IWXEventParam);
        //--Update Case Qty On LP Line--\\
        UpdateCaseQtyOnLPLine(LPNo, ItemNo, CaseQty);
        //----\\
    end;
    */
    local procedure AFDPIWUpdateDUCaseQtyOnLPLine(var IWXEventParam: Record "IWX Event Param"; var Output: BigText)
    var
        WHICommonFunction: Codeunit "WHI Common Functions";
        LPNo: Code[20];
        ItemNo: Code[20];
        CaseQty: Decimal;
    begin
        // get the variables/data required to execute the procedure        
        CaseQty := this.GetDUUnitsCase(IWXEventParam);
        LPNo := Copystr(IWXEventParam.GetExtendedValue('lp_number'), 1, MaxStrLen(LPNo));
        ItemNo := GetItemNo(IWXEventParam);
        //--Update Case Qty On LP Line--\\
        UpdateCaseQtyOnLPLine(LPNo, ItemNo, CaseQty);
        //---\\        
        WHICommonFunction.generateSuccessReturn('', Output);
    end;

    local procedure GetLPLineItemCaseQty(LicensePlateNo: Code[20]; LPItemNo: code[20]): Decimal
    var
        IWXLPLine: Record "IWX LP Line";
    begin
        IWXLPLine.Reset();
        IWXLPLine.SetRange("License Plate No.", LicensePlateNo);
        IWXLPLine.SetRange("No.", LPItemNo);
        if IWXLPLine.FindFirst() then
            exit(IWXLPLine."AFDP DU Units Quantity");
        exit(0);
    end;

    local procedure UpdateCaseQtyOnLPLine(LicensePlateNo: Code[20]; LPItemNo: code[20]; CaseQty: Decimal)
    var
        IWXLPLine: Record "IWX LP Line";
    begin
        IWXLPLine.Reset();
        IWXLPLine.SetRange("License Plate No.", LicensePlateNo);
        IWXLPLine.SetRange("No.", LPItemNo);
        if IWXLPLine.FindFirst() then begin
            IWXLPLine.Validate("AFDP DU Units Quantity", CaseQty);
            IWXLPLine.Modify(true);
        end;
    end;

    local procedure GetSingleXmlValueMsg(): Text
    begin
        exit(this.SingleXmlValueMsg);
    end;

    local procedure GetItemNo(var IWXEventParam: Record "IWX Event Param") ItemNo: Code[20];
    begin
        ItemNo := CopyStr(IWXEventParam.GetExtendedValue('barcode.ItemNumber'), 1, MaxStrLen(ItemNo));
        if ItemNo = '' then
            ItemNo := CopyStr(IWXEventParam.GetExtendedValue('No.'), 1, MaxStrLen(ItemNo));
    end;

    local procedure IsDUUnitsItem(var IWXEventParam: Record "IWX Event Param"): Boolean;
    var
        Item: Record Item;
        ItemDUUOMMgt: Codeunit "AFDP Item Dual UOM Management";
        ItemNo: Code[20];
    begin
        ItemNo := this.GetItemNo(IWXEventParam);
        if ItemNo <> '' then begin
            ItemDUUOMMgt.GetGlobalItem(Item, ItemNo);
            if Item."Unit of Measure - Units_DU_TSL" = '' then
                exit(false)
            else
                exit(true);
        end else
            exit(false);
    end;

    local procedure GetDUUnitsCase(var IWXEventParam: Record "IWX Event Param") DUUnitsCaseQty: Decimal
    begin
        DUUnitsCaseQty := IWXEventParam.getValueAsDecimal('AFDPDUUnitsQTY');
    end;

    local procedure GetCaseQtyRequiredErr(): Text
    begin
        exit(this.CaseQtyRequiredErr);
    end;

    local procedure GenerateError(ErrorMessage: Text): Text
    var
        ErrorMessageLbl: Label '<ERROR><MSG>%1</MSG></ERROR>', Locked = true;
    begin
        if (ErrorMessage <> '') then
            exit(StrSubstNo(ErrorMessageLbl, ErrorMessage))
        else
            exit('');
    end;

    //---OLD Work---\\
    local procedure AFDPIWCaseQtyValidate(var IWXEventParam: Record "IWX Event Param"; var Output: BigText; var OverrideWHI: Boolean)
    var
        Item: Record Item;
        ItemDUUOMMgt: Codeunit "AFDP Item Dual UOM Management";
        WHICommonFunction: Codeunit "WHI Common Functions";
        LPNo: Code[20];
        ItemNo: Code[20];
        CaseQty: Decimal;
    begin
        // indicate the event has been handled
        OverrideWHI := true;
        // get the variables/data required to execute the procedure
        LPNo := Copystr(IWXEventParam.GetExtendedValue('lp_number'), 1, MaxStrLen(LPNo));
        ItemNo := CopyStr(IWXEventParam.GetExtendedValue('barcode.ItemNumber'), 1, MaxStrLen(ItemNo));
        if ItemNo = '' then
            ItemNo := Format(IWXEventParam.GetExtendedValue('No.'));
        CaseQty := IWXEventParam.getValueAsDecimal('AFDPDUUnitsQTY');
        //----\\
        if LPNo = '' then
            Error('LP No. is required');
        if ItemNo = '' then
            Error('1234-Item No. is required');
        //--Find License Plate Line--\\
        ItemDUUOMMgt.GetGlobalItem(Item, ItemNo);
        if Item."Unit of Measure - Units_DU_TSL" = '' then
            if CaseQty <> 0 then
                Error('Case Quantity should be zero for Non DU UOM Item No. %1', ItemNo);
        if Item."Unit of Measure - Units_DU_TSL" <> '' then
            if CaseQty = 0 then
                Error('Case Quantity Cannot be zero for DU UOM Item No. %1', ItemNo);
        WHICommonFunction.generateSuccessReturn('', Output);
        //----\\
    end;

    local procedure AFDPIWUpdateDUUnitsQty(var IWXEventParam: Record "IWX Event Param"; var Output: BigText)
    var
        Item: Record Item;
        IWXLPLine: Record "IWX LP Line";
        IWXLPHeader: Record "IWX LP Header";
        ItemDUUOMMgt: Codeunit "AFDP Item Dual UOM Management";
        WHICommonFunction: Codeunit "WHI Common Functions";
        LPNo: Code[20];
        ItemNo: Code[20];
        CaseQty: Decimal;
    begin
        // get the variables/data required to execute the procedure
        LPNo := CopyStr(IWXEventParam.GetExtendedValue('lp_number'), 1, MaxStrLen(LPNo));
        ItemNo := CopyStr(IWXEventParam.GetExtendedValue('barcode.ItemNumber'), 1, MaxStrLen(ItemNo));
        if ItemNo = '' then
            ItemNo := Format(IWXEventParam.GetExtendedValue('No.'));
        CaseQty := IWXEventParam.getValueAsDecimal('AFDPDUUnitsQTY');
        //----\\
        if LPNo = '' then
            Error('LP No. is required');
        if ItemNo = '' then
            Error('Item No. is required');
        //--Find License Plate Line--\\
        ItemDUUOMMgt.GetGlobalItem(Item, ItemNo);
        //----\\
        IWXLPHeader.Reset();
        IWXLPHeader.SetRange("No.", LPNo);
        if IWXLPHeader.FindFirst() then begin
            IWXLPLine.Reset();
            IWXLPLine.SetRange("License Plate No.", IWXLPHeader."No.");
            IWXLPLine.SetRange("No.", ItemNo);
            if IWXLPLine.FindFirst() then begin
                if CaseQty <> 0 then begin
                    IWXLPLine.Validate("AFDP DU Units Quantity", CaseQty);
                    IWXLPLine.Modify(true);
                end;
            end else
                Error('License Plate Line not found for LP No. %1 and Item No. %2', LPNo, ItemNo);
        end else
            Error('License Plate Header not found for LP No. %1', LPNo);

        //---\\        
        WHICommonFunction.generateSuccessReturn('', Output);
    end;

    local procedure AFDPIWUpdateDUUnitsQtyBefore(var IWXEventParam: Record "IWX Event Param"; var Output: BigText; var OverrideWHI: Boolean)
    var
        Item: Record Item;
        IWXLPLine: Record "IWX LP Line";
        IWXLPHeader: Record "IWX LP Header";
        ItemDUUOMMgt: Codeunit "AFDP Item Dual UOM Management";
        WHICommonFunction: Codeunit "WHI Common Functions";
        LPNo: Code[20];
        ItemNo: Code[20];
        CaseQty: Decimal;
    begin
        // indicate the event has been handled
        OverrideWHI := true;
        // get the variables/data required to execute the procedure
        LPNo := CopyStr(IWXEventParam.GetExtendedValue('lp_number'), 1, MaxStrLen(LPNo));
        ItemNo := CopyStr(IWXEventParam.GetExtendedValue('barcode.ItemNumber'), 1, MaxStrLen(ItemNo));
        if ItemNo = '' then
            ItemNo := Format(IWXEventParam.GetExtendedValue('No.'));
        CaseQty := IWXEventParam.getValueAsDecimal('AFDPDUUnitsQTY');
        //----\\
        if LPNo = '' then
            Error('LP No. is required');
        if ItemNo = '' then
            Error('Item No. is required');
        //--Find License Plate Line--\\
        ItemDUUOMMgt.GetGlobalItem(Item, ItemNo);
        //----\\
        IWXLPHeader.Reset();
        IWXLPHeader.SetRange("No.", LPNo);
        if IWXLPHeader.FindFirst() then begin
            IWXLPLine.Reset();
            IWXLPLine.SetRange("License Plate No.", IWXLPHeader."No.");
            IWXLPLine.SetRange("No.", ItemNo);
            if IWXLPLine.FindFirst() then begin
                if CaseQty <> 0 then begin
                    IWXLPLine.Validate("AFDP DU Units Quantity", CaseQty);
                    IWXLPLine.Modify(true);
                end;
            end else
                Error('License Plate Line not found for LP No. %1 and Item No. %2', LPNo, ItemNo);
        end else
            Error('License Plate Header not found for LP No. %1', LPNo);

        //---\\                
        WHICommonFunction.generateSuccessReturn('', Output);
    end;

    local procedure AFDPIWUpdateFormWithCaseQty(var IWXEventParam: Record "IWX Event Param"; var Output: BigText; var OverrideWHI: Boolean)
    var
        WHICommonFunction: Codeunit "WHI Common Functions";
        LPNo: Code[20];
        ItemNo: Code[20];
        CaseQty: Decimal;
    begin
        // indicate the event has been handled
        OverrideWHI := true;
        // get the variables/data required to execute the procedure
        LPNo := CopyStr(IWXEventParam.GetExtendedValue('lp_number'), 1, MaxStrLen(LPNo));
        ItemNo := CopyStr(IWXEventParam.GetExtendedValue('barcode.ItemNumber'), 1, MaxStrLen(ItemNo));
        if ItemNo = '' then
            ItemNo := Format(IWXEventParam.GetExtendedValue('No.'));
        CaseQty := IWXEventParam.getValueAsDecimal('Case');
        //----\\
        if LPNo = '' then
            Error('LP No. is required');
        if ItemNo = '' then
            Error('Item No. is required');
        //---\\
        IWXEventParam.setValue('AFDPDUUnitsQTY', format(CaseQty));
        WHICommonFunction.generateSuccessReturn('', Output);
    end;


    local procedure GetLotNoIfExist(var IWXEventParam: Record "IWX Event Param"; var Output: BigText; var OverrideWHI: Boolean)
    var
        WHICommonFunction: Codeunit "WHI Common Functions";
        LPNo: Code[20];
        ItemNo: Code[20];
        LotNo: code[50];
    begin
        // indicate the event has been handled
        OverrideWHI := true;
        // get the variables/data required to execute the procedure
        LPNo := CopyStr(IWXEventParam.GetExtendedValue('lp_number'), 1, MaxStrLen(LPNo));
        ItemNo := CopyStr(IWXEventParam.GetExtendedValue('barcode.ItemNumber'), 1, MaxStrLen(ItemNo));
        if ItemNo = '' then
            ItemNo := Format(IWXEventParam.getValue('barcode.ItemNumber'));
        //----\\
        if LPNo = '' then
            Error('LP No. is required');
        if ItemNo = '' then
            Error('Item No. is required');
        // get default lot no.--\\
        if (ItemNo <> '') and (LPNo <> '') then
            LotNo := AFDPIWFindLotNoFromWarehouseEntry(LPNo, ItemNo);

        if LotNo <> '' then
            CreateLPLine(LPNo, ItemNo, LotNo);
        //error('Lot Number is:%1', LotNo);
        //Output.AddText(StrSubstNo('<VALUE>%</VALUE>', LotNo));
        WHICommonFunction.generateSuccessReturn('', Output);
    end;

    // local procedure GetLotNoIfExistAfter(var IWXEventParam: Record "IWX Event Param"; var Output: BigText)
    // var
    //     WHICommonFunction: Codeunit "WHI Common Functions";
    //     LPNo: Code[20];
    //     ItemNo: Code[20];
    //     LotNo: code[50];
    // begin
    //     // get the variables/data required to execute the procedure
    //     LPNo := CopyStr(IWXEventParam.GetExtendedValue('lp_number'), 1, MaxStrLen(LPNo));
    //     ItemNo := CopyStr(IWXEventParam.GetExtendedValue('barcode.ItemNumber'), 1, MaxStrLen(ItemNo));
    //     if ItemNo = '' then
    //         ItemNo := Format(IWXEventParam.getValue('barcode.ItemNumber'));
    //     // get default lot no.--\\
    //     if (ItemNo <> '') and (LPNo <> '') then
    //         LotNo := AFDPIWFindLotNoFromWarehouseEntry(LPNo, ItemNo);

    //     if LotNo <> '' then begin
    //         IWXEventParam.setValue('form.LotNumber', format(LotNo));
    //         IWXEventParam.setValue('lot_number', format(LotNo));
    //     end;
    //     error('Lot Number is:%1', LotNo);
    //     //Output.AddText(StrSubstNo('<VALUE>%</VALUE>', LotNo));
    //     WHICommonFunction.generateSuccessReturn('', Output);
    // end;

    local procedure AFDPIWFindLotNoFromWarehouseEntry(LicensePlateNo: Code[20]; LPItemNo: code[20]): Code[50]
    var
        WarehouseEntry: Record "Warehouse Entry";
        IWXLPHeader: Record "IWX LP Header";
        OldLotNo: Code[50];
        LotNo: Code[50];
        LotNo1: Code[50];
        LotNo2: Code[50];
        LotQty: Decimal;
    begin
        Clear(OldLotNo);
        LotNo := '';
        LotNo1 := '';
        LotNo2 := '';
        if LicensePlateNo = '' then
            exit(LotNo);
        if IWXLPHeader.Get(LicensePlateNo) then begin
            WarehouseEntry.Reset();
            WarehouseEntry.SetCurrentKey("Lot No.");
            WarehouseEntry.SetRange("Bin Code", IWXLPHeader."Bin Code");
            WarehouseEntry.SetRange("Item No.", LPItemNo);
            WarehouseEntry.SetRange("Location Code", IWXLPHeader."Location Code");
            //WarehouseEntry.SetRange("Unit of Measure Code", IWXLPLine."Unit of Measure Code");
            //WarehouseEntry.SetRange("Variant Code", IWXLPLine."Variant Code");
            WarehouseEntry.SetFilter(Quantity, '<>0');
            if WarehouseEntry.FindSet() then
                repeat
                    if OldLotNo <> WarehouseEntry."Lot No." then
                        if WarehouseEntry."Lot No." <> '' then begin
                            LotQty := GetSummarizeLotQty(WarehouseEntry);
                            if LotQty <> 0 then
                                if LotNo1 = '' then
                                    LotNo1 := WarehouseEntry."Lot No."
                                else
                                    if LotNo2 = '' then
                                        LotNo2 := WarehouseEntry."Lot No.";
                            if (LotNo1 <> '') and (LotNo2 <> '') then
                                exit(LotNo);
                        end;
                    OldLotNo := WarehouseEntry."Lot No.";
                until WarehouseEntry.Next() = 0;
        end;
        if (LotNo1 <> '') and (LotNo2 = '') then
            exit(LotNo1)
        else
            exit(LotNo);
    end;

    local procedure GetSummarizeLotQty(var WarehouseEntry: Record "Warehouse Entry"): Decimal
    var
        WarehouseEntry1: Record "Warehouse Entry";
    begin
        if WarehouseEntry."Lot No." = '' then
            exit(0);
        WarehouseEntry1.Reset();
        WarehouseEntry1.SetRange("Bin Code", WarehouseEntry."Bin Code");
        WarehouseEntry1.SetRange("Item No.", WarehouseEntry."Item No.");
        WarehouseEntry1.SetRange("Location Code", WarehouseEntry."Location Code");
        WarehouseEntry1.SetRange("Unit of Measure Code", WarehouseEntry."Unit of Measure Code");
        WarehouseEntry1.SetRange("Variant Code", WarehouseEntry."Variant Code");
        WarehouseEntry1.SetRange("Lot No.", WarehouseEntry."Lot No.");
        WarehouseEntry1.CalcSums(Quantity);
        if WarehouseEntry1.Quantity <> 0 then
            exit(WarehouseEntry1.Quantity)
        else
            exit(0);
    end;

    local procedure CreateLPLine(LicensePlateNo: Code[20]; LPItemNo: code[20]; LPLotNo: Code[50])
    var
        IWXLPLine: Record "IWX LP Line";
        IWXLPHeader: Record "IWX LP Header";
        LastLPLineNo: Integer;
    begin
        IWXLPHeader.Reset();
        IWXLPHeader.SetRange("No.", LicensePlateNo);
        if IWXLPHeader.FindFirst() then begin
            IWXLPLine.Reset();
            IWXLPLine.SetRange("License Plate No.", IWXLPHeader."No.");
            IWXLPLine.SetRange("No.", LPItemNo);
            if Not IWXLPLine.FindFirst() then begin
                IWXLPLine.Init();
                LastLPLineNo := GetLastLPLineNo(LicensePlateNo);
                IWXLPLine."License Plate No." := LicensePlateNo;
                IWXLPLine."Line No." := LastLPLineNo + 10000;
                IWXLPLine.Validate(Type, IWXLPLine.Type::Item);
                IWXLPLine.Validate("No.", LPItemNo);
                IWXLPLine.Validate("Lot No.", LPLotNo);
                IWXLPLine.Insert();
            end;
        end;
    end;

    Local procedure GetLastLPLineNo(LicensePlateNo: Code[20]): Integer
    var
        IWXLPLine: Record "IWX LP Line";
    begin
        IWXLPLine.Reset();
        IWXLPLine.SetCurrentKey("Line No.");
        IWXLPLine.SetRange("License Plate No.", LicensePlateNo);
        if IWXLPLine.FindLast() then
            exit(IWXLPLine."Line No.")
        else
            exit(0);
    end;

}

//AFDP 07/09/2025 'T0011-Dual UOM on Handheld-For LP'
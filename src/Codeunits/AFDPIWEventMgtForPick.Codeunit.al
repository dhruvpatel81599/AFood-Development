namespace AFood.DP.AFoodDevelopment;

using Microsoft.Inventory.Tracking;
using Microsoft.Inventory.Location;
using Microsoft.Sales.Document;
using Microsoft.Inventory.Transfer;
using Microsoft.Inventory.Item;
using Microsoft.Warehouse.Ledger;
using Microsoft.Warehouse.Activity;

codeunit 50306 "AFDP IW Event Mgt. For Pick"
{

    #region Global Variables
    var
        cuCommonFuncs: Codeunit "WHI Common Functions";
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
            700070020:
                this.AFDPIWGetDUCaseQty(IWXEventParam, Output, OverrideWHI);
            700070021:
                this.AFDPIWValidateDUCaseQty(IWXEventParam, Output, OverrideWHI);
        end;
    end;

    local procedure ProcessWHIAfterEventId(EventID: Integer; var IWXEventParam: Record "IWX Event Param"; var Output: BigText)
    begin
        // case EventID of
        //     95003:
        //         this.AFDPIWUpdateDUCaseQtyOnLPLine(IWXEventParam, Output);
        //     95004:
        //         this.AFDPIWUpdateDUCaseQtyOnLPLine(IWXEventParam, Output);
        // // 413:
        // //     this.GetLotNoIfExistAfter(IWXEventParam, Output);
        // // 700070001:
        // //     this.GetLotNoIfExist(IWXEventParam, Output);
        // end;
    end;
    //---New Work---\\
    local procedure AFDPIWGetDUCaseQty(var IWXEventParam: Record "IWX Event Param"; var Output: BigText; var OverrideWHI: Boolean)
    var
        WarehouseActivityLine: Record "Warehouse Activity Line";
        CaseQty: Decimal;
        ActivityNo: Code[20];
        ActivityType: Integer;
        LineNo: Integer;
    begin
        // indicate the event has been handled
        OverrideWHI := true;
        //-----\\
        ActivityNo := this.GetDocNo(IWXEventParam);
        ActivityType := this.GetDocType(IWXEventParam);
        LineNo := this.GetLineNo(IWXEventParam);

        if WarehouseActivityLine.Get(ActivityType, ActivityNo, LineNo) then
            CaseQty := WarehouseActivityLine."Units to Handle_DU_TSL";

        Output.AddText(StrSubstNo(this.GetSingleXmlValueMsg(), CaseQty));
    end;

    local procedure AFDPIWValidateDUCaseQty(var IWXEventParam: Record "IWX Event Param"; var Output: BigText; var OverrideWHI: Boolean)
    var
        WarehouseActivityLine: Record "Warehouse Activity Line";
        ActivityNo: Code[20];
        ActivityType: Integer;
        LineNo: Integer;
        CaseQty: Decimal;
    begin
        // indicate the event has been handled
        OverrideWHI := true;
        //--Check Dual Units Item or not--\\
        if not this.IsDUUnitsItem(IWXEventParam) then
            exit;
        if not this.TrackingRequired(IWXEventParam) then
            exit;
        //------\\        
        CaseQty := this.GetDUUnitsCase(IWXEventParam);
        if CaseQty = 0 then begin
            Output.AddText(this.GenerateError(this.GetCaseQtyRequiredErr()));
            OverrideWHI := true;
            exit;
        end;
        //-------\\  
        ActivityNo := this.GetDocNo(IWXEventParam);
        ActivityType := this.GetDocType(IWXEventParam);
        LineNo := this.GetLineNo(IWXEventParam);

        if not WarehouseActivityLine.Get(ActivityType, ActivityNo, LineNo) then
            exit;

        if Abs(CaseQty) <> Abs(WarehouseActivityLine."Units to Handle_DU_TSL") then
            UpdateWarehouseActivtyLine(WarehouseActivityLine, CaseQty, IWXEventParam);
    end;

    local procedure UpdateWarehouseActivtyLine(var WarehouseActivityLine: Record "Warehouse Activity Line"; CaseQtyToHandle: Decimal; var IWXEventParam: Record "IWX Event Param")
    var
        WHIDeviceConfiguration: Record "WHI Device Configuration";
        lbUpdateAssemblyOnPick: Boolean;
    begin
        this.cuCommonFuncs.getDeviceConfig(WHIDeviceConfiguration, IWXEventParam);

        lbUpdateAssemblyOnPick := this.IsUpdateAssemblyOnPick(WHIDeviceConfiguration, WarehouseActivityLine);

        if lbUpdateAssemblyOnPick and ((WarehouseActivityLine."Source Document" = WarehouseActivityLine."Source Document"::"Assembly Consumption") or (WarehouseActivityLine."Whse. Document Type" = WarehouseActivityLine."Whse. Document Type"::"Assembly")) then
            Error('Assembly Orders are not supported for dual units');

        WarehouseActivityLine.Validate("Units to Handle_DU_TSL", CaseQtyToHandle);

        WarehouseActivityLine.Modify(true);

        this.processTakePlace(WarehouseActivityLine, CaseQtyToHandle);
    end;

    local procedure IsUpdateAssemblyOnPick(WHIDeviceConfiguration: Record "WHI Device Configuration"; WarehouseActivityLine: Record "Warehouse Activity Line"): Boolean
    var
        UpdateAssemblyConsumption: Boolean;
        AutoPlace: Boolean;
    begin
        UpdateAssemblyConsumption := false;

        if ((WarehouseActivityLine."Source Document" = WarehouseActivityLine."Source Document"::"Assembly Consumption") or (WarehouseActivityLine."Whse. Document Type" = WarehouseActivityLine."Whse. Document Type"::"Assembly")) and (WHIDeviceConfiguration."Update Assembly on Pick" = WHIDeviceConfiguration."Update Assembly on Pick"::Yes) then begin
            AutoPlace := this.IsAutoTakePlace(WHIDeviceConfiguration, WarehouseActivityLine);

            case WarehouseActivityLine."Activity Type" of
                WarehouseActivityLine."Activity Type"::Pick:
                    if (AutoPlace or (WarehouseActivityLine."Action Type" = WarehouseActivityLine."Action Type"::Place) or (WarehouseActivityLine."Action Type" = WarehouseActivityLine."Action Type"::" ")) then
                        UpdateAssemblyConsumption := true;
                WarehouseActivityLine."Activity Type"::"Invt. Pick":
                    UpdateAssemblyConsumption := true;
            end;
        end;

        exit(UpdateAssemblyConsumption);
    end;

    local procedure processTakePlace(WarehouseActivityLineIn: Record "Warehouse Activity Line"; CaseQtyToHandle: Decimal)
    var
        WarehouseActivityLine: Record "Warehouse Activity Line";
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
        ActionType: Text[30];
    begin

        WarehouseActivityLine.SetRange("Activity Type", WarehouseActivityLineIn."Activity Type");
        WarehouseActivityLine.SetRange("No.", WarehouseActivityLineIn."No.");
        WarehouseActivityLine.SetRange("Item No.", WarehouseActivityLineIn."Item No.");
        WarehouseActivityLine.SetRange("Whse. Document Type", WarehouseActivityLineIn."Whse. Document Type");
        WarehouseActivityLine.SetRange("Whse. Document No.", WarehouseActivityLineIn."Whse. Document No.");
        WarehouseActivityLine.SetRange("Whse. Document Line No.", WarehouseActivityLineIn."Whse. Document Line No.");
        WarehouseActivityLine.SetFilter("Qty. Outstanding", '>%1', 0);

        if (WarehouseActivityLineIn."Action Type" = WarehouseActivityLineIn."Action Type"::Take) then
            WarehouseActivityLine.SetFilter("Line No.", '>%1', WarehouseActivityLineIn."Line No.")
        else
            WarehouseActivityLine.SetFilter("Line No.", '<%1', WarehouseActivityLineIn."Line No.");

        WarehouseActivityLine.SetRange("Breakbulk No.", 0);

        Item.Get(WarehouseActivityLineIn."Item No.");

        if (Item."Item Tracking Code" <> '') then
            ItemTrackingCode.Get(Item."Item Tracking Code");

        if (ItemTrackingCode."Lot Warehouse Tracking") and (WarehouseActivityLineIn."Lot No." <> '') then
            WarehouseActivityLine.SetFilter("Lot No.", '%1', WarehouseActivityLineIn."Lot No.");

        if (ItemTrackingCode."SN Warehouse Tracking") and (WarehouseActivityLineIn."Serial No." <> '') then
            WarehouseActivityLine.SetFilter("Serial No.", '%1', WarehouseActivityLineIn."Serial No.");

        if (ItemTrackingCode."SN Warehouse Tracking" or ItemTrackingCode."Lot Warehouse Tracking") and (WarehouseActivityLineIn."Package No." <> '') then
            WarehouseActivityLine.SetFilter("Package No.", '%1', WarehouseActivityLineIn."Package No.");

        if (WarehouseActivityLineIn."Action Type" = WarehouseActivityLineIn."Action Type"::Take) then begin
            WarehouseActivityLine.SetRange("Action Type", WarehouseActivityLine."Action Type"::Place);
#pragma warning disable AA0217
            ActionType := StrSubstNo('%1', WarehouseActivityLine."Action Type"::Place);
#pragma warning restore AA0217
        end
        else begin
            WarehouseActivityLine.SetRange("Action Type", WarehouseActivityLine."Action Type"::Take);
#pragma warning disable AA0217
            ActionType := StrSubstNo('%1', WarehouseActivityLine."Action Type"::Take);
#pragma warning restore AA0217
        end;

        WarehouseActivityLine.SetRange(Quantity, WarehouseActivityLineIn.Quantity);

        if WarehouseActivityLine.FindFirst() then begin
            WarehouseActivityLine.Validate("Units to Handle_DU_TSL", CaseQtyToHandle);
            WarehouseActivityLine.Modify(true);
        end;
    end;

    local procedure IsAutoTakePlace(WHIDeviceConfiguration: Record "WHI Device Configuration"; WarehouseActivityLie: Record "Warehouse Activity Line"): Boolean
    var
        WHIWhseActivityMgmt: Codeunit "WHI Whse. Activity Mgmt.";
    begin
        exit(WHIWhseActivityMgmt.IsAutoTakePlace(WHIDeviceConfiguration, WarehouseActivityLie));
    end;

    local procedure GetDocNo(var IWXEventParam: Record "IWX Event Param") DocNo: Code[20]
    begin
        DocNo := CopyStr(IWXEventParam.GetExtendedValue('doc_num'), 1, MaxStrLen(DocNo));
    end;

    procedure GetLineNo(var IWXEventParam: Record "IWX Event Param") LineNo: Integer
    begin
        LineNo := IWXEventParam.getLineNo();
    end;

    procedure GetDocType(var IWXEventParam: Record "IWX Event Param") DocType: Integer
    begin
        DocType := IWXEventParam.getValueAsInt('document_type');
    end;

    local procedure TrackingRequired(var IWXEventParam: Record "IWX Event Param") TrackingRequired: Boolean;
    begin
        TrackingRequired := IWXEventParam.getValueAsBool('RequireLN') or IWXEventParam.getValueAsBool('RequireSN');
    end;

    local procedure GetSingleXmlValueMsg(): Text
    begin
        exit(this.SingleXmlValueMsg);
    end;

    // local procedure GetItemNo(var IWXEventParam: Record "IWX Event Param") ItemNo: Code[20];
    // begin
    //     ItemNo := CopyStr(IWXEventParam.GetExtendedValue('barcode.ItemNumber'), 1, MaxStrLen(ItemNo));
    //     if ItemNo = '' then
    //         ItemNo := CopyStr(IWXEventParam.GetExtendedValue('No.'), 1, MaxStrLen(ItemNo));
    // end;
    local procedure GetItemNo(var IWXEventParam: Record "IWX Event Param") ItemNo: Code[20];
    begin
#pragma warning disable AA0139
        ItemNo := IWXEventParam.getItemNo();
#pragma warning restore AA0139
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
}

//AFDP 07/09/2025 'T0008-Receiving Enhancements'
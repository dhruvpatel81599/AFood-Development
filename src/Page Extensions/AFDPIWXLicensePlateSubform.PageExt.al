//>>AFDP 08/04/2025 'T0017-Remove Insight Work Customization'
/*
namespace AFood.DP.AFoodDevelopment;
using Microsoft.Sales.Document;
using Microsoft.Inventory.Tracking;
using Microsoft.Inventory.Transfer;

pageextension 50319 "AFDP IWX License Plate Subform" extends "IWX License Plate Subform"
{
    layout
    {
        //>>AFDP 07/01/2025 'T0008-Receiving Enhancements'
        modify("Lot No.")
        {
            trigger OnAssistEdit()
            var
                TempTrackingSpecification: Record "Tracking Specification" temporary;
                ItemDUUOMMgt: Codeunit "AFDP Item Dual UOM Management";
                ItemTrackingDataCollection: Codeunit "Item Tracking Data Collection";
                MaxQuantity: Decimal;
                // UndefinedQtyArray: array[3] of Decimal;
                CurrentRunMode: Enum "Item Tracking Run Mode";
                CurrentSignFactor: Integer;
            begin
                CurrentSignFactor := 1;
                //--Initialize TrackingSpecification--\\
                TempTrackingSpecification.Init();
                TempTrackingSpecification."Entry No." := 1;
                TempTrackingSpecification."Item No." := Rec."No.";
                TempTrackingSpecification."Variant Code" := Rec."Variant Code";
                TempTrackingSpecification."Location Code" := ItemDUUOMMgt.GetLocationFromLPHeader(rec);
                TempTrackingSpecification."Quantity (Base)" := Rec.Quantity;
                TempTrackingSpecification.Insert();
                MaxQuantity := Rec.Quantity;

                TempTrackingSpecification."Bin Code" := ItemDUUOMMgt.GetBinCodeFromLPHeader(rec);
                if (TempTrackingSpecification."Source Type" = Database::"Transfer Line") and (CurrentRunMode = CurrentRunMode::Reclass) then
                    ItemTrackingDataCollection.SetDirectTransfer(true);
                ItemTrackingDataCollection.AssistEditTrackingNo(TempTrackingSpecification,
                    false, CurrentSignFactor, "Item Tracking Type"::"Lot No.", MaxQuantity);
                TempTrackingSpecification."Bin Code" := '';
                CurrPage.Update();
            end;
        }
        addafter(Quantity)
        {
            field("AFDP DU Units Quantity"; Rec."AFDP DU Units Quantity")
            {
                ApplicationArea = All;
                Caption = 'Case';
                DecimalPlaces = 0 : 5;
                ToolTip = 'Specifies the quantity in dual unit of measure.';
            }
            field("AFDP DU Unit of Measure Code"; Rec."AFDP DU Unit of Measure Code")
            {
                ApplicationArea = All;
                Caption = 'Case UOM';
                ToolTip = 'Specifies the unit of measure for the dual unit of measure quantity.';
                ShowMandatory = true;
            }
        }
        //<<AFDP 07/01/2025 'T0008-Receiving Enhancements'
    }
}

//AFDP 07/01/2025 'T0008-Receiving Enhancements'
*/
//<<AFDP 08/04/2025 'T0017-Remove Insight Work Customization'
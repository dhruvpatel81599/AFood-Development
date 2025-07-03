namespace AFood.DP.AFoodDevelopment;
using Microsoft.Inventory.Item;
using Microsoft.Purchases.Document;
tableextension 50314 "AFDP IWX LP Line" extends "IWX LP Line"
{
    fields
    {
        modify("No.")
        {
            trigger OnBeforeValidate()
            begin
                UpdateCalledByFieldNameBeforeValidate(FieldName("No."));
            end;

            trigger OnAfterValidate()
            begin
                if (Type = Type::Item) and ("No." <> '') then begin
                    ItemDUUOMMgt.GetGlobalItem(Item, "No.");
                    if Item."Unit of Measure - Units_DU_TSL" = '' then
                        "AFDP DU Units Quantity" := 0
                    else
                        UpdateQtyIfFixedRatio(Rec);
                    "AFDP DU Unit of Measure Code" := Item."Unit of Measure - Units_DU_TSL";
                end;
                UpdateCalledByFieldNameAfterValidate(FieldName("No."));
            end;
        }
        modify(Quantity)
        {
            trigger OnAfterValidate()
            var
                LotNo: Code[50];
            begin
                LotNo := ItemDUUOMMgt.FindLotNoFromWarehouseEntry(Rec);
                if (LotNo <> '') then
                    Validate("Lot No.", LotNo);
            end;
        }
        field(50300; "AFDP DU Units Quantity"; Decimal)
        {
            BlankZero = true;
            Caption = 'Case';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            trigger OnValidate()
            var
                AverageQty: Decimal;
                BinAverageQty: Decimal;
            begin
                if "AFDP DU Unit of Measure Code" = '' then begin
                    TestField("AFDP DU Units Quantity", 0);
                    exit;
                end;
                UpdateCalledByFieldNameBeforeValidate(FieldName("AFDP DU Units Quantity"));
                if not QuantityEntered then
                    UnitsEntered := true;
                TestField(Type, Type::Item);
                ItemDUUOMMgt.GetGlobalItem(Item, "No.");
                if "AFDP DU Units Quantity" <> 0 then
                    Item.TestField("Unit of Measure - Units_DU_TSL");

                AverageQty := CalcAverageQty("AFDP DU Units Quantity");
                BinAverageQty := ItemDUUOMMgt.CalcBinAverageQty(rec);
                if (BinAverageQty <> 0) and ("AFDP DU Units Quantity" <> 0) then begin
                    BinAverageQty := "AFDP DU Units Quantity" * BinAverageQty;
                    BinAverageQty := Round(BinAverageQty, 0.00001); // Round to 5 decimal places;
                    Validate(Quantity, BinAverageQty);
                end else
                    Validate(Quantity, AverageQty);
            end;
        }
        field(50304; "AFDP DU Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure - Units';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = if (Type = const(Item)) "Item Unit of Measure".Code where("Item No." = field("No."));
        }
    }
    var
        Item: Record Item;
        ItemDUUOMMgt: Codeunit "AFDP Item Dual UOM Management";
        GotSetups, OrderQtyEntered, QuantityEntered, UnitsEntered, CalledFromOverReceiptUnits, CalledFromOverReceiptQty, QtyToShipReceiveEntered,
        UnitsToReceiveEntered, OverUnderReceiptCalledFromWarehouse : Boolean;
        CalledByFieldName: Text;
        FieldValidateLevel: Integer;

    procedure UpdateQtyIfFixedRatio(var IWXLPLine: Record "IWX LP Line")
    begin
        if ItemDUUOMMgt.IsDualUOMFixedRatio(IWXLPLine."No.") then
            IWXLPLine.Validate(Quantity,
                ItemDUUOMMgt.ConvertToNewUnit(
                    Item."No.", Item."Unit of Measure - Units_DU_TSL", IWXLPLine."Unit of Measure Code", IWXLPLine."AFDP DU Units Quantity", false));
    end;

    local procedure UpdateCalledByFieldNameBeforeValidate(CurrentFieldName: Text)
    begin
        if CalledByFieldName = '' then begin
            CalledByFieldName := CurrentFieldName;
            FieldValidateLevel := 1;
        end else
            FieldValidateLevel += 1;
    end;

    local procedure UpdateCalledByFieldNameAfterValidate(CurrentFieldName: Text)
    begin
        if (CalledByFieldName = CurrentFieldName) and (FieldValidateLevel <= 1) then
            CalledByFieldName := ''
        else
            FieldValidateLevel -= 1;
    end;

    local procedure CalcAverageQty(NewUnits: Decimal) AverageQty: Decimal
    begin
        AverageQty :=
            ItemDUUOMMgt.ConvertToNewUOM(
                "No.", "AFDP DU Unit of Measure Code", "Unit of Measure Code", NewUnits);
    end;
}

//AFDP 07/01/2025 'T0008-Receiving Enhancements'
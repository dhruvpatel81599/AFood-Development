namespace AFood.DP.AFoodDevelopment;

using Microsoft.Inventory.Item;
using Microsoft.Foundation.UOM;
using Microsoft.Warehouse.Structure;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Inventory.Tracking;
using Microsoft.Warehouse.Ledger;

codeunit 50304 "AFDP Item Dual UOM Management"
{

    #region Global Variables
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        GlobalItem: Record Item;
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        UnitofMeasure: Record "Unit of Measure";
    // CaptionManagement: Codeunit CaptionManagement_DU_TSL;
    #endregion Global Variables

    #region EventSubcribers

    #endregion EventSubscribers

    #region Functions    
    internal procedure IsDualUOMFixedRatio(ItemCode: Code[20]): Boolean
    begin
        GetGlobalItem(ItemCode, false);
        if GlobalItem."Fxd.Wgt. to Units Ratio_DU_TSL" and (GlobalItem."Unit of Measure - Units_DU_TSL" <> '') then
            exit(true)
        else
            exit(false);
    end;

    internal procedure GetGlobalItem(var Item: Record Item; ItemCode: Code[20])
    begin
        GetGlobalItem(ItemCode, true);
        Item := GlobalItem;
    end;

    local procedure GetGlobalItem(ItemCode: Code[20]; ErrorIfNoItem: Boolean)
    begin
        if ItemCode <> GlobalItem."No." then
            if ErrorIfNoItem then
                GlobalItem.Get(ItemCode)
            else
                if not GlobalItem.Get(ItemCode) then
                    GlobalItem.Init();
    end;

    internal procedure ConvertToNewUnit(ItemNo: Code[20]; FromUnitOfMeasure: Code[10]; ToUnitOfMeasure: Code[10]; Value: Decimal; ConvertPrice: Boolean) NewValue: Decimal
    var
        Item: Record Item;
        UnitOfMeasureL: Record "Unit of Measure";
    begin
        Item.Get(ItemNo);
        if Item."Unit of Measure - Units_DU_TSL" = '' then
            exit;
        NewValue := Value;
        if FromUnitOfMeasure <> '' then
            if ConvertPrice then
                NewValue := NewValue / GetQtyPerUnitOfMeasure(ItemNo, FromUnitOfMeasure)
            else
                NewValue := NewValue * GetQtyPerUnitOfMeasure(ItemNo, FromUnitOfMeasure);

        if ToUnitOfMeasure <> '' then
            if ConvertPrice then
                NewValue := NewValue * GetQtyPerUnitOfMeasure(ItemNo, ToUnitOfMeasure)
            else
                if GetQtyPerUnitOfMeasure(ItemNo, ToUnitOfMeasure) <> 0 then
                    NewValue := NewValue / GetQtyPerUnitOfMeasure(ItemNo, ToUnitOfMeasure);

        GeneralLedgerSetup.Get();
        if not UnitOfMeasureL.Get(ToUnitOfMeasure) then
            UnitOfMeasureL.Init();
        if ConvertPrice then
            NewValue := Round(NewValue, GeneralLedgerSetup."Unit-Amount Rounding Precision")
        else
            NewValue := Round(NewValue, GetUOMConversionRounding(UnitOfMeasureL)) // AFDP 07/01/2025 'T0008-Receiving Enhancements'
                                                                                  // NewValue := Round(NewValue, UnitOfMeasureL.GetUOMConversionRounding()) // Default rounding
    end;

    local procedure GetQtyPerUnitOfMeasure(ItemNo: Code[20]; UnitOfMeasureCode: Code[10]) QtyPerUnitOfMeasure: Decimal
    begin
        GetItemUnitOfMeasure(ItemNo, UnitOfMeasureCode, ItemUnitOfMeasure);
        QtyPerUnitOfMeasure := ItemUnitOfMeasure."Qty. per Unit of Measure";
    end;

    local procedure GetItemUnitOfMeasure(ItemNo: Code[20]; UnitOfMeasureCode: Code[10]; var ItemUnitOfMeasureP: Record "Item Unit of Measure")
    begin
        if (ItemUnitOfMeasureP."Item No." <> ItemNo) or
        (ItemUnitOfMeasureP.Code <> UnitOfMeasureCode)
        then
            if not ItemUnitOfMeasureP.Get(ItemNo, UnitOfMeasureCode) then begin
                ItemUnitOfMeasureP.Code := '';
                ItemUnitOfMeasureP."Qty. per Unit of Measure" := 1;
            end;
    end;

    internal procedure ConvertToNewUOM(ItemNo: Code[20]; FromUOMCode: Code[10]; ToUOMCode: Code[10]; FromQty: Decimal) NewQuantity: Decimal
    begin
        exit(ConvertToNewUOM(ItemNo, FromUOMCode, ToUOMCode, FromQty, true));
    end;

    local procedure ConvertToNewUOM(ItemNo: Code[20]; FromUOMCode: Code[10]; ToUOMCode: Code[10]; FromQty: Decimal; ApplyUnitsRounding: Boolean) NewQuantity: Decimal
    var
        Item: Record Item;
        LocItemUnitOfMeasure: Record "Item Unit of Measure";
        QtyBase: Decimal;
    begin
        if (ItemNo = '') or (FromUOMCode = '') or (ToUOMCode = '') or (FromQty = 0) then
            exit;
        if FromUOMCode = ToUOMCode then begin
            NewQuantity := FromQty;
            exit;
        end;
        Item := GlobalItem;
        if Item."No." <> ItemNo then
            Item.Get(ItemNo);
        if ApplyUnitsRounding then
            ApplyUnitsRounding := not Item."Fxd.Wgt. to Units Ratio_DU_TSL";
        if FromUOMCode = Item."Base Unit of Measure" then
            QtyBase := FromQty
        else begin
            if not LocItemUnitOfMeasure.Get(ItemNo, FromUOMCode) then
                LocItemUnitOfMeasure.Init();
            QtyBase := LocItemUnitOfMeasure."Qty. per Unit of Measure" * FromQty;
        end;

        if ToUOMCode = Item."Base Unit of Measure" then
            NewQuantity := QtyBase
        else begin
            if not LocItemUnitOfMeasure.Get(ItemNo, ToUOMCode) then
                LocItemUnitOfMeasure.Init();
            if LocItemUnitOfMeasure."Qty. per Unit of Measure" <> 0 then
                NewQuantity := QtyBase / LocItemUnitOfMeasure."Qty. per Unit of Measure"
            else
                NewQuantity := 0;
        end;
        if ApplyUnitsRounding then begin
            GetUnitOfMeasure(ToUOMCode, false);
            NewQuantity := Round(NewQuantity, GetUOMConversionRounding(UnitofMeasure)); // AFDP 07/01/2025 'T0008-Receiving Enhancements'
            // NewQuantity := Round(NewQuantity, UnitofMeasure.GetUOMConversionRounding());
        end else
            NewQuantity := Round(NewQuantity, 0.00001);
    end;

    local procedure GetUnitOfMeasure(UOMCode: Code[10]; ErrorIfNotExists: Boolean)
    begin
        if UnitofMeasure.Code <> UOMCode then
            if ErrorIfNotExists then
                UnitofMeasure.Get(UOMCode)
            else
                if not UnitofMeasure.Get(UOMCode) then
                    UnitofMeasure.Init();
    end;

    local procedure GetUOMConversionRounding(UnitOfMeasure1: Record "Unit of Measure"): Decimal
    begin
        if UnitOfMeasure1."UOM Conversion Rounding_DU_TSL" <> 0 then
            exit(UnitOfMeasure1."UOM Conversion Rounding_DU_TSL");
        exit(0.00001);
    end;

    //>>AFDP 08/04/2025 'T0017-Remove Insight Work Customization'
    /*
    procedure GetBinCodeFromLPHeader(var IWXLPLine: Record "IWX LP Line"): Code[20]
    var
        IWXLPHeader: Record "IWX LP Header";
    begin
        if IWXLPLine."License Plate No." <> '' then begin
            if IWXLPHeader.Get(IWXLPLine."License Plate No.") then
                exit(IWXLPHeader."Bin Code");
        end else
            exit('');
    end;

    procedure GetLocationFromLPHeader(var IWXLPLine: Record "IWX LP Line"): Code[10]
    var
        IWXLPHeader: Record "IWX LP Header";
    begin
        if IWXLPLine."License Plate No." <> '' then begin
            if IWXLPHeader.Get(IWXLPLine."License Plate No.") then
                exit(IWXLPHeader."Location Code");
        end else
            exit('');
    end;

    procedure CalcBinAverageQty(var IWXLPLine: Record "IWX LP Line"): Decimal
    var
        IWXLPHeader: Record "IWX LP Header";
        BinContent: Record "Bin Content";
        BinAverageQty: Decimal;
    begin
        if IWXLPLine."License Plate No." <> '' then
            if IWXLPHeader.Get(IWXLPLine."License Plate No.") then begin
                if IWXLPHeader."Bin Code" = '' then
                    exit(0);
                BinContent.Reset();
                BinContent.SetRange("Location Code", IWXLPHeader."Location Code");
                BinContent.SetRange("Item No.", IWXLPLine."No.");
                BinContent.SetRange("Variant Code", IWXLPLine."Variant Code");
                BinContent.SetRange("Bin Code", IWXLPHeader."Bin Code");
                BinContent.SetRange("Unit of Measure Code", IWXLPLine."Unit of Measure Code");
                if BinContent.FindFirst() then begin
                    BinContent.CalcFields("Quantity (Base)", Units_DU_TSL);
                    if BinContent."Units_DU_TSL" <> 0 then
                        BinAverageQty := BinContent."Quantity (Base)" / BinContent."Units_DU_TSL"
                    else
                        BinAverageQty := 0;
                end else
                    BinAverageQty := 0;
                exit(BinAverageQty);
            end;
        exit(0);
    end;

    procedure FindLotNoFromWarehouseEntry(var IWXLPLine: Record "IWX LP Line"): Code[50]
    var
        WarehouseEntry: Record "Warehouse Entry";
        IWXLPHeader: Record "IWX LP Header";
        AFDPSingleInstance: Codeunit "AFDP Single Instance";
        OldLotNo: Code[50];
        LotNo: Code[50];
        LotNo1: Code[50];
        LotNo2: Code[50];
        LotQty: Decimal;
        LotExpirationDate: date;
    begin
        Clear(OldLotNo);
        Clear(LotExpirationDate);
        LotNo := '';
        LotNo1 := '';
        LotNo2 := '';
        AFDPSingleInstance.SetLotExpirationDate(LotExpirationDate);
        if IWXLPLine."License Plate No." = '' then
            exit(LotNo);
        if IWXLPHeader.Get(IWXLPLine."License Plate No.") then begin
            WarehouseEntry.Reset();
            WarehouseEntry.SetCurrentKey("Lot No.");
            WarehouseEntry.SetRange("Bin Code", IWXLPHeader."Bin Code");
            WarehouseEntry.SetRange("Item No.", IWXLPLine."No.");
            WarehouseEntry.SetRange("Location Code", IWXLPHeader."Location Code");
            WarehouseEntry.SetRange("Unit of Measure Code", IWXLPLine."Unit of Measure Code");
            WarehouseEntry.SetRange("Variant Code", IWXLPLine."Variant Code");
            WarehouseEntry.SetFilter(Quantity, '<>0');
            if WarehouseEntry.FindSet() then
                repeat
                    if OldLotNo <> WarehouseEntry."Lot No." then
                        if WarehouseEntry."Lot No." <> '' then begin
                            LotQty := GetSummarizeLotQty(WarehouseEntry);
                            if LotQty <> 0 then
                                if LotNo1 = '' then begin
                                    LotNo1 := WarehouseEntry."Lot No.";
                                    AFDPSingleInstance.SetLotExpirationDate(WarehouseEntry."Expiration Date");
                                end else
                                    if LotNo2 = '' then begin
                                        LotNo2 := WarehouseEntry."Lot No.";
                                        AFDPSingleInstance.SetLotExpirationDate(WarehouseEntry."Expiration Date");
                                    end;

                            if (LotNo1 <> '') and (LotNo2 <> '') then begin
                                AFDPSingleInstance.SetLotExpirationDate(LotExpirationDate);
                                exit(LotNo);
                            end;
                        end;
                    OldLotNo := WarehouseEntry."Lot No.";
                until WarehouseEntry.Next() = 0;
        end;
        if (LotNo1 <> '') and (LotNo2 = '') then
            exit(LotNo1)
        else begin
            AFDPSingleInstance.SetLotExpirationDate(LotExpirationDate);
            exit(LotNo);
        end;
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
    */
    //<<AFDP 08/04/2025 'T0017-Remove Insight Work Customization'
    #endregion Functions
}

//AFDP 07/09/2025 'T0008-Receiving Enhancements'



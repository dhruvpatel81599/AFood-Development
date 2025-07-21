namespace AFood.DP.AFoodDevelopment;
codeunit 50302 "AFDP Single Instance"
{
    SingleInstance = true;
    //>>AFDP 05/31/2025 'Short Orders'
    procedure SetIsWarehousePostShipment(SetValue: Boolean)
    begin
        IsWarehousePostShipment := SetValue;
    end;

    procedure GetIsWarehousePostShipment(): Boolean
    begin
        exit(IsWarehousePostShipment);
    end;

    procedure SetIsWarehousePostReceipt(SetValue: Boolean)
    begin
        IsWarehousePostReceipt := SetValue;
    end;

    procedure GetIsWarehousePostReceipt(): Boolean
    begin
        exit(IsWarehousePostReceipt);
    end;
    //<<AFDP 05/31/2025 'Short Orders'
    //>>AFDP 07/18/2025 'T0012-Item Tracking Import Tools'
    procedure SetIsRunFromItemTrackingImport(SetValue: Boolean)
    begin
        IsRunFromItemTrackingImport := SetValue;
    end;

    procedure GetIsRunFromItemTrackingImport(): Boolean
    begin
        exit(IsRunFromItemTrackingImport);
    end;
    //<<AFDP 07/18/2025 'T0012-Item Tracking Import Tools'    
    //>>AFDP 07/09/2025 'T0008-Receiving Enhancements'
    procedure SetLotExpirationDate(SetValue: date)
    begin
        LotExpirationDate := SetValue;
    end;

    procedure GetLotExpirationDate(): Date
    begin
        exit(LotExpirationDate);
    end;
    //<<AFDP 07/09/2025 'T0008-Receiving Enhancements'
    //>>AFDP 07/19/2025 'T0005-Customer Lot Preference'
    procedure SetLotPreferenceCustomerNo(SetValue: Code[20])
    begin
        LotPreferenceCustomerNo := SetValue;
    end;

    procedure GetLotPreferenceCustomerNo(): Code[20]
    begin
        exit(LotPreferenceCustomerNo);
    end;

    procedure SetLotPreferenceItemNo(SetValue: Code[20])
    begin
        LotPreferenceItemNo := SetValue;
    end;

    procedure GetLotPreferenceItemNo(): Code[20]
    begin
        exit(LotPreferenceItemNo);
    end;

    procedure SetLotPreferenceVariantCode(SetValue: Code[10])
    begin
        LotPreferenceVariantCode := SetValue;
    end;

    procedure GetLotPreferenceVariantCode(): Code[10]
    begin
        exit(LotPreferenceVariantCode);
    end;

    procedure SetLotPreferenceSourceNo(SetValue: Code[20])
    begin
        LotPreferenceSourceNo := SetValue;
    end;

    procedure GetLotPreferenceSourceNo(): Code[20]
    begin
        exit(LotPreferenceSourceNo);
    end;

    procedure SetLotPreferenceSourceLineNo(SetValue: Integer)
    begin
        LotPreferenceSourceLineNo := SetValue;
    end;

    procedure GetLotPreferenceSourceLineNo(): Integer
    begin
        exit(LotPreferenceSourceLineNo);
    end;

    procedure SetPreviousLotPreferenceItemNo(SetValue: Code[20])
    begin
        PreviousLotPreferenceItemNo := SetValue;
    end;

    procedure GetPreviousLotPreferenceItemNo(): Code[20]
    begin
        exit(PreviousLotPreferenceItemNo);
    end;

    procedure SetPreviousLotPreferenceSourceLineNo(SetValue: Integer)
    begin
        PreviousLotPreferenceSourceLineNo := SetValue;
    end;

    procedure GetPreviousLotPreferenceSourceLineNo(): Integer
    begin
        exit(PreviousLotPreferenceSourceLineNo);
    end;

    procedure SetShipmentDate(SetValue: date)
    begin
        ShipmentDate := SetValue;
    end;

    procedure GetShipmentDate(): Date
    begin
        exit(ShipmentDate);
    end;

    procedure SetIsShelfLifeNotValidForLot(SetValue: Boolean)
    begin
        IsShelfLifeNotValidForLot := SetValue;
    end;

    procedure GetIsShelfLifeNotValidForLot(): Boolean
    begin
        exit(IsShelfLifeNotValidForLot);
    end;
    //<<AFDP 07/19/2025 'T0005-Customer Lot Preference'

    var
        IsWarehousePostShipment: Boolean;
        IsWarehousePostReceipt: Boolean;
        LotExpirationDate: date;
        IsRunFromItemTrackingImport: Boolean;
        LotPreferenceCustomerNo: Code[20];
        LotPreferenceItemNo: code[20];
        LotPreferenceVariantCode: Code[10];
        LotPreferenceSourceNo: Code[20];
        LotPreferenceSourceLineNo: Integer;
        PreviousLotPreferenceItemNo: Code[20];
        PreviousLotPreferenceSourceLineNo: Integer;
        ShipmentDate: Date;
        IsShelfLifeNotValidForLot: Boolean;
}

//AFDP 05/30/2025 'Short Orders'
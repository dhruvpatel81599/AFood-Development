namespace AFood.DP.AFoodDevelopment;
codeunit 50302 "INVC Single Instance"
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
    var
        IsWarehousePostShipment: Boolean;
        IsWarehousePostReceipt: Boolean;
        IsRunFromItemTrackingImport: Boolean;
}

//AFDP 05/30/2025 'Short Orders'
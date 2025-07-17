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


    var
        IsWarehousePostShipment: Boolean;
        IsWarehousePostReceipt: Boolean;
}

//AFDP 05/30/2025 'Short Orders'
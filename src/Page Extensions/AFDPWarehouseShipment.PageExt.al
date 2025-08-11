namespace AFood.DP.AFoodDevelopment;
using Microsoft.Sales.History;
using Microsoft.Warehouse.Document;
pageextension 50322 "AFDP Warehouse Shipment" extends "Warehouse Shipment"
{
    actions
    {
        //>>AFDP 08/05/2025 'T0014-Warehouse Shipment – Edit Qty'
        addlast("F&unctions")
        {
            action("Process Allocation")
            {
                ApplicationArea = All;
                Caption = 'Process Allocation';
                Image = Process;
                ToolTip = 'Process the allocation of cases and quantities for the warehouse shipment.';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                trigger OnAction()
                var
                    WarehouseShipmentLine: Record "Warehouse Shipment Line";
                begin
                    WarehouseShipmentLine.Reset();
                    WarehouseShipmentLine.SetRange("No.", Rec."No.");
                    if WarehouseShipmentLine.FindSet() then
                        repeat
                            if (WarehouseShipmentLine."AFDP Cases to Allocate" <> WarehouseShipmentLine.Units_DU_TSL) and
                                (WarehouseShipmentLine."AFDP Cases to Allocate" <> 0) then
                                WarehouseShipmentLine.Validate(Units_DU_TSL, WarehouseShipmentLine."AFDP Cases to Allocate");
                            if (WarehouseShipmentLine."AFDP Qty. to Allocate" <> WarehouseShipmentLine.Quantity) and
                                (WarehouseShipmentLine."AFDP Qty. to Allocate" <> 0) then
                                WarehouseShipmentLine.Validate(Quantity, WarehouseShipmentLine."AFDP Qty. to Allocate");
                            WarehouseShipmentLine.Modify();
                            CurrPage.Update(false);
                        until WarehouseShipmentLine.Next() = 0;
                end;
            }
        }
        //<<AFDP 08/05/2025 'T0014-Warehouse Shipment – Edit Qty'
    }
}

//AFDP 08/05/2025 'T0014-Warehouse Shipment – Edit Qty'
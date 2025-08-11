namespace AFood.DP.AFoodDevelopment;
using Microsoft.Warehouse.Document;
tableextension 50317 "AFDP Warehouse Shipment Line" extends "Warehouse Shipment Line"
{
    fields
    {
        //>>AFDP 08/04/2025 'T0014-Warehouse Shipment – Edit Qty'
        field(50300; "AFDP Cases to Allocate"; Decimal)
        {
            Caption = 'Cases to Allocate';
            DecimalPlaces = 0 : 5;
            DataClassification = CustomerContent;
        }
        field(50301; "AFDP Qty. to Allocate"; Decimal)
        {
            Caption = 'Qty. to Allocate';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
        //<<AFDP 08/04/2025 'T0014-Warehouse Shipment – Edit Qty'
    }
}

//AFDP 08/04/2025 'T0014-Warehouse Shipment – Edit Qty'
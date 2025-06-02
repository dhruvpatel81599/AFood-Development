namespace AFood.DP.AFoodDevelopment;
using Microsoft.Sales.History;
tableextension 50306 "AFDP Sales Shipment Line" extends "Sales Shipment Line"
{
    fields
    {
        //>>AFDP 06/02/2025 'Short Orders'
        field(50300; "Original Quantity"; Decimal)
        {
            Caption = 'Original Quantity';
            DecimalPlaces = 0 : 5;
            Editable = false;
            DataClassification = CustomerContent;
        }
        //<<AFDP 06/02/2025 'Short Orders'
    }
}

//AFDP 06/02/2025 'Short Orders'
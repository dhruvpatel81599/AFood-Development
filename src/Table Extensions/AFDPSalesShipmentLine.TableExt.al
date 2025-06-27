namespace AFood.DP.AFoodDevelopment;
using Microsoft.Sales.History;
tableextension 50306 "AFDP Sales Shipment Line" extends "Sales Shipment Line"
{
    fields
    {
        //>>AFDP 06/02/2025 'Short Orders'
        field(50300; "AFDP Original Quantity"; Decimal)
        {
            Caption = 'Original Quantity';
            DecimalPlaces = 0 : 5;
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(50301; "AFDP Original Unit Price"; Decimal)
        {
            AutoFormatExpression = GetCurrencyCode();
            AutoFormatType = 2;
            Caption = 'Original Unit Price';
            Editable = false;
        }
        //<<AFDP 06/02/2025 'Short Orders'
    }
}

//AFDP 06/02/2025 'Short Orders'
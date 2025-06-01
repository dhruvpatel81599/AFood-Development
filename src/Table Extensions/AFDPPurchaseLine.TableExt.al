namespace AFood.DP.AFoodDevelopment;
using Microsoft.Purchases.Document;
tableextension 50304 "AFDP Purchase Line" extends "Purchase Line"
{
    fields
    {
        //>>AFDP 05/30/2025 'Short Orders'
        field(50300; "Original Quantity"; Decimal)
        {
            Caption = 'Original Quantity';
            DecimalPlaces = 0 : 5;
            Editable = false;
            DataClassification = CustomerContent;
        }
        //<<AFDP 05/30/2025 'Short Orders'
    }
}

//AFDP 05/30/2025 'Short Orders'
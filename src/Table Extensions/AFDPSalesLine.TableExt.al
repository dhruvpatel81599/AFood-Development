namespace AFood.DP.AFoodDevelopment;
using Microsoft.Sales.Document;
tableextension 50303 "AFDP Sales Line" extends "Sales Line"
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
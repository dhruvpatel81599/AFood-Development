namespace AFood.DP.AFoodDevelopment;
using Microsoft.Purchases.History;
tableextension 50308 "AFDP Purch.Receipt Line" extends "Purch. Rcpt. Line"
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
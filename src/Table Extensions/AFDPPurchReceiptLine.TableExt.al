namespace AFood.DP.AFoodDevelopment;
using Microsoft.Purchases.History;
tableextension 50308 "AFDP Purch.Receipt Line" extends "Purch. Rcpt. Line"
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
            AutoFormatType = 2;
            Caption = 'Original Unit Price';
            Editable = false;
        }
        //<<AFDP 06/02/2025 'Short Orders'
    }
}

//AFDP 06/02/2025 'Short Orders'
namespace AFood.DP.AFoodDevelopment;
using Microsoft.Purchases.Document;
tableextension 50304 "AFDP Purchase Line" extends "Purchase Line"
{
    fields
    {
        //>>AFDP 05/30/2025 'Short Orders'
        field(50300; "AFDP Original Quantity"; Decimal)
        {
            Caption = 'Original Quantity';
            DecimalPlaces = 0 : 5;
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(50301; "AFDP Original Unit Price"; Decimal)
        {
            AutoFormatExpression = Rec."Currency Code";
            AutoFormatType = 2;
            Caption = 'Original Unit Price';
            Editable = false;
        }
        //<<AFDP 05/30/2025 'Short Orders'
    }
}

//AFDP 05/30/2025 'Short Orders'
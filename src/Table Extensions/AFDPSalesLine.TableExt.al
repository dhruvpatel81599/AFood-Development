namespace AFood.DP.AFoodDevelopment;
using Microsoft.Sales.Document;
tableextension 50303 "AFDP Sales Line" extends "Sales Line"
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
        field(50302; "AFDP Original Amount"; Decimal)
        {
            AutoFormatExpression = Rec."Currency Code";
            AutoFormatType = 1;
            Caption = 'Original Amount';
            Editable = false;
        }
        //<<AFDP 05/30/2025 'Short Orders'
    }
}

//AFDP 05/30/2025 'Short Orders'
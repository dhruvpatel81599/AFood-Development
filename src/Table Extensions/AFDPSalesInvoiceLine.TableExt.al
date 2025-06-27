namespace AFood.DP.AFoodDevelopment;
using Microsoft.Sales.History;
tableextension 50307 "AFDP Sales Invoice Line" extends "Sales Invoice Line"
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
        field(50302; "AFDP Original Amount"; Decimal)
        {
            AutoFormatExpression = GetCurrencyCode();
            AutoFormatType = 1;
            Caption = 'Original Amount';
            Editable = false;
        }
        //<<AFDP 06/02/2025 'Short Orders'
    }
}

//AFDP 06/02/2025 'Short Orders'
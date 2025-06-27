namespace AFood.DP.AFoodDevelopment;
using Microsoft.Purchases.History;
pageextension 50318 "AFDP Posted P.Invoice Lines" extends "Posted Purchase Invoice Lines"
{
    layout
    {
        //>>AFDP 06/27/2025 'Short Orders'
        addafter(Quantity)
        {
            field("Original Quantity"; Rec."AFDP Original Quantity")
            {
                ApplicationArea = all;
                Caption = 'Original Quantity';
                ToolTip = 'The original quantity of the purchase invoice line before any modifications.';
            }
        }
        //<<AFDP 06/27/2025 'Short Orders'
    }
}

//AFDP 06/27/2025 'Short Orders'
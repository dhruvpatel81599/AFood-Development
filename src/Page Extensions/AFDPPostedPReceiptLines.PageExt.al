namespace AFood.DP.AFoodDevelopment;
using Microsoft.Purchases.History;
pageextension 50317 "AFDP Posted P.Receipt Lines" extends "Posted Purchase Receipt Lines"
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
                ToolTip = 'The original quantity of the purchase receipt line before any modifications.';
            }
        }
        //<<AFDP 06/27/2025 'Short Orders'
    }
}

//AFDP 06/27/2025 'Short Orders'
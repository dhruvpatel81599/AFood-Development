namespace AFood.DP.AFoodDevelopment;
using Microsoft.Purchases.History;
pageextension 50308 "AFDP Posted P.Receipt Subform" extends "Posted Purchase Rcpt. Subform"
{
    layout
    {
        //>>AFDP 06/02/2025 'Short Orders'
        addafter(Quantity)
        {
            field("Original Quantity"; Rec."AFDP Original Quantity")
            {
                ApplicationArea = all;
                Caption = 'Original Quantity';
                ToolTip = 'The original quantity of the purchase receipt line before any modifications.';
            }
        }
        //<<AFDP 06/02/2025 'Short Orders'
    }
}

//AFDP 06/02/2025 'Short Orders'
namespace AFood.DP.AFoodDevelopment;
using Microsoft.Purchases.Document;
pageextension 50304 "AFDP Purchase Order Subform" extends "Purchase Order Subform"
{
    layout
    {
        //>>AFDP 05/30/2025 'Short Orders'
        addafter(Quantity)
        {
            field("Original Quantity"; Rec."Original Quantity")
            {
                ApplicationArea = all;
                Caption = 'Original Quantity';
                ToolTip = 'The original quantity of the sales line before any modifications.';
            }
        }
        //<<AFDP 05/30/2025 'Short Orders'
    }
}

//AFDP 05/30/2025 'Short Orders'
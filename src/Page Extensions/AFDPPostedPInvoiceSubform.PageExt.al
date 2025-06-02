namespace AFood.DP.AFoodDevelopment;
using Microsoft.Purchases.History;
pageextension 50309 "AFDP Posted P.Invoice Subform" extends "Posted Purch. Invoice Subform"
{
    layout
    {
        //>>AFDP 06/02/2025 'Short Orders'
        addafter(Quantity)
        {
            field("Original Quantity"; Rec."Original Quantity")
            {
                ApplicationArea = all;
                Caption = 'Original Quantity';
                ToolTip = 'The original quantity of the purchase invoice line before any modifications.';
            }
        }
        //<<AFDP 06/02/2025 'Short Orders'
    }
}

//AFDP 06/02/2025 'Short Orders'
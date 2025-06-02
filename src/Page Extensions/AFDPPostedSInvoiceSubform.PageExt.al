namespace AFood.DP.AFoodDevelopment;
using Microsoft.Sales.History;
pageextension 50307 "AFDP Posted S.Invoice Subform" extends "Posted Sales Invoice Subform"
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
                ToolTip = 'The original quantity of the sales line before any modifications.';
            }
        }
        //<<AFDP 06/02/2025 'Short Orders'
    }

}

//AFDP 06/02/2025 'Short Orders'
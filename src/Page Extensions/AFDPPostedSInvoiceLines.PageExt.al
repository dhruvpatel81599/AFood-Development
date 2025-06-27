namespace AFood.DP.AFoodDevelopment;
using Microsoft.Sales.History;
pageextension 50316 "AFDP Posted S.Invoice Lines" extends "Posted Sales Invoice Lines"
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
                ToolTip = 'The original quantity of the sales invoice line before any modifications.';
            }
        }
        //<<AFDP 06/27/2025 'Short Orders'
    }

}

//AFDP 06/27/2025 'Short Orders'
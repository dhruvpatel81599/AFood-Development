namespace AFood.DP.AFoodDevelopment;
using Microsoft.Sales.Document;
pageextension 50303 "AFDP Sales Order Subform" extends "Sales Order Subform"
{
    layout
    {
        //>>AFDP 05/30/2025 'Short Orders'
        addafter(Quantity)
        {
            field("Original Quantity"; Rec."AFDP Original Quantity")
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
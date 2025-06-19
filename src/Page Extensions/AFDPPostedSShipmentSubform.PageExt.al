namespace AFood.DP.AFoodDevelopment;
using Microsoft.Sales.History;
pageextension 50306 "AFDP Posted S.Shipment Subform" extends "Posted Sales Shpt. Subform"
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
                ToolTip = 'The original quantity of the sales shipment line before any modifications.';
            }
        }
        //<<AFDP 06/02/2025 'Short Orders'
    }

}

//AFDP 06/02/2025 'Short Orders'
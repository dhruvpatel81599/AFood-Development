namespace AFood.DP.AFoodDevelopment;
using Microsoft.Sales.History;
pageextension 50315 "AFDP Posted S.Shipment Lines" extends "Posted Sales Shipment Lines"
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
                ToolTip = 'The original quantity of the sales shipment line before any modifications.';
            }
        }
        //<<AFDP 06/27/2025 'Short Orders'
    }

}

//AFDP 06/27/2025 'Short Orders'
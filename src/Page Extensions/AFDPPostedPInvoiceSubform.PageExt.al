namespace AFood.DP.AFoodDevelopment;
using Microsoft.Purchases.History;
pageextension 50309 "AFDP Posted P.Invoice Subform" extends "Posted Purch. Invoice Subform"
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
                ToolTip = 'The original quantity of the purchase invoice line before any modifications.';
            }
            field("AFDP Original Unit Price"; Rec."AFDP Original Unit Price")
            {
                ApplicationArea = all;
                Caption = 'Original Unit Price';
                ToolTip = 'The original unit price of the purchase invoice line before any modifications.';
                Visible = false; // Hide this field by default
            }
            field("AFDP Original Amount"; Rec."AFDP Original Amount")
            {
                ApplicationArea = all;
                Caption = 'Original Amount';
                ToolTip = 'The original amount of the purchase invoice line before any modifications.';
                Visible = false; // Hide this field by default
            }
        }
        //<<AFDP 06/02/2025 'Short Orders'
    }
}

//AFDP 06/02/2025 'Short Orders'
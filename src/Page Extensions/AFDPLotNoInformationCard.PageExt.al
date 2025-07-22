namespace AFood.DP.AFoodDevelopment;

using Microsoft.Inventory.Tracking;
pageextension 50320 "AFDP Lot No Information Card" extends "Lot No. Information Card"
{
    layout
    {
        //>>AFDP 07/22/2025 'T0005-Customer Lot Preference'
        addlast(General)
        {
            field("AFDP Default Sales Shelf Life"; Rec."AFDP Default Sales Shelf Life")
            {
                Caption = 'Default Sales Shelf Life';
                ApplicationArea = ItemTracking;
                ToolTip = 'Default Sales Shelf Life';
            }
            field("AFDP Plant Number Mandatory"; Rec."AFDP Plant Number Mandatory")
            {
                Caption = 'Plant Number Mandatory';
                ApplicationArea = ItemTracking;
                ToolTip = 'Plant Number Mandatory';
            }
            field("AFDP Plant Number"; Rec."AFDP Plant Number")
            {
                Caption = 'Plant Number';
                ApplicationArea = ItemTracking;
                ToolTip = 'Plant Number';
            }
        }
        //<<AFDP 07/22/2025 'T0005-Customer Lot Preference'
    }
}

//AFDP 07/22/2025 'T0005-Customer Lot Preference'
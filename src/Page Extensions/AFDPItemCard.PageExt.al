namespace AFood.DP.AFoodDevelopment;
using Microsoft.Inventory.Item;
pageextension 50312 "AFDP Item Card" extends "Item Card"
{
    layout
    {
        addlast(Item)
        {
            field("AFDP Old Item No."; Rec."AFDP Old Item No.")
            {
                ApplicationArea = all;
                Caption = 'Old Item No.';
                ToolTip = 'Specify the old item number for AFDP';
                Editable = false;
            }
        }
        //>>AFDP 07/19/2025 'T0005-Customer Lot Preference'
        addlast(ItemTracking)
        {
            field("AFDP Default Sales Shelf Life"; Rec."AFDP Default Sales Shelf Life")
            {
                Caption = 'Default Sales Shelf Life';
                ApplicationArea = ItemTracking;
                ToolTip = 'Default Sales Shelf Life';
            }
        }
        //<<AFDP 07/19/2025 'T0005-Customer Lot Preference'
    }
}

//AFDP 06/11/2025 'T0006-Item Number Rename'
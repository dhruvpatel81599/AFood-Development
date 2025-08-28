namespace AFood.DP.AFoodDevelopment;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Tracking;
using Microsoft.Warehouse.Activity;
pageextension 50325 "AFDP Whse. Pick Subform" extends "Whse. Pick Subform"
{
    layout
    {
        addafter("Lot No.")
        {
            //>>AFDP 08/28/2025 'T0021-Show License Plate on Pick'
            field("License Plate"; Rec."AFDP License Plate")
            {
                ApplicationArea = All;
                Caption = 'License Plate';
                Editable = false;
                ToolTip = 'Specifies the license plate associated with the item.';
            }
            //<<AFDP 08/28/2025 'T0021-Show License Plate on Pick'
        }
    }
}

//AFDP 08/28/2025 'T0021-Show License Plate on Pick'
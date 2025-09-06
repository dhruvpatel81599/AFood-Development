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
            //>>AFDP 08/27/2025 'T0022-Plant Number'
            field("AFDP Plant Number Mandatory"; Rec."AFDP Plant Number Mandatory")
            {
                Caption = 'Plant Number Mandatory';
                ApplicationArea = ItemTracking;
                ToolTip = 'Plant Number Mandatory';
            }
            field("AFDP Default Plant Number"; Rec."AFDP Default Plant Number")
            {
                Caption = 'Plant Number';
                ApplicationArea = ItemTracking;
                ToolTip = 'Plant Number';
                Enabled = Rec."AFDP Plant Number Mandatory";
            }
            //<<AFDP 08/27/2025 'T0022-Plant Number'
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

//AFDP 08/27/2025 'T0022-Plant Number'
//AFDP 08/28/2025 'T0021-Show License Plate on Pick'

namespace AFood.DP.AFoodDevelopment;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Tracking;
using Microsoft.Warehouse.Activity.History;
using Microsoft.Warehouse.Activity;
pageextension 50326 "AFDP Registered Pick Subform" extends "Registered Pick Subform"
{
    layout
    {
        addafter(Description)
        {
            //>>AFDP 08/29/2025 'T0022-Plant Number'
            field("AFDP Plant Number Mandatory"; Rec."AFDP Plant Number Mandatory")
            {
                Caption = 'Plant Number Mandatory';
                ApplicationArea = ItemTracking;
                ToolTip = 'Plant Number Mandatory';
            }
            field("AFDP Default Plant Number"; Rec."AFDP Default Plant Number")
            {
                Caption = 'Default Plant Number';
                ApplicationArea = ItemTracking;
                ToolTip = 'Default Plant Number';
                Enabled = Rec."AFDP Plant Number Mandatory";
            }
            //<<AFDP 08/29/2025 'T0022-Plant Number'
        }
    }
}

//AFDP 08/29/2025 'T0022-Plant Number'
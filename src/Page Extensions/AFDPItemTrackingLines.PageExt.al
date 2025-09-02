namespace AFood.DP.AFoodDevelopment;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Tracking;
pageextension 50323 "AFDP Item Tracking Lines" extends "Item Tracking Lines"
{
    layout
    {
        addafter("Expiration Date")
        {
            //>>AFDP 08/26/2025 'T0022-Plant Number'
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
                // Enabled = Rec."AFDP Plant Number Mandatory";
                trigger OnValidate()
                begin
                    LotNoOnAfterValidate();
                end;
            }
            //<<AFDP 08/26/2025 'T0022-Plant Number'
        }
    }
}

//AFDP 08/26/2025 'T0022-Plant Number'
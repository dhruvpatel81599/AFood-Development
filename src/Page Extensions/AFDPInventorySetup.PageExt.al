namespace AFood.DP.AFoodDevelopment;
using Microsoft.Inventory.Setup;
pageextension 50305 "AFDP Inventory Setup" extends "Inventory Setup"
{
    layout
    {
        //>>AFDP 05/30/2025 'Short Orders'
        addlast(General)
        {
            field("Enable Sales Short"; Rec."AFDP Enable Sales Short")
            {
                ApplicationArea = all;
                Caption = 'Enable Sales Short';
                ToolTip = 'If enabled, sales backorders will not be allowed.';
            }
            field("Enable Purchase Short"; Rec."AFDP Enable Purchase Short")
            {
                ApplicationArea = all;
                Caption = 'Enable Purchase Short';
                ToolTip = 'If enabled, purchase backorders will not be allowed.';
            }
        }
        //<<AFDP 05/30/2025 'Short Orders'
    }
}

//AFDP 05/30/2025 'Short Orders'
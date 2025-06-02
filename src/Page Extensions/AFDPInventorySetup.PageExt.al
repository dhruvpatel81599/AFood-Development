namespace AFood.DP.AFoodDevelopment;
using Microsoft.Inventory.Setup;
pageextension 50305 "AFDP Inventory Setup" extends "Inventory Setup"
{
    layout
    {
        //>>AFDP 05/30/2025 'Short Orders'
        addlast(General)
        {
            field("Disable Sales Backorders"; Rec."AFDP Disable Sales Backorders")
            {
                ApplicationArea = all;
                Caption = 'Disable Sales Backorders';
                ToolTip = 'If enabled, sales backorders will not be allowed.';
            }
            field("Disable Purchase Backorders"; Rec."AFDPDisablePurchaseBackorders")
            {
                ApplicationArea = all;
                Caption = 'Disable Purchase Backorders';
                ToolTip = 'If enabled, purchase backorders will not be allowed.';
            }
        }
        //<<AFDP 05/30/2025 'Short Orders'
    }
}

//AFDP 05/30/2025 'Short Orders'
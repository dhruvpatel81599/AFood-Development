namespace AFood.DP.AFoodDevelopment;
using Microsoft.Inventory.Setup;
pageextension 50305 "AFDP Inventory Setup" extends "Inventory Setup"
{
    layout
    {
        addlast(General)
        {
            //>>AFDP 05/30/2025 'Short Orders'
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
            //<<AFDP 05/30/2025 'Short Orders'
            //>>AFDP 06/28/2025 'T0008-Receiving Enhancements'
            field("Receiving Template Name"; Rec."AFDP Receiving Template Name")
            {
                ApplicationArea = all;
                Caption = 'Receiving Reclass Template Name';
                ToolTip = 'Specifies the item journal template used for receiving reclassifications.';
            }
            field("Receiving Batch Name"; Rec."AFDP Receiving Batch Name")
            {
                ApplicationArea = all;
                Caption = 'Receiving Reclass Batch Name';
                ToolTip = 'Specifies the item journal batch used for receiving reclassifications.';
            }
            //<<AFDP 06/28/2025 'T0008-Receiving Enhancements'
        }
    }
}

//AFDP 05/30/2025 'Short Orders'
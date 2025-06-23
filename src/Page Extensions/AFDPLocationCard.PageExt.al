namespace AFood.DP.AFoodDevelopment;
using Microsoft.Inventory.Location;
pageextension 50313 "AFDP Location Card" extends "Location Card"
{
    layout
    {
        addlast(General)
        {
            group("AFDP Default Missing Bin")
            {
                field(AFDPDefaultMissingBin; Rec."AFDP Default Missing Bin")
                {
                    ApplicationArea = all;
                    Caption = 'Default Missing Bin';
                    ToolTip = 'Specify the default missing bin';
                }
            }
        }
    }
}

//AFDP 06/22/2025 'T0008-Receiving Enhancements'
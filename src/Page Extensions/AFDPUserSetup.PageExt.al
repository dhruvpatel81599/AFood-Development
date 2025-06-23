namespace AFood.DP.AFoodDevelopment;
using System.Security.User;
pageextension 50314 "AFDP User Setup" extends "User Setup"
{
    layout
    {
        addlast(Control1)
        {
            field("AFDP Allow Return Order"; Rec."AFDP Allow Return Order")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies whether the user is allowed to return orders.';
            }
        }
    }
}

//AFDP 06/22/2025 'T0008-Receiving Enhancements'
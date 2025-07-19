namespace AFood.DP.AFoodDevelopment;
using System.Security.User;
tableextension 50312 "AFDP User Setup" extends "User Setup"
{
    fields
    {
        field(50300; "AFDP Allow Return Order"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Allow To Create Return Order';
            ToolTip = 'Specify if return orders are allowed';
        }
    }
}

//AFDP 06/22/2025 'T0008-Receiving Enhancements'
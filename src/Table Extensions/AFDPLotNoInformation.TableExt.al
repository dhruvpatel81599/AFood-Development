namespace AFood.DP.AFoodDevelopment;

using Microsoft.Inventory.Tracking;
tableextension 50315 "AFDP Lot No. Information" extends "Lot No. Information"
{
    fields
    {
        //>>AFDP 07/22/2025 'T0005-Customer Lot Preference'
        field(50301; "AFDP Default Sales Shelf Life"; DateFormula)
        {
            Caption = 'Default Sales Shelf Life';
        }
        field(50302; "AFDP Plant Number Mandatory"; Boolean)
        {
            Caption = 'Plant Number Mandatory';
        }
        //>>AFDP 08/26/2025 'T0022-Plant Number'
        // field(50303; "AFDP Plant Number"; Enum "AFDP Plant Number Option")
        // {
        //     Caption = 'Plant Number';
        // }
        field(50303; "AFDP Default Plant Number"; Code[20])
        {
            Caption = 'Default Plant Number';
        }
        //<<AFDP 08/26/2025 'T0022-Plant Number'
        //<<AFDP 07/22/2025 'T0005-Customer Lot Preference'
    }
}

//AFDP 07/22/2025 'T0005-Customer Lot Preference'
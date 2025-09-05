namespace AFood.DP.AFoodDevelopment;
using Microsoft.Inventory.Item;
tableextension 50310 "AFDP Item" extends Item
{
    fields
    {
        field(50300; "AFDP Old Item No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Old Item No.';
            ToolTip = 'Specify the old item number for AFDP';
            Editable = false;
        }
        //>>AFDP 07/19/2025 'T0005-Customer Lot Preference'
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
        //<<AFDP 07/19/2025 'T0005-Customer Lot Preference'
    }
}

//AFDP 06/11/2025 'T0006-Item Number Rename'
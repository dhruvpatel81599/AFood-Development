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
    }
}

//AFDP 06/11/2025 'T0006-Item Number Rename'
namespace AFood.DP.AFoodDevelopment;
using Microsoft.Inventory.Journal;
tableextension 50313 "AFDP Item Journal Line" extends "Item Journal Line"
{
    fields
    {
        field(50300; "AFDP Receiving Return Order"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Receiving Return Order';
            ToolTip = 'Specify if this item journal line is for a receiving return order';
            Editable = false;
        }
    }
}

//AFDP 06/28/2025 'T0008-Receiving Enhancements'
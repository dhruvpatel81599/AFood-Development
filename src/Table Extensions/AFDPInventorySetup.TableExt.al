namespace AFood.DP.AFoodDevelopment;
using Microsoft.Inventory.Setup;
tableextension 50305 "AFDP Inventory Setup" extends "Inventory Setup"
{
    fields
    {
        //>>AFDP 05/30/2025 'Short Orders'
        field(50300; "AFDP Enable Sales Short"; Boolean)
        {
            Caption = 'Enable Sales Short';
            DataClassification = CustomerContent;
        }
        field(50301; "AFDP Enable Purchase Short"; Boolean)
        {
            Caption = 'Enable Purchase Short';
            DataClassification = CustomerContent;
        }
        //<<AFDP 05/30/2025 'Short Orders'
    }
}

//AFDP 05/30/2025 'Short Orders'
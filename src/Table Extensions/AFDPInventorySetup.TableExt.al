namespace AFood.DP.AFoodDevelopment;
using Microsoft.Inventory.Setup;
tableextension 50305 "AFDP Inventory Setup" extends "Inventory Setup"
{
    fields
    {
        //>>AFDP 05/30/2025 'Short Orders'
        field(50300; "Disable Sales Backorders"; Boolean)
        {
            Caption = 'Disable Sales Backorders';
            DataClassification = CustomerContent;
        }
        field(50301; "Disable Purchase Backorders"; Boolean)
        {
            Caption = 'Disable Purchase Backorders';
            DataClassification = CustomerContent;
        }
        //<<AFDP 05/30/2025 'Short Orders'
    }
}

//AFDP 05/30/2025 'Short Orders'
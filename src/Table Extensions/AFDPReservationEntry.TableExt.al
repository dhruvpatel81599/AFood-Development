namespace AFood.DP.AFoodDevelopment;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Tracking;
tableextension 50319 "AFDP Reservation Entry" extends "Reservation Entry"
{
    fields
    {
        //>>AFDP 08/26/2025 'T0022-Plant Number'
        field(50300; "AFDP Plant Number Mandatory"; Boolean)
        {
            Caption = 'Plant Number Mandatory';
            Editable = false;
        }
        field(50301; "AFDP Default Plant Number"; Code[20])
        {
            Caption = 'Plant Number';
            Editable = false;
        }
        //<<AFDP 08/26/2025 'T0022-Plant Number'        
    }
}

//AFDP 08/26/2025 'T0022-Plant Number'
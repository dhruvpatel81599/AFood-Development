namespace AFood.DP.AFoodDevelopment;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Tracking;
using Microsoft.Warehouse.Activity;
tableextension 50320 "AFDP Warehouse Activity Line" extends "Warehouse Activity Line"
{
    fields
    {
        //>>AFDP 08/27/2025 'T0022-Plant Number'
        field(50300; "AFDP Plant Number Mandatory"; Boolean)
        {
            Caption = 'Plant Number Mandatory';
        }
        field(50301; "AFDP Default Plant Number"; Code[20])
        {
            Caption = 'Plant Number';
        }
        //<<AFDP 08/27/2025 'T0022-Plant Number'        
    }
}

//AFDP 08/27/2025 'T0022-Plant Number'
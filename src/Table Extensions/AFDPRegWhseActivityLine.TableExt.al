namespace AFood.DP.AFoodDevelopment;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Tracking;
using Microsoft.Warehouse.Activity.History;
using Microsoft.Warehouse.Activity;
tableextension 50321 "AFDP Reg.Whse. Activity Line" extends "Registered Whse. Activity Line"
{
    fields
    {
        //>>AFDP 08/29/2025 'T0022-Plant Number'
        field(50300; "AFDP Plant Number Mandatory"; Boolean)
        {
            Caption = 'Plant Number Mandatory';
        }
        field(50301; "AFDP Default Plant Number"; Code[20])
        {
            Caption = 'Default Plant Number';
        }
        //<<AFDP 08/29/2025 'T0022-Plant Number'
    }
}

//AFDP 08/29/2025 'T0022-Plant Number'
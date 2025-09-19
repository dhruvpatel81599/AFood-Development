namespace AFood.DP.AFoodDevelopment;
using Microsoft.Inventory.Item;
using Microsoft.Warehouse.Structure;
using Microsoft.Inventory.Tracking;
using Microsoft.Warehouse.Activity.History;
using Microsoft.Warehouse.Activity;
pageextension 50327 "AFDPLotNumbersbyBinFactBox" extends "Lot Numbers by Bin FactBox"
{
    layout
    {
        addafter("Qty. (Base)")
        {
            //>>AFDP 00/19/2025 'T0030-General Development Request'
            field("AFDP Cases"; Rec."AFDP Cases")
            {
                Caption = 'Cases';
                ApplicationArea = ItemTracking;
                ToolTip = 'Cases';
            }
            //<<AFDP 00/19/2025 'T0030-General Development Request'
        }
    }
}

//AFDP 00/19/2025 'T0030-General Development Request'
namespace AFood.DP.AFoodDevelopment;
using Microsoft.Warehouse.Structure;
using Microsoft.Warehouse.Ledger;
tableextension 50322 "AFDP Lot Bin Buffer" extends "Lot Bin Buffer"
{
    fields
    {
        //>>AFDP 00/19/2025 'T0030-General Development Request'
        field(50300; "AFDP Cases"; Decimal)
        {
            CalcFormula = sum("Warehouse Entry"."Units_DU_TSL" where("Item No." = field("Item No."),
                                                                    "Bin Code" = field("Bin Code"),
                                                                  "Location Code" = field("Location Code"),
                                                                  "Variant Code" = field("Variant Code"),
                                                                  "Lot No." = field("Lot No.")));
            Caption = 'Cases';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        //<<AFDP 00/19/2025 'T0030-General Development Request'
    }
}

//AFDP 00/19/2025 'T0030-General Development Request'
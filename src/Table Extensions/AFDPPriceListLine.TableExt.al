namespace AFood.DP.AFoodDevelopment;
using Microsoft.Pricing.PriceList;
tableextension 50302 "AFDP Price List Line" extends "Price List Line"
{
    fields
    {
        field(50300; "AFDP Sales Contract"; Boolean)
        {
            Caption = 'Sales Contract';
            ToolTip = 'Indicates if this price list is a sales contract.';
            FieldClass = FlowField;
            CalcFormula = min("Price List Header"."AFDP Sales Contract" where("Code" = field("Price List Code")));
            Editable = false;
        }
    }
}

//AFDP 05/26/2025 'Sales Contract'
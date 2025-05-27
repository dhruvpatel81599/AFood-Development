namespace AFood.DP.AFoodDevelopment;
using Microsoft.Pricing.PriceList;
tableextension 50301 "AFDP Price List Header" extends "Price List Header"
{
    fields
    {
        field(50300; "AFDP Sales Contract"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Sales Contract';
            ToolTip = 'Indicates if this price list is a sales contract.';
        }
    }
}

//AFDP 05/26/2025 'Sales Contract'
namespace AFood.DP.AFoodDevelopment;
using Microsoft.Sales.Pricing;
pageextension 50301 "AFDP Sales Price List" extends "Sales Price List"
{
    layout
    {
        addlast(General)
        {
            field("AFDP Sales Contract"; Rec."AFDP Sales Contract")
            {
                ApplicationArea = all;
                CaptionML = ENU = 'Sales Contract';
                ToolTipML = ENU = 'Indicates if this price list is a sales contract.';
            }
        }
    }
}
//AFDP 05/26/2025 'Sales Contract'
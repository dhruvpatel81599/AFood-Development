namespace AFood.DP.AFoodDevelopment;
using Microsoft.Pricing.PriceList;
pageextension 50302 "AFDP Price List Lines" extends "Price List Lines"
{
    layout
    {
        addlast(Control1)
        {
            field("AFDP Sales Contract"; Rec."AFDP Sales Contract")
            {
                ApplicationArea = all;
                CaptionML = ENU = 'Sales Contract';
                ToolTipML = ENU = 'Indicates if this price list is a sales contract.';
                Visible = false;
            }
        }
    }

}

//AFDP 05/26/2025 'Sales Contract'
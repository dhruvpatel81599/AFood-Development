namespace AFood.DP.AFoodDevelopment;

using Microsoft.Sales.Customer;
pageextension 50300 "AFDP Customer Card" extends "Customer Card"
{
    layout
    {
        addlast(General)
        {
            field("AFDP ItemCodeType"; Rec."AFDP ItemCodeType")
            {
                ApplicationArea = all;
                CaptionML = ENU = 'Item Code Type';
                ToolTipML = ENU = 'Specifies the item code type field.';
            }
        }
    }
    actions
    {
        addlast("F&unctions")
        {
            //>>AFDP 07/19/2025 'T0005-Customer Lot Preference'
            action(CustomerLotPreference)
            {
                ApplicationArea = all;
                Caption = 'Customer Lot Preference';
                Image = Lot;
                RunObject = page "AFDP Customer Lot Preferences";
                RunPageLink = "AFDP Customer No." = field("No.");
                ToolTip = 'Setup customer lot preference';
            }
            //<<AFDP 07/19/2025 'T0005-Customer Lot Preference'
        }
    }
}

//AFDP 05/24/2025 'Item Code Type'
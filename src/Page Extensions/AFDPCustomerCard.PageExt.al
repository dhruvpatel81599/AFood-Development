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
}

//AFDP 05/24/2025 'Item Code Type'
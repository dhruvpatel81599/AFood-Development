namespace AFood.DP.AFoodDevelopment;
page 50303 "AFDP Customer Lot Preferences"
{
    ApplicationArea = All;
    Caption = 'Customer Lot Preferences';
    PageType = List;
    SourceTable = "AFDP Customer Lot Preferences";
    UsageCategory = Lists;
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("AFDP Customer No."; Rec."AFDP Customer No.")
                {
                    ToolTip = 'Customer No.';
                    ApplicationArea = All;
                }
                field("AFDP Item No."; Rec."AFDP Item No.")
                {
                    ToolTip = 'Item No.';
                    ApplicationArea = All;
                }
                field("AFDP Item Description"; Rec."AFDP Item Description")
                {
                    ToolTip = 'Item Description';
                    ApplicationArea = All;
                }
                field("AFDP Shelf Life"; Rec."AFDP Shelf Life")
                {
                    ToolTip = 'Specifies the value of the Shelf life field';
                    ApplicationArea = All;
                }
            }
        }
    }
}

//AFDP 07/19/2025 'T0005-Customer Lot Preference'
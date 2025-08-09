namespace AFood.DP.AFoodDevelopment;

using Microsoft.Sales.Customer;
using Microsoft.Inventory.Item;
table 50303 "AFDP Customer Lot Preferences"
{
    DataClassification = CustomerContent;
    Caption = 'Customer Lot Preferences';
    fields
    {
        field(50300; "AFDP Customer No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Customer No.';
            TableRelation = Customer."No.";
            ValidateTableRelation = true;
        }
        field(50302; "AFDP Item No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Item No.';
            TableRelation = Item."No.";
            ValidateTableRelation = true;
        }
        field(50303; "AFDP Item Description"; Text[100])
        {
            Caption = 'Item Description';
            ToolTip = 'Item Description';
            FieldClass = FlowField;
            CalcFormula = lookup(Item.Description where("No." = field("AFDP Item No.")));
            Editable = false;
        }
        field(50310; "AFDP Shelf Life"; DateFormula)
        {
            DataClassification = CustomerContent;
            Caption = 'Shelf Life';
        }
    }

    keys
    {
        key(Key1; "AFDP Customer No.", "AFDP Item No.")
        {
            Clustered = true;
        }
    }
}

//AFDP 07/19/2025 'T0005-Customer Lot Preference'

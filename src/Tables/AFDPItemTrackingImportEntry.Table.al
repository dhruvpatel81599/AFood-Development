namespace AFood.DP.AFoodDevelopment;
table 50300 "AFDP Item Tracking ImportEntry"
{
    Caption = 'Item Tracking Import Entry';
    DataClassification = CustomerContent;
    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
        }
        field(3; "PO No."; Code[20])
        {
            Caption = 'PO Number';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(4; "PO Date"; Date)
        {
            Caption = 'PO Date';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(6; "Vendor Item No."; Code[20])
        {
            Caption = 'Vendor Item No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(7; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(8; "Quantity Shipped"; Decimal)
        {
            Caption = 'Quantity Shipped';
            DecimalPlaces = 0 : 5;
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(10; "Lot Number"; Code[20])
        {
            Caption = 'Lot Number';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(12; "Expiration Date"; Date)
        {
            Caption = 'Expiration Date';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(13; "Production Date"; Date)
        {
            Caption = 'Production Date';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(20; "Tracking Created"; Boolean)
        {
            Caption = 'Tracking Created';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
}
//AFDP 06/06/2025 'Item Tracking Import Tools'

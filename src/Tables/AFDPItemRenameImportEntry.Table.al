namespace AFood.DP.AFoodDevelopment;
table 50301 "AFDP Item Rename Import Entry"
{
    Caption = 'Item Tracking Import Entry';
    DataClassification = CustomerContent;
    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
        }
        field(3; "Current Item No."; Code[20])
        {
            Caption = 'Current Item No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(4; "New Item No."; Code[20])
        {
            Caption = 'New Item No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(6; "Item Found"; Boolean)
        {
            Caption = 'Item Found';
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
//AFDP 06/11/2025 'T0006-Item Number Rename'

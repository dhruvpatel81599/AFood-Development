namespace AFood.DP.AFoodDevelopment;
using Microsoft.Warehouse.Ledger;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Foundation.NoSeries;
using Microsoft.Inventory.Counting.Journal;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Location;
using Microsoft.Warehouse.Journal;
using Microsoft.Warehouse.Setup;
using Microsoft.Warehouse.Structure;
using System.Security.AccessControl;
table 50302 "AFDP Warehouse Entries"
{
    Caption = 'Warehouse Entry';
    DrillDownPageID = "Warehouse Entries";
    LookupPageID = "Warehouse Entries";
    Permissions = TableData "Warehouse Entry" = ri;
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
        }
        field(2; "Journal Batch Name"; Code[10])
        {
            Caption = 'Journal Batch Name';
        }
        field(3; "Line No."; Integer)
        {
            BlankZero = true;
            Caption = 'Line No.';
        }
        field(4; "Registering Date"; Date)
        {
            Caption = 'Registering Date';
        }
        field(5; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;
        }
        field(6; "Zone Code"; Code[10])
        {
            Caption = 'Zone Code';
            TableRelation = Zone.Code where("Location Code" = field("Location Code"));
        }
        field(7; "Bin Code"; Code[20])
        {
            Caption = 'Bin Code';
            TableRelation = Bin.Code where("Location Code" = field("Location Code"));
        }
        field(8; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(9; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;
        }
        field(10; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
        }
        field(11; "Qty. (Base)"; Decimal)
        {
            Caption = 'Qty. (Base)';
            DecimalPlaces = 0 : 5;
        }
        field(12; "Warehouse Register No."; Integer)
        {
            Caption = 'Warehouse Register No.';
            Editable = false;
            TableRelation = "Warehouse Register";
        }
        field(13; "SIFT Bucket No."; Integer)
        {
            Caption = 'SIFT Bucket No.';
            ToolTip = 'Specifies an automatically generated number that is used by the system to enable better concurrency.';
            Editable = false;
        }
        field(20; "Source Type"; Integer)
        {
            Caption = 'Source Type';
        }
        field(21; "Source Subtype"; Option)
        {
            Caption = 'Source Subtype';
            OptionCaption = '0,1,2,3,4,5,6,7,8,9,10';
            OptionMembers = "0","1","2","3","4","5","6","7","8","9","10";
        }
        field(22; "Source No."; Code[20])
        {
            Caption = 'Source No.';
        }
        field(23; "Source Line No."; Integer)
        {
            BlankZero = true;
            Caption = 'Source Line No.';
        }
        field(24; "Source Subline No."; Integer)
        {
            Caption = 'Source Subline No.';
        }
        field(25; "Source Document"; Enum "Warehouse Journal Source Document")
        {
            BlankZero = true;
            Caption = 'Source Document';
        }
        field(26; "Source Code"; Code[10])
        {
            Caption = 'Source Code';
            TableRelation = "Source Code";
        }
        field(29; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            TableRelation = "Reason Code";
        }
        field(33; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            TableRelation = "No. Series";
        }
        field(35; "Bin Type Code"; Code[10])
        {
            Caption = 'Bin Type Code';
            TableRelation = "Bin Type";
        }
        field(40; Cubage; Decimal)
        {
            Caption = 'Cubage';
            DecimalPlaces = 0 : 5;
        }
        field(41; Weight; Decimal)
        {
            Caption = 'Weight';
            DecimalPlaces = 0 : 5;
        }
        field(45; "Journal Template Name"; Code[10])
        {
            Caption = 'Journal Template Name';
        }
        field(50; "Whse. Document No."; Code[20])
        {
            Caption = 'Whse. Document No.';
        }
        field(51; "Whse. Document Type"; Enum "Warehouse Journal Document Type")
        {
            Caption = 'Whse. Document Type';
        }
        field(52; "Whse. Document Line No."; Integer)
        {
            BlankZero = true;
            Caption = 'Whse. Document Line No.';
        }
        field(55; "Entry Type"; Option)
        {
            Caption = 'Entry Type';
            OptionCaption = 'Negative Adjmt.,Positive Adjmt.,Movement';
            OptionMembers = "Negative Adjmt.","Positive Adjmt.",Movement;
        }
        field(60; "Reference Document"; Enum "Whse. Reference Document Type")
        {
            Caption = 'Reference Document';
        }
        field(61; "Reference No."; Code[20])
        {
            Caption = 'Reference No.';
        }
        field(67; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
        }
        field(5402; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code where("Item No." = field("Item No."));
        }
        field(5404; "Qty. per Unit of Measure"; Decimal)
        {
            Caption = 'Qty. per Unit of Measure';
            DecimalPlaces = 0 : 5;
            InitValue = 1;
        }
        field(5407; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = "Item Unit of Measure".Code where("Item No." = field("Item No."));
        }
        field(6500; "Serial No."; Code[50])
        {
            Caption = 'Serial No.';
        }
        field(6501; "Lot No."; Code[50])
        {
            Caption = 'Lot No.';
        }
        field(6502; "Warranty Date"; Date)
        {
            Caption = 'Warranty Date';
        }
        field(6503; "Expiration Date"; Date)
        {
            Caption = 'Expiration Date';
        }
        field(6515; "Package No."; Code[50])
        {
            Caption = 'Package No.';
            CaptionClass = '6,1';
        }
        field(7380; "Phys Invt Counting Period Code"; Code[10])
        {
            Caption = 'Phys Invt Counting Period Code';
            Editable = false;
            TableRelation = "Phys. Invt. Counting Period";
        }
        field(7381; "Phys Invt Counting Period Type"; Option)
        {
            Caption = 'Phys Invt Counting Period Type';
            Editable = false;
            OptionCaption = ' ,Item,SKU';
            OptionMembers = " ",Item,SKU;
        }
        field(7382; Dedicated; Boolean)
        {
            Caption = 'Dedicated';
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Reference No.", "Registering Date")
        {
        }
        key(Key3; "Source Type", "Source Subtype", "Source No.", "Source Line No.", "Source Subline No.", "Source Document", "Bin Code")
        {
        }
        key(Key4; "Serial No.", "Item No.", "Variant Code", "Location Code", "Bin Code")
        {
            IncludedFields = "Qty. (Base)";
        }
        key(Key5; "Item No.", "Bin Code", "Location Code", "Variant Code", "Unit of Measure Code", "Lot No.", "Serial No.", "Entry Type", Dedicated, "Package No.", "Bin Type Code", "SIFT Bucket No.")
        {
            SumIndexFields = "Qty. (Base)", Cubage, Weight, Quantity;
        }
        key(Key7; "Bin Code", "Location Code", "Item No.", "SIFT Bucket No.")
        {
            SumIndexFields = Cubage, Weight, Quantity, "Qty. (Base)";
        }
        key(Key8; "Location Code", "Item No.", "Variant Code", "Zone Code", "Bin Code", "Lot No.", "SIFT Bucket No.")
        {
            SumIndexFields = Quantity, "Qty. (Base)";
        }
        key(key9; "Warehouse Register No.")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Entry No.", "Registering Date", "Location Code", "Item No.")
        {
        }
    }
}

//AFDP 06/28/2025 'T0008-Receiving Enhancements'

namespace AFood.DP.AFoodDevelopment;
using Microsoft.Inventory.Setup;
using Microsoft.Inventory.Journal;
tableextension 50305 "AFDP Inventory Setup" extends "Inventory Setup"
{
    fields
    {
        //>>AFDP 05/30/2025 'Short Orders'
        field(50300; "AFDP Enable Sales Short"; Boolean)
        {
            Caption = 'Enable Sales Short';
            DataClassification = CustomerContent;
        }
        field(50301; "AFDP Enable Purchase Short"; Boolean)
        {
            Caption = 'Enable Purchase Short';
            DataClassification = CustomerContent;
        }
        //<<AFDP 05/30/2025 'Short Orders'
        //>>AFDP 06/28/2025 'T0008-Receiving Enhancements'
        field(50302; "AFDP Receiving Template Name"; Code[10])
        {
            Caption = 'Receiving Reclass Template Name';
            TableRelation = "Item Journal Template".Name where(Type = const(Transfer));
            ValidateTableRelation = true;
        }
        field(50303; "AFDP Receiving Batch Name"; Code[10])
        {
            Caption = 'Receiving Reclass Batch Name';
            TableRelation = "Item Journal Batch".Name where("Journal Template Name" = field("AFDP Receiving Template Name"));
            ValidateTableRelation = true;
        }
        //<<AFDP 06/28/2025 'T0008-Receiving Enhancements'
    }
}

//AFDP 05/30/2025 'Short Orders'
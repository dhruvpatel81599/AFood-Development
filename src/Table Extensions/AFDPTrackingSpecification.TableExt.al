namespace AFood.DP.AFoodDevelopment;
using Microsoft.Inventory.Item;
using Microsoft.Warehouse.Journal;
using Microsoft.Inventory.Tracking;
tableextension 50318 "AFDP Tracking Specification" extends "Tracking Specification"
{
    fields
    {
        //>>AFDP 08/26/2025 'T0022-Plant Number'
        field(50300; "AFDP Plant Number Mandatory"; Boolean)
        {
            Caption = 'Plant Number Mandatory';
            // Editable = false;
        }
        field(50301; "AFDP Default Plant Number"; Code[20])
        {
            Caption = 'Default Plant Number';
            trigger OnValidate()
            var
                WMSManagement: Codeunit "WMS Management";
            begin
                if "AFDP Default Plant Number" <> xRec."AFDP Default Plant Number" then begin
                    TestField("Quantity Handled (Base)", 0);
                    TestField("Appl.-from Item Entry", 0);
                    WMSManagement.CheckItemTrackingChange(Rec, xRec);
                    InitExpirationDate();
                end;
            end;
        }
        //<<AFDP 08/26/2025 'T0022-Plant Number'        
    }
}

//AFDP 08/26/2025 'T0022-Plant Number'
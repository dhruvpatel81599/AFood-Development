namespace AFood.DP.AFoodDevelopment;
using Microsoft.Sales.History;
using Microsoft.Warehouse.Document;
pageextension 50321 "AFDP Whse Shipment Subform" extends "Whse. Shipment Subform"
{
    layout
    {
        //>>AFDP 08/04/2025 'T0014-Warehouse Shipment – Edit Qty'
        addafter(Quantity)
        {
            field("AFDP Cases to Allocate"; Rec."AFDP Cases to Allocate")
            {
                ApplicationArea = All;
                Caption = 'Cases to Allocate';
                ToolTip = 'Specifies the number of cases to allocate for this line.';
            }
            field("AFDP Qty. to Allocate"; Rec."AFDP Qty. to Allocate")
            {
                ApplicationArea = All;
                Caption = 'Qty. to Allocate';
                ToolTip = 'Specifies the quantity to allocate for this line.';
            }
        }
        //<<AFDP 08/04/2025 'T0014-Warehouse Shipment – Edit Qty'
    }
    trigger OnAfterGetRecord()
    begin
        // Ensure the fields are updated when the record is retrieved
        Rec."AFDP Cases to Allocate" := rec.Units_DU_TSL;
        Rec."AFDP Qty. to Allocate" := Rec.Quantity;
    end;
}

//AFDP 08/04/2025 'T0014-Warehouse Shipment – Edit Qty'
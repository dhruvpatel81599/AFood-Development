namespace AFood.DP.AFoodDevelopment;
using Microsoft.Warehouse.Reports;
using Microsoft.Warehouse.Setup;

reportextension 50300 "AFDP Picking List" extends "Picking List"
{
    dataset
    {
        add(WhseActLine)
        {
            column(Units_DU_TSL; Units_DU_TSL) { }
        }
        modify(WhseActLine)
        {
            trigger OnBeforeAfterGetRecord()
            begin
                if WhseActLine."Action Type" <> WhseActLine."Action Type"::Take then
                    CurrReport.Skip();
            end;
        }
    }

    requestpage
    {
        // Add changes to the requestpage here
    }

    rendering
    {
        layout(AFDPPickingList)
        {
            Type = RDLC;
            LayoutFile = './src/Reports Extensions/AFDPPickingList.rdl';
        }
    }
}

//AFDP 08/11/2025 'T0018-AFoods-Picking List Report'
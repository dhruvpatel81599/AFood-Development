namespace AFood.DP.AFoodDevelopment;
using Microsoft.Inventory.Location;
using Microsoft.Warehouse.Structure;
tableextension 50311 "AFDP Location" extends Location
{
    fields
    {
        field(50300; "AFDP Default Missing Bin"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Default Missing Bin';
            ToolTip = 'Specify the default missing bin';
            TableRelation = Bin.Code where("Location Code" = field("Code"));
        }
    }
}

//AFDP 06/22/2025 'T0008-Receiving Enhancements'
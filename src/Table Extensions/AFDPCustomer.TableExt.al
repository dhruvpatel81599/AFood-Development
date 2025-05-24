namespace AFood.DP.AFoodDevelopment;

using Microsoft.Sales.Customer;
tableextension 50300 "AFDP Customer" extends Customer
{
    fields
    {
        field(50300; "AFDP ItemCodeType"; Enum "AFDP Item Code Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Item Code Type';
            ToolTip = 'Specify Item code type';
        }
    }
}

//AFDP 05/24/2025 'Item Code Type'
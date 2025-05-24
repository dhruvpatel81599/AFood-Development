codeunit 50300 "AFDP Sales Event Management"
{

    #region Global Variables
    var
        ItemCode: Code[50];
        ItemDescription1: Text[100];
        ItemDescription2: text[50];
    #endregion Global Variables

    #region EventSubcribers
    //>>AFDP 05/24/2025 'Item Code Type'
    [EventSubscriber(ObjectType::Report, Report::"AFDP Sales Quote NA", 'OnAfterCalculateSalesTax', '', false, false)]
    local procedure SalesQuoteNA_OnAfterCalculateSalesTax(var SalesHeaderParm: Record "Sales Header"; var SalesLineParm: Record "Sales Line"; var TaxAmount: Decimal; var TaxLiable: Decimal)
    var
        Customer: Record Customer;
    begin
        Clear(ItemCode);
        Clear(ItemDescription1);
        Clear(ItemDescription2);
        if Customer.get(SalesHeaderParm."Bill-to Customer No.") then
            if Customer."AFDP ItemCodeType" = Customer."AFDP ItemCodeType"::"Item Reference" then
                GetItemCodeForCustomer(SalesLineParm."No.", SalesLineParm."Variant Code", SalesLineParm."Unit of Measure Code", SalesHeaderParm."Bill-to Customer No.");
        if ItemCode <> '' then begin
            SalesLineParm."No." := Format(ItemCode);
            SalesLineParm.Description := ItemDescription1;
            SalesLineParm."Description 2" := ItemDescription2
        end;
    end;
    //<<AFDP 05/24/2025 'Item Code Type'
    #endregion EventSubscribers

    #region Functions
    //>>AFDP 05/24/2025 'Item Code Type'
    // local procedure GetItemCodeForCustomer(ItemNo: Code[50]; VariantCode: code[10]; UOMCode: Code[10]; ItemCodeType: Enum "AFDP Item Code Type"; ReferenceTypeNo: Code[20]) ItemCode: Code[50]
    local procedure GetItemCodeForCustomer(ItemNo: Code[50]; VariantCode: code[10]; UOMCode: Code[10]; ReferenceTypeNo: Code[20])
    var
        ItemReference: Record "Item Reference";
    begin
        ItemReference.Reset();
        ItemReference.SetRange("Item No.", ItemNo);
        ItemReference.SetRange("Variant Code", VariantCode);
        ItemReference.SetRange("Unit of Measure", UOMCode);
        ItemReference.SetRange("Reference Type", "Item Reference Type"::"Customer");
        ItemReference.SetRange("Reference Type No.", ReferenceTypeNo);
        if ItemReference.FindFirst() then begin
            ItemCode := ItemReference."Reference No.";
            ItemDescription1 := ItemReference.Description;
            ItemDescription2 := ItemReference."Description 2";
        end;
    end;
    //<<AFDP 05/24/2025 'Item Code Type'
    #endregion Functions
}

//AFDP 05/24/2025 'Item Code Type'


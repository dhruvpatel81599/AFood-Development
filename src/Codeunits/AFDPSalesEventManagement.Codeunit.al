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
    local procedure AFDPSalesQuoteNA_OnAfterCalculateSalesTax(var SalesHeaderParm: Record "Sales Header"; var SalesLineParm: Record "Sales Line"; var TaxAmount: Decimal; var TaxLiable: Decimal)
    var
        Customer: Record Customer;
    begin
        Clear(ItemCode);
        Clear(ItemDescription1);
        Clear(ItemDescription2);
        if Customer.get(SalesHeaderParm."Bill-to Customer No.") then
            if Customer."AFDP ItemCodeType" = Customer."AFDP ItemCodeType"::"Item Reference" then
                GetItemReferenceCodeForCustomer(SalesLineParm."No.", SalesLineParm."Variant Code", SalesLineParm."Unit of Measure Code", SalesHeaderParm."Bill-to Customer No.")
            else
                if Customer."AFDP ItemCodeType" = Customer."AFDP ItemCodeType"::GTIN then
                    GetGTINCodeForItem(SalesLineParm."No.");

        if ItemCode <> '' then begin
            SalesLineParm."No." := Format(ItemCode);
            SalesLineParm.Description := ItemDescription1;
            SalesLineParm."Description 2" := ItemDescription2
        end;
    end;

    [EventSubscriber(ObjectType::Report, Report::"AFDP Standard Sales Invoice", 'OnAfterCalculateSalesTax', '', false, false)]
    local procedure AFDPStandardSalesInvoice_OnAfterCalculateSalesTax(var SalesInvoiceHeader: Record "Sales Invoice Header"; var SalesInvoiceLine: Record "Sales Invoice Line"; var TotalAmount: Decimal; var TotalAmountVAT: Decimal; var TotalAmountInclVAT: Decimal)
    var
        Customer: Record Customer;
    begin
        Clear(ItemCode);
        Clear(ItemDescription1);
        Clear(ItemDescription2);
        if Customer.get(SalesInvoiceHeader."Bill-to Customer No.") then
            if Customer."AFDP ItemCodeType" = Customer."AFDP ItemCodeType"::"Item Reference" then
                GetItemReferenceCodeForCustomer(SalesInvoiceLine."No.", SalesInvoiceLine."Variant Code", SalesInvoiceLine."Unit of Measure Code", SalesInvoiceLine."Bill-to Customer No.")
            else
                if Customer."AFDP ItemCodeType" = Customer."AFDP ItemCodeType"::GTIN then
                    GetGTINCodeForItem(SalesInvoiceLine."No.");

        if ItemCode <> '' then begin
            SalesInvoiceLine."No." := Format(ItemCode);
            SalesInvoiceLine.Description := ItemDescription1;
            SalesInvoiceLine."Description 2" := ItemDescription2
        end;
    end;

    [EventSubscriber(ObjectType::Report, Report::"AFDP Sales-Pro Forma Invoice", 'OnBeforeLineOnAfterGetRecord', '', false, false)]
    local procedure AFDPSalesProFormaInvoice_OnBeforeLineOnAfterGetRecord(SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    var
        Customer: Record Customer;
    begin
        Clear(ItemCode);
        Clear(ItemDescription1);
        Clear(ItemDescription2);
        if Customer.get(SalesHeader."Bill-to Customer No.") then
            if Customer."AFDP ItemCodeType" = Customer."AFDP ItemCodeType"::"Item Reference" then
                GetItemReferenceCodeForCustomer(SalesLine."No.", SalesLine."Variant Code", SalesLine."Unit of Measure Code", SalesLine."Bill-to Customer No.")
            else
                if Customer."AFDP ItemCodeType" = Customer."AFDP ItemCodeType"::GTIN then
                    GetGTINCodeForItem(SalesLine."No.");

        if ItemCode <> '' then begin
            SalesLine."No." := Format(ItemCode);
            SalesLine.Description := ItemDescription1;
            SalesLine."Description 2" := ItemDescription2
        end;
    end;
    //<<AFDP 05/24/2025 'Item Code Type'
    #endregion EventSubscribers

    #region Functions
    //>>AFDP 05/24/2025 'Item Code Type'    
    local procedure GetItemReferenceCodeForCustomer(ItemNo: Code[50]; VariantCode: code[10]; UOMCode: Code[10]; ReferenceTypeNo: Code[20])
    var
        ItemReference: Record "Item Reference";
    begin
        ItemReference.Reset();
        ItemReference.SetRange("Item No.", ItemNo);
        // ItemReference.SetRange("Variant Code", VariantCode);
        // ItemReference.SetRange("Unit of Measure", UOMCode);
        ItemReference.SetRange("Reference Type", "Item Reference Type"::"Customer");
        ItemReference.SetRange("Reference Type No.", ReferenceTypeNo);
        if ItemReference.FindFirst() then begin
            ItemCode := ItemReference."Reference No.";
            ItemDescription1 := ItemReference.Description;
            ItemDescription2 := ItemReference."Description 2";
        end else begin
            ItemReference.SetRange("Reference Type No.");
            if ItemReference.FindFirst() then begin
                ItemCode := ItemReference."Reference No.";
                ItemDescription1 := ItemReference.Description;
                ItemDescription2 := ItemReference."Description 2";
            end;
        end;
    end;

    local procedure GetGTINCodeForItem(ItemNo: Code[50])
    var
        Item: Record item;
    begin
        If item.get(ItemNo) then
            if item.GTIN <> '' then begin
                ItemCode := item.GTIN;
                ItemDescription1 := item.Description;
                ItemDescription2 := item."Description 2";
            end;
    end;
    //<<AFDP 05/24/2025 'Item Code Type'
    #endregion Functions
}

//AFDP 05/24/2025 'Item Code Type'


namespace AFood.DP.AFoodDevelopment;
using Microsoft.CRM.Contact;
using Microsoft.CRM.Team;
using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Foundation.PaymentTerms;
using KCP.AFI.AFICustom;
using Microsoft.Sales.Document;
using Microsoft.Finance.VAT.Calculation;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.Company;
using Microsoft.Foundation.Shipping;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Location;
using Microsoft.Sales.Customer;
using Microsoft.Utilities;
using System.Globalization;
using System.Reflection;
using System.Text;
using System.Utilities;
report 50302 "AFDP Sales-Pro Forma Invoice"
{
    ApplicationArea = all;
    UsageCategory = ReportsAndAnalysis;
    DefaultLayout = RDLC;
    RDLCLayout = './src/Reports/AFDPSalesProformaInvoice.rdl';
    Caption = 'Pro Forma Invoice';

    dataset
    {
        dataitem(Header; "Sales Header")
        {
            DataItemTableView = sorting("Document Type", "No.");
            RequestFilterFields = "No.", "Sell-to Customer No.", "No. Printed";
            RequestFilterHeading = 'Pro Forma Invoice';
            column(DocumentDate; Format("Document Date", 0, 4))
            {
            }
            column(CompanyPicture; CompanyInformation.Picture)
            {
            }
            column(CompanyEMail; CompanyInformation."E-Mail")
            {
            }
            column(CompanyHomePage; CompanyInformation."Home Page")
            {
            }
            column(CompanyPhoneNo; CompanyInformation."Phone No.")
            {
            }
            column(CompanyVATRegNo; CompanyInformation.GetVATRegistrationNumber())
            {
            }
            column(CompanyAddress1; CompanyAddress[1])
            {
            }
            column(CompanyAddress2; CompanyAddress[2])
            {
            }
            column(CompanyAddress3; CompanyAddress[3])
            {
            }
            column(CompanyAddress4; CompanyAddress[4])
            {
            }
            column(CompanyAddress5; CompanyAddress[5])
            {
            }
            column(CompanyAddress6; CompanyAddress[6])
            {
            }
            column(CompanyAddress7; CompanyAddress[7])
            {
            }
            column(CompanyAddress8; CompanyAddress[8])
            {
            }
            column(CustomerAddress1; CustomerAddress[1])
            {
            }
            column(CustomerAddress2; CustomerAddress[2])
            {
            }
            column(CustomerAddress3; CustomerAddress[3])
            {
            }
            column(CustomerAddress4; CustomerAddress[4])
            {
            }
            column(CustomerAddress5; CustomerAddress[5])
            {
            }
            column(CustomerAddress6; CustomerAddress[6])
            {
            }
            column(CustomerAddress7; CustomerAddress[7])
            {
            }
            column(CustomerAddress8; CustomerAddress[8])
            {
            }
            column(SellToContactPhoneNoLbl; SellToContactPhoneNoLbl)
            {
            }
            column(SellToContactMobilePhoneNoLbl; SellToContactMobilePhoneNoLbl)
            {
            }
            column(SellToContactEmailLbl; SellToContactEmailLbl)
            {
            }
            column(BillToContactPhoneNoLbl; BillToContactPhoneNoLbl)
            {
            }
            column(BillToContactMobilePhoneNoLbl; BillToContactMobilePhoneNoLbl)
            {
            }
            column(BillToContactEmailLbl; BillToContactEmailLbl)
            {
            }
            column(SellToContactPhoneNo; SellToContact."Phone No.")
            {
            }
            column(SellToContactMobilePhoneNo; SellToContact."Mobile Phone No.")
            {
            }
            column(SellToContactEmail; SellToContact."E-Mail")
            {
            }
            column(BillToContactPhoneNo; BillToContact."Phone No.")
            {
            }
            column(BillToContactMobilePhoneNo; BillToContact."Mobile Phone No.")
            {
            }
            column(BillToContactEmail; BillToContact."E-Mail")
            {
            }
            column(YourReference; "Your Reference")
            {
            }
            column(ExternalDocumentNo; "External Document No.")
            {
            }
            column(DocumentNo; "No.")
            {
            }
            column(CompanyLegalOffice; LegalOfficeTxt)
            {
            }
            column(SalesPersonName; SalespersonPurchaserName)
            {
            }
            column(ShipmentMethodDescription; ShipmentMethodDescription)
            {
            }
            column(Currency; CurrencyCode)
            {
            }
            column(CustomerVATRegNo; GetCustomerVATRegistrationNumber())
            {
            }
            column(CustomerVATRegistrationNoLbl; GetCustomerVATRegistrationNumberLbl())
            {
            }
            column(PageLbl; PageLbl)
            {
            }
            column(DocumentTitleLbl; DocumentCaption())
            {
            }
            column(YourReferenceLbl; FieldCaption("Your Reference"))
            {
            }
            column(ExternalDocumentNoLbl; FieldCaption("External Document No."))
            {
            }
            column(CompanyLegalOfficeLbl; LegalOfficeLbl)
            {
            }
            column(SalesPersonLbl; SalesPersonLblText)
            {
            }
            column(EMailLbl; CompanyInformation.FieldCaption("E-Mail"))
            {
            }
            column(HomePageLbl; CompanyInformation.FieldCaption("Home Page"))
            {
            }
            column(CompanyPhoneNoLbl; CompanyInformation.FieldCaption("Phone No."))
            {
            }
            column(ShipmentMethodDescriptionLbl; DummyShipmentMethod.TableCaption())
            {
            }
            column(CurrencyLbl; DummyCurrency.TableCaption())
            {
            }
            column(ItemLbl; Item.TableCaption())
            {
            }
            column(TariffLbl; Item.FieldCaption("Tariff No."))
            {
            }
            column(UnitPriceLbl; Item.FieldCaption("Unit Price"))
            {
            }
            column(CountryOfManufactuctureLbl; CountryOfManufactuctureLbl)
            {
            }
            column(AmountLbl; Line.FieldCaption(Amount))
            {
            }
            column(VATPctLbl; Line.FieldCaption("VAT %"))
            {
            }
            column(VATAmountLbl; DummyVATAmountLine.VATAmountText())
            {
            }
            column(TotalWeightLbl; TotalWeightLbl)
            {
            }
            column(TotalAmountLbl; TotalAmountLbl)
            {
            }
            column(TotalAmountInclVATLbl; TotalAmountInclVATLbl)
            {
            }
            column(QuantityLbl; Line.FieldCaption(Quantity))
            {
            }
            column(NetWeightLbl; Line.FieldCaption("Net Weight"))
            {
            }
            column(DeclartionLbl; DeclartionLbl)
            {
            }
            column(SignatureLbl; SignatureLbl)
            {
            }
            column(SignatureNameLbl; SignatureNameLbl)
            {
            }
            column(SignaturePositionLbl; SignaturePositionLbl)
            {
            }
            column(VATRegNoLbl; CompanyInformation.GetVATRegistrationNumberLbl())
            {
            }
            column(ShowWorkDescription; ShowWorkDescription) { }
            //>>AFDP 05/28/2025 'Item Code Type'
            column(AFIDocumentTitle; DocumentTitle) { }
            column(AFICompanyInfo1; AFICompanyInfo.Get(1)) { }
            column(AFICompanyInfo2; AFICompanyInfo.Get(2)) { }
            column(AFICompanyInfo3; AFICompanyInfo.Get(3)) { }
            column(AFICompanyInfo4; AFICompanyInfo.Get(4)) { }
            column(AFISellTo1; AFISellTo.Get(1)) { }
            column(AFISellTo2; AFISellTo.Get(2)) { }
            column(AFISellTo3; AFISellTo.Get(3)) { }
            column(AFISellTo4; AFISellTo.Get(4)) { }
            column(AFIShipTo1; AFIShipTo.Get(1)) { }
            column(AFIShipTo2; AFIShipTo.Get(2)) { }
            column(AFIShipTo3; AFIShipTo.Get(3)) { }
            column(AFIShipTo4; AFIShipTo.Get(4)) { }
            column(AFIShipTo5; AFIShipTo.Get(5)) { }
            column(AFIDocNo; "No.") { }
            column(AFIDocumentDate; "Document Date") { }
            column(AFIDeliveryDate; "Shipment Date") { }
            column(AFIPurchOrder; "External Document No.") { }
            column(AFIIncoterm; Incoterms) { }
            column(AFICountryOfOriginLbl; CountryOfOriginLbl) { }
            column(AFICountryOfOrigin; CountryOfOrigin) { }
            column(AFIShipVia; ReportHelperFunctionsAFI.GetShippingAgentName(Header."Shipping Agent Code")) { }
            // column(AFITerms; ReportHelperFunctionsAFI.GetPaymentTermstName(Header."Payment Terms Code")) { }
            column(AFITerms; GetPaymentTermstName(Header."Payment Terms Code")) { }
            column(AFICustomer; "Bill-to Customer No.") { }
            column(AFISalesPerson; "Salesperson Code") { }
            column(AFISubtotal; DocSubtotal) { }
            column(AFIDiscount; DocDiscount) { }
            column(AFITax; DocTax) { }
            column(AFITotal; DocTotal) { }
            column(AFISubjectTotal; DocSubjectTotal) { }
            column(AFIExemptTotal; DocExemptTotal) { }
            column(AFITotalCases; DocTotalCases) { }
            //<<AFDP 05/28/2025 'Item Code Type'
            dataitem(Line; "Sales Line")
            {
                DataItemLink = "Document Type" = field("Document Type"), "Document No." = field("No.");
                DataItemLinkReference = Header;
                DataItemTableView = sorting("Document No.", "Line No.");
                column(SalesLineNo; "No.")
                {
                }
                column(ItemDescription; Description + ' ' + "Description 2")
                {
                }
                column(CountryOfManufacturing; Item."Country/Region of Origin Code")
                {
                }
                column(Tariff; Item."Tariff No.")
                {
                }
                column(Quantity; "Qty. to Invoice")
                {
                }
                column(Price; FormattedLinePrice)
                {
                    AutoFormatExpression = "Currency Code";
                    AutoFormatType = 2;
                }
                column(NetWeight; "Net Weight")
                {
                }
                column(LineAmount; FormattedLineAmount)
                {
                    AutoFormatExpression = "Currency Code";
                    AutoFormatType = 1;
                }
                column(VATPct; "VAT %")
                {
                }
                column(VATAmount; FormattedVATAmount)
                {
                }
                //>>AFDP 05/28/2025 'Item Code Type'
                column(AFIItemNo; ItemNo) { }
                column(AFIDescription; LineDescription) { }
                column(AFINetWeight; ItemNetWeight) { }
                column(AFIPricePer; ItemBaseUOM) { }
                column(AFIUnitPrice; LineUnitPrice) { }
                column(AFITotalPrice; TotLineAmount) { }
                column(AFIUnits; LineQuantity) { }
                //<<AFDP 05/28/2025 'Item Code Type'

                trigger OnAfterGetRecord()
                var
                    Location: Record Location;
                    _Item: Record Item;
                    AutoFormatType: Enum "Auto Format";
                begin
                    GetItemForRec("No.");
                    ItemNo := Line."No.";  //AFDP 05/28/2025 'Item Code Type'                    
                    OnBeforeLineOnAfterGetRecord(Header, Line);

                    if IsShipment() then
                        if Location.RequireShipment("Location Code") and ("Quantity Shipped" = 0) then
                            "Qty. to Invoice" := Quantity;

                    if FormatDocument.HideDocumentLine(HideLinesWithZeroQuantity, Line, FieldNo("Qty. to Invoice")) then
                        CurrReport.Skip();

                    if Quantity = 0 then begin
                        LinePrice := "Unit Price";
                        LineAmount := 0;
                        VATAmount := 0;
                    end else begin
                        LinePrice := Round(Amount / Quantity, Currency."Unit-Amount Rounding Precision");
                        LineAmount := Round(Amount * "Qty. to Invoice" / Quantity, Currency."Amount Rounding Precision");
                        if Currency.Code = '' then
                            VATAmount := "Amount Including VAT" - Amount
                        else
                            VATAmount := Round(
                                Amount * "VAT %" / 100 * "Qty. to Invoice" / Quantity, Currency."Amount Rounding Precision");

                        TotalAmount += LineAmount;
                        TotalWeight += Round("Qty. to Invoice" * "Net Weight");
                        TotalVATAmount += VATAmount;
                        TotalAmountInclVAT += Round("Amount Including VAT" * "Qty. to Invoice" / Quantity, Currency."Amount Rounding Precision");
                    end;

                    FormattedLinePrice := Format(LinePrice, 0, AutoFormat.ResolveAutoFormat(AutoFormatType::UnitAmountFormat, CurrencyCode));
                    FormattedLineAmount := Format(LineAmount, 0, AutoFormat.ResolveAutoFormat(AutoFormatType::AmountFormat, CurrencyCode));
                    FormattedVATAmount := Format(VATAmount, 0, AutoFormat.ResolveAutoFormat(AutoFormatType::AmountFormat, CurrencyCode));
                    //>>AFDP 05/28/2025 'Item Code Type'
                    LineQuantity := ReportHelperFunctionsAFI.GetDocLineQuantity(Line.Units_DU_TSL, Line.Quantity);
                    // if (Line."Type" = Line."Type"::Item) and _Item.Get(Line."No.") then begin
                    if (Line."Type" = Line."Type"::Item) and _Item.Get(ItemNo) then begin
                        ItemBaseUOM := _Item."Base Unit of Measure";
                        ItemNetWeight := _Item."Net Weight" * LineQuantity;
                    end;
                    ItemNo := ReportHelperFunctionsAFI.SelectItemCode(Line."No.", ItemCodeType, 0, Header."Bill-to Customer No.");
                    LineDescription := ReportHelperFunctionsAFI.MergeText(Line.Description, Line."Description 2");
                    LineUnitPrice := Line."Unit Price";
                    TotLineAmount := Line.Amount;
                    if ItemNo = '' then begin
                        ItemNetWeight := 0;
                        ItemBaseUOM := '';
                        LineUnitPrice := 0;
                        TotLineAmount := 0;
                        LineQuantity := 0;
                    end;
                    //<<AFDP 05/28/2025 'Item Code Type'
                end;

                trigger OnPreDataItem()
                begin
                    TotalWeight := 0;
                    TotalAmount := 0;
                    TotalVATAmount := 0;
                    TotalAmountInclVAT := 0;
                    SetRange(Type, Type::Item);

                    OnAfterLineOnPreDataItem(Header, Line);
                end;
            }
            dataitem(WorkDescriptionLines; "Integer")
            {
                DataItemTableView = sorting(Number) where(Number = filter(1 .. 99999));
                column(WorkDescriptionLineNumber; Number) { }
                column(WorkDescriptionLine; WorkDescriptionLine) { }

                trigger OnAfterGetRecord()
                var
                    TypeHelper: Codeunit "Type Helper";
                begin
                    if WorkDescriptionInStream.EOS() then
                        CurrReport.Break();
                    WorkDescriptionLine := TypeHelper.ReadAsTextWithSeparator(WorkDescriptionInStream, TypeHelper.LFSeparator());
                end;

                trigger OnPostDataItem()
                begin
                    Clear(WorkDescriptionInStream)
                end;

                trigger OnPreDataItem()
                begin
                    if not ShowWorkDescription then
                        CurrReport.Break();
                    Header."Work Description".CreateInStream(WorkDescriptionInStream, TextEncoding::UTF8);
                end;
            }
            dataitem(Totals; "Integer")
            {
                MaxIteration = 1;
                column(TotalWeight; TotalWeight)
                {
                }
                column(TotalValue; FormattedTotalAmount)
                {
                }
                column(TotalVATAmount; FormattedTotalVATAmount)
                {
                }
                column(TotalAmountInclVAT; FormattedTotalAmountInclVAT)
                {
                }

                trigger OnPreDataItem()
                var
                    AutoFormatType: Enum "Auto Format";
                begin
                    FormattedTotalAmount := Format(TotalAmount, 0, AutoFormat.ResolveAutoFormat(AutoFormatType::AmountFormat, CurrencyCode));
                    FormattedTotalVATAmount := Format(TotalVATAmount, 0, AutoFormat.ResolveAutoFormat(AutoFormatType::AmountFormat, CurrencyCode));
                    FormattedTotalAmountInclVAT := Format(TotalAmountInclVAT, 0, AutoFormat.ResolveAutoFormat(AutoFormatType::AmountFormat, CurrencyCode));
                end;
            }

            trigger OnAfterGetRecord()
            begin
                CurrReport.Language := LanguageMgt.GetLanguageIdOrDefault("Language Code");
                CurrReport.FormatRegion := LanguageMgt.GetFormatRegionOrDefault("Format Region");
                FormatDocumentFields(Header);
                if SellToContact.Get("Sell-to Contact No.") then;
                if BillToContact.Get("Bill-to Contact No.") then;

                CalcFields("Work Description");
                ShowWorkDescription := "Work Description".HasValue();
                //>>AFDP 05/28/2025 'Item Code Type'
                AFICompanyInfo := ReportHelperFunctionsAFI.BuildCompanyInfo();
                AFISellTo := ReportHelperFunctionsAFI.BuilldSellToInfo(Header);
                AFIShipTo := ReportHelperFunctionsAFI.BuilldShipToInfo(Header);
                ReportHelperFunctionsAFI.GetSalesDocAmounts(Header, DocSubtotal, DocDiscount, DocTax, DocExemptTotal, DocSubjectTotal, DocTotal, DocTotalCases);
                Gettotalcase(Header, DocTotalCases);  //AFDP 06/04/2025 'Item Code Type'
                if ShowCountryOfOrigin then begin
                    CountryOfOriginLbl := 'Country of Origin';
                    CountryOfOrigin := 'USA'
                end
                else begin
                    CountryOfOriginLbl := '';
                    CountryOfOrigin := ''
                end;
                //<<AFDP 05/28/2025 'Item Code Type'
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    //>>AFDP 05/28/2025 'Item Code Type'
                    field("ShowCountryOfOrigin"; ShowCountryOfOrigin)
                    {
                        Caption = 'Show Country of Origin';
                        ApplicationArea = All;
                    }
                    // field("ItemCodeType"; ItemCodeType)
                    // {
                    //     Caption = 'Item Code Type';
                    //     ApplicationArea = All;
                    // }
                    //<<AFDP 05/28/2025 'Item Code Type'
                    field(HideLinesWithZeroQuantityControl; HideLinesWithZeroQuantity)
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies if the lines with zero quantity are printed.';
                        Caption = 'Hide lines with zero quantity';
                    }
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnInitReport()
    var
        IsHandled: Boolean;
    begin
        CompanyInformation.Get();
        CompanyInformation.CalcFields(Picture);

        IsHandled := false;
        OnInitReportForGlobalVariable(IsHandled, LegalOfficeTxt, LegalOfficeLbl);
    end;

    var
        DummyVATAmountLine: Record "VAT Amount Line";
        DummyShipmentMethod: Record "Shipment Method";
        DummyCurrency: Record Currency;
        AutoFormat: Codeunit "Auto Format";
        LanguageMgt: Codeunit Language;
        FormatDocument: Codeunit "Format Document";
        ReportHelperFunctionsAFI: Codeunit "Report Helper Functions AFI";
        CountryOfManufactuctureLbl: Label 'Country';
        TotalWeightLbl: Label 'Total Weight';
        SalespersonPurchaserName: Text;
        ShipmentMethodDescription: Text;
        // DocumentTitleLbl: Label 'Pro Forma Invoice';
        DocumentTitleLbl: Label 'Invoice';
        PageLbl: Label 'Page';
        DeclartionLbl: Label 'For customs purposes only.';
        SignatureLbl: Label 'For and on behalf of the above named company:';
        SignatureNameLbl: Label 'Name (in print) Signature';
        SignaturePositionLbl: Label 'Position in company';
        SellToContactPhoneNoLbl: Label 'Sell-to Contact Phone No.';
        SellToContactMobilePhoneNoLbl: Label 'Sell-to Contact Mobile Phone No.';
        SellToContactEmailLbl: Label 'Sell-to Contact E-Mail';
        BillToContactPhoneNoLbl: Label 'Bill-to Contact Phone No.';
        BillToContactMobilePhoneNoLbl: Label 'Bill-to Contact Mobile Phone No.';
        BillToContactEmailLbl: Label 'Bill-to Contact E-Mail';
        LegalOfficeTxt, LegalOfficeLbl : Text;
        //>>AFDP 05/28/2025 'Item Code Type'

        AFICompanyInfo: List of [Text[200]];
        AFISellTo: List of [Text[200]];
        AFIShipTo: List of [Text[200]];
        ItemNo: Code[50];
        ItemBaseUOM: Code[20];
        ItemNetWeight: Decimal;
        LineDescription: Text;
        LineQuantity: Decimal;
        LineUnitPrice: Decimal;
        TotLineAmount: Decimal;
        // DocumentTitle: Option "Pro Forma Invoice";
        DocumentTitle: Option "Invoice";
        ItemCodeType: Option GTIN,SKU,Reference;
        ShowCountryOfOrigin: Boolean;
        CountryOfOriginLbl: Text;
        CountryOfOrigin: Text;
        DocSubtotal: Decimal;
        DocDiscount: Decimal;
        DocTax: Decimal;
        DocTotal: Decimal;
        DocSubjectTotal: Decimal;
        DocExemptTotal: Decimal;
        DocTotalCases: Decimal;
    //<<AFDP 05/28/2025 'Item Code Type'

    protected var
        CompanyInformation: Record "Company Information";
        Item: Record Item;
        Currency: Record Currency;
        SellToContact: Record Contact;
        BillToContact: Record Contact;
        CompanyAddress: array[8] of Text[100];
        CustomerAddress: array[8] of Text[100];
        WorkDescriptionInStream: InStream;
        SalesPersonLblText: Text[50];
        TotalAmountLbl: Text[50];
        TotalAmountInclVATLbl: Text[50];
        FormattedLinePrice: Text;
        FormattedLineAmount: Text;
        FormattedVATAmount: Text;
        FormattedTotalAmount: Text;
        FormattedTotalVATAmount: Text;
        FormattedTotalAmountInclVAT: Text;
        WorkDescriptionLine: Text;
        CurrencyCode: Code[10];
        TotalWeight: Decimal;
        TotalAmount: Decimal;
        TotalVATAmount: Decimal;
        TotalAmountInclVAT: Decimal;
        LinePrice: Decimal;
        LineAmount: Decimal;
        VATAmount: Decimal;
        ShowWorkDescription: Boolean;
        HideLinesWithZeroQuantity: Boolean;

    local procedure FormatDocumentFields(SalesHeader: Record "Sales Header")
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        ShipmentMethod: Record "Shipment Method";
        ResponsibilityCenter: Record "Responsibility Center";
        Customer: Record Customer;
        FormatAddress: Codeunit "Format Address";
        TotalAmounExclVATLbl: Text[50];
    begin
        FormatAddress.SetLanguageCode(SalesHeader."Language Code");
        Customer.Get(SalesHeader."Sell-to Customer No.");
        FormatDocument.SetSalesPerson(SalespersonPurchaser, SalesHeader."Salesperson Code", SalesPersonLblText);
        SalespersonPurchaserName := SalespersonPurchaser.Name;

        FormatDocument.SetShipmentMethod(ShipmentMethod, SalesHeader."Shipment Method Code", SalesHeader."Language Code");
        ShipmentMethodDescription := ShipmentMethod.Description;

        FormatAddress.GetCompanyAddr(SalesHeader."Responsibility Center", ResponsibilityCenter, CompanyInformation, CompanyAddress);
        FormatAddress.SalesHeaderBillTo(CustomerAddress, SalesHeader);

        if SalesHeader."Currency Code" = '' then begin
            GeneralLedgerSetup.Get();
            GeneralLedgerSetup.TestField("LCY Code");
            CurrencyCode := GeneralLedgerSetup."LCY Code";
            Currency.InitRoundingPrecision();
        end else begin
            CurrencyCode := SalesHeader."Currency Code";
            Currency.Get(SalesHeader."Currency Code");
        end;

        FormatDocument.SetTotalLabels(SalesHeader."Currency Code", TotalAmountLbl, TotalAmountInclVATLbl, TotalAmounExclVATLbl);
    end;

    local procedure DocumentCaption(): Text
    var
        DocCaption: Text;
    begin
        OnBeforeGetDocumentCaption(Header, DocCaption);
        if DocCaption <> '' then
            exit(DocCaption);
        exit(DocumentTitleLbl);
    end;

    local procedure GetItemForRec(ItemNo: Code[20])
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeGetItemForRec(ItemNo, IsHandled);
        if IsHandled then
            exit;

        Item.Get(ItemNo);
    end;

    local procedure GetPaymentTermstName(PaymentTermsCode: Code[20]) PaymentTermsName: Text
    var
        PaymentTermst: Record "Payment Terms";
    begin
        if PaymentTermst.Get(PaymentTermsCode) then
            PaymentTermsName := PaymentTermst.Description
        else
            PaymentTermsName := PaymentTermsName;
        exit(PaymentTermsName);
    end;
    //>>AFDP 06/04/2025 'Item Code Type'
    procedure GetTotalCase(SalesHeader: Record "Sales Header"; var DocTotalCases1: Decimal)
    var
        SalesLine: Record "Sales Line";
    begin
        DocTotalCases1 := 0;
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetFilter("Unit of Measure Code", '<>UN');
        if SalesLine.FindSet() then
            repeat
                if SalesLine.Units_DU_TSL = 0 then
                    DocTotalCases1 += SalesLine.Quantity
                else
                    DocTotalCases1 += SalesLine.Units_DU_TSL;
            until SalesLine.Next() = 0;
    end;
    //<<AFDP 06/04/2025 'Item Code Type'

    [IntegrationEvent(false, false)]
    local procedure OnAfterLineOnPreDataItem(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetDocumentCaption(SalesHeader: Record "Sales Header"; var DocCaption: Text)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeGetItemForRec(ItemNo: Code[20]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeLineOnAfterGetRecord(SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInitReportForGlobalVariable(var IsHandled: Boolean; var LegalOfficeTxt: Text; var LegalOfficeLbl: Text)
    begin
    end;
}

//AFDP 05/28/2025 'Item Code Type'
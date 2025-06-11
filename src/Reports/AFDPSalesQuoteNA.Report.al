namespace AFood.DP.AFoodDevelopment;

using Microsoft.CRM.Contact;
using Microsoft.CRM.Interaction;
using Microsoft.CRM.Segment;
using Microsoft.CRM.Team;
using Microsoft.Finance.SalesTax;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.Company;
using Microsoft.Foundation.PaymentTerms;
using Microsoft.Foundation.Shipping;
using Microsoft.Inventory.Location;
using Microsoft.Sales.Comment;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Setup;
using Microsoft.Utilities;
using System.Globalization;
using System.Utilities;
using Microsoft.Sales.Document;
using Microsoft.Inventory.Item;
using KCP.AFI.AFICustom;
using Microsoft.Inventory.Item.Attribute;
report 50300 "AFDP Sales Quote NA"
{
    ApplicationArea = all;
    UsageCategory = ReportsAndAnalysis;
    DefaultLayout = RDLC;
    RDLCLayout = './src/Reports/AFDPSalesQuoteNA.rdl';
    Caption = 'Sales - Quote';

    dataset
    {
        dataitem("Sales Header"; "Sales Header")
        {
            DataItemTableView = sorting("Document Type", "No.") where("Document Type" = const(Quote));
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.", "Sell-to Customer No.", "Bill-to Customer No.", "Ship-to Code", "No. Printed";
            RequestFilterHeading = 'Sales Order';
            column(DocType_SalesHeader; "Document Type")
            {
            }
            column(No_SalesHeader; "No.")
            {
            }
            //>>AFDP 05/24/2025 'Item Code Type'
            column(DPAFIDocumentTitle; DPDocumentTitle) { }
            column(DPAFICompanyInfo1; DPAFICompanyInfo.Get(1)) { }
            column(DPAFICompanyInfo2; DPAFICompanyInfo.Get(2)) { }
            column(DPAFICompanyInfo3; DPAFICompanyInfo.Get(3)) { }
            column(DPAFICompanyInfo4; DPAFICompanyInfo.Get(4)) { }
            column(DPAFISellTo1; DPAFISellTo.Get(1)) { }
            column(DPAFISellTo2; DPAFISellTo.Get(2)) { }
            column(DPAFISellTo3; DPAFISellTo.Get(3)) { }
            column(DPAFISellTo4; DPAFISellTo.Get(4)) { }
            column(DPAFIShipTo1; DPAFIShipTo.Get(1)) { }
            column(DPAFIShipTo2; DPAFIShipTo.Get(2)) { }
            column(DPAFIShipTo3; DPAFIShipTo.Get(3)) { }
            column(DPAFIShipTo4; DPAFIShipTo.Get(4)) { }
            column(DPAFIShipTo5; DPAFIShipTo.Get(5)) { }
            column(DPAFIDocNo; "No.") { }
            column(DPAFIDocumentDate; "Document Date") { }
            column(DPAFIDeliveryDate; "Shipment Date") { }
            column(DPAFIPurchOrder; "External Document No.") { }
            column(DPAFIIncoterm; Incoterms) { }
            column(DPAFICountryOfOriginLbl; DPCountryOfOriginLbl) { }
            column(DPAFICountryOfOrigin; DPCountryOfOrigin) { }
            column(DPAFIShipVia; DPReportHelperFunctionsAFI.GetShippingAgentName("Sales Header"."Shipping Agent Code")) { }
            column(DPAFITerms; DPReportHelperFunctionsAFI.GetPaymentTermstName("Sales Header"."Payment Terms Code")) { }
            column(DPAFICustomer; "Bill-to Customer No.") { }
            column(DPAFISalesPerson; "Salesperson Code") { }
            column(DPAFISubtotal; DPDocSubtotal) { }
            column(DPAFIDiscount; DPDocDiscount) { }
            column(DPAFITax; DPDocTax) { }
            column(DPAFITotal; DPDocTotal) { }
            column(DPAFISubjectTotal; DPDocSubjectTotal) { }
            column(DPAFIExemptTotal; DPDocExemptTotal) { }
            column(DPAFITotalCases; DPDocTotalCases) { }
            column(AFoodLogo; CompanyInfo.Picture) { }  //AFDP 06/11/2025 'Item Code Type'
            //<<AFDP 05/24/2025 'Item Code Type'
            dataitem("Sales Line"; "Sales Line")
            {
                DataItemLink = "Document No." = field("No.");
                DataItemTableView = sorting("Document Type", "Document No.", "Line No.") where("Document Type" = const(Quote));
                dataitem(SalesLineComments; "Sales Comment Line")
                {
                    DataItemLink = "No." = field("Document No."), "Document Line No." = field("Line No.");
                    DataItemTableView = sorting("Document Type", "No.", "Document Line No.", "Line No.") where("Document Type" = const(Quote), "Print On Quote" = const(true));

                    trigger OnAfterGetRecord()
                    begin
                        TempSalesLine.Init();
                        TempSalesLine."Document Type" := "Sales Header"."Document Type";
                        TempSalesLine."Document No." := "Sales Header"."No.";
                        TempSalesLine."Line No." := HighestLineNo + 10;
                        HighestLineNo := TempSalesLine."Line No.";
                        if StrLen(Comment) <= MaxStrLen(TempSalesLine.Description) then begin
                            TempSalesLine.Description := Comment;
                            TempSalesLine."Description 2" := '';
                        end else begin
                            SpacePointer := MaxStrLen(TempSalesLine.Description) + 1;
                            while (SpacePointer > 1) and (Comment[SpacePointer] <> ' ') do
                                SpacePointer := SpacePointer - 1;
                            if SpacePointer = 1 then
                                SpacePointer := MaxStrLen(TempSalesLine.Description) + 1;
                            TempSalesLine.Description := CopyStr(Comment, 1, SpacePointer - 1);
                            TempSalesLine."Description 2" := CopyStr(CopyStr(Comment, SpacePointer + 1), 1, MaxStrLen(TempSalesLine."Description 2"));
                        end;
                        TempSalesLine.Insert();
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    TempSalesLine := "Sales Line";
                    TempSalesLine.Insert();
                    HighestLineNo := "Line No.";
                    if ("Sales Header"."Tax Area Code" <> '') and not UseExternalTaxEngine then
                        SalesTaxCalc.AddSalesLine(TempSalesLine);
                    //>>AFDP 05/24/2025 'Item Code Type'
                    TempAuxSalesLine1.Init();
                    TempAuxSalesLine1.TransferFields("Sales Line");
                    TempAuxSalesLine1.Insert();
                    //<<AFDP 05/24/2025 'Item Code Type'
                end;

                trigger OnPostDataItem()
                begin
                    if "Sales Header"."Tax Area Code" <> '' then begin
                        if UseExternalTaxEngine then
                            SalesTaxCalc.CallExternalTaxEngineForSales("Sales Header", true)
                        else
                            SalesTaxCalc.EndSalesTaxCalculation(UseDate);
                        SalesTaxCalc.DistTaxOverSalesLines(TempSalesLine);
                        SalesTaxCalc.GetSummarizedSalesTaxTable(TempSalesTaxAmtLine);
                        BrkIdx := 0;
                        PrevPrintOrder := 0;
                        PrevTaxPercent := 0;
                        TempSalesTaxAmtLine.Reset();
                        TempSalesTaxAmtLine.SetCurrentKey("Print Order", "Tax Area Code for Key", "Tax Jurisdiction Code");
                        if TempSalesTaxAmtLine.Find('-') then
                            repeat
                                if (TempSalesTaxAmtLine."Print Order" = 0) or
                                   (TempSalesTaxAmtLine."Print Order" <> PrevPrintOrder) or
                                   (TempSalesTaxAmtLine."Tax %" <> PrevTaxPercent)
                                then begin
                                    BrkIdx := BrkIdx + 1;
                                    if BrkIdx > 1 then
                                        if TaxArea."Country/Region" = TaxArea."Country/Region"::CA then
                                            BreakdownTitle := Text006
                                        else
                                            BreakdownTitle := Text003;
                                    if BrkIdx > ArrayLen(BreakdownAmt) then begin
                                        BrkIdx := BrkIdx - 1;
                                        BreakdownLabel[BrkIdx] := Text004;
                                    end else
                                        BreakdownLabel[BrkIdx] := StrSubstNo(TempSalesTaxAmtLine."Print Description", TempSalesTaxAmtLine."Tax %");
                                end;
                                BreakdownAmt[BrkIdx] := BreakdownAmt[BrkIdx] + TempSalesTaxAmtLine."Tax Amount";
                            until TempSalesTaxAmtLine.Next() = 0;
                        if BrkIdx = 1 then begin
                            Clear(BreakdownLabel);
                            Clear(BreakdownAmt);
                        end;
                    end;
                end;

                trigger OnPreDataItem()
                begin
                    TempSalesLine.Reset();
                    TempSalesLine.DeleteAll();
                    //>>AFDP 05/24/2025 'Item Code Type'
                    TempAuxSalesLine1.DeleteAll();
                    //<<AFDP 05/24/2025 'Item Code Type'
                end;
            }
            dataitem("Sales Comment Line"; "Sales Comment Line")
            {
                DataItemLink = "No." = field("No.");
                DataItemTableView = sorting("Document Type", "No.", "Document Line No.", "Line No.") where("Document Type" = const(Quote), "Print On Quote" = const(true), "Document Line No." = const(0));

                trigger OnAfterGetRecord()
                begin
                    TempSalesLine.Init();
                    TempSalesLine."Document Type" := "Sales Header"."Document Type";
                    TempSalesLine."Document No." := "Sales Header"."No.";
                    TempSalesLine."Line No." := HighestLineNo + 1000;
                    HighestLineNo := TempSalesLine."Line No.";
                    if StrLen(Comment) <= MaxStrLen(TempSalesLine.Description) then begin
                        TempSalesLine.Description := Comment;
                        TempSalesLine."Description 2" := '';
                    end else begin
                        SpacePointer := MaxStrLen(TempSalesLine.Description) + 1;
                        while (SpacePointer > 1) and (Comment[SpacePointer] <> ' ') do
                            SpacePointer := SpacePointer - 1;
                        if SpacePointer = 1 then
                            SpacePointer := MaxStrLen(TempSalesLine.Description) + 1;
                        TempSalesLine.Description := CopyStr(Comment, 1, SpacePointer - 1);
                        TempSalesLine."Description 2" := CopyStr(CopyStr(Comment, SpacePointer + 1), 1, MaxStrLen(TempSalesLine."Description 2"));
                    end;
                    TempSalesLine.Insert();
                end;

                trigger OnPreDataItem()
                begin
                    TempSalesLine.Init();
                    TempSalesLine."Document Type" := "Sales Header"."Document Type";
                    TempSalesLine."Document No." := "Sales Header"."No.";
                    TempSalesLine."Line No." := HighestLineNo + 1000;
                    HighestLineNo := TempSalesLine."Line No.";
                    TempSalesLine.Insert();
                end;
            }
            dataitem(CopyLoop; "Integer")
            {
                DataItemTableView = sorting(Number);
                dataitem(PageLoop; "Integer")
                {
                    DataItemTableView = sorting(Number) where(Number = const(1));
                    column(CompanyInfo2Picture; CompanyInfo2.Picture)
                    {
                    }
                    column(CompanyInfo1Picture; CompanyInfo1.Picture)
                    {
                    }
                    column(CompanyInfoPicture; CompanyInfo3.Picture)
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
                    column(CopyTxt; CopyTxt)
                    {
                    }
                    column(BillToAddress1; BillToAddress[1])
                    {
                    }
                    column(BillToAddress2; BillToAddress[2])
                    {
                    }
                    column(BillToAddress3; BillToAddress[3])
                    {
                    }
                    column(BillToAddress4; BillToAddress[4])
                    {
                    }
                    column(BillToAddress5; BillToAddress[5])
                    {
                    }
                    column(BillToAddress6; BillToAddress[6])
                    {
                    }
                    column(BillToAddress7; BillToAddress[7])
                    {
                    }
                    column(ShipToAddress1; ShipToAddress[1])
                    {
                    }
                    column(ShipToAddress2; ShipToAddress[2])
                    {
                    }
                    column(ShipToAddress3; ShipToAddress[3])
                    {
                    }
                    column(ShipToAddress4; ShipToAddress[4])
                    {
                    }
                    column(ShipToAddress5; ShipToAddress[5])
                    {
                    }
                    column(ShipToAddress6; ShipToAddress[6])
                    {
                    }
                    column(ShipToAddress7; ShipToAddress[7])
                    {
                    }
                    column(BilltoCustNo_SalesHeader; "Sales Header"."Bill-to Customer No.")
                    {
                    }
                    column(SalesPurchPersonName; SalesPurchPerson.Name)
                    {
                    }
                    column(OrderDate_SalesHeader; "Sales Header"."Order Date")
                    {
                    }
                    column(CompanyAddress7; CompanyAddress[7])
                    {
                    }
                    column(CompanyAddress8; CompanyAddress[8])
                    {
                    }
                    column(BillToAddress8; BillToAddress[8])
                    {
                    }
                    column(ShipToAddress8; ShipToAddress[8])
                    {
                    }
                    column(ShipmentMethodDesc; ShipmentMethod.Description)
                    {
                    }
                    column(PaymentTermsDesc; PaymentTerms.Description)
                    {
                    }
                    column(TaxRegLabel; TaxRegLabel)
                    {
                    }
                    column(TaxRegNo; TaxRegNo)
                    {
                    }
                    column(PrintFooter; PrintFooter)
                    {
                    }
                    column(CopyNo; CopyNo)
                    {
                    }
                    column(CustTaxIdentificationType; Format(Cust."Tax Identification Type"))
                    {
                    }
                    column(SellCaption; SellCaptionLbl)
                    {
                    }
                    column(ToCaption; ToCaptionLbl)
                    {
                    }
                    column(CustomerIDCaption; CustomerIDCaptionLbl)
                    {
                    }
                    column(SalesPersonCaption; SalesPersonCaptionLbl)
                    {
                    }
                    column(ShipCaption; ShipCaptionLbl)
                    {
                    }
                    column(SalesQuoteCaption; SalesQuoteCaptionLbl)
                    {
                    }
                    column(SalesQuoteNumberCaption; SalesQuoteNumberCaptionLbl)
                    {
                    }
                    column(SalesQuoteDateCaption; SalesQuoteDateCaptionLbl)
                    {
                    }
                    column(PageCaption; PageCaptionLbl)
                    {
                    }
                    column(ShipViaCaption; ShipViaCaptionLbl)
                    {
                    }
                    column(TermsCaption; TermsCaptionLbl)
                    {
                    }
                    column(TaxIdentTypeCaption; TaxIdentTypeCaptionLbl)
                    {
                    }
                    dataitem(SalesLine; "Integer")
                    {
                        DataItemTableView = sorting(Number);
                        column(Number_IntegerLine; Number)
                        {
                        }
                        column(AmountExclInvDisc; AmountExclInvDisc)
                        {
                        }
                        column(TempSalesLineNo; TempSalesLine."No.")
                        {
                        }
                        column(TempSalesLineUOM; TempSalesLine."Unit of Measure")
                        {
                        }
                        column(TempSalesLineQuantity; TempSalesLine.Quantity)
                        {
                            DecimalPlaces = 0 : 5;
                        }
                        column(UnitPriceToPrint; UnitPriceToPrint)
                        {
                            DecimalPlaces = 2 : 5;
                        }
                        column(TempSalesLineDescription; TempSalesLine.Description + ' ' + TempSalesLine."Description 2")
                        {
                        }
                        column(TaxLiable; TaxLiable)
                        {
                        }
                        column(TempSalesLineLineAmtTaxLiable; TempSalesLine."Line Amount" - TaxLiable)
                        {
                        }
                        column(TempSalesLineInvDiscAmt; TempSalesLine."Inv. Discount Amount")
                        {
                        }
                        column(TaxAmount; TaxAmount)
                        {
                        }
                        column(TempSalesLineLineAmtTaxAmtInvDiscAmt; TempSalesLine."Line Amount" + TaxAmount - TempSalesLine."Inv. Discount Amount")
                        {
                        }
                        column(BreakdownTitle; BreakdownTitle)
                        {
                        }
                        column(BreakdownLabel1; BreakdownLabel[1])
                        {
                        }
                        column(BreakdownLabel2; BreakdownLabel[2])
                        {
                        }
                        column(BreakdownAmt1; BreakdownAmt[1])
                        {
                        }
                        column(BreakdownAmt2; BreakdownAmt[2])
                        {
                        }
                        column(BreakdownLabel3; BreakdownLabel[3])
                        {
                        }
                        column(BreakdownAmt3; BreakdownAmt[3])
                        {
                        }
                        column(BreakdownAmt4; BreakdownAmt[4])
                        {
                        }
                        column(BreakdownLabel4; BreakdownLabel[4])
                        {
                        }
                        column(TotalTaxLabel; TotalTaxLabel)
                        {
                        }
                        column(ItemNoCaption; ItemNoCaptionLbl)
                        {
                        }
                        column(UnitCaption; UnitCaptionLbl)
                        {
                        }
                        column(DescriptionCaption; DescriptionCaptionLbl)
                        {
                        }
                        column(QuantityCaption; QuantityCaptionLbl)
                        {
                        }
                        column(UnitPriceCaption; UnitPriceCaptionLbl)
                        {
                        }
                        column(TotalPriceCaption; TotalPriceCaptionLbl)
                        {
                        }
                        column(SubtotalCaption; SubtotalCaptionLbl)
                        {
                        }
                        column(InvoiceDiscountCaption; InvoiceDiscountCaptionLbl)
                        {
                        }
                        column(TotalCaption; TotalCaptionLbl)
                        {
                        }
                        column(AmtSubjecttoSalesTaxCptn; AmtSubjecttoSalesTaxCptnLbl)
                        {
                        }
                        column(AmtExemptfromSalesTaxCptn; AmtExemptfromSalesTaxCptnLbl)
                        {
                        }
                        //>>AFDP 05/24/2025 'Item Code Type'
                        column(DPAFIItemNo; DPItemNo) { }
                        column(DPAFIDescription; DPLineDescription) { }
                        column(DPAFINetWeight; DPItemNetWeight) { }
                        column(DPAFIPricePer; DPItemBaseUOM) { }
                        column(DPAFIUnitPrice; DPLineUnitPrice) { }
                        column(DPAFITotalPrice; DPTotLineAmount) { }
                        column(DPAFIUnits; DPLineQuantity) { }
                        //<<AFDP 05/24/2025 'Item Code Type'

                        trigger OnAfterGetRecord()
                        var
                            _Item: Record Item;  //AFDP 05/24/2025 'Item Code Type'
                        begin
                            OnLineNumber := OnLineNumber + 1;

                            if OnLineNumber = 1 then
                                TempSalesLine.Find('-')
                            else
                                TempSalesLine.Next();

                            if TempSalesLine.Type = TempSalesLine.Type::" " then begin
                                TempSalesLine."No." := '';
                                TempSalesLine."Unit of Measure" := '';
                                TempSalesLine."Line Amount" := 0;
                                TempSalesLine."Inv. Discount Amount" := 0;
                                TempSalesLine.Quantity := 0;
                            end else
                                if TempSalesLine.Type = TempSalesLine.Type::"G/L Account" then
                                    TempSalesLine."No." := '';

                            if TempSalesLine."Tax Area Code" <> '' then
                                TaxAmount := TempSalesLine."Amount Including VAT" - TempSalesLine.Amount
                            else
                                TaxAmount := 0;
                            if TaxAmount <> 0 then
                                TaxLiable := TempSalesLine.Amount
                            else
                                TaxLiable := 0;

                            OnAfterCalculateSalesTax("Sales Header", TempSalesLine, TaxAmount, TaxLiable);

                            AmountExclInvDisc := TempSalesLine."Line Amount";

                            if TempSalesLine.Quantity = 0 then
                                UnitPriceToPrint := 0
                            // so it won't print
                            else
                                UnitPriceToPrint := Round(AmountExclInvDisc / TempSalesLine.Quantity, 0.00001);

                            if OnLineNumber = NumberOfLines then
                                PrintFooter := true;
                            //>>AFDP 05/24/2025 'Item Code Type'
                            if DPRemainingLines = 0 then
                                CurrReport.Skip();
                            DPLineQuantity := DPReportHelperFunctionsAFI.GetDocLineQuantity(TempAuxSalesLine1.Units_DU_TSL, TempAuxSalesLine1.Quantity);
                            if (TempAuxSalesLine1."Type" = TempAuxSalesLine1."Type"::Item) and _Item.Get(TempAuxSalesLine1."No.") then begin
                                DPItemBaseUOM := _Item."Base Unit of Measure";
                                //>>AFDP 06/11/2025 'Item Code Type'
                                // DPItemNetWeight := _Item."Net Weight" * DPLineQuantity;
                                if TempAuxSalesLine1.Units_DU_TSL = 0 then
                                    DPItemNetWeight := _Item."Net Weight" * DPLineQuantity
                                else
                                    DPItemNetWeight := TempAuxSalesLine1.Quantity;
                                //>>AFDP 06/11/2025 'Item Code Type'
                            end;
                            DPItemNo := DPReportHelperFunctionsAFI.SelectItemCode(TempAuxSalesLine1."No.", DPItemCodeType, 0, "Sales Header"."Bill-to Customer No.");
                            DPLineDescription := DPReportHelperFunctionsAFI.MergeText(TempAuxSalesLine1.Description, TempAuxSalesLine1."Description 2");
                            DPLineUnitPrice := TempAuxSalesLine1."Unit Price";
                            DPTotLineAmount := TempAuxSalesLine1.Amount;
                            if DPItemNo = '' then begin
                                DPItemNetWeight := 0;
                                DPItemBaseUOM := '';
                                DPLineUnitPrice := 0;
                                DPTotLineAmount := 0;
                                DPLineQuantity := 0;
                            end;
                            DPRemainingLines := TempAuxSalesLine1.Next();
                            //<<AFDP 05/24/2025 'Item Code Type'
                        end;

                        trigger OnPreDataItem()
                        begin
                            Clear(TaxLiable);
                            Clear(TaxAmount);
                            Clear(AmountExclInvDisc);
                            TempSalesLine.Reset();
                            NumberOfLines := TempSalesLine.Count();
                            SetRange(Number, 1, NumberOfLines);
                            OnLineNumber := 0;
                            PrintFooter := false;
                            //>>AFDP 05/24/2025 'Item Code Type'
                            TempAuxSalesLine1.FindSet();
                            DPRemainingLines := 1;
                            //<<AFDP 05/24/2025 'Item Code Type'
                        end;
                    }
                }

                trigger OnAfterGetRecord()
                begin
                    if CopyNo = NoLoops then begin
                        if not CurrReport.Preview then
                            SalesPrinted.Run("Sales Header");
                        CurrReport.Break();
                    end;
                    CopyNo := CopyNo + 1;
                    if CopyNo = 1 then // Original
                        Clear(CopyTxt)
                    else
                        CopyTxt := Text000;
                end;

                trigger OnPreDataItem()
                begin
                    NoLoops := 1 + Abs(NoCopies);
                    if NoLoops <= 0 then
                        NoLoops := 1;
                    CopyNo := 0;
                end;
            }

            trigger OnAfterGetRecord()
            begin
                if PrintCompany then
                    if RespCenter.Get("Responsibility Center") then begin
                        FormatAddress.RespCenter(CompanyAddress, RespCenter);
                        CompanyInformation."Phone No." := RespCenter."Phone No.";
                        CompanyInformation."Fax No." := RespCenter."Fax No.";
                    end;

                CurrReport.Language := LanguageMgt.GetLanguageIdOrDefault("Language Code");
                CurrReport.FormatRegion := LanguageMgt.GetFormatRegionOrDefault("Format Region");

                FormatDocumentFields("Sales Header");

                if not Cust.Get("Sell-to Customer No.") then
                    Clear(Cust);

                FormatAddress.SalesHeaderSellTo(BillToAddress, "Sales Header");
                FormatAddress.SalesHeaderShipTo(ShipToAddress, ShipToAddress, "Sales Header");

                if not CurrReport.Preview then begin
                    if ArchiveDocument then
                        ArchiveManagement.StoreSalesDocument("Sales Header", LogInteraction);

                    if LogInteraction then begin
                        CalcFields("No. of Archived Versions");
                        if "Bill-to Contact No." <> '' then
                            SegManagement.LogDocument(
                              1, "No.", "Doc. No. Occurrence",
                              "No. of Archived Versions", DATABASE::Contact, "Bill-to Contact No.",
                              "Salesperson Code", "Campaign No.", "Posting Description", "Opportunity No.")
                        else
                            SegManagement.LogDocument(
                              1, "No.", "Doc. No. Occurrence",
                              "No. of Archived Versions", DATABASE::Customer, "Bill-to Customer No.",
                              "Salesperson Code", "Campaign No.", "Posting Description", "Opportunity No.");
                    end;
                end;

                Clear(BreakdownTitle);
                Clear(BreakdownLabel);
                Clear(BreakdownAmt);
                TotalTaxLabel := Text008;
                TaxRegNo := '';
                TaxRegLabel := '';
                if "Tax Area Code" <> '' then begin
                    TaxArea.Get("Tax Area Code");
                    case TaxArea."Country/Region" of
                        TaxArea."Country/Region"::US:
                            TotalTaxLabel := Text005;
                        TaxArea."Country/Region"::CA:
                            begin
                                TotalTaxLabel := Text007;
                                TaxRegNo := CompanyInformation."VAT Registration No.";
                                TaxRegLabel := CompanyInformation.FieldCaption("VAT Registration No.");
                            end;
                    end;
                    UseExternalTaxEngine := TaxArea."Use External Tax Engine";
                    SalesTaxCalc.StartSalesTaxCalculation();
                end;

                UseDate := WorkDate();
                //>>AFDP 05/24/2025 'Item Code Type'
                DPAFICompanyInfo := DPReportHelperFunctionsAFI.BuildCompanyInfo();
                DPAFISellTo := DPReportHelperFunctionsAFI.BuilldSellToInfo("Sales Header");
                DPAFIShipTo := DPReportHelperFunctionsAFI.BuilldShipToInfo("Sales Header");
                DPReportHelperFunctionsAFI.GetSalesDocAmounts("Sales Header", DPDocSubtotal, DPDocDiscount, DPDocTax, DPDocExemptTotal, DPDocSubjectTotal, DPDocTotal, DPDocTotalCases);
                Gettotalcase("Sales Header", DPDocTotalCases);  //AFDP 06/04/2025 'Item Code Type'
                if DPShowCountryOfOrigin then begin
                    DPCountryOfOriginLbl := 'Country of Origin';
                    DPCountryOfOrigin := 'USA'
                end
                else begin
                    DPCountryOfOriginLbl := '';
                    DPCountryOfOrigin := ''
                end;
                //<<AFDP 05/24/2025 'Item Code Type'
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    //>>AFDP 05/24/2025 'Item Code Type'
                    field("DPAFIDocumentTitle"; DPDocumentTitle)
                    {
                        Caption = 'Document Title';
                        OptionCaption = 'Estimate,Pro Forma';
                        ToolTip = 'Document Title';
                        ApplicationArea = All;
                    }
                    field("DPShowCountryOfOrigin"; DPShowCountryOfOrigin)
                    {
                        Caption = 'Show Country of Origin';
                        ToolTip = 'Show Country of Origin';
                        ApplicationArea = All;
                    }
                    field("DPItemCodeType"; DPItemCodeType)
                    {
                        Caption = 'Item Code Type';
                        OptionCaption = 'GTIN,SKU,Reference';
                        ToolTip = 'Item Code Type';
                        ApplicationArea = All;
                        Visible = false;
                    }
                    //<<AFDP 05/24/2025 'Item Code Type'
                    field(NoCopies; NoCopies)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Number of Copies';
                        ToolTip = 'Specifies the number of copies of each document (in addition to the original) that you want to print.';
                    }
                    field(PrintCompanyAddress; PrintCompany)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Print Company Address';
                        ToolTip = 'Specifies if your company address is printed at the top of the sheet, because you do not use pre-printed paper. Leave this check box blank to omit your company''s address.';
                    }
                    field(ArchiveDocument; ArchiveDocument)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Archive Document';
                        Enabled = ArchiveDocumentEnable;
                        ToolTip = 'Specifies if the document is archived after you preview or print it.';

                        trigger OnValidate()
                        begin
                            if not ArchiveDocument then
                                LogInteraction := false;
                        end;
                    }
                    field(LogInteraction; LogInteraction)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Log Interaction';
                        Enabled = LogInteractionEnable;
                        ToolTip = 'Specifies if you want to record the related interactions with the involved contact person in the Interaction Log Entry table.';

                        trigger OnValidate()
                        begin
                            if LogInteraction then
                                ArchiveDocument := ArchiveDocumentEnable;
                        end;
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnInit()
        begin
            LogInteractionEnable := true;
            ArchiveDocumentEnable := true;
        end;

        trigger OnOpenPage()
        begin
            ArchiveDocument :=
              (SalesSetup."Archive Quotes" = SalesSetup."Archive Quotes"::Question) or
              (SalesSetup."Archive Quotes" = SalesSetup."Archive Quotes"::Always);
            LogInteraction := SegManagement.FindInteractionTemplateCode("Interaction Log Entry Document Type"::"Sales Qte.") <> '';

            ArchiveDocumentEnable := ArchiveDocument;
            LogInteractionEnable := LogInteraction;
        end;
    }

    labels
    {
    }

    trigger OnInitReport()
    begin
        CompanyInfo.Get();
        CompanyInfo.CalcFields(Picture);  //AFDP 06/11/2025 'Item Code Type'
        SalesSetup.Get();
        FormatDocument.SetLogoPosition(SalesSetup."Logo Position on Documents", CompanyInfo1, CompanyInfo2, CompanyInfo3);
    end;

    trigger OnPreReport()
    begin
        if PrintCompany then
            FormatAddress.Company(CompanyAddress, CompanyInformation)
        else
            Clear(CompanyAddress);
    end;

    var
        TempAuxSalesLine1: Record "Sales Line" temporary;
        ShipmentMethod: Record "Shipment Method";
        PaymentTerms: Record "Payment Terms";
        SalesPurchPerson: Record "Salesperson/Purchaser";
        CompanyInformation: Record "Company Information";
        CompanyInfo: Record "Company Information";
        SalesSetup: Record "Sales & Receivables Setup";
        TempSalesLine: Record "Sales Line" temporary;
        RespCenter: Record "Responsibility Center";
        TempSalesTaxAmtLine: Record "Sales Tax Amount Line" temporary;
        TaxArea: Record "Tax Area";
        Cust: Record Customer;
        LanguageMgt: Codeunit Language;
        SalesPrinted: Codeunit "Sales-Printed";
        FormatAddress: Codeunit "Format Address";
        FormatDocument: Codeunit "Format Document";
        SalesTaxCalc: Codeunit "Sales Tax Calculate";
        ArchiveManagement: Codeunit ArchiveManagement;
        SegManagement: Codeunit SegManagement;
        DPReportHelperFunctionsAFI: Codeunit "Report Helper Functions AFI";
        TaxLiable: Decimal;
        UnitPriceToPrint: Decimal;
        AmountExclInvDisc: Decimal;
        CompanyAddress: array[8] of Text[100];
        BillToAddress: array[8] of Text[100];
        ShipToAddress: array[8] of Text[100];
        CopyTxt: Text;
        SalespersonText: Text[50];
        PrintCompany: Boolean;
        PrintFooter: Boolean;
        NoCopies: Integer;
        NoLoops: Integer;
        CopyNo: Integer;
        NumberOfLines: Integer;
        OnLineNumber: Integer;
        HighestLineNo: Integer;
        SpacePointer: Integer;
        TaxAmount: Decimal;
        ArchiveDocument: Boolean;
        LogInteraction: Boolean;
        Text000: Label 'COPY';
        TaxRegNo: Text;
        TaxRegLabel: Text;
        TotalTaxLabel: Text;
        BreakdownTitle: Text;
        BreakdownLabel: array[4] of Text;
        BreakdownAmt: array[4] of Decimal;
        BrkIdx: Integer;
        PrevPrintOrder: Integer;
        PrevTaxPercent: Decimal;
        UseDate: Date;
        Text003: Label 'Sales Tax Breakdown:';
        Text004: Label 'Other Taxes';
        Text005: Label 'Total Sales Tax:';
        Text006: Label 'Tax Breakdown:';
        Text007: Label 'Total Tax:';
        Text008: Label 'Tax:';
        UseExternalTaxEngine: Boolean;
        ArchiveDocumentEnable: Boolean;
        LogInteractionEnable: Boolean;
        SellCaptionLbl: Label 'Sell';
        ToCaptionLbl: Label 'To:';
        CustomerIDCaptionLbl: Label 'Customer ID';
        SalesPersonCaptionLbl: Label 'SalesPerson';
        ShipCaptionLbl: Label 'Ship';
        SalesQuoteCaptionLbl: Label 'Sales Quote';
        SalesQuoteNumberCaptionLbl: Label 'Sales Quote Number:';
        SalesQuoteDateCaptionLbl: Label 'Sales Quote Date:';
        PageCaptionLbl: Label 'Page:';
        ShipViaCaptionLbl: Label 'Ship Via';
        TermsCaptionLbl: Label 'Terms';
        TaxIdentTypeCaptionLbl: Label 'Tax Ident. Type';
        ItemNoCaptionLbl: Label 'Item No.';
        UnitCaptionLbl: Label 'Unit';
        DescriptionCaptionLbl: Label 'Description';
        QuantityCaptionLbl: Label 'Quantity';
        UnitPriceCaptionLbl: Label 'Unit Price';
        TotalPriceCaptionLbl: Label 'Total Price';
        SubtotalCaptionLbl: Label 'Subtotal:';
        InvoiceDiscountCaptionLbl: Label 'Invoice Discount:';
        TotalCaptionLbl: Label 'Total:';
        AmtSubjecttoSalesTaxCptnLbl: Label 'Amount Subject to Sales Tax';
        AmtExemptfromSalesTaxCptnLbl: Label 'Amount Exempt from Sales Tax';
        //>>AFDP 05/24/2025 'Item Code Type'        
        DPAFICompanyInfo: List of [Text[200]];
        DPAFISellTo: List of [Text[200]];
        DPAFIShipTo: List of [Text[200]];
        DPItemNo: Code[50];
        DPItemBaseUOM: Code[20];
        DPItemNetWeight: Decimal;
        DPLineDescription: Text;
        DPLineQuantity: Decimal;
        DPLineUnitPrice: Decimal;
        DPTotLineAmount: Decimal;
        DPDocumentTitle: Option "Estimate","Pro Forma";
        DPItemCodeType: Option GTIN,SKU,Reference;
        DPShowCountryOfOrigin: Boolean;
        DPCountryOfOriginLbl: Text;
        DPCountryOfOrigin: Text;
        DPDocSubtotal: Decimal;
        DPDocDiscount: Decimal;
        DPDocTax: Decimal;
        DPDocTotal: Decimal;
        DPDocSubjectTotal: Decimal;
        DPDocExemptTotal: Decimal;
        DPDocTotalCases: Decimal;
        DPRemainingLines: Integer;
    //<<AFDP 05/24/2025 'Item Code Type'

    protected var
        CompanyInfo1: Record "Company Information";
        CompanyInfo2: Record "Company Information";
        CompanyInfo3: Record "Company Information";

    local procedure FormatDocumentFields(SalesHeader: Record "Sales Header")
    begin
        FormatDocument.SetSalesPerson(SalesPurchPerson, SalesHeader."Salesperson Code", SalespersonText);
        FormatDocument.SetPaymentTerms(PaymentTerms, SalesHeader."Payment Terms Code", SalesHeader."Language Code");
        FormatDocument.SetShipmentMethod(ShipmentMethod, SalesHeader."Shipment Method Code", SalesHeader."Language Code");
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
    local procedure OnAfterCalculateSalesTax(var SalesHeaderParm: Record "Sales Header"; var SalesLineParm: Record "Sales Line"; var TaxAmount: Decimal; var TaxLiable: Decimal)
    begin
    end;
}


namespace AFood.DP.AFoodDevelopment;
xmlport 50300 "AFDP Item Tracking Import Tool"
{
    Caption = 'Item Tracking Import Tool';
    UseRequestPage = false;
    Direction = Import;
    DefaultFieldsValidation = false;
    Format = VariableText;
    schema
    {
        textelement(Root)
        {
            tableelement(AFDPItemTrackingImportEntry; "AFDP Item Tracking ImportEntry")
            {
                AutoSave = false;
                AutoUpdate = false;
                AutoReplace = false;
                textelement(PONumber) { }
                textelement(PODate) { }
                textelement(VendorItemNumber) { }
                textelement(QuantityShipped) { }
                textelement(LotNumber) { }
                textelement(ExpirationDate) { }
                textelement(ProductionDate) { }
                trigger OnAfterInitRecord()
                begin
                    Clear(LastEntryNo);
                    Clear(PONumber);
                    Clear(PODate);
                    Clear(VendorItemNumber);
                    Clear(QuantityShipped);
                    Clear(LotNumber);
                    Clear(ExpirationDate);
                    Clear(ProductionDate);
                end;

                trigger OnBeforeInsertRecord()
                begin
                    if PONumber <> 'PO Number' then begin   //skip header row
                        LastEntryNo := GetLastEntryNo();
                        ProgressWindow.UPDATE(1, format(LotNumber));
                        //---------------------\\
                        ItemTrackingImportEntry1.Init();
                        ItemTrackingImportEntry1."Entry No." := LastEntryNo + 1;
                        ItemTrackingImportEntry1."PO No." := format(PONumber);
                        ItemTrackingImportEntry1."PO Date" := ConvertIntoDate(PODate);
                        ItemTrackingImportEntry1."Vendor Item No." := format(VendorItemNumber);
                        // ItemTrackingImportEntry1.Description := format(Description);
                        ItemTrackingImportEntry1."Quantity Shipped" := ConvertIntoDecimal(QuantityShipped);
                        ItemTrackingImportEntry1."Lot Number" := format(LotNumber);
                        ItemTrackingImportEntry1."Expiration Date" := ConvertIntoDate(ExpirationDate);
                        ItemTrackingImportEntry1."Production Date" := ConvertIntoDate(ProductionDate);
                        ItemTrackingImportEntry1.Insert();
                        TotalRecordImported += 1;
                    end;
                end;
            }
        }
    }
    trigger OnPreXmlPort()
    begin
        ProgressWindow.OPEN('Importing Lot No.: #1#############');
        TotalRecordImported := 0;
    end;

    trigger OnPostXmlPort()
    begin
        ProgressWindow.CLOSE();
        MESSAGE('Total Record Imported: %1', TotalRecordImported);
    end;

    var
        ItemTrackingImportEntry1: Record "AFDP Item Tracking ImportEntry";
        ProgressWindow: Dialog;
        TotalRecordImported: Integer;
        LastEntryNo: Integer;

    local procedure GetLastEntryNo(): Integer;
    var
        ItemTrackingImportEntry: Record "AFDP Item Tracking ImportEntry";
    begin
        ItemTrackingImportEntry.Reset();
        ItemTrackingImportEntry.SetCurrentKey("Entry No.");
        ItemTrackingImportEntry.SetRange("Entry No.");
        if ItemTrackingImportEntry.FindLast() then
            exit(ItemTrackingImportEntry."Entry No.")
        else
            exit(0);
    end;

    local procedure ConvertIntoDecimal(DecimalTxt: Text[30]) DecimalValue: Decimal;
    begin
        if (DecimalTxt = '-') or (DecimalTxt = '') then
            DecimalTxt := '0';

        Evaluate(DecimalValue, DecimalTxt);
    end;

    local procedure ConvertIntoInteger(IntegerTxt: Text[30]) IntegerValue: Integer;
    begin
        if (IntegerTxt = '-') or (IntegerTxt = '') then
            IntegerTxt := '0';

        Evaluate(IntegerValue, IntegerTxt);
    end;

    local procedure ConvertIntoDate(DateTxt: Text[30]) DateValue: Date;
    begin
        if (DateTxt = '-') or (DateTxt = '') then begin
            DateValue := 0D;
            exit(DateValue);
        end;

        if Evaluate(DateValue, DateTxt) then
            DateValue := DateValue
        else
            DateValue := 0D;
    end;
}

//AFDP 06/06/2025 'Item Tracking Import Tools'
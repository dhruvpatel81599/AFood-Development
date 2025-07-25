namespace AFood.DP.AFoodDevelopment;
page 50302 "AFDP Warehouse Entries"
{
    ApplicationArea = Warehouse;
    Caption = 'Warehouse Entries For Receiving Enhancements';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "AFDP Warehouse Entries";
    SourceTableView = sorting("Entry No.")
                      order(descending);
    UsageCategory = History;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Entry Type"; Rec."Entry Type")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the entry type, which can be Negative Adjmt., Positive Adjmt., or Movement.';
                }
                field("Journal Batch Name"; Rec."Journal Batch Name")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the name of the journal batch, a personalized journal layout, that the entries were posted from.';
                    Visible = false;
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the line number of the warehouse document line or warehouse journal line that was registered.';
                    Visible = false;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = Location;
                    ToolTip = 'Specifies the code of the location to which the entry is linked.';
                }
                field("Expiration Date"; Rec."Expiration Date")
                {
                    ApplicationArea = ItemTracking;
                    ToolTip = 'Specifies the expiration date of the serial number.';
                    Visible = false;
                }
                field("Zone Code"; Rec."Zone Code")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the code of the zone to which the entry is linked.';
                }
                field("Bin Code"; Rec."Bin Code")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the bin where the items are picked or put away.';
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the number of the item in the entry.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies a description of the warehouse entry.';
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = Planning;
                    ToolTip = 'Specifies the variant of the item on the line.';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the number of units of the item in the warehouse entry.';
                }
                field("Qty. (Base)"; Rec."Qty. (Base)")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the quantity of the entry, in the base unit of measure.';
                    Visible = false;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies how each unit of the item or resource is measured, such as in pieces or hours. By default, the value in the Base Unit of Measure field on the item or resource card is inserted.';
                }
                field("Serial No."; Rec."Serial No.")
                {
                    ApplicationArea = ItemTracking;
                    ToolTip = 'Specifies the serial number.';
                }
                field("Lot No."; Rec."Lot No.")
                {
                    ApplicationArea = ItemTracking;
                    ToolTip = 'Specifies the lot number assigned to the warehouse entry.';
                }
                field("Package No."; Rec."Package No.")
                {
                    ApplicationArea = ItemTracking;
                    ToolTip = 'Specifies the package number assigned to the warehouse entry.';
                }
                field("Qty. per Unit of Measure"; Rec."Qty. per Unit of Measure")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the number of base units of measure that are in the unit of measure specified for the item on the line.';
                    Visible = false;
                }
                field("Source Type"; Rec."Source Type")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the table number that is the source of the entry line, for example, 39 for a purchase line, 37 for a sales line.';
                    Visible = false;
                }
                field("Source Subtype"; Rec."Source Subtype")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the source subtype of the document to which the warehouse entry line relates.';
                    Visible = false;
                }
                field("Source Document"; Rec."Source Document")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the type of document that the line relates to.';
                }
                field("Source No."; Rec."Source No.")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the number of the source document that the entry originates from.';
                }
                field("Source Line No."; Rec."Source Line No.")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the line number of the source document that the entry originates from.';
                }
                field("Source Subline No."; Rec."Source Subline No.")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the source subline number of the document from which the entry originates.';
                    Visible = false;
                }
                field("Reason Code"; Rec."Reason Code")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the reason code, a supplementary source code that enables you to trace the entry.';
                }
                field("No. Series"; Rec."No. Series")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the number series from which entry or record numbers are assigned to new entries or records.';
                    Visible = false;
                }
                field(Cubage; Rec.Cubage)
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the total cubage of the items on the warehouse entry line.';
                    Visible = false;
                }
                field(Weight; Rec.Weight)
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the weight of one item unit when measured in the specified unit of measure.';
                    Visible = false;
                }
                field("Journal Template Name"; Rec."Journal Template Name")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the name of the journal template, the basis of the journal batch, that the entries were posted from.';
                    Visible = false;
                }
                field("Whse. Document Type"; Rec."Whse. Document Type")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the type of the document from which this entry originated.';
                }
                field("Whse. Document No."; Rec."Whse. Document No.")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the number of the warehouse document from which this entry originated.';
                }
                field("Registering Date"; Rec."Registering Date")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the date the entry was registered.';
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the ID of the user who posted the entry, to be used, for example, in the change log.';
                    Visible = false;
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the number of the entry, as assigned from the specified number series when the entry was created.';
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
                Visible = false;
            }
        }
    }
}

//AFDP 06/28/2025 'T0008-Receiving Enhancements'
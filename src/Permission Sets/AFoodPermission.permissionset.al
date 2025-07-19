namespace AFood.DP.AFoodDevelopment;
permissionset 50300 AFoodPermission
{
    Assignable = true;
    Permissions = tabledata "AFDP Item Tracking ImportEntry" = RIMD,
        table "AFDP Item Tracking ImportEntry" = X,
        report "AFDP Sales Quote NA" = X,
        report "AFDP Sales-Pro Forma Invoice" = X,
        report "AFDP Standard Sales Invoice" = X,
        codeunit "AFDP Purchase Event Management" = X,
        codeunit "AFDP Sales Event Management" = X,
        codeunit "AFDP Warehouse EventManagement" = X,
        xmlport "AFDP Item Tracking Import Tool" = X,
        tabledata "AFDP Item Rename Import Entry" = RIMD,
        table "AFDP Item Rename Import Entry" = X,
        xmlport "AFDP Item Number Rename Tool" = X,
        codeunit "AFDP Single Instance" = X,
        tabledata "AFDP Warehouse Entries" = RIMD,
        table "AFDP Warehouse Entries" = X,
        report "INVC Item Number Rename" = X,
        page "AFDP Item Tracking ImportEntry" = X,
        page "AFDP Short Purchase Order" = X;
}
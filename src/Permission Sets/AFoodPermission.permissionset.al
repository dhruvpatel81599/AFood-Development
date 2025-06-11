namespace AFood.DP.AFoodDevelopment;

using AFood.DP.AFoodDevelopment;

permissionset 50300 AFoodPermission
{
    Assignable = true;
    Permissions =
        report "AFDP Sales Quote NA" = X,
        report "AFDP Sales-Pro Forma Invoice" = X,
        report "AFDP Standard Sales Invoice" = X,
        codeunit "AFDP Purchase Event Management" = X,
        codeunit "AFDP Sales Event Management" = X,
        codeunit "AFDP Warehouse EventManagement" = X,
        codeunit "INVC Single Instance" = X,
        tabledata "AFDP Item Rename Import Entry" = RIMD,
        table "AFDP Item Rename Import Entry" = X,
        xmlport "AFDP Item Number Rename Tool" = X;
}
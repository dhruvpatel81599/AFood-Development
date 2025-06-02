namespace AFood.DP.AFoodDevelopment;
using Microsoft.Purchases.Document;

codeunit 50303 "AFDP Purchase Event Management"
{

    #region Global Variables
    var
    #endregion Global Variables

    #region EventSubcribers    
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Purchase Document", 'OnAfterReleasePurchaseDoc', '', false, false)]
    local procedure ReleasePurchaseDocument_OnAfterReleasePurchaseDoc(var PurchaseHeader: Record "Purchase Header"; PreviewMode: Boolean; var LinesWereModified: Boolean; SkipWhseRequestOperations: Boolean)
    begin
        //>>AFDP 05/31/2025 'Short Orders'
        UpdateOriginalQuantityOnPurchaseLine(PurchaseHeader);
        //<<AFDP 05/31/2025 'Short Orders'
    end;
    #endregion EventSubscribers

    #region Functions    
    //>>AFDP 05/31/2025 'Short Orders'
    local procedure UpdateOriginalQuantityOnPurchaseLine(var PurchaseHeader: Record "Purchase Header")
    var
        PurchaseLine: Record "Purchase Line";
    begin
        PurchaseLine.Reset();
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        if PurchaseLine.FindSet() then
            repeat
                if PurchaseLine."Quantity Received" = 0 then begin
                    PurchaseLine."Original Quantity" := PurchaseLine.Quantity;
                    PurchaseLine.Modify(true);
                end;
            until PurchaseLine.Next() = 0;
    end;
    //<<AFDP 05/31/2025 'Short Orders'
    #endregion Functions
}

//AFDP 05/31/2025 'Short Orders'


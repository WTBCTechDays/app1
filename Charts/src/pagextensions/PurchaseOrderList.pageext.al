pageextension 50104 "Purchase Order List" extends "Purchase Order List"
{
    layout
    {
        addfirst(factboxes)
        {
            part(Chart; Chart)
            {
                ApplicationArea = All;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    var
        PurchaseLine: Record "Purchase Line";
    begin
        PurchaseLine.SetRange("Document Type", Rec."Document Type");
        PurchaseLine.SetRange("Document No.", Rec."No.");

        CurrPage.Chart.Page.SetVariant(PurchaseLine);
    end;

    trigger OnOpenPage()
    var
        PurchaseLine: Record "Purchase Line";
    begin
        CurrPage.Chart.Page.SetChartType('bar');
        CurrPage.Chart.Page.SetDimension(PurchaseLine.FieldNo(Type));
        CurrPage.Chart.Page.AddSumField(PurchaseLine.FieldNo("Line Amount"));
    end;
}
pageextension 50103 "Sales Order List" extends "Sales Order List"
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
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetRange("Document Type", Rec."Document Type");
        SalesLine.SetRange("Document No.", Rec."No.");

        CurrPage.Chart.Page.SetVariant(SalesLine);
    end;

    trigger OnOpenPage()
    var
        SalesLine: Record "Sales Line";
    begin
        CurrPage.Chart.Page.SetChartType('bar');
        CurrPage.Chart.Page.SetDimension(SalesLine.FieldNo(Type));
        CurrPage.Chart.Page.AddSumField(SalesLine.FieldNo("Line Amount"));
    end;
}
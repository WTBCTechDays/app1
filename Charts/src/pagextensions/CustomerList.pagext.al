pageextension 50100 "Customer List" extends "Customer List"
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
        CustomerEntry: Record "Cust. Ledger Entry";
    begin
        CustomerEntry.SetRange("Customer No.", Rec."No.");
        CurrPage.Chart.Page.SetVariant(CustomerEntry);
    end;

    trigger OnOpenPage()
    var
        CustomerEntry: Record "Cust. Ledger Entry";
    begin
        CurrPage.Chart.Page.SetDimension(CustomerEntry.FieldNo("Posting Date"));
        CurrPage.Chart.Page.AddSumField(CustomerEntry.FieldNo("Sales (LCY)"));
    end;
}
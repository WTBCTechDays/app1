pageextension 50101 "Item List" extends "Item List"
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
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        ItemLedgerEntry.SetRange("Item No.", Rec."No.");
        CurrPage.Chart.Page.SetVariant(ItemLedgerEntry);
    end;

    trigger OnOpenPage()
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        CurrPage.Chart.Page.SetDimension(ItemLedgerEntry.FieldNo("Posting Date"));
        CurrPage.Chart.Page.AddSumField(ItemLedgerEntry.FieldNo(Quantity));
    end;
}
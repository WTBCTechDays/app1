pageextension 50102 "Vendor List" extends "Vendor List"
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
        VendorEntry: Record "Vendor Ledger Entry";
    begin
        VendorEntry.SetRange("Vendor No.", Rec."No.");
        CurrPage.Chart.Page.SetVariant(VendorEntry);
    end;

    trigger OnOpenPage()
    var
        VendorEntry: Record "Vendor Ledger Entry";
    begin
        CurrPage.Chart.Page.SetDimension(VendorEntry.FieldNo("Posting Date"));
        CurrPage.Chart.Page.AddSumField(VendorEntry.FieldNo("Purchase (LCY)"), true);
    end;
}
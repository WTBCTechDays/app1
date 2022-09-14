page 50100 Chart
{
    Caption = 'Chart';
    PageType = CardPart;

    layout
    {
        area(Content)
        {
            usercontrol(Chart; "Chart")
            {
                ApplicationArea = All;

                trigger OnReady()
                begin
                    Initialize();
                end;
            }
        }
    }

    procedure SetDimension(Dimension: Integer)
    var
        TableKey: Record "Key";
    begin
        if Dimension = DimensionField then
            exit;

        DimensionField := Dimension;
        VolatileDataFresh := false;
        FindKey(DimensionField);

        UpdateData();
    end;

    procedure AddSumField(FieldIndex: Integer)
    begin
        AddSumField(FieldIndex, false);
    end;

    procedure AddSumField(FieldIndex: Integer; Invert: Boolean)
    begin
        if not SumFields.ContainsKey(FieldIndex) then
            SumFields.Add(FieldIndex, Invert);

        VolatileDataFresh := false;

        UpdateData();
    end;

    procedure SetVariant(RecVariant: Variant)
    var
        DataTypeMgt: Codeunit "Data Type Management";
    begin
        if not DataTypeMgt.GetRecordRef(RecVariant, RecRef) then
            Error(VariantNotRecordErr);

        VolatileDataFresh := false;
        RecRefSet := true;
        FindKey(DimensionField);

        UpdateData();
    end;


    procedure SetChartType(NewChartType: Text)
    begin
        ChartType := NewChartType;
    end;

    local procedure UpdateData()
    begin
        if not RecRefSet then
            exit;

        if Ready then
            CurrPage.Chart.SetData(GetData())
        else
            Initialize();
    end;

    local procedure FindKey(FieldNo: Integer)
    var
        TableFieldRef: FieldRef;
        TableKey: Record "Key";
        KeyFields: List of [Text];
        TableKeyIndex: Integer;
    begin
        if not RecRefSet then
            exit;

        if FieldNo = 0 then
            exit;

        TableFieldRef := RecRef.Field(FieldNo);

        TableKey.SetRange(TableNo, RecRef.Number);
        TableKey.SetRange(Enabled, true);

        TableKey.SetRange("Key", TableFieldRef.Name);
        if TableKey.FindFirst() then
            TableKeyIndex := TableKey."No."
        else begin
            TableKey.SetRange("Key");

            if TableKey.FindSet() then
                repeat
                    KeyFields := TableKey."Key".Split(',');

                    if KeyFields.Contains(TableFieldRef.Name) then
                        TableKeyIndex := TableKey."No.";
                until (TableKey.Next() = 0) or (TableKeyIndex <> 0);
        end;

        if TableKeyIndex = 0 then
            Error(KeyNotFoundErr, TableFieldRef.Name);

        KeyIndex := TableKeyIndex;
    end;

    local procedure Initialize()
    begin
        if not RecRefSet then
            exit;

        if Ready then begin
            UpdateData();
            exit;
        end;

        if ChartType = '' then
            ChartType := 'line';

        CurrPage.Chart.Initialize(ChartType, GetData());
        Ready := true;
    end;

    local procedure GetData() Data: JsonObject
    var
        LabelList: List of [Text];
        ChartLabel: Text;
        LabelsJson: JsonArray;
        SumFieldIndex: Integer;
        ChartDataSets: JsonArray;
        ChartDataSet: JsonObject;
        ChartDataSetData: JsonArray;
        SumFieldRef: FieldRef;
        FieldData: List of [Decimal];
        FieldDataEntry: Decimal;
    begin
        PrepareData();
        LabelList := GetLabels();

        foreach ChartLabel in LabelList do begin
            LabelsJson.Add(ChartLabel);
        end;
        Data.Add('labels', LabelsJson);

        foreach SumFieldIndex in SumFields.Keys do begin
            Clear(ChartDataSet);
            Clear(ChartDataSetData);

            SumFieldRef := RecRef.Field(SumFieldIndex);
            ChartDataSet.Add('label', SumFieldRef.Caption);

            FieldData := GetFieldData(SumFieldIndex, LabelList);
            foreach FieldDataEntry in FieldData do begin
                ChartDataSetData.Add(FieldDataEntry);
            end;
            ChartDataSet.Add('data', ChartDataSetData);

            ChartDataSet.Add('backgroundColor', 'rgb(255, 99, 132)');
            ChartDataSet.Add('borderColor', 'rgb(255, 99, 132)');

            ChartDataSets.Add(ChartDataSet);
        end;
        Data.Add('datasets', ChartDataSets);
    end;

    local procedure GetLabels() LabelList: List of [Text];
    var
        SumFieldIndex: Integer;
        ChartLabel: Text;
    begin
        foreach SumFieldIndex in ChartLabelValues.Keys do begin
            foreach ChartLabel in ChartLabelValues.Get(SumFieldIndex).Keys() do begin
                if not LabelList.Contains(ChartLabel) then
                    LabelList.Add(ChartLabel);
            end;
        end;
    end;

    local procedure GetFieldData(SumFieldIndex: Integer; LabelList: List of [Text]) Data: List of [Decimal]
    var
        ChartLabel: Text;
        LabelValue: Decimal;
    begin
        foreach ChartLabel in LabelList do begin
            if not ChartLabelValues.Get(SumFieldIndex).Get(ChartLabel, LabelValue) then
                LabelValue := 0;

            Data.Add(LabelValue);
        end;
    end;

    local procedure PrepareData();
    var
        DimensionFieldRef: FieldRef;
        SumFieldIndex: Integer;
        SumFieldRef: FieldRef;
        LabelValues: Dictionary of [Text, Decimal];
    begin
        if VolatileDataFresh then
            exit;

        Clear(ChartLabelValues);
        DimensionFieldRef := RecRef.Field(DimensionField);

        foreach SumFieldIndex in SumFields.Keys do begin
            Clear(LabelValues);
            ChartLabelValues.Add(SumFieldIndex, LabelValues);
        end;

        RecRef.CurrentKeyIndex(KeyIndex);
        if RecRef.FindFirst() then
            repeat
                DimensionFieldRef.SetRange(DimensionFieldRef.Value);

                foreach SumFieldIndex in SumFields.Keys do begin
                    SumFieldRef := RecRef.Field(SumFieldIndex);
                    ChartLabelValues.Get(SumFieldIndex).Add(Format(DimensionFieldRef.Value), CalcSums(SumFieldRef, SumFields.Get(SumFieldIndex)));
                end;

                RecRef.FindLast();
                DimensionFieldRef.SetRange();
            until RecRef.Next() = 0;

        VolatileDataFresh := true;
    end;

    local procedure CalcSums(SumFieldRef: FieldRef; Invert: Boolean) FieldSum: Decimal
    var
        CurrValue: Decimal;
    begin
        if SumFieldRef.Class = SumFieldRef.Class::FlowField then begin
            repeat
                Clear(CurrValue);

                SumFieldRef.CalcField();
                Evaluate(CurrValue, Format(SumFieldRef.Value));

                if Invert then
                    FieldSum -= CurrValue
                else
                    FieldSum += CurrValue;
            until RecRef.Next() = 0;

            RecRef.FindFirst();
        end else begin
            SumFieldRef.CalcSum();

            if Invert then begin
                FieldSum := SumFieldRef.Value;
                FieldSum *= -1;
            end else
                FieldSum := SumFieldRef.Value;
        end;
    end;

    var
        ChartType: Text;
        RecRefSet: Boolean;
        Ready: Boolean;
        VolatileDataFresh: Boolean;
        ChartLabelValues: Dictionary of [Integer, Dictionary of [Text, Decimal]];
        RecRef: RecordRef;
        SumFields: Dictionary of [Integer, Boolean];
        DimensionField: Integer;
        KeyIndex: Integer;
        VariantNotRecordErr: Label 'Variant is not a record type';
        KeyNotFoundErr: Label 'No Key for field %1 found';
}
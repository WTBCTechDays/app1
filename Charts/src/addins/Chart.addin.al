controladdin Chart
{
    RequestedHeight = 300;
    MinimumHeight = 300;
    MaximumHeight = 300;

    RequestedWidth = 300;
    MinimumWidth = 300;
    MaximumWidth = 700;

    VerticalStretch = false;
    VerticalShrink = false;
    HorizontalStretch = true;
    HorizontalShrink = true;

    Scripts = 'src/addins/js/chartjs.min.js', 'src/addins/js/jquery.min.js', 'src/addins/js/chart.js';
    StartupScript = 'src/addins/js/chartStartUp.js';

    event OnReady();

    procedure Initialize(chartType: Text; data: JsonObject);

    procedure SetData(data: JsonObject);
}
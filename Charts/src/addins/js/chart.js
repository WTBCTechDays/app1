let myChart;
function Initialize(chartType, data) {
    let config = {
        type: chartType,
        data,
        options: {
            responsive: true,
        }
    }

    console.log('Initializing with config:', config);

    const newCanvas = $('<canvas/>', {
        id: 'chart'
    }).prop({
        width: '100%',
        height: '100%',
        position: 'relative'
    });
    
    $('#controlAddIn').append(newCanvas);
    
    myChart = new Chart(
        newCanvas,
        config
    );
}

function SetData(data) {
    console.log('Setting data:', data);

    myChart.data = data;
    myChart.update();
}
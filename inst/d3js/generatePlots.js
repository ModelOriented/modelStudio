function generatePlots(tData, time){
  /// this function generates modelStudio plots

  /// load all data
  var bdData = tData[0],
      cpData = tData[1],
      svData = tData[2];
  // fiData and pdData comes from modelStudio.js file

  var bdBarCount = bdData.m[0],
      fiBarCount = bdData.m[0]-1,
      svBarCount = svData.m[0];

  var plotTop = margin.top, plotLeft = margin.left;

  /// set plot specific measures and colors
  var bdPlotHeight = bdBarCount*barWidth + (bdBarCount+1)*barWidth/2,
      bdPlotWidth = w,
      bdBarWidth = barWidth;

  if (bdPlotHeight<h || TSCALE) {
    bdPlotHeight = h;
    bdBarWidth = h/(3*bdBarCount/2 + 1/2);
  }

  var bdColors = getColors(3, "breakDown"),
      positiveColor = bdColors[0],
      negativeColor = bdColors[1],
      defaultColor = bdColors[2];

  var svPlotHeight = svBarCount*barWidth + (svBarCount+1)*barWidth/2,
      svPlotWidth = w,
      svBarWidth = barWidth;

  if (svPlotHeight<h || TSCALE) {
    svPlotHeight = h;
    svBarWidth = h/(3*svBarCount/2 + 1/2);
  }

  var cpPlotHeight = h,
      cpPlotWidth = w;

  var cpColors = getColors(3, "point"),
      pointColor = cpColors[0],
      lineColor = cpColors[1],
      greyColor = cpColors[2];

  var fiPlotHeight = fiBarCount*barWidth + (fiBarCount+1)*barWidth/2,
      fiPlotWidth = w,
      fiBarWidth = barWidth;

  if (fiPlotHeight<h || TSCALE) {
    fiPlotHeight = h;
    fiBarWidth = h/(3*fiBarCount/2 + 1/2);
  }

  var fiColors = getColors(1, "bar"),
      barColor = fiColors[0];

  var pdPlotHeight = cpPlotHeight,
      pdPlotWidth = cpPlotWidth;

  var adPlotHeight = cpPlotHeight,
      adPlotWidth = cpPlotWidth;

  var fdPlotHeight = cpPlotHeight,
      fdPlotWidth = cpPlotWidth;

  /// initialize plots, select them if already there
  var BD, SV, CP, FI, PD, AD, FD;

  if (svg.select("#BD").empty()) {
    BD = svg.append("g")
                .attr("class","plot")
                .attr("id", "BD")
                .style("visibility", "hidden");
  } else {
    BD = svg.select("#BD");
  }
  breakDown();

  if (svg.select("#SV").empty()) {
    SV = svg.append("g")
            .attr("class","plot")
            .attr("id","SV")
            .style("visibility", "hidden");
  } else {
    SV = svg.select("#SV");
  }
  shapleyValues();

  if (svg.select("#CP").empty()) {
    CP = svg.append("g")
            .attr("class","plot")
            .attr("id", "CP")
            .style("visibility", "hidden");
  } else {
    CP = svg.select("#CP");
  }
  ceterisParibus();

  if (svg.select("#FI").empty()) {
    FI = svg.append("g")
            .attr("class","plot")
            .attr("id","FI")
            .style("visibility", "hidden");
  } else {
    FI = svg.select("#FI");
  }
  featureImportance();

  if (svg.select("#PD").empty()) {
    PD = svg.append("g")
            .attr("class","plot")
            .attr("id","PD")
            .style("visibility", "hidden");
  } else {
    PD = svg.select("#PD");
  }
  partialDependency();

  if (svg.select("#AD").empty()) {
    AD = svg.append("g")
            .attr("class","plot")
            .attr("id","AD")
            .style("visibility", "hidden");
  } else {
    AD = svg.select("#AD");
  }
  accumulatedDependency();

  if (svg.select("#FD").empty()) {
    FD = svg.append("g")
            .attr("class","plot")
            .attr("id","FD")
            .style("visibility", "hidden");
  } else {
    FD = svg.select("#FD");
  }
  featureDistribution();

  ///
  svg.selectAll("text")
     .style('font-family', 'Arial');

  /// general plot functions

  function breakDown() {

    svg.select("#BD").selectAll("*").remove();

    var bData = bdData.x;
    var xMinMax = bdData.x_min_max;

    var x = d3.scaleLinear()
              .range([plotLeft,  plotLeft + bdPlotWidth])
              .domain([xMinMax[0], xMinMax[1]]);

    BD.append("text")
      .attr("transform",
            "translate(" + (plotLeft + bdPlotWidth/2) + " ," +
                           (plotTop + bdPlotHeight + 45) + ")")
      .attr("class", "axisTitle")
      .attr("text-anchor", "middle")
      .text("contribution");

    var xAxis = d3.axisBottom(x)
                  .ticks(5)
                  .tickSize(0);

    xAxis = BD.append("g")
              .attr("class", "axisLabel")
              .attr("transform", "translate(0," + (plotTop + bdPlotHeight) + ")")
              .call(xAxis)
              .call(g => g.select(".domain").remove());

    var y = d3.scaleBand()
              .rangeRound([plotTop, plotTop + bdPlotHeight])
              .padding(0.33)
              .domain(bData.map(d => d.variable));

    var xGrid = BD.append("g")
                  .attr("class", "grid")
                  .attr("transform", "translate(0," + (plotTop + bdPlotHeight) + ")")
                  .call(d3.axisBottom(x)
                          .ticks(10)
                          .tickSize(-bdPlotHeight)
                          .tickFormat("")
                  ).call(g => g.select(".domain").remove());

    var yGrid = BD.append("g")
                  .attr("class", "grid")
                  .attr("transform", "translate(" + plotLeft + ",0)")
                  .call(d3.axisLeft(y)
                          .tickSize(-bdPlotWidth)
                          .tickFormat("")
                  ).call(g => g.select(".domain").remove());

    var yAxis = d3.axisLeft(y)
                  .tickSize(0);

    yAxis = BD.append("g")
              .attr("class", "axisLabel")
              .attr("transform","translate(" + (plotLeft-10) + ",0)")
              .call(yAxis)
              .call(g => g.select(".domain").remove());

    yAxis.select(".tick:last-child").select("text").attr('font-weight', 600);

    // wrap y label text
    yAxis.selectAll("text").call(wrapText, margin.left-15);

    BD.append("text")
      .attr("x", plotLeft)
      .attr("y", plotTop - 15)
      .attr("class", "smallTitle")
      .text(modelName);

    BD.append("text")
      .attr("x", plotLeft)
      .attr("y", plotTop - 40)
      .attr("class", "bigTitle")
      .text(bdTitle);

    // add tooltip
    var tooltip = d3.tip()
                    .attr("class", "tooltip")
                    .offset([-8, 0])
                    .html(d => d.type === "desc" ? descTooltipHtml(d) : bdTooltipHtml(d));

    BD.call(tooltip);

    // find boundaries
    let intercept = bData[0].contribution > 0 ? bData[0].barStart : bData[0].barSupport;

    // make dotted line from intercept to prediction
    var dotLineData = [{"x": x(intercept), "y": y("intercept")},
                       {"x": x(intercept), "y": y("prediction") + bdBarWidth}];

    var lineFunction = d3.line()
                         .x(d => d.x)
                         .y(d => d.y);

    BD.append("path")
      .data([dotLineData])
      .attr("class", "dotLine")
      .attr("d", lineFunction)
      .style("stroke-dasharray", ("1, 2"));

    // add bars
    var bars = BD.selectAll()
                 .data(bData)
                 .enter()
                 .append("g");

    bars.append("rect")
        .attr("class", modelName.replace(/\s/g,''))
        .attr("id", (d) => d.variable_name)
        .attr("fill",function(d){
          switch(d.sign){
            case "-1":
              return negativeColor;
            case "1":
              return positiveColor;
            default:
              return defaultColor;
          }
        })
        .attr("fill-opacity",
        d => x(d.barSupport)-x(d.barStart) < 1 ? 0 : 1) //invisible bar for clicking purpose
        .attr("y", d => y(d.variable))
        .attr("height", y.bandwidth())
        .attr("x", d => d.contribution > 0 ? x(d.barStart) : x(d.barSupport))
        .on('mouseover', tooltip.show)
        .on('mouseout', tooltip.hide)
        .on("click", function(){
          CLICKED_VARIABLE_NAME = this.id;
          updateCP(this.id);
          updatePD(this.id);
          updateAD(this.id);
          updateFD(this.id);
        })
        .transition()
        .duration(time)
        .delay((d,i) => i * time)
        .attr("x", d => x(d.barStart))
        .attr("width", d => x(d.barSupport)-x(d.barStart) < 1 ? 5 : x(d.barSupport) - x(d.barStart));

    // add labels to bars
    var ctbLabel = BD.selectAll()
                     .data(bData)
                     .enter()
                     .append("g");

    ctbLabel.append("text")
            .attr("class", "axisLabel")
            .attr("x", d => {
              switch(d.sign){
                case "X":
                  return d.contribution < 0 ? x(d.barStart) - 5 : x(d.barSupport) + 5;
                default:
                  return x(d.barSupport) + 5;
              }
            })
            .attr("y", d => y(d.variable) + bdBarWidth/2)
            .attr("dy", "0.4em")
            .attr("text-anchor", d => d.sign == "X" && d.contribution < 0 ? "end" : null)
            .transition()
            .duration(time)
            .delay((d,i) => (i+1) * time)
            .text(d => {
              switch(d.variable){
                case "intercept":
                case "prediction":
                  return d.cummulative;
                default:
                  return d.sign === "-1" ? d.contribution : "+"+d.contribution;
              }
            });

    // add lines to bars
    var lines = BD.selectAll()
                  .data(bData)
                  .enter()
                  .append("g");

    lines.append("line")
         .attr("class", "interceptLine")
         .attr("x1", d => d.contribution < 0 ? x(d.barStart) : x(d.barSupport))
         .attr("y1", d => y(d.variable))
         .attr("x2", d => d.contribution < 0 ? x(d.barStart) : x(d.barSupport))
         .attr("y2", d => y(d.variable))
         .transition()
         .duration(time)
         .delay((d,i) => (i+1) * time)
         .attr("y2", d =>
         d.variable == "prediction" ? y(d.variable) : y(d.variable) + bdBarWidth*2.5);

    let desctemp = [{type:"desc", "text":"Description: TBD"}];

    let tempWH = 20;

    var description = BD.append("g")
                        .attr("transform", "translate(" +
                              (plotLeft + bdPlotWidth - tempWH) +
                              "," + (plotTop - tempWH - 5) + ")");

    description.selectAll()
               .data(desctemp)
               .enter()
               .append("rect")
               .attr("class", "descriptionBox")
               .attr("width", tempWH)
               .attr("height", tempWH)
               .on('mouseover', tooltip.show)
               .on('mouseout', tooltip.hide);

    description.selectAll()
               .data(desctemp)
               .enter()
               .append("text")
               .attr("class", "descriptionLabel")
               .attr("dy", "1.1em")
               .attr("x", 5)
               .text("D")
               .on('mouseover', function(d) {
                 tooltip.show(d);
                 d3.select(this).style("cursor", "default");
               })
               .on('mouseout', tooltip.hide);
  }

  function shapleyValues() {

    svg.select("#SV").selectAll("*").remove();

    var bData = svData.x;
    var xMinMax = svData.x_min_max;

    var x = d3.scaleLinear()
              .range([plotLeft,  plotLeft + svPlotWidth])
              .domain([xMinMax[0], xMinMax[1]]);

    SV.append("text")
      .attr("transform",
            "translate(" + (plotLeft + svPlotWidth/2) + " ," +
                           (plotTop + svPlotHeight + 45) + ")")
      .attr("class", "axisTitle")
      .attr("text-anchor", "middle")
      .text("contribution");

    var xAxis = d3.axisBottom(x)
                  .ticks(5)
                  .tickSize(0);

    xAxis = SV.append("g")
              .attr("class", "axisLabel")
              .attr("transform", "translate(0," + (plotTop + svPlotHeight) + ")")
              .call(xAxis)
              .call(g => g.select(".domain").remove());

    var y = d3.scaleBand()
              .rangeRound([plotTop, plotTop + svPlotHeight])
              .padding(0.33)
              .domain(bData.map(d => d.variable));

    var xGrid = SV.append("g")
                  .attr("class", "grid")
                  .attr("transform", "translate(0," + (plotTop + svPlotHeight) + ")")
                  .call(d3.axisBottom(x)
                          .ticks(10)
                          .tickSize(-svPlotHeight)
                          .tickFormat("")
                  ).call(g => g.select(".domain").remove());

    var yGrid = SV.append("g")
                  .attr("class", "grid")
                  .attr("transform", "translate(" + plotLeft + ",0)")
                  .call(d3.axisLeft(y)
                          .tickSize(-svPlotWidth)
                          .tickFormat("")
                  ).call(g => g.select(".domain").remove());

    var yAxis = d3.axisLeft(y)
                  .tickSize(0);

    yAxis = SV.append("g")
              .attr("class", "axisLabel")
              .attr("transform","translate(" + (plotLeft-10) + ",0)")
              .call(yAxis)
              .call(g => g.select(".domain").remove());

    // wrap y label text
    yAxis.selectAll("text").call(wrapText, margin.left-15);

    SV.append("text")
      .attr("x", plotLeft)
      .attr("y", plotTop - 15)
      .attr("class", "smallTitle")
      .text(modelName);

    SV.append("text")
      .attr("x", plotLeft)
      .attr("y", plotTop - 40)
      .attr("class", "bigTitle")
      .text(svTitle);

    // add tooltip
    var tooltip = d3.tip()
                    .attr("class", "tooltip")
                    .offset([-8, 0])
                    .html(d => d.type === "desc" ? descTooltipHtml(d) : bdTooltipHtml(d));

    SV.call(tooltip);

    // add bars
    var bars = SV.selectAll()
                 .data(bData)
                 .enter()
                 .append("g");

    bars.append("rect")
        .attr("class", modelName.replace(/\s/g,''))
        .attr("id", (d) => d.variable_name)
        .attr("fill",function(d){
          switch(d.sign){
            case "-1":
              return negativeColor;
            case "1":
              return positiveColor;
            default:
              return defaultColor;
          }
        })
        .attr("fill-opacity",
        d => x(d.barSupport)-x(d.barStart) < 1 ? 0 : 1) //invisible bar for clicking purpose
        .attr("x", d => d.contribution > 0 ? x(d.barStart) : x(d.barSupport))
        .attr("y", d => y(d.variable))
        .attr("height", y.bandwidth())
        .on('mouseover', tooltip.show)
        .on('mouseout', tooltip.hide)
        .on("click", function(){
          CLICKED_VARIABLE_NAME = this.id;
          updateCP(this.id);
          updatePD(this.id);
          updateAD(this.id);
          updateFD(this.id);
        })
        .transition()
        .duration(time)
        .delay((d,i) => i * time)
        .attr("x", d => x(d.barStart))
        .attr("width", d => x(d.barSupport)-x(d.barStart) < 1 ? 5 : x(d.barSupport) - x(d.barStart));

    // add labels to bars
    var ctbLabel = SV.selectAll()
                     .data(bData)
                     .enter()
                     .append("g");

    ctbLabel.append("text")
            .attr("class", "axisLabel")
            .attr("x", d => d.contribution < 0 ? x(d.barStart) - 5 : x(d.barSupport) + 5)
            .attr("y", d => y(d.variable) + svBarWidth/2)
            .attr("dy", "0.4em")
            .attr("text-anchor", d => d.sign == "-1" ? "end" : "start")
            .transition()
            .duration(time)
            .delay((d,i) => (i+1) * time)
            .text(d => d.sign === "-1" ? d.contribution : "+"+d.contribution);

    // add lines to bars
    var lines = SV.selectAll()
                  .data(bData)
                  .enter()
                  .append("g");

    lines.append("line")
          .attr("class", "interceptLine")
          .attr("x1", d => d.contribution < 0 ? x(d.barSupport) : x(d.barStart))
          .attr("y1", d => y(d.variable))
          .attr("x2", d => d.contribution < 0 ? x(d.barSupport) : x(d.barStart))
          .attr("y2", d => y(d.variable))
          .transition()
          .duration(time)
          .delay((d,i) => (i+1) * time)
          .attr("y2", (d,i) =>
          i == svBarCount-1 ? y(d.variable) + svBarWidth : y(d.variable) + svBarWidth*2.5);

    let desctemp = [{type:"desc", "text":"Description: TBD"}];

    let tempWH = 20;

    var description = SV.append("g")
                        .attr("transform", "translate(" +
                              (plotLeft + svPlotWidth - tempWH) +
                              "," + (plotTop - tempWH - 5) + ")");

    description.selectAll()
               .data(desctemp)
               .enter()
               .append("rect")
               .attr("class", "descriptionBox")
               .attr("width", tempWH)
               .attr("height", tempWH)
               .on('mouseover', tooltip.show)
               .on('mouseout', tooltip.hide);

    description.selectAll()
               .data(desctemp)
               .enter()
               .append("text")
               .attr("class", "descriptionLabel")
               .attr("dy", "1.1em")
               .attr("x", 5)
               .text("D")
               .on('mouseover', function(d) {
                 tooltip.show(d);
                 d3.select(this).style("cursor", "default");
               })
               .on('mouseout', tooltip.hide);
  }

  function ceterisParibus() {

    svg.select("#CP").selectAll("*").remove();

    var profData = cpData.x;
    var xMinMax = cpData.x_min_max_list;
    var yMinMax = cpData.y_min_max;
    var obsData = cpData.observation;
    var isNumeric = cpData.is_numeric;

    let variableName = CLICKED_VARIABLE_NAME;

    // lines or bars?
    if (isNumeric[variableName][0]) {
      cpNumericalPlot(variableName, profData[variableName], xMinMax[variableName],
                      yMinMax, obsData);
    } else {
      cpCategoricalPlot(variableName, profData[variableName],
                        yMinMax, obsData);
    }
  }

  function featureImportance() {

    svg.select("#FI").selectAll("*").remove();

    var bData = fiData.x;
    var xMinMax = fiData.x_min_max;

    var x = d3.scaleLinear()
              .range([plotLeft, plotLeft + fiPlotWidth])
              .domain([xMinMax[0], xMinMax[1]]);

    FI.append("text")
      .attr("transform",
            "translate(" + (plotLeft + fiPlotWidth/2) + " ," +
                           (plotTop + fiPlotHeight + 45) + ")")
      .attr("class", "axisTitle")
      .attr("text-anchor", "middle")
      .text("drop-out loss");

    var xAxis = d3.axisBottom(x)
                  .ticks(5)
                  .tickSize(0);

    xAxis = FI.append("g")
              .attr("class", "axisLabel")
              .attr("transform", "translate(0," + (plotTop + fiPlotHeight) + ")")
              .call(xAxis)
              .call(g => g.select(".domain").remove());

    var y = d3.scaleBand()
              .rangeRound([plotTop + fiPlotHeight, plotTop])
              .padding(0.33)
              .domain(bData.map(d => d.variable));

    var xGrid = FI.append("g")
                  .attr("class", "grid")
                  .attr("transform", "translate(0," + (plotTop + fiPlotHeight) + ")")
                  .call(d3.axisBottom(x)
                          .ticks(10)
                          .tickSize(-fiPlotHeight)
                          .tickFormat("")
                  ).call(g => g.select(".domain").remove());

    var yGrid = FI.append("g")
                  .attr("class", "grid")
                  .attr("transform", "translate(" + plotLeft + ",0)")
                  .call(d3.axisLeft(y)
                          .tickSize(-fiPlotWidth)
                          .tickFormat("")
                  ).call(g => g.select(".domain").remove());

    var yAxis = d3.axisLeft(y)
                  .tickSize(0);

    yAxis = FI.append("g")
              .attr("class", "axisLabel")
              .attr("transform","translate(" + (plotLeft-10) + ",0)")
              .call(yAxis)
              .call(g => g.select(".domain").remove());

    yAxis.selectAll("text").call(wrapText, margin.left-15);

    FI.append("text")
      .attr("x", plotLeft)
      .attr("y", plotTop - 40)
      .attr("class", "bigTitle")
      .text(fiTitle);

    FI.append("text")
      .attr("x", plotLeft)
      .attr("y", plotTop - 15)
      .attr("class", "smallTitle")
      .text(modelName);

    // tooltip
    var tooltip = d3.tip()
                    .attr("class", "tooltip")
                    .offset([-8, 0])
                    .html(d => d.type === "desc" ?
                     descTooltipHtml(d) : fiStaticTooltipHtml(d, modelName));
    FI.call(tooltip);

    // bars
    var bars = FI.selectAll()
                 .data(bData)
                 .enter()
                 .append("g");

    // find full model dropout_loss value
    var fullModel = bData[0].full_model;

    bars.append("rect")
        .attr("class", modelName.replace(/\s/g,''))
        .attr("fill", barColor)
        .attr("y", d => y(d.variable))
        .attr("height", y.bandwidth())
        .attr("x", d => x(d.dropout_loss) < x(fullModel) ? x(d.dropout_loss) : x(fullModel))
        .attr("width", d => Math.abs(x(d.dropout_loss) - x(fullModel)))
        .on('mouseover', tooltip.show)
        .on('mouseout', tooltip.hide)
        .attr("id", (d) => d.variable)
        .on("click", function(){
          CLICKED_VARIABLE_NAME = this.id;
          updateCP(this.id);
          updatePD(this.id);
          updateAD(this.id);
          updateFD(this.id);
        });

    // make line next to bars
    var minimumY = Number.MAX_VALUE;
    var maximumY = Number.MIN_VALUE;
    bars.selectAll(".".concat(modelName.replace(/\s/g,''))).each(function() {
      if (+this.getAttribute('y') < minimumY) {
        minimumY = +this.getAttribute('y');
      }
      if (+this.getAttribute('y') > maximumY) {
        maximumY = +this.getAttribute('y');
      }
    });

    FI.append("line")
      .attr("class", "interceptLine")
      .attr("x1", x(fullModel))
      .attr("y1", minimumY)
      .attr("x2", x(fullModel))
      .attr("y2", maximumY + y.bandwidth());

    let desctemp = [{type:"desc", "text":"Description: TBD"}];

    let tempWH = 20;

    var description = FI.append("g")
                        .attr("transform", "translate(" +
                              (plotLeft + fiPlotWidth - tempWH) +
                              "," + (plotTop - tempWH - 5) + ")");

    description.selectAll()
               .data(desctemp)
               .enter()
               .append("rect")
               .attr("class", "descriptionBox")
               .attr("width", tempWH)
               .attr("height", tempWH)
               .on('mouseover', tooltip.show)
               .on('mouseout', tooltip.hide);

    description.selectAll()
               .data(desctemp)
               .enter()
               .append("text")
               .attr("class", "descriptionLabel")
               .attr("dy", "1.1em")
               .attr("x", 5)
               .text("D")
               .on('mouseover', function(d) {
                 tooltip.show(d);
                 d3.select(this).style("cursor", "default");
               })
               .on('mouseout', tooltip.hide);
  }

  function partialDependency() {

    svg.select("#PD").selectAll("*").remove();

    var profData = pdData.x;
    var xMinMax = pdData.x_min_max_list;
    var yMinMax = pdData.y_min_max;
    var yMean = pdData.y_mean;
    var isNumeric = pdData.is_numeric;

    let variableName = CLICKED_VARIABLE_NAME;

    // lines or bars?
    if (isNumeric[variableName][0]) {
      pdNumericalPlot(variableName, profData[variableName], xMinMax[variableName],
                      yMinMax, yMean);
    } else {
      pdCategoricalPlot(variableName, profData[variableName],
                        yMinMax, yMean);
    }
  }

  function accumulatedDependency() {

    svg.select("#AD").selectAll("*").remove();

    var profData = adData.x;
    var xMinMax = adData.x_min_max_list;
    var yMinMax = adData.y_min_max;
    var yMean = adData.y_mean;
    var isNumeric = adData.is_numeric;

    let variableName = CLICKED_VARIABLE_NAME;

    // lines or bars?
    if (isNumeric[variableName][0]) {
      adNumericalPlot(variableName, profData[variableName], xMinMax[variableName],
                      yMinMax, yMean);
    } else {
      adCategoricalPlot(variableName, profData[variableName],
                        yMinMax, yMean);
    }
  }

  function featureDistribution() {

    svg.select("#FD").selectAll("*").remove();

    var dData = fdData.x;
    var xMinMax = fdData.x_min_max_list;
    var xMax = fdData.x_max_list;
    var nBin = fdData.nbin;
    var isNumeric = fdData.is_numeric;

    let variableName = CLICKED_VARIABLE_NAME;

    // histogram or bars?
    if (isNumeric[variableName][0]) {
      fdNumericalPlot(variableName, dData, xMinMax[variableName],
                      nBin[variableName]);
    } else {
      fdCategoricalPlot(variableName, dData, xMax[variableName]);
    }
  }

  /// update plot functions

  function updateCP(variableName) {

    if (variableName == "prediction" || variableName == "intercept" ||
        variableName == "other") { return;}

    svg.select("#CP").selectAll("*").remove();
    d3.select("body").select("#tooltipCP").remove();

    var profData = cpData.x;
    var xMinMax = cpData.x_min_max_list;
    var yMinMax = cpData.y_min_max;
    var obsData = cpData.observation;
    var isNumeric = cpData.is_numeric;

    // lines or bars?
    if (isNumeric[variableName][0]) {
      cpNumericalPlot(variableName, profData[variableName], xMinMax[variableName],
                      yMinMax, obsData);
    } else {
      cpCategoricalPlot(variableName, profData[variableName],
                        yMinMax, obsData);
    }

    // safeguard font-family update
    svg.selectAll("text")
       .style('font-family', 'Arial');
  }

  function updatePD(variableName) {

    if (variableName == "prediction" || variableName == "intercept" ||
        variableName == "other") { return;}

    svg.select("#PD").selectAll("*").remove();
    d3.select("body").select("#tooltipPD").remove();

    var profData = pdData.x;
    var xMinMax = pdData.x_min_max_list;
    var yMinMax = pdData.y_min_max;
    var yMean = pdData.y_mean;
    var isNumeric = pdData.is_numeric;

    // lines or bars?
    if (isNumeric[variableName][0]) {
      pdNumericalPlot(variableName, profData[variableName], xMinMax[variableName],
                      yMinMax, yMean);
    } else {
      pdCategoricalPlot(variableName, profData[variableName],
                        yMinMax, yMean);
    }

    // safeguard font-family update
    svg.selectAll("text")
       .style('font-family', 'Arial');
  }

  function updateAD(variableName) {

    if (variableName == "prediction" || variableName == "intercept" ||
        variableName == "other") { return;}

    svg.select("#AD").selectAll("*").remove();
    d3.select("body").select("#tooltipAD").remove();

    var profData = adData.x;
    var xMinMax = adData.x_min_max_list;
    var yMinMax = adData.y_min_max;
    var yMean = adData.y_mean;
    var isNumeric = adData.is_numeric;

    // lines or bars?
    if (isNumeric[variableName][0]) {
      adNumericalPlot(variableName, profData[variableName], xMinMax[variableName],
                      yMinMax, yMean);
    } else {
      adCategoricalPlot(variableName, profData[variableName],
                        yMinMax, yMean);
    }

    // safeguard font-family update
    svg.selectAll("text")
       .style('font-family', 'Arial');
  }

  function updateFD(variableName) {

    if (variableName == "prediction" || variableName == "intercept" ||
        variableName == "other") { return;}

    svg.select("#FD").selectAll("*").remove();
    d3.select("body").select("#tooltipFD").remove();

    var dData = fdData.x;
    var xMinMax = fdData.x_min_max_list;
    var xMax = fdData.x_max_list;
    var nBin = fdData.nbin;
    var isNumeric = fdData.is_numeric;

    // histogram or bars?
    if (isNumeric[variableName][0]) {
      fdNumericalPlot(variableName, dData, xMinMax[variableName],
                      nBin[variableName]);
    } else {
      fdCategoricalPlot(variableName, dData, xMax[variableName]);
    }

    // safeguard font-family update
    svg.selectAll("text")
       .style('font-family', 'Arial');
  }

  /// small plot functions

  function cpNumericalPlot(variableName, lData, mData, yMinMax, pData) {

    var x = d3.scaleLinear()
              .range([plotLeft + 10, plotLeft + cpPlotWidth - 10])
              .domain([mData[0], mData[1]]);

    CP.append("text")
      .attr("transform",
            "translate(" + (plotLeft + cpPlotWidth/2) + " ," +
                           (plotTop + cpPlotHeight + 45) + ")")
      .attr("class", "axisTitle")
      .attr("text-anchor", "middle")
      .text(variableName + " = " + pData[0][variableName]);

    var y = d3.scaleLinear()
              .range([plotTop + cpPlotHeight, plotTop])
              .domain([yMinMax[0], yMinMax[1]]);

    var line = d3.line()
                 .x(d => x(d.xhat))
                 .y(d => y(d.yhat))
                 .curve(d3.curveMonotoneX);

    CP.append("text")
      .attr("class", "bigTitle")
      .attr("x", plotLeft)
      .attr("y", plotTop - 40)
      .text(cpTitle);

    CP.append("text")
      .attr("class","smallTitle")
      .attr("x", plotLeft)
      .attr("y", plotTop - 15)
      .text(modelName); //variableName + " = " + pData[0][variableName]

    // find 5 nice ticks with max and min - do better than d3
    var tickValues = getTickValues(x.domain());

    var xAxis = d3.axisBottom(x)
                  .tickValues(tickValues)
                  .tickSizeInner(0)
                  .tickPadding(15);

    xAxis = CP.append("g")
              .attr("class", "axisLabel")
              .attr("transform", "translate(0,"+ (plotTop + cpPlotHeight) + ")")
              .call(xAxis);

    var yGrid = CP.append("g")
                  .attr("class", "grid")
                  .attr("transform", "translate(" + plotLeft + ",0)")
                  .call(d3.axisLeft(y)
                          .ticks(10)
                          .tickSize(-cpPlotWidth)
                          .tickFormat("")
                  ).call(g => g.select(".domain").remove());

    var yAxis = d3.axisLeft(y)
                  .ticks(5)
                  .tickSize(0);

    yAxis = CP.append("g")
              .attr("class", "axisLabel")
              .attr("transform","translate(" + plotLeft + ",0)")
              .call(yAxis)
              .call(g => g.select(".domain").remove());

    // make tooltip
    var tooltip = d3.tip()
                    .attr("class", "tooltip")
                    .attr("id", "tooltipCP")
                    .offset([-8, 0])
                    .html((d, addData) => {

                      if (d.type === "desc") {
                        return descTooltipHtml(d)
                      } else if (addData !== undefined) {
                        return cpChangedTooltipHtml(d, addData);
                      } else {
                          return cpStaticTooltipHtml(d);
                      }
                     });
    CP.call(tooltip);

    // function to find nearest point on the line
    var bisectXhat = d3.bisector(d => d.xhat).right;

    // show tooltip with info nearest to mouseover
    function showTooltip(hover){
      var x0 = x.invert(d3.mouse(d3.event.currentTarget)[0]),
          i = bisectXhat(hover, x0),
          d0 = hover[i - 1],
          d1 = hover[i],
          d = x0 - d0.xhat > d1.xhat - x0 ? d1 : d0;
      let temp = pData.find(el => el["observation.id"] === d.id);
      tooltip.show(d, temp);
    }

    // add lines
    CP.append("path")
      .data([lData])
      .attr("class", "line " + variableName)
      .attr("d", line)
      .style("fill", "none")
      .style("stroke", lineColor)
      .style("opacity", alpha)
      .style("stroke-width", size)
      .on('mouseover', function(d){

        // make mouseover line more visible
        d3.select(this)
          .style("stroke", pointColor)
          .style("stroke-width", size*1.5);

        // make line and points appear on top
        this.parentNode.appendChild(this);
        d3.select(this.parentNode).selectAll(".point").each(function() {
                         this.parentNode.appendChild(this);
                    });

        // show changed tooltip
        showTooltip(d);
      })
      .on('mouseout', function(d){

        d3.select(this)
          .style("stroke", lineColor)
          .style("stroke-width", size);

        // hide changed tooltip
        tooltip.hide(d);
      });

    // add points
    CP.selectAll()
      .data(pData)
      .enter()
      .append("circle")
      .attr("class", "point")
      .attr("id", d => d["observation.id"])
      .attr("cx", d => x(d[variableName]))
      .attr("cy", d => y(d.yhat))
      .attr("r", 3)
      .style("stroke-width", 15)
      .style("stroke", "red")
      .style("stroke-opacity", 0)
      .style("fill", pointColor)
      .on('mouseover', function(d) {
        tooltip.show(d);
    		d3.select(this)
    			.attr("r", 6);
    	})
      .on('mouseout', function(d) {
        tooltip.hide(d);
    		d3.select(this)
    			.attr("r", 3);
    	});

    if (showRugs === true) {

      // add rugs
      CP.selectAll()
        .data(pData)
        .enter()
        .append("line")
        .attr("class", "rugLine")
        .style("stroke", "red")
        .style("stroke-width", 2)
        .attr("x1", d => x(d[variableName]))
        .attr("y1", plotTop + cpPlotHeight)
        .attr("x2", d => x(d[variableName]))
        .attr("y2", plotTop + cpPlotHeight - 10);
    }

    CP.append("text")
      .attr("class", "axisTitle")
      .attr("transform", "rotate(-90)")
      .attr("y", plotLeft-40)
      .attr("x", -(plotTop + cpPlotHeight/2))
      .attr("text-anchor", "middle")
      .text("prediction");

    let desctemp = [{type:"desc", "text":"Description: TBD"}];

    let tempWH = 20;

    var description = CP.append("g")
                        .attr("transform", "translate(" +
                              (plotLeft + cpPlotWidth - tempWH) +
                              "," + (plotTop - tempWH - 5) + ")");

    description.selectAll()
               .data(desctemp)
               .enter()
               .append("rect")
               .attr("class", "descriptionBox")
               .attr("width", tempWH)
               .attr("height", tempWH)
               .on('mouseover', tooltip.show)
               .on('mouseout', tooltip.hide);

    description.selectAll()
               .data(desctemp)
               .enter()
               .append("text")
               .attr("class", "descriptionLabel")
               .attr("dy", "1.1em")
               .attr("x", 5)
               .text("D")
               .on('mouseover', function(d) {
                 tooltip.show(d);
                 d3.select(this).style("cursor", "default");
               })
               .on('mouseout', tooltip.hide);
  }

  function cpCategoricalPlot(variableName, bData, yMinMax, lData) {

    var x = d3.scaleLinear()
              .range([plotLeft,  plotLeft + cpPlotWidth])
              .domain([yMinMax[0], yMinMax[1]]); // because it is flipped 
 
    var xAxis = d3.axisBottom(x)
                  .ticks(5)
                  .tickSize(0);

    xAxis = CP.append("g")
              .attr("class", "axisLabel")
              .attr("transform", "translate(0," + (plotTop + cpPlotHeight) + ")")
              .call(xAxis)
              .call(g => g.select(".domain").remove());

    var y = d3.scaleBand()
              .rangeRound([plotTop + cpPlotHeight, plotTop])
              .padding(0.33)
              .domain(bData.map(d => d.xhat));

    var xGrid = CP.append("g")
                  .attr("class", "grid")
                  .attr("transform", "translate(0," + (plotTop + cpPlotHeight) + ")")
                  .call(d3.axisBottom(x)
                          .ticks(10)
                          .tickSize(-cpPlotHeight)
                          .tickFormat("")
                  ).call(g => g.select(".domain").remove());

    var yGrid = CP.append("g")
                  .attr("class", "grid")
                  .attr("transform", "translate(" + plotLeft + ",0)")
                  .call(d3.axisLeft(y)
                          .tickSize(-cpPlotWidth)
                          .tickFormat("")
                  ).call(g => g.select(".domain").remove());

    var yAxis = d3.axisLeft(y)
                  .tickSize(0);

    yAxis = CP.append("g")
              .attr("class", "axisLabel")
              .attr("transform","translate(" + (plotLeft-8) + ",0)")
              .call(yAxis)
              .call(g => g.select(".domain").remove());

    yAxis.selectAll("text").call(wrapText, margin.left-15);

    CP.append("text")
      .attr("x", plotLeft)
      .attr("y", plotTop - 15)
      .attr("class", "smallTitle")
      .text(modelName); //variableName + " = " + lData[0][variableName]

    CP.append("text")
      .attr("x", plotLeft)
      .attr("y", plotTop - 40)
      .attr("class", "bigTitle")
      .text(cpTitle);

    var bars = CP.selectAll()
                 .data(bData)
                 .enter()
                 .append("g");

    var fullModel = lData[0].yhat;

    // make tooltip
    var tooltip = d3.tip()
                    .attr("class", "tooltip")
                    .attr("id", "tooltipCP")
                    .offset([-8, 0])
                    .html(d => d.type === "desc" ?
                     descTooltipHtml(d) : cpChangedTooltipHtml(d, lData[0]));
    CP.call(tooltip);

    // add bars
    bars.append("rect")
        .attr("class", variableName)
        .attr("fill", lineColor)
        .attr("y", d => y(d.xhat))
        .attr("height", y.bandwidth())
        .attr("x", d => x(d.yhat) < x(fullModel) ? x(d.yhat) : x(fullModel))
        .attr("width", d => Math.abs(x(d.yhat) - x(fullModel)))
        .on('mouseover', tooltip.show)
        .on('mouseout', tooltip.hide);

    // add intercept line
    var minimumY = Number.MAX_VALUE;
    var maximumY = Number.MIN_VALUE;

    bars.selectAll(".".concat(variableName)).each(function() {
        if (+this.getAttribute('y') < minimumY) {
          minimumY = +this.getAttribute('y');
        }
        if (+this.getAttribute('y') > maximumY) {
          maximumY = +this.getAttribute('y');
        }
      });

    CP.append("line")
      .attr("class", "interceptLine")
      .attr("x1", x(fullModel))
      .attr("y1", minimumY)
      .attr("x2", x(fullModel))
      .attr("y2", maximumY + y.bandwidth());

    CP.append("text")
      .attr("transform",
            "translate(" + (plotLeft + cpPlotWidth/2) + " ," +
                           (plotTop + cpPlotHeight + 45) + ")")
      .attr("class", "axisTitle")
      .attr("text-anchor", "middle")
      .text("prediction");

    let desctemp = [{type:"desc", "text":"Description: TBD"}];

    let tempWH = 20;

    var description = CP.append("g")
                        .attr("transform", "translate(" +
                              (plotLeft + cpPlotWidth - tempWH) +
                              "," + (plotTop - tempWH - 5) + ")");

    description.selectAll()
               .data(desctemp)
               .enter()
               .append("rect")
               .attr("class", "descriptionBox")
               .attr("width", tempWH)
               .attr("height", tempWH)
               .on('mouseover', tooltip.show)
               .on('mouseout', tooltip.hide);

    description.selectAll()
               .data(desctemp)
               .enter()
               .append("text")
               .attr("class", "descriptionLabel")
               .attr("dy", "1.1em")
               .attr("x", 5)
               .text("D")
               .on('mouseover', function(d) {
                 tooltip.show(d);
                 d3.select(this).style("cursor", "default");
               })
               .on('mouseout', tooltip.hide);
  }

  function pdNumericalPlot(variableName, lData, mData, yMinMax, yMean) {

    var x = d3.scaleLinear()
              .range([plotLeft + 10, plotLeft + pdPlotWidth - 10])
              .domain([mData[0], mData[1]]);

    PD.append("text")
      .attr("transform",
            "translate(" + (plotLeft + pdPlotWidth/2) + " ," +
                           (plotTop + pdPlotHeight + 45) + ")")
      .attr("class", "axisTitle")
      .attr("text-anchor", "middle")
      .text(variableName);

    var y = d3.scaleLinear()
              .range([plotTop + pdPlotHeight, plotTop])
              .domain([yMinMax[0], yMinMax[1]]);

    var line = d3.line()
                 .x(d => x(d.xhat))
                 .y(d => y(d.yhat))
                 .curve(d3.curveMonotoneX);

    PD.append("text")
      .attr("class", "bigTitle")
      .attr("x", plotLeft)
      .attr("y", plotTop - 40)
      .text(pdTitle);

    PD.append("text")
      .attr("class","smallTitle")
      .attr("x", plotLeft)
      .attr("y", plotTop - 15)
      .text(modelName); // variableName

    // find 5 nice ticks with max and min - do better than d3
    var tickValues = getTickValues(x.domain());

    var xAxis = d3.axisBottom(x)
                  .tickValues(tickValues)
                  .tickSizeInner(0)
                  .tickPadding(15);

    xAxis = PD.append("g")
              .attr("class", "axisLabel")
              .attr("transform", "translate(0,"+ (plotTop + pdPlotHeight) + ")")
              .call(xAxis);

    var yGrid = PD.append("g")
                  .attr("class", "grid")
                  .attr("transform", "translate(" + plotLeft + ",0)")
                  .call(d3.axisLeft(y)
                          .ticks(10)
                          .tickSize(-pdPlotWidth)
                          .tickFormat("")
                  ).call(g => g.select(".domain").remove());

    var yAxis = d3.axisLeft(y)
                  .ticks(5)
                  .tickSize(0);

    yAxis = PD.append("g")
              .attr("class", "axisLabel")
              .attr("transform","translate(" + plotLeft + ",0)")
              .call(yAxis)
              .call(g => g.select(".domain").remove());

    // make tooltip
    var tooltip = d3.tip()
                    .attr("class", "tooltip")
                    .attr("id", "tooltipPD")
                    .offset([-8, 0])
                    .html(d => d.type === "desc" ?
                     descTooltipHtml(d) : pdStaticTooltipHtml(d, variableName, yMean));
    PD.call(tooltip);

    // function to find nearest point on the line
    var bisectXhat = d3.bisector(d => d.xhat).right;

    // show tooltip with info nearest to mouseover
    function showTooltip(hover){
      var x0 = x.invert(d3.mouse(d3.event.currentTarget)[0]),
          i = bisectXhat(hover, x0),
          d0 = hover[i - 1],
          d1 = hover[i],
          d = x0 - d0.xhat > d1.xhat - x0 ? d1 : d0;

      tooltip.show(d);
    }

    // add lines
    PD.append("path")
      .data([lData])
      .attr("class", "line " + variableName)
      .attr("d", line)
      .style("fill", "none")
      .style("stroke", lineColor)
      .style("opacity", alpha)
      .style("stroke-width", size)
      .on('mouseover', function(d){

        // make mouseover line more visible
        d3.select(this)
          .style("stroke", pointColor)
          .style("stroke-width", size*1.5);

        // make line appear on top
        this.parentNode.appendChild(this);

        // show changed tooltip
        showTooltip(d);
      })
      .on('mouseout', function(d){

        d3.select(this)
          .style("stroke", lineColor)
          .style("stroke-width", size);

        // hide changed tooltip
        tooltip.hide(d);
      });

    PD.append("text")
      .attr("class", "axisTitle")
      .attr("transform", "rotate(-90)")
      .attr("y", plotLeft-40)
      .attr("x", -(plotTop + pdPlotHeight/2))
      .attr("text-anchor", "middle")
      .text("average prediction");

    let desctemp = [{type:"desc", "text":"Description: TBD"}];

    let tempWH = 20;

    var description = PD.append("g")
                        .attr("transform", "translate(" +
                              (plotLeft + pdPlotWidth - tempWH) +
                              "," + (plotTop - tempWH - 5) + ")");

    description.selectAll()
               .data(desctemp)
               .enter()
               .append("rect")
               .attr("class", "descriptionBox")
               .attr("width", tempWH)
               .attr("height", tempWH)
               .on('mouseover', tooltip.show)
               .on('mouseout', tooltip.hide);

    description.selectAll()
               .data(desctemp)
               .enter()
               .append("text")
               .attr("class", "descriptionLabel")
               .attr("dy", "1.1em")
               .attr("x", 5)
               .text("D")
               .on('mouseover', function(d) {
                 tooltip.show(d);
                 d3.select(this).style("cursor", "default");
               })
               .on('mouseout', tooltip.hide);
  }

  function pdCategoricalPlot(variableName, bData, yMinMax, yMean) {

    var x = d3.scaleLinear()
              .range([plotLeft,  plotLeft + pdPlotWidth])
              .domain([yMinMax[0], yMinMax[1]]); // because it is flipped 

    var xAxis = d3.axisBottom(x)
                  .ticks(5)
                  .tickSize(0);

    xAxis = PD.append("g")
              .attr("class", "axisLabel")
              .attr("transform", "translate(0," + (plotTop + pdPlotHeight) + ")")
              .call(xAxis)
              .call(g => g.select(".domain").remove());

    var y = d3.scaleBand()
              .rangeRound([plotTop + pdPlotHeight, plotTop])
              .padding(0.33)
              .domain(bData.map(d => d.xhat));

    var xGrid = PD.append("g")
                  .attr("class", "grid")
                  .attr("transform", "translate(0," + (plotTop + pdPlotHeight) + ")")
                  .call(d3.axisBottom(x)
                          .ticks(10)
                          .tickSize(-pdPlotHeight)
                          .tickFormat("")
                  ).call(g => g.select(".domain").remove());

    var yGrid = PD.append("g")
                  .attr("class", "grid")
                  .attr("transform", "translate(" + plotLeft + ",0)")
                  .call(d3.axisLeft(y)
                          .tickSize(-pdPlotWidth)
                          .tickFormat("")
                  ).call(g => g.select(".domain").remove());

    var yAxis = d3.axisLeft(y)
                  .tickSize(0);

    yAxis = PD.append("g")
              .attr("class", "axisLabel")
              .attr("transform","translate(" + (plotLeft-8) + ",0)")
              .call(yAxis)
              .call(g => g.select(".domain").remove());

    PD.append("text")
      .attr("x", plotLeft)
      .attr("y", plotTop - 15)
      .attr("class", "smallTitle")
      .text(modelName); // variableName

    PD.append("text")
      .attr("x", plotLeft)
      .attr("y", plotTop - 40)
      .attr("class", "bigTitle")
      .text(pdTitle);

    var bars = PD.selectAll()
                 .data(bData)
                 .enter()
                 .append("g");

    var fullModel = yMean;

    // make tooltip
    var tooltip = d3.tip()
                    .attr("class", "tooltip")
                    .attr("id", "tooltipPD")
                    .offset([-8, 0])
                    .html(d => d.type === "desc" ?
                     descTooltipHtml(d) : pdStaticTooltipHtml(d, variableName, yMean));
    PD.call(tooltip);

    // add bars
    bars.append("rect")
        .attr("class", variableName)
        .attr("fill", lineColor)
        .attr("y", d => y(d.xhat))
        .attr("height", y.bandwidth())
        .attr("x", d => x(d.yhat) < x(fullModel) ? x(d.yhat) : x(fullModel))
        .attr("width", d => Math.abs(x(d.yhat) - x(fullModel)))
        .on('mouseover', tooltip.show)
        .on('mouseout', tooltip.hide);

    // add intercept line
    var minimumY = Number.MAX_VALUE;
    var maximumY = Number.MIN_VALUE;

    bars.selectAll(".".concat(variableName)).each(function() {
        if (+this.getAttribute('y') < minimumY) {
          minimumY = +this.getAttribute('y');
        }
        if (+this.getAttribute('y') > maximumY) {
          maximumY = +this.getAttribute('y');
        }
      });

    PD.append("line")
      .attr("class", "interceptLine")
      .attr("x1", x(fullModel))
      .attr("y1", minimumY)
      .attr("x2", x(fullModel))
      .attr("y2", maximumY + y.bandwidth());

    PD.append("text")
      .attr("transform",
            "translate(" + (plotLeft + pdPlotWidth/2) + "," +
                           (plotTop + pdPlotHeight + 45) + ")")
      .attr("class", "axisTitle")
      .attr("text-anchor", "middle")
      .text("average prediction");

    let desctemp = [{type:"desc", "text":"Description: TBD"}];

    let tempWH = 20;

    var description = PD.append("g")
                        .attr("transform", "translate(" +
                              (plotLeft + pdPlotWidth - tempWH) +
                              "," + (plotTop - tempWH - 5) + ")");

    description.selectAll()
               .data(desctemp)
               .enter()
               .append("rect")
               .attr("class", "descriptionBox")
               .attr("width", tempWH)
               .attr("height", tempWH)
               .on('mouseover', tooltip.show)
               .on('mouseout', tooltip.hide);

    description.selectAll()
               .data(desctemp)
               .enter()
               .append("text")
               .attr("class", "descriptionLabel")
               .attr("dy", "1.1em")
               .attr("x", 5)
               .text("D")
               .on('mouseover', function(d) {
                 tooltip.show(d);
                 d3.select(this).style("cursor", "default");
               })
               .on('mouseout', tooltip.hide);
  }

  function adNumericalPlot(variableName, lData, mData, yMinMax, yMean) {

    var x = d3.scaleLinear()
              .range([plotLeft + 10, plotLeft + adPlotWidth - 10])
              .domain([mData[0], mData[1]]);

    AD.append("text")
      .attr("transform",
            "translate(" + (plotLeft + adPlotWidth/2) + " ," +
                           (plotTop + adPlotHeight + 45) + ")")
      .attr("class", "axisTitle")
      .attr("text-anchor", "middle")
      .text(variableName);

    var y = d3.scaleLinear()
              .range([plotTop + adPlotHeight, plotTop])
              .domain([yMinMax[0], yMinMax[1]]);

    var line = d3.line()
                 .x(d => x(d.xhat))
                 .y(d => y(d.yhat))
                 .curve(d3.curveMonotoneX);

    AD.append("text")
      .attr("class", "bigTitle")
      .attr("x", plotLeft)
      .attr("y", plotTop - 40)
      .text(adTitle);

    AD.append("text")
      .attr("class","smallTitle")
      .attr("x", plotLeft)
      .attr("y", plotTop - 15)
      .text(modelName); // variableName

    // find 5 nice ticks with max and min - do better than d3
    var tickValues = getTickValues(x.domain());

    var xAxis = d3.axisBottom(x)
                  .tickValues(tickValues)
                  .tickSizeInner(0)
                  .tickPadding(15);

    xAxis = AD.append("g")
              .attr("class", "axisLabel")
              .attr("transform", "translate(0,"+ (plotTop + adPlotHeight) + ")")
              .call(xAxis);

    var yGrid = AD.append("g")
                  .attr("class", "grid")
                  .attr("transform", "translate(" + plotLeft + ",0)")
                  .call(d3.axisLeft(y)
                          .ticks(10)
                          .tickSize(-adPlotWidth)
                          .tickFormat("")
                  ).call(g => g.select(".domain").remove());

    var yAxis = d3.axisLeft(y)
                  .ticks(5)
                  .tickSize(0);

    yAxis = AD.append("g")
              .attr("class", "axisLabel")
              .attr("transform","translate(" + plotLeft + ",0)")
              .call(yAxis)
              .call(g => g.select(".domain").remove());

    // make tooltip
    var tooltip = d3.tip()
                    .attr("class", "tooltip")
                    .attr("id", "tooltipPD")
                    .offset([-8, 0])
                    .html(d => d.type === "desc" ?
                     descTooltipHtml(d) : adStaticTooltipHtml(d, variableName, yMean));
    AD.call(tooltip);

    // function to find nearest point on the line
    var bisectXhat = d3.bisector(d => d.xhat).right;

    // show tooltip with info nearest to mouseover
    function showTooltip(hover){
      var x0 = x.invert(d3.mouse(d3.event.currentTarget)[0]),
          i = bisectXhat(hover, x0),
          d0 = hover[i - 1],
          d1 = hover[i],
          d = x0 - d0.xhat > d1.xhat - x0 ? d1 : d0;

      tooltip.show(d);
    }

    // add lines
    AD.append("path")
      .data([lData])
      .attr("class", "line " + variableName)
      .attr("d", line)
      .style("fill", "none")
      .style("stroke", lineColor)
      .style("opacity", alpha)
      .style("stroke-width", size)
      .on('mouseover', function(d){

        // make mouseover line more visible
        d3.select(this)
          .style("stroke", pointColor)
          .style("stroke-width", size*1.5);

        // make line appear on top
        this.parentNode.appendChild(this);

        // show changed tooltip
        showTooltip(d);
      })
      .on('mouseout', function(d){

        d3.select(this)
          .style("stroke", lineColor)
          .style("stroke-width", size);

        // hide changed tooltip
        tooltip.hide(d);
      });

    AD.append("text")
      .attr("class", "axisTitle")
      .attr("transform", "rotate(-90)")
      .attr("y", plotLeft-40)
      .attr("x", -(plotTop + adPlotHeight/2))
      .attr("text-anchor", "middle")
      .text("accumulated prediction");

    let desctemp = [{type:"desc", "text":"Description: TBD"}];

    let tempWH = 20;

    var description = AD.append("g")
                        .attr("transform", "translate(" +
                              (plotLeft + adPlotWidth - tempWH) +
                              "," + (plotTop - tempWH - 5) + ")");

    description.selectAll()
               .data(desctemp)
               .enter()
               .append("rect")
               .attr("class", "descriptionBox")
               .attr("width", tempWH)
               .attr("height", tempWH)
               .on('mouseover', tooltip.show)
               .on('mouseout', tooltip.hide);

    description.selectAll()
               .data(desctemp)
               .enter()
               .append("text")
               .attr("class", "descriptionLabel")
               .attr("dy", "1.1em")
               .attr("x", 5)
               .text("D")
               .on('mouseover', function(d) {
                 tooltip.show(d);
                 d3.select(this).style("cursor", "default");
               })
               .on('mouseout', tooltip.hide);
  }

  function adCategoricalPlot(variableName, bData, yMinMax, yMean) {

    var x = d3.scaleLinear()
              .range([plotLeft,  plotLeft + adPlotWidth])
              .domain([yMinMax[0], yMinMax[1]]); // because it is flipped 

    var xAxis = d3.axisBottom(x)
                  .ticks(5)
                  .tickSize(0);

    xAxis = AD.append("g")
              .attr("class", "axisLabel")
              .attr("transform", "translate(0," + (plotTop + adPlotHeight) + ")")
              .call(xAxis)
              .call(g => g.select(".domain").remove());

    var y = d3.scaleBand()
              .rangeRound([plotTop + adPlotHeight, plotTop])
              .padding(0.33)
              .domain(bData.map(d => d.xhat));

    var xGrid = AD.append("g")
                  .attr("class", "grid")
                  .attr("transform", "translate(0," + (plotTop + adPlotHeight) + ")")
                  .call(d3.axisBottom(x)
                          .ticks(10)
                          .tickSize(-adPlotHeight)
                          .tickFormat("")
                  ).call(g => g.select(".domain").remove());

    var yGrid = AD.append("g")
                  .attr("class", "grid")
                  .attr("transform", "translate(" + plotLeft + ",0)")
                  .call(d3.axisLeft(y)
                          .tickSize(-adPlotWidth)
                          .tickFormat("")
                  ).call(g => g.select(".domain").remove());

    var yAxis = d3.axisLeft(y)
                  .tickSize(0);

    yAxis = AD.append("g")
              .attr("class", "axisLabel")
              .attr("transform","translate(" + (plotLeft-8) + ",0)")
              .call(yAxis)
              .call(g => g.select(".domain").remove());

    AD.append("text")
      .attr("x", plotLeft)
      .attr("y", plotTop - 15)
      .attr("class", "smallTitle")
      .text(modelName); // variableName

    AD.append("text")
      .attr("x", plotLeft)
      .attr("y", plotTop - 40)
      .attr("class", "bigTitle")
      .text(adTitle);

    var bars = AD.selectAll()
                 .data(bData)
                 .enter()
                 .append("g");

    var fullModel = 0; //yMean;

    // make tooltip
    var tooltip = d3.tip()
                    .attr("class", "tooltip")
                    .attr("id", "tooltipAD")
                    .offset([-8, 0])
                    .html(d => d.type === "desc" ?
                     descTooltipHtml(d) : adStaticTooltipHtml(d, variableName, yMean));
    AD.call(tooltip);

    // add bars
    bars.append("rect")
        .attr("class", variableName)
        .attr("fill", lineColor)
        .attr("y", d => y(d.xhat))
        .attr("height", y.bandwidth())
        .attr("x", d => x(d.yhat) < x(fullModel) ? x(d.yhat) : x(fullModel))
        .attr("width", d => Math.abs(x(d.yhat) - x(fullModel)))
        .on('mouseover', tooltip.show)
        .on('mouseout', tooltip.hide);

    // add intercept line
    var minimumY = Number.MAX_VALUE;
    var maximumY = Number.MIN_VALUE;

    bars.selectAll(".".concat(variableName)).each(function() {
        if (+this.getAttribute('y') < minimumY) {
          minimumY = +this.getAttribute('y');
        }
        if (+this.getAttribute('y') > maximumY) {
          maximumY = +this.getAttribute('y');
        }
      });

    AD.append("line")
      .attr("class", "interceptLine")
      .attr("x1", x(fullModel))
      .attr("y1", minimumY)
      .attr("x2", x(fullModel))
      .attr("y2", maximumY + y.bandwidth());

    AD.append("text")
      .attr("transform",
            "translate(" + (plotLeft + adPlotWidth/2) + "," +
                           (plotTop + adPlotHeight + 45) + ")")
      .attr("class", "axisTitle")
      .attr("text-anchor", "middle")
      .text("accumulated prediction");

    let desctemp = [{type:"desc", "text":"Description: TBD"}];

    let tempWH = 20;

    var description = AD.append("g")
                        .attr("transform", "translate(" +
                              (plotLeft + adPlotWidth - tempWH) +
                              "," + (plotTop - tempWH - 5) + ")");

    description.selectAll()
               .data(desctemp)
               .enter()
               .append("rect")
               .attr("class", "descriptionBox")
               .attr("width", tempWH)
               .attr("height", tempWH)
               .on('mouseover', tooltip.show)
               .on('mouseout', tooltip.hide);

    description.selectAll()
               .data(desctemp)
               .enter()
               .append("text")
               .attr("class", "descriptionLabel")
               .attr("dy", "1.1em")
               .attr("x", 5)
               .text("D")
               .on('mouseover', function(d) {
                 tooltip.show(d);
                 d3.select(this).style("cursor", "default");
               })
               .on('mouseout', tooltip.hide);
  }

  function fdNumericalPlot(variableName, dData, mData, nBin) {

    var x = d3.scaleLinear()
              .range([plotLeft + 10, plotLeft + fdPlotWidth - 10])
              .domain([mData[0], mData[1]]);

    FD.append("text")
      .attr("transform",
            "translate(" + (plotLeft + fdPlotWidth/2) + " ," +
                           (plotTop + fdPlotHeight + 45) + ")")
      .attr("class", "axisTitle")
      .attr("text-anchor", "middle")
      .text(variableName);

    FD.append("text")
      .attr("class", "axisTitle")
      .attr("transform", "rotate(-90)")
      .attr("y", plotLeft-40)
      .attr("x", -(plotTop + fdPlotHeight/2))
      .attr("text-anchor", "middle")
      .text("count");

    var y = d3.scaleLinear()
          .range([plotTop + fdPlotHeight - 5, plotTop]);

    FD.append("text")
      .attr("class", "bigTitle")
      .attr("x", plotLeft)
      .attr("y", plotTop - 40)
      .text(fdTitle);

    FD.append("text")
      .attr("class","smallTitle")
      .attr("x", plotLeft)
      .attr("y", plotTop - 15)
      .text(modelName);

    // find 5 nice ticks with max and min - do better than d3
    var tickValues = getTickValues(x.domain());

    var xAxis = d3.axisBottom(x)
                  .tickValues(tickValues)
                  .tickSizeInner(0)
                  .tickPadding(15);

    xAxis = FD.append("g")
              .attr("class", "axisLabel")
              .attr("transform", "translate(0,"+ (plotTop + fdPlotHeight) + ")")
              .call(xAxis);

    var yAxis = FD.append("g")
                  .attr("class", "axisLabel")
                  .attr("transform", "translate(" + plotLeft + ",0)");

    var yGrid = FD.append("g")
                    .attr("class", "grid")
                    .attr("transform", "translate(" + plotLeft + ",0)");
    
    var slider = d3.sliderBottom()
                   .min(d3.max([+nBin-10,2]))
                   .max(d3.max([+nBin+10,12]))
                   .width(fdPlotWidth/2 - 10)
                   .ticks(6)
                   .step(1)
                   .default(nBin)
                   .fill(lineColor)
                   .on('drag', val => updateHist(val));

    var sliderg = FD.append("g").call(slider);

    sliderg.attr("transform", "translate(" + (plotLeft + fdPlotWidth/2) + "," +
                               margin.small + ")");

    updateHist(nBin);

    function updateHist(nbin) {

      var histogram = d3.histogram()
                        .value(d => d[variableName])
                        .domain(x.domain())
                        .thresholds(x.ticks(nbin));

      var bins = histogram(dData);
      
      y.domain([0, d3.max(bins, d => d.length)]);

      let yaF = d3.axisLeft(y)
                  .ticks(5)
                  .tickSize(0);

      yAxis.call(yaF)
           .call(g => g.select(".domain").remove());

      yGrid.call(d3.axisLeft(y)
                   .ticks(10)
                   .tickSize(-fdPlotWidth)
                   .tickFormat("")
                 ).call(g => g.select(".domain").remove());

      var bars = FD.selectAll("rect")
                   .data(bins);

      bars.enter()
          .append("rect")
          .attr("fill", lineColor)
          .merge(bars)
          .attr("x", d => x(d.x0))
          .attr("y", d => y(0))
          .attr("height", d => 0)
          .attr("width", d => x(d.x1) - x(d.x0))
          .transition()
          .duration(time)
            .attr("y", d => y(d.length))
            .attr("height", d => y(0) - y(d.length));

      bars.exit()
          .remove()
    }
  }

  function fdCategoricalPlot(variableName, dData, mData) {

    // equivalent of R table function
    var tData = d3.nest()
                  .key(d => d[variableName])
                  .rollup(v => v.length)
                  .entries(dData);
              
    var x = d3.scaleLinear()
              .range([plotLeft,  plotLeft + fdPlotWidth])
              .domain([0, mData]); 

    var xAxis = d3.axisBottom(x)
                  .ticks(5)
                  .tickSize(0);

    xAxis = FD.append("g")
              .attr("class", "axisLabel")
              .attr("transform", "translate(0," + (plotTop + fdPlotHeight) + ")")
              .call(xAxis)
              .call(g => g.select(".domain").remove());

    var y = d3.scaleBand()
              .rangeRound([plotTop + adPlotHeight, plotTop])
              .padding(0.33)
              .domain(tData.map(d => d.key));

    var xGrid = FD.append("g")
                  .attr("class", "grid")
                  .attr("transform", "translate(0," + (plotTop + fdPlotHeight) + ")")
                  .call(d3.axisBottom(x)
                          .ticks(10)
                          .tickSize(-fdPlotHeight)
                          .tickFormat("")
                  ).call(g => g.select(".domain").remove());

    var yGrid = FD.append("g")
                  .attr("class", "grid")
                  .attr("transform", "translate(" + plotLeft + ",0)")
                  .call(d3.axisLeft(y)
                          .tickSize(-fdPlotWidth)
                          .tickFormat("")
                  ).call(g => g.select(".domain").remove());

    var yAxis = d3.axisLeft(y)
                  .tickSize(0);

    yAxis = FD.append("g")
              .attr("class", "axisLabel")
              .attr("transform","translate(" + (plotLeft-8) + ",0)")
              .call(yAxis)
              .call(g => g.select(".domain").remove());

    FD.append("text")
      .attr("x", plotLeft)
      .attr("y", plotTop - 15)
      .attr("class", "smallTitle")
      .text(modelName);

    FD.append("text")
      .attr("x", plotLeft)
      .attr("y", plotTop - 40)
      .attr("class", "bigTitle")
      .text(fdTitle);

    var bars = FD.selectAll()
                 .data(tData)
                 .enter()
                 .append("g");

    // add bars
    bars.append("rect")
        .attr("class", variableName)
        .attr("fill", lineColor)
        .attr("x", d => x(0))
        .attr("y", d => y(d.key))
        .attr("height", y.bandwidth())
        .attr("width", d => x(d.value)-x(0));

    FD.append("text")
      .attr("transform",
            "translate(" + (plotLeft + fdPlotWidth/2) + "," +
                           (plotTop + fdPlotHeight + 45) + ")")
      .attr("class", "axisTitle")
      .attr("text-anchor", "middle")
      .text("count");
  }
}

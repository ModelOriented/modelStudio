// load all data
var bdData = data[0],
    cpData = data[1];

var cpPlotCount = bdData.variables.length, bdBarCount = bdData.m[0];

// load options
var size = options.size, alpha = options.alpha, barWidth = options.bar_width,
    cpTitle = options.cp_title, bdTitle = options.bd_title,
    modelName = options.model_name,
    showRugs = options.show_rugs;

// calculate BD left margin
var maxLength = calculateTextWidth(bdData.label_list)+15;

var margin = {top: 100, right: 20, bottom: 70, left: maxLength, inner: 40},
    w = width - margin.left - margin.right,
    h = height - margin.top - margin.bottom,
    plotTop = margin.top, plotLeft = margin.left,
    plotHeight = 600, plotWidth = 900;

var bdPlotHeight = bdBarCount*barWidth + (bdBarCount+1)*barWidth/2,
    bdPlotWidth = 420;

if (bdPlotHeight<280) {
  barWidth = 280/(3*bdBarCount/2 + 1/2);
  bdPlotHeight = 280;
}

var bdColors = getColors(3, "breakDown"),
    positiveColor = bdColors[0],
    negativeColor = bdColors[1],
    defaultColor = bdColors[2];

var cpPlotHeight = 280,
    cpPlotWidth = 420;

var cpColors = getColors(3, "point"),
    pointColor = cpColors[0],
    lineColor = cpColors[1],
    greyColor = cpColors[2];


// plot
var BD = svg.append("g");
breakDown();
plotLeft = 60;

var CP = svg.append("g").attr("transform", "translate(" +
                              (420 + margin.left + margin.right) + ",0)");
ceterisParibus();

function breakDown() {

  var bData = bdData.x;
  var xMinMax = bdData.x_min_max;

  var x = d3.scaleLinear()
        .range([plotLeft,  plotLeft + bdPlotWidth])
        .domain([xMinMax[0], xMinMax[1]]);

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
        .domain(bData.map(function (d) {
             return d.variable;
        }));

  var xGrid = BD.append("g")
         .attr("class", "grid")
         .attr("transform", "translate(0," + (plotTop + bdPlotHeight) + ")")
         .call(d3.axisBottom(x)
                .ticks(10)
                .tickSize(-bdPlotHeight)
                .tickFormat("")
        ).call(g => g.select(".domain").remove());

  // effort to make grid endings clean
  let str = xGrid.select('.tick:first-child').attr('transform');
  let yGridStart = str.substring(str.indexOf("(")+1,str.indexOf(","));
  str = xGrid.select('.tick:last-child').attr('transform');
  let yGridEnd = str.substring(str.indexOf("(")+1,str.indexOf(","));

  var yGrid = BD.append("g")
         .attr("class", "grid")
         .attr("transform", "translate(" + yGridStart + ",0)")
         .call(d3.axisLeft(y)
                .tickSize(-(yGridEnd-yGridStart))
                .tickFormat("")
        ).call(g => g.select(".domain").remove());

  var yAxis = d3.axisLeft(y)
        .tickSize(0);

  yAxis = BD.append("g")
        .attr("class", "axisLabel")
        .attr("transform","translate(" + (yGridStart-10) + ",0)")
        .call(yAxis)
        .call(g => g.select(".domain").remove());

  yAxis.select(".tick:last-child").select("text").attr('font-weight', 600);

  BD.append("text")
        .attr("x", yGridStart)
        .attr("y", plotTop - 15)
        .attr("class", "smallTitle")
        .text(modelName);

  BD.append("text")
        .attr("x", yGridStart)
        .attr("y", plotTop - 40)
        .attr("class", "bigTitle")
        .text(bdTitle);

  // add tooltip
  var tool_tip = d3.tip()
        .attr("class", "tooltip")
        .offset([-8, 0])
        .html(function(d) { return bdTooltipHtml(d); });

  BD.call(tool_tip);

  // find boundaries
  let intercept = bData[0].contribution > 0 ? bData[0].barStart : bData[0].barSupport;

  // make dotted line from intercept to prediction
  var dotLineData = [{"x": x(intercept), "y": y("intercept")},
                     {"x": x(intercept), "y": y("prediction") + barWidth}];

  var lineFunction = d3.line()
                         .x(function(d) { return d.x; })
                         .y(function(d) { return d.y; });
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
        .attr("y", d => y(d.variable) )
        .attr("height", y.bandwidth() )
        .attr("x", d => x(d.barStart))
        .attr("width", d => x(d.barSupport) - x(d.barStart))
        .on('mouseover', tool_tip.show)
        .on('mouseout', tool_tip.hide)
        .attr("id", (d,i) => i-1)
        .on("click", function(){
          clicked = this.id;
          updateCP(this.id);
        });

  // add labels to bars
  var contributionLabel = BD.selectAll()
        .data(bData)
        .enter()
        .append("g");

  contributionLabel.append("text")
        .attr("x", d => {
          switch(d.sign){
            case "X":
              return d.contribution < 0 ? x(d.barStart) - 5 : x(d.barSupport) + 5;
            default:
              return x(d.barSupport) + 5;
          }
        })
        .attr("text-anchor", d => d.sign == "X" && d.contribution < 0 ? "end" : null)
        .attr("y", d => y(d.variable) + barWidth/2)
        .attr("dy", "0.5em")
        .attr("class", "axisLabel")
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
        .attr("y2", d => d.variable == "prediction" ? y(d.variable) : y(d.variable) + barWidth*2.5);
}

function ceterisParibus() {

  var profData = cpData.x;
  var xMinMax = cpData.x_min_max_list;
  var yMinMax = cpData.y_min_max;
  var obsData = cpData.observation;
  var isNumeric = cpData.is_numeric;
  var variables = cpData.variables;

  var start = 1;

  let variableName = variables[start];

  //lines or bars?
  if (isNumeric[start]) {
    cpNumericalPlot(variableName, profData[variableName], xMinMax[variableName],
                    yMinMax, obsData, start+1);
  } else {
    cpCategoricalPlot(variableName, profData[variableName],
                      yMinMax, obsData, start+1);
  }
}

function updateCP(clicked) {

  if (clicked === "-1" || clicked === (bdBarCount-2) +"") { return;}

  var profData = cpData.x;
  var xMinMax = cpData.x_min_max_list;
  var yMinMax = cpData.y_min_max;
  var obsData = cpData.observation;
  var isNumeric = cpData.is_numeric;
  var variables = cpData.variables;

  let variableName = variables[clicked];
  CP.selectAll("*").remove();

  //lines or bars?
  if (isNumeric[clicked]) {
    cpNumericalPlot(variableName, profData[variableName], xMinMax[variableName],
                    yMinMax, obsData);
  } else {
    cpCategoricalPlot(variableName, profData[variableName],
                      yMinMax, obsData);
  }
}

function cpNumericalPlot(variableName, lData, mData, yMinMax, pData) {

  var x = d3.scaleLinear()
            .range([plotLeft + 10, plotLeft + cpPlotWidth - 10])
            .domain([mData[0], mData[1]]);

  var y = d3.scaleLinear()
            .range([plotTop + cpPlotHeight, plotTop])
            .domain([yMinMax[0], yMinMax[1]]);

  var line = d3.line()
               .x(function(d) { return x(d.xhat); })
               .y(function(d) { return y(d.yhat); })
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
      .text(variableName + " = " + pData[0][variableName]);

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
  var tool_tip = d3.tip()
            .attr("class", "tooltip")
            .offset([-8, 0])
            .html(function(d, addData) {
              if(addData !== undefined){
                return cpChangedTooltipHtml(d, addData);
              } else {
                return cpStaticTooltipHtml(d);
              }
            });
  svg.call(tool_tip);

  // function to find nearest point on the line
  var bisectXhat = d3.bisector(d => d.xhat).right;

  // tooltip appear with info nearest to mouseover
  function appear(data){
    var x0 = x.invert(d3.mouse(d3.event.currentTarget)[0]),
        i = bisectXhat(data, x0),
        d0 = data[i - 1],
        d1 = data[i],
        d = x0 - d0.xhat > d1.xhat - x0 ? d1 : d0;
    let temp = pData.find(el => el["observation.id"] === d.id);
    tool_tip.show(d, temp);
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

      d3.select(this)
        .style("stroke", pointColor)
        .style("stroke-width", size*1.5);

      // make line and points appear on top
      this.parentNode.appendChild(this);
      d3.select(this.parentNode).selectAll(".point").each(function() {
                       this.parentNode.appendChild(this);
                  });

      // show changed tooltip
      appear(d);
    })
    .on('mouseout', function(d){

      d3.select(this)
        .style("stroke", lineColor)
        .style("stroke-width", size);

      // hide changed tooltip
      tool_tip.hide(d);
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
          tool_tip.show(d);
      		d3.select(this)
      			.attr("r", 6);
      	})
        .on('mouseout', function(d) {
          tool_tip.hide(d);
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
        .attr("y", 15)
        .attr("x", -(plotTop + cpPlotHeight/2))
        .attr("text-anchor", "middle")
        .text("prediction");
}

function cpCategoricalPlot(variableName, bData, yMinMax, lData) {

  var x = d3.scaleLinear()
        .range([plotLeft,  plotLeft + cpPlotWidth])
        .domain([yMinMax[0], yMinMax[1]]);

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
        .domain(bData.map(function (d) {
             return d.xhat;
        }));

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

  CP.append("text")
        .attr("x", plotLeft)
        .attr("y", plotTop - 15)
        .attr("class", "smallTitle")
        .text(variableName + " = " + lData[0][variableName]);

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
  var tool_tip = d3.tip()
        .attr("class", "tooltip")
        .offset([-8, 0])
        .html(function(d) { return cpChangedTooltipHtml(d, lData[0]); });
  svg.call(tool_tip);

  // add bars
  bars.append("rect")
        .attr("class", variableName)
        .attr("fill", lineColor)
        .attr("y", function (d) {
            return y(d.xhat);
        })
        .attr("height", y.bandwidth())
        .attr("x", function (d) {
          // start ploting the bar left to full model line
          if (x(d.yhat) < x(fullModel)) {
            return x(d.yhat);
          } else {
            return x(fullModel);
          }
        })
        .attr("width", function (d) {
            return  Math.abs(x(d.yhat) - x(fullModel));
        })
        .on('mouseover', tool_tip.show)
        .on('mouseout', tool_tip.hide);

  // add intercept line
  var minimumY = Number.MAX_VALUE;
  var maximumY = Number.MIN_VALUE;

  bars.selectAll(".".concat(variableName)).each(function() {
      if(+this.getAttribute('y') < minimumY) {
        minimumY = +this.getAttribute('y');
      }
      if(+this.getAttribute('y') > maximumY) {
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
              "translate(" + (plotLeft + cpPlotWidth + margin.right)/2 + " ," +
                             (plotTop + cpPlotHeight + 45) + ")")
        .attr("class", "axisTitle")
        .text("prediction");
}

function bdTooltipHtml(d, prediction) {
  var temp = "<center>";
  temp += d.tooltipText;
  temp += "</center>";
  return temp;
}

function cpStaticTooltipHtml(d, addData) {
  // function formats tooltip text
  var temp = "";
  for (var [k, v] of Object.entries(d)) {
    if (k === "yhat") {
      k = "prediction";
      temp += "<center>" +  k + ": " + v + "</br>";
      temp += "</br>";
    } else{
      temp += "<center>" +  k + ": " + v + "</br>";
    }
  }
  return temp;
}

function cpChangedTooltipHtml(d, addData) {
  // function formats tooltip text with update in red
  var temp = "<center>";
  for (var [k, v] of Object.entries(addData)) {
    if (k === "yhat") {
      temp += "prediction:</br>";
      temp += "- before" + ": " + v + "</br>";
      temp += "- after" + ": " + "<font color = \"red\">" + d.yhat + "</br></font>";
      temp += "</br>";
    } else if (k === d.vname) {
      temp +=  k + ": " + "<font color = \"red\">"  +  d.xhat + "</br></font>";
    } else {
      temp += k + ": " + v + "</br>";
    }
  }
  temp += "</center>";
  return temp;
}

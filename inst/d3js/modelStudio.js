//// set all dimmensions \\\\
// load all data
var obsData = data[0],
    fiData = data[1], pdData = data[2],
    adData = data[3], fdData = data[4];
// load options
var time = options.time,
    size = options.size, alpha = options.alpha, barWidth = options.bar_width,
    bdTitle = options.bd_title, svTitle = options.sv_Title,
    cpTitle = options.cp_title, fiTitle = options.fi_title,
    pdTitle = options.pd_title, adTitle = options.ad_title,
    fdTitle = options.fd_title,
    modelName = options.model_name, variableNames = options.variable_names,
    showRugs = options.show_rugs,
    dim = options.facet_dim;

var GLOBAL_CLICKED_VARIABLE_NAME = variableNames[0];

// set dimensions (TODO: pass as options)
var margin = {top: 50, right: 20, bottom: 70, left: 105, inner: 40,
              small: 5, big: 10};

var w = 420, h = 280;

var plotWidth = 420 + margin.left + margin.right,
    plotHeight = 280 + margin.top + margin.bottom;

var studioWidth = dim[1]*plotWidth,
    studioHeight = dim[0]*plotHeight + margin.top;

// for observation choice
var observationIds = Object.keys(obsData);

var notVisiblePlots = [{text:"Break Down [Local]",id:"BD"},
                       {text:"Shapley Values [Local]",id:"SV"},
                       {text:"Ceteris Paribus [Local]",id:"CP"},
                       {text:"Feature Importance [Global]",id:"FI"},
                       {text:"Partial Dependency [Global]",id:"PD"},
                       {text:"Accumulated Dependency [Global]",id:"AD"},
                       {text:"Feature Density",id:"FD"}];

var visiblePlots = [];

var plotCountTreshold = d3.min(notVisiblePlots.length,(dim[0]*dim[1]));

// generate facet x,y coordinates
/// FIXME: change this double loop
var buttonData = [];
for (let i=0; i<dim[0]; i++) {
  for (let j=0; j<dim[1]; j++) {
    buttonData.push({x:0+j*plotWidth, y:margin.top+i*plotHeight});
  }
}
/// TODO:change scaling and this flag
tscale = true;

////                     \\\\
initializeStudio();
////                     \\\\

function initializeStudio() {
  /// this function initializes modelStudio (used only once, at start)
  /// uses reloadStudio+generatePlot (using 1st observation data)

  var DEC = svg.append("g")
               .attr("class", "DEC");

  DEC.append("text")
     .attr("class", "mainTitle")
     .attr("x", 15)
     .attr("y", 30)
     .text("Interactive Model Studio");

  DEC.append("line")
     .attr("class", "mainLine")
     .attr("x1", 10)
     .attr("x2", studioWidth-10)
     .attr("y1", margin.top - margin.big)
     .attr("y2", margin.top - margin.big);

  var buttonClicked = false;

  // add select observation input
  d3.select(".r2d3.html-widget.html-widget-static-bound")
    .style("position","absolute");

  let tempW = calculateTextWidth(observationIds)*1.6 + 18;

  var inputDiv = d3.select("#htmlwidget_container")
                   .append("div")
                   .style("position", "absolute")
                   .style("display", "inline-grid")
                   .style("left", (studioWidth - margin.big - tempW)+"px")
                   .style("top", -studioHeight + 180);

  var input = inputDiv.append("select")
                      .attr("id","input")
                      .style("font-size", "15px")
                      .style("font-weight", 600)
                      .style("color", "#371ea3");

  input.selectAll()
       .data(observationIds)
       .enter()
       .append("option")
       .attr("value", d => d)
       .text(d => d)
       .style("font-size", "15px")
       .style("font-weight", 600)
       .style("color", "#371ea3");

  input.on("change", function() {

         // delete old tooltips, when changing observation
         d3.select("body").selectAll(".tooltip").remove();
         // chose clicked data
         let tData = obsData[this.value];
         // update all plots with new data (with existing ones on their places)
         generatePlots(tData);
       });

  // reload studio = delete everything and set up buttons
  reloadStudio();
  // chose new data, initialize with 1st observation
  let tData = obsData[observationIds[0]];
  // plot new data
  generatePlots(tData);
}

function reloadStudio() {
  ///  delete plots and set up buttons (without initializeStudio)

  svg.selectAll(".plot").remove();
  svg.selectAll(".STARTG").remove();

  // change text font
  var STARTG = svg.append("g")
                  .attr("class", "STARTG");

  var chosePlotButton = STARTG.selectAll()
                              .data(buttonData)
                              .enter()
                              .append("rect")
                              .attr("class", "chosePlotButton")
                              .attr("id", (d,i) => "plot"+i)
                              .attr("width", plotWidth)
                              .attr("height", plotHeight)
                              .attr("x", d => d.x)
                              .attr("y", d => d.y);

  // add `+` to buttons
  STARTG.selectAll()
        .data(buttonData)
        .enter()
        .append("line")
        .attr("class", "mainLine")
        .attr("id", (d,i) => "plot"+i)
        .attr("x1", d => d.x + plotWidth/2)
        .attr("x2", d => d.x + plotWidth/2)
        .attr("y1", d => d.y + plotHeight/2 - margin.big)
        .attr("y2", d => d.y + plotHeight/2 + margin.big);

  STARTG.selectAll()
        .data(buttonData)
        .enter()
        .append("line")
        .attr("class", "mainLine")
        .attr("id", (d,i) => "plot"+i)
        .attr("x1", d => d.x + plotWidth/2 - margin.big)
        .attr("x2", d => d.x + plotWidth/2 + margin.big)
        .attr("y1", d => d.y + plotHeight/2)
        .attr("y2", d => d.y + plotHeight/2);

  chosePlotButton.on('mouseover', function() { d3.select(this).style("opacity", 1);})
                 .on('mouseout', function() { d3.select(this).style("opacity", 0.5);})
                 .on("click", function(){

                   // check if any button is already clicked
                   if (!buttonClicked) {
                    chosePlot(this);
                    buttonClicked = true;
                   }
                 });

  // initialize flag, is any button clicked?
  var buttonClicked = false;

  function chosePlot(object) {

    // hide grey button with `+`
    svg.selectAll("#"+object.id).style("visibility", "hidden");

    // make background white button for off click purpose
    let plotWidth = parseFloat(d3.select(object).attr("width")),
        plotHeight = parseFloat(d3.select(object).attr("height")),
        x = parseFloat(d3.select(object).attr("x")),
        y = parseFloat(d3.select(object).attr("y"));

    let tempButton = STARTG.append("g")
                           .attr("id","tempButton"+object.id);

    tempButton.append("rect")
              .attr("class", "whiteButton")
              .attr("width", plotWidth-margin.big)
              .attr("height", plotHeight-margin.big)
              .attr("x", x+margin.small)
              .attr("y", y+margin.small)
              .style("fill", "white")
              .on("click", function() {

                // when clicking outside of text remove it
                svg.select("#tempText"+object.id).remove();
                // show button and `+` again
                svg.selectAll("#"+object.id).style("visibility", "visible");
                // remove this rect
                svg.select("#tempButton"+object.id).remove();
                // let the user click other buttons now
                buttonClicked = false;
              });

    let tempText = STARTG.append("g")
                         .attr("id","tempText"+object.id);

    tempText.selectAll()
            .data(notVisiblePlots)
            .enter()
            .append("text")
            .attr("class", "bigTitle")
            .attr("id", d => d.id)
            .attr("x", x + plotWidth/2)
            .attr("y", (d,i) => y + plotHeight/2 + 25*i - (notVisiblePlots.length/2)*25)
            .attr("text-anchor", "middle")
            .text(d => d.text)
            .style('font-family', 'Arial')
            .on("mouseover", function() { d3.select(this).style("cursor", "pointer");})
            .on("mouseout", function() { d3.select(this).style("cursor", "auto");})
            .on("click", function() {

              // when clicking outside of button remove it
              svg.select("#tempButton"+object.id).remove();
              // delete text buttons
              svg.select("#tempText"+object.id).remove();
              // add this plot  to visible
              visiblePlots.push({text: this.text, id: this.id});
              // delete this plot from not visible
              notVisiblePlots = notVisiblePlots.filter(el => el.id !== this.id);
              // let the user click other buttons now
              buttonClicked = false;

              // delete all not needed items
              if (visiblePlots.length === plotCountTreshold) STARTG.remove(); //

              // show plot
              svg.select("#"+this.id)
                 .attr("transform","translate(" + (x) + "," + (y + margin.big) + ")")
                 .style("visibility", "visible");
                 // margin.big added because translate 0 is -10
            });
  }

  // safeguard font-family update
  svg.selectAll("text")
     .style('font-family', 'Arial');
}

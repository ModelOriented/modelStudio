///:\\\ --------- main modelStudio file --------- ///:\\\
///:\\\ (for myself to remember):                 ///:\\\
///:\\\ use CAPITAL for global variables and 'g'  ///:\\\
///:\\\ use let where possible                    ///:\\\
///:\\\ use class for css and id for select       ///:\\\
///:\\\ use lambdas and ifelse where possible     ///:\\\
///:\\\ ----------------------------------------- ///:\\\

/// prevent modelStudio from reloading onResize
r2d3.onResize(function() {
  return;
});

/// load all data
var obsData = data[0],
    fiData = data[1], pdData = data[2],
    adData = data[3], fdData = data[4];

/// load options
var TIME = options.time,
    size = options.size, alpha = options.alpha, barWidth = options.bar_width,
    bdTitle = options.bd_title, svTitle = options.sv_title,
    cpTitle = options.cp_title, fiTitle = options.fi_title,
    pdTitle = options.pd_title, adTitle = options.ad_title,
    fdTitle = options.fd_title,
    modelName = options.model_name,
    variableNames = options.variable_names,
    showRugs = options.show_rugs,
    dim = options.facet_dim;

/// for observation choice
var observationIds = Object.keys(obsData);

/// set global variables
var CLICKED_VARIABLE_NAME = variableNames[0],
    CLICKED_OBSERVATION_ID = observationIds[0],
    IS_BUTTON_CLICKED = false;

/// TODO:change scaling and this flag
var IS_TSCALE = true;

/// set dimensions
/// TODO: pass as options
var margin = {top: 50, right: 20, bottom: 70, left: 105,
              inner: 40, small: 5, big: 10};

var w = 420, h = 280;

var plotWidth = 420 + margin.left + margin.right,
    plotHeight = 280 + margin.top + margin.bottom;

var studioWidth = dim[1]*plotWidth,
    studioHeight = dim[0]*plotHeight + margin.top;

/// for plot chosing
var notVisiblePlots = [{id:"BD", text:"Break Down [Local]"},
                       {id:"SV", text:"Shapley Values [Local]"},
                       {id:"CP", text:"Ceteris Paribus [Local]"},
                       {id:"FI", text:"Feature Importance [Global]"},
                       {id:"PD", text:"Partial Dependency [Global]"},
                       {id:"AD", text:"Accumulated Dependency [Global]"},
                       {id:"FD", text:"Feature Distribution [EDA]"}];

var visiblePlots = [];

/// generate facet x,y coordinates with grid index
var facetData = [], id = 0;
for (let i=0; i<dim[0]; i++) {
  for (let j=0; j<dim[1]; j++) {
    facetData.push({x: 0 + j*plotWidth, y: margin.top + i*plotHeight, index: id});
    id++;
  }
}

///:\\\
initializeStudio();
///:\\\

function initializeStudio() {
  /// this function initializes modelStudio (used only once, at start)

  // top decorations
  var TOP_G = svg.append("g")
                  .attr("class", "TOP_G");

  TOP_G.append("text")
        .attr("class", "mainTitle")
        .attr("x", 15)
        .attr("y", 30)
        .text("Interactive Model Studio");

  TOP_G.append("line")
        .attr("class", "mainLine")
        .attr("x1", 10)
        .attr("x2", studioWidth-10)
        .attr("y1", margin.top - margin.big)
        .attr("y2", margin.top - margin.big);

  ///:\\\ add select observation input
  // to make input appear on top
  d3.select(".r2d3.html-widget.html-widget-static-bound")
    .style("position","absolute");

  let tempW = calculateTextWidth(observationIds)*1.6 + 18; // 15px bold 600

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

    // update observation specific plots
    updatePlots(event = "observationChange",
                variableName = null,
                observationId = this.value,
                time = 1000,
                plotId = null);
  });
  ///:\\\

  // bottom buttons
  var BOTTOM_G = svg.append("g")
                    .attr("class", "BOTTOM_G");

  var enterChoiceButtons = BOTTOM_G.selectAll()
                                   .data(facetData)
                                   .enter()
                                   .append("rect")
                                   .attr("class", "enterChoiceButton")
                                   .attr("id", (d,i) => "enterChoiceButton"+i)
                                   .attr("width", plotWidth)
                                   .attr("height", plotHeight)
                                   .attr("x", d => d.x)
                                   .attr("y", d => d.y);

  // add `+` to buttons
  BOTTOM_G.selectAll()
          .data(facetData)
          .enter()
          .append("line")
          .attr("class", "mainLine")
          .attr("id", (d,i) => "enterChoiceButton"+i)
          .attr("x1", d => d.x + plotWidth/2)
          .attr("x2", d => d.x + plotWidth/2)
          .attr("y1", d => d.y + plotHeight/2 - margin.big)
          .attr("y2", d => d.y + plotHeight/2 + margin.big);

  BOTTOM_G.selectAll()
          .data(facetData)
          .enter()
          .append("line")
          .attr("class", "mainLine")
          .attr("id", (d,i) => "enterChoiceButton"+i)
          .attr("x1", d => d.x + plotWidth/2 - margin.big)
          .attr("x2", d => d.x + plotWidth/2 + margin.big)
          .attr("y1", d => d.y + plotHeight/2)
          .attr("y2", d => d.y + plotHeight/2);

  // events
  enterChoiceButtons.on('mouseover', function() { d3.select(this).style("opacity", 1);})
                    .on('mouseout', function() { d3.select(this).style("opacity", 0.5);})
                    .on("click", function(d,i){

                      // block other buttons
                      if (!IS_BUTTON_CLICKED) {
                        IS_BUTTON_CLICKED = true;
                        // allow for plot choice or exit choice
                        showChoiceButtons(this, i);
                      }
                    });

  var exitChoiceButtons = BOTTOM_G.selectAll()
                                  .data(facetData)
                                  .enter()
                                  .append("rect")
                                  .attr("class", "exitChoiceButton")
                                  .attr("id", (d,i) => "exitChoiceButton"+i)
                                  .attr("width", plotWidth - margin.big)
                                  .attr("height", plotHeight - margin.big)
                                  .attr("x", d => d.x + margin.small)
                                  .attr("y", d => d.y + margin.small)
                                  .style("visibility", "hidden");

  // events
  exitChoiceButtons.on("click", function(d,i) {

                     // delete chosePlotButtons
                     svg.select("#chosePlotButton"+i).remove();
                     // hide this button
                     svg.select("#exitChoiceButton"+i).style("visibility", "hidden");
                     // show enterChoiceButton
                     svg.selectAll("#enterChoiceButton"+i).style("visibility", "visible");
                     // let the user click other buttons
                     IS_BUTTON_CLICKED = false;
                   });

  var exitPlotButtons = BOTTOM_G.selectAll()
                                .data(facetData)
                                .enter()
                                .append("g")
                                .attr("id", (d,i) => "exitPlotButton"+i)
                                .attr("transform", d => "translate(" +
                                (d.x + margin.left + w - 2*margin.big) + "," +
                                (d.y + margin.small) + ")")
                                .style("visibility", "hidden");

  exitPlotButtons.append("rect")
                 .attr("class", "descriptionBox")
                 .attr("width", 2*margin.big)
                 .attr("height", 2*margin.big)
                 .attr("rx", 2*margin.big)
                 .attr("ry", 2*margin.big);

  exitPlotButtons.append("text")
                 .attr("class", "descriptionLabel")
                 .attr("dy", "1em")
                 .attr("x", 6)
                 .text("X");

  // events
  exitPlotButtons.selectAll("*")
                 .on("mouseover", function() { d3.select(this).style("cursor", "pointer");})
                 .on("mouseout", function() { d3.select(this).style("cursor", "auto");})
                 .on("click", function(d) {

                   let j = d.index;
                   // available only when no enterPlotButton clicked
                   if (!IS_BUTTON_CLICKED) {
                     // which plot is in this place?
                     let temp = visiblePlots.filter(el => el.index == j)[0];
                     // add this plot to not visible
                     notVisiblePlots.push({text: temp.text, id: temp.id});
                     // delete this plot from visible
                     visiblePlots = visiblePlots.filter(el => el.id !== temp.id);
                     // hide this button
                     svg.select("#exitPlotButton"+j).style("visibility", "hidden");
                     // hide plot
                     svg.select("#"+temp.id)
                        .style("visibility", "hidden");
                     // show enterChoiceButton
                     svg.selectAll("#enterChoiceButton"+j).style("visibility", "visible");
                   }
                 });

  function showChoiceButtons(object, j) {
    /// chosePlotButtons controller

    // hide this button
    svg.selectAll("#enterChoiceButton"+j).style("visibility", "hidden");
    // show exitChoiceButton
    svg.select("#exitChoiceButton"+j).style("visibility", "visible");

    // where to place text?
    let plotWidth = parseFloat(d3.select(object).attr("width")),
        plotHeight = parseFloat(d3.select(object).attr("height")),
        x = parseFloat(d3.select(object).attr("x")),
        y = parseFloat(d3.select(object).attr("y"));

    let chosePlotButtons = BOTTOM_G.append("g")
                                   .attr("id","chosePlotButton"+j);

    chosePlotButtons.selectAll()
             .data(notVisiblePlots)
             .enter()
             .append("text")
             .attr("class", "bigTitle")
             .attr("id", d => d.id)
             .attr("x", x + plotWidth/2)
             .attr("y", (d,i) => y + plotHeight/2 + 25*i - (notVisiblePlots.length/2)*25)
             .attr("text-anchor", "middle")
             .text(d => d.text)
             .on("mouseover", function() { d3.select(this).style("cursor", "pointer");})
             .on("mouseout", function() { d3.select(this).style("cursor", "auto");})
             .on("click", function(d) {

               // when clicking on text, hide exitChoiceButton
               svg.selectAll("#exitChoiceButton"+j).style("visibility", "hidden");
               // delete chosePlotButtons
               svg.select("#chosePlotButton"+j).remove();
               // add this plot to visible
               visiblePlots.push({text: d.text, id: this.id, index: j });
               // delete this plot from not visible
               notVisiblePlots = notVisiblePlots.filter(el => el.id !== this.id);

               updatePlots(event = "chosePlot",
                           variableName = null,
                           observationId = null,
                           time = TIME,
                           plotId = this.id);

               // show plot and move it to the right place
               // margin.big added because translate 0 is -10
               svg.select("#"+this.id)
                  .attr("transform","translate(" + (x) + "," + (y + 1.5*margin.big) + ")")
                  .style("visibility", "visible");

               // make exit button visible
               svg.select("#exitPlotButton"+j).style("visibility", "visible");

               // let the user click other buttons
               IS_BUTTON_CLICKED = false;
             });
  }
}

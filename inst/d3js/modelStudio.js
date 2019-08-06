//:\\\ main modelStudio file //:\\\

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

/// stop codon for plot chosing
var plotCountTreshold = d3.min([notVisiblePlots.length,(dim[0]*dim[1])]);

/// generate facet x,y coordinates
var facetData = [];
for (let i=0; i<dim[0]; i++) {
  for (let j=0; j<dim[1]; j++) {
    facetData.push({x:0+j*plotWidth, y:margin.top+i*plotHeight});
  }
}

//:\\\
initializeStudio();
//:\\\

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

  //:\\\ add select observation input
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
                      .attr("disabled", true)
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
  //:\\\

  // bottom buttons
  var BOTTOM_G = svg.append("g")
                    .attr("class", "BOTTOM_G");

  var chosePlotButtons = BOTTOM_G.selectAll()
                                 .data(facetData)
                                 .enter()
                                 .append("rect")
                                 .attr("class", "chosePlotButton")
                                 .attr("id", (d,i) => "plot"+i)
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
        .attr("id", (d,i) => "plot"+i)
        .attr("x1", d => d.x + plotWidth/2)
        .attr("x2", d => d.x + plotWidth/2)
        .attr("y1", d => d.y + plotHeight/2 - margin.big)
        .attr("y2", d => d.y + plotHeight/2 + margin.big);

  BOTTOM_G.selectAll()
        .data(facetData)
        .enter()
        .append("line")
        .attr("class", "mainLine")
        .attr("id", (d,i) => "plot"+i)
        .attr("x1", d => d.x + plotWidth/2 - margin.big)
        .attr("x2", d => d.x + plotWidth/2 + margin.big)
        .attr("y1", d => d.y + plotHeight/2)
        .attr("y2", d => d.y + plotHeight/2);

  chosePlotButtons.on('mouseover', function() { d3.select(this).style("opacity", 1);})
                  .on('mouseout', function() { d3.select(this).style("opacity", 0.5);})
                  .on("click", function(){
                    // block other buttons
                    if (!IS_BUTTON_CLICKED) {
                      IS_BUTTON_CLICKED = true;
                      chosePlot(this);
                    }
                  });

  function chosePlot(object) {
    /// chose plot button controller

    // hide grey button with `+`
    svg.selectAll("#"+object.id).style("visibility", "hidden");

    // make background white button for off click purpose
    let plotWidth = parseFloat(d3.select(object).attr("width")),
        plotHeight = parseFloat(d3.select(object).attr("height")),
        x = parseFloat(d3.select(object).attr("x")),
        y = parseFloat(d3.select(object).attr("y"));

    let tButton = BOTTOM_G.append("g")
                          .attr("id","tempButton"+object.id);

    tButton.append("rect")
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
             IS_BUTTON_CLICKED = false;
           });

    let tText = BOTTOM_G.append("g")
                        .attr("id","tempText"+object.id);

    tText.selectAll()
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
         .on("click", function(d) {

           // when clicking outside of button remove it
           svg.select("#tempButton"+object.id).remove();
           // delete text buttons
           svg.select("#tempText"+object.id).remove();
           // add this plot to visible
           visiblePlots.push({text: d.text, id: this.id});

           // delete this plot from not visible
           notVisiblePlots = notVisiblePlots.filter(el => el.id !== this.id);
           // let the user click other buttons now
           IS_BUTTON_CLICKED = false;

           updatePlots(event = "chosePlot",
                       variableName = null,
                       observationId = null,
                       time = TIME,
                       plotId = this.id);

           // show plot
           svg.select("#"+this.id)
              .attr("transform","translate(" + (x) + "," + (y + margin.big) + ")")
              .style("visibility", "visible");
              // margin.big added because translate 0 is -10

           var tthis = this;

           // add exit button
           svg.select("#"+this.id)
              .append("rect")
              .attr("class", "descriptionBox")
              .attr("id", "exitButton")
              .attr("width", 2*margin.big)
              .attr("height", 2*margin.big)
              .attr("x", margin.big)
              .attr("y",1)
              .attr("rx", 2*margin.big)
              .attr("ry", 2*margin.big);

           svg.select("#"+this.id)
              .append("text")
              .attr("class", "descriptionLabel")
              .attr("id", "exitButton")
              .attr("dy", "1.1em")
              .attr("x", margin.big+margin.small)
              .attr("y", 1)
              .text("X")
              .style("font-family", "Arial");

           // add events for exit button
           svg.select("#"+this.id)
              .selectAll("#exitButton")
              .on("mouseover", function() { d3.select(this).style("cursor", "pointer");})
              .on("mouseout", function() { d3.select(this).style("cursor", "auto");})
              .on("click", function() {

                 // add this plot to not visible
                 notVisiblePlots.push({text: d.text, id: tthis.id});
                 // delete this plot from visible
                 visiblePlots = visiblePlots.filter(el => el.id !== tthis.id);
                 // remove exitButton
                 svg.select("#"+tthis.id).selectAll("#exitButton").remove();
                 // hide plot
                 svg.select("#"+tthis.id)
                    .style("visibility", "hidden");

                 // show grey button with `+`
                 svg.selectAll("#"+object.id).style("visibility", "visible");
             })

           // delete all not needed items and unblock observation choice
           if (visiblePlots.length === plotCountTreshold) {
             BOTTOM_G.remove();
             svg.selectAll("#exitButton").remove();
             inputDiv.select("#input").attr("disabled", null);
           }
         });
  }

  // safeguard font-family update
  svg.selectAll("text")
     .style('font-family', 'Arial');
}

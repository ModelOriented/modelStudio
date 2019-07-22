var dim = generatePlots();

//TODO: change this variables
var studioWidth = dim[0], studioHeight = dim[1], margin = dim[2];
var plotWidth = 420 + margin.left + margin.right,
    plotHeight = 280 + margin.top + margin.bottom;

/// add non plot related stuff
var DEC = svg.append("g");

var plotNavigation = [{text:"Break Down",id:"BD"},{text:"Ceteris Paribus",id:"CP"},
                      {text:"Feature Importance",id:"FI"},{text:"Partial Dependency",id:"PD"}];

decorateStudio();

/// change text font
svg.selectAll("text")
   .style('font-family', 'Fira Sans, sans-serif');

var STARTG = svg.append("g")
                .attr("class", "STARTG");

var chosePlotData = [{x: 0, y: margin.top},
                     {x: plotWidth, y: margin.top},
                     {x: 0, y: margin.top + plotHeight},
                     {x: plotWidth, y: margin.top + plotHeight}];

var chosePlotButton = STARTG.selectAll()
                            .data(chosePlotData)
                            .enter()
                            .append("rect")
                            .attr("class", "chosePlotButton")
                            .attr("id", (d,i) => "plot"+i)
                            .attr("width", plotWidth)
                            .attr("height", plotHeight)
                            .attr("x", d => d.x)
                            .attr("y", d => d.y);

STARTG.append("line")
      .attr("class", "mainLine")
      .attr("x1", plotWidth)
      .attr("x2", plotWidth)
      .attr("y1", margin.top)
      .attr("y2", margin.top + 2*plotHeight);

STARTG.append("line")
      .attr("class", "mainLine")
      .attr("x1", 0)
      .attr("x2", studioWidth)
      .attr("y1", margin.top + plotHeight)
      .attr("y2", margin.top + plotHeight);

STARTG.selectAll()
      .data(chosePlotData)
      .enter()
      .append("line")
      .attr("class", "mainLine")
      .attr("id", (d,i) => "plot"+i)
      .attr("x1", d => d.x + plotWidth/2)
      .attr("x2", d => d.x + plotWidth/2)
      .attr("y1", d => d.y + plotHeight/2 - margin.big)
      .attr("y2", d => d.y + plotHeight/2 + margin.big);


STARTG.selectAll()
      .data(chosePlotData)
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
                 // check if some button is already clicked
                 if (!buttonClicked) {
                  chosePlot(this);
                  buttonClicked = true;
                 }
               });

// at start click first element
var buttonClicked = false;
chosePlotButton.select(".chosePlotButton").dispatch("click");

function decorateStudio(){

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
}

function chosePlot(object) {

  svg.selectAll("#"+object.id).style("visibility", "hidden");

  let plotWidth = parseFloat(d3.select(object).attr("width")),
      plotHeight = parseFloat(d3.select(object).attr("height")),
      x = parseFloat(d3.select(object).attr("x")),
      y = parseFloat(d3.select(object).attr("y"));

  let tempButton = svg.append("g")
                      .attr("id","tempButton"+object.id);

  tempButton.append("rect")
            .attr("width", plotWidth)
            .attr("height", plotHeight)
            .attr("x", x)
            .attr("y", y)
            .style("fill", "white")
            .on("click", function() {

              // when clicking outside of text remove it
              svg.select("#tempText"+object.id).remove();
              // show button again
              svg.selectAll("#"+object.id).style("visibility", "visible");
              // remove this rect
              svg.select("#tempButton"+object.id).remove();
              // let the user click other buttons now
              buttonClicked = false;
            });

  let tempText = svg.append("g")
                    .attr("id","tempText"+object.id);

  tempText.selectAll()
          .data(plotNavigation)
          .enter()
          .append("text")
          .attr("class", "bigTitle")
          .attr("id", d => d.id)
          .attr("x", x + plotWidth/2)
          .attr("y", (d,i) => y + plotHeight/2 + 25*i - (plotNavigation.length/2)*25)
          .attr("text-anchor", "middle")
          .text(d => d.text)
          .style('font-family', 'Fira Sans, sans-serif')
          .on("mouseover", function() { d3.select(this).style("cursor", "pointer");})
          .on("mouseout", function() { d3.select(this).style("cursor", "auto");})
          .on("click", function() {

            // when clicking outside of button remove it
              svg.select("#tempButton"+object.id).remove();
            // delete text buttons
            svg.select("#tempText"+object.id).remove();
            // delete this plot option from text array
            plotNavigation = plotNavigation.filter(el => el.id !== this.id);
            // let the user click other buttons now
            buttonClicked = false;

            // delete all not needed items
            if (plotNavigation.length === 0) STARTG.remove();

            // show plot
            svg.select("#"+this.id)
               .attr("transform","translate(" + (x) + "," + (y + margin.big) + ")")
               .style("visibility", "visible"); // margin.big added because translate 0 is -10
          });
}


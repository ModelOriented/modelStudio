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
    adData = data[3], rvData = data[4],
    fdData = data[4],
    tvData = data[4], atData = data[5];

/// load options
var TIME = options.time,
    modelName = options.model_name,
    variableNames = options.variable_names,
    dim = options.facet_dim,
    versionText = options.version_text,
    measureText = options.measure_text,
    dropDownData = options.drop_down_data,
    openPlots= options.open_plots,
    EDA = options.eda,
    WIDGET_ID = options.widget_id,
    IS_TARGET_BINARY = options.is_target_binary,
    SCALE_PLOT = options.scale_plot,
    SHOW_BOXPLOT = options.show_boxplot,
    SHOW_SUBTITLE = options.show_subtitle,
    subTitle = options.subtitle || modelName,
    msTitle = options.ms_title,
    msSubtitle = options.ms_subtitle,
    barWidth = options.bar_width,
    lineSize = options.line_size,
    pointSize = options.point_size,
    barColor = options.bar_color,
    lineColor = options.line_color,
    pointColor = options.point_color,
    positiveColor = options.positive_color,
    negativeColor = options.negative_color,
    defaultColor = options.default_color,
    bdTitle = options.bd_title,
    bdSubtitle = options.bd_subtitle || subTitle,
    bdAxisTitle = options.bd_axis_title,
    bdBarWidth = options.bd_bar_width || barWidth,
    bdPositiveColor = options.bd_positive_color || positiveColor,
    bdNegativeColor = options.bd_negative_color || negativeColor,
    bdDefaultColor = options.bd_default_color || defaultColor,
    svTitle = options.sv_title,
    svSubtitle = options.sv_subtitle || subTitle,
    svAxisTitle = options.sv_axis_title,
    svBarWidth = options.sv_bar_width || barWidth,
    svPositiveColor = options.sv_positive_color || positiveColor,
    svNegativeColor = options.sv_negative_color || negativeColor,
    cpTitle = options.cp_title,
    cpSubtitle = options.cp_subtitle || subTitle,
    cpAxisTitle = options.cp_axis_title,
    cpBarWidth = options.cp_bar_width || barWidth,
    cpLineSize = options.cp_line_size || lineSize,
    cpPointSize = options.cp_point_size || pointSize,
    cpBarColor = options.cp_bar_color || barColor,
    cpLineColor = options.cp_line_color || lineColor,
    cpPointColor = options.cp_point_color || pointColor,
    fiTitle = options.fi_title,
    fiSubtitle = options.fi_subtitle || subTitle,
    fiAxisTitle = options.fi_axis_title,
    fiBarWidth = options.fi_bar_width || barWidth,
    fiBarColor = options.fi_bar_color || barColor,
    pdTitle = options.pd_title,
    pdSubtitle = options.pd_subtitle || subTitle,
    pdAxisTitle = options.pd_axis_title,
    pdBarWidth = options.pd_bar_width || barWidth,
    pdLineSize = options.pd_line_size || lineSize,
    pdBarColor = options.pd_bar_color || barColor,
    pdLineColor = options.pd_line_color || lineColor,
    adTitle = options.ad_title,
    adSubtitle = options.ad_subtitle || subTitle,
    adAxisTitle = options.ad_axis_title,
    adBarWidth = options.ad_bar_width || barWidth,
    adLineSize = options.ad_line_size || lineSize,
    adBarColor = options.ad_bar_color || barColor,
    adLineColor = options.ad_line_color || lineColor,
    rvTitle = options.rv_title,
    rvSubtitle = options.rv_subtitle || subTitle,
    rvAxisTitle = options.rv_axis_title,
    rvPointSize = options.rv_point_size || pointSize,
    rvPointColor = options.tv_point_color || pointColor,
    fdTitle = options.fd_title,
    fdSubtitle = options.fd_subtitle || subTitle,
    fdAxisTitle = options.fd_axis_title,
    fdBarWidth = options.fd_bar_width || barWidth,
    fdBarColor = options.fd_bar_color || barColor,
    tvTitle = options.tv_title,
    tvSubtitle = options.tv_subtitle || subTitle,
    tvAxisTitle = options.tv_axis_title,
    tvPointSize = options.tv_point_size || pointSize,
    tvPointColor = options.tv_point_color || pointColor,
    atTitle = options.at_title,
    atSubtitle = options.at_subtitle || subTitle,
    atAxisTitle = options.at_axis_title,
    atBarWidth = options.at_bar_width || barWidth,
    atLineSize = options.at_line_size || lineSize,
    atPointSize = options.at_point_size || pointSize,
    atBarColor = options.at_bar_color || barColor,
    atLineColor = options.at_line_color || lineColor,
    atPointColor = options.at_point_color || pointColor,
    telemetry = options.telemetry,
    license = options.license;

/// for observation choice
var observationIds = Object.keys(obsData);

/// set global variables
var CLICKED_VARIABLE_NAME = variableNames[0],
    CLICKED_OBSERVATION_ID = observationIds[0],
    IS_BUTTON_CLICKED = false;

/// set dimensions
var margin = {
  top: options.margin_top,
  right: options.margin_right,
  bottom: options.margin_bottom,
  left: options.margin_left,
  inner: options.margin_inner,
  small: options.margin_small,
  big: options.margin_big,
  ytitle: options.margin_ytitle
};

var w = options.w, h = options.h;

var plotWidth = w + margin.left + margin.right,
    plotHeight = h + margin.top + margin.bottom;

var studioMargin = {top: options.ms_margin_top, bottom: options.ms_margin_bottom},
    studioWidth = dim[1]*plotWidth,
    studioHeight = studioMargin.top + dim[0]*plotHeight + studioMargin.bottom;

/// should subtitle be displayed and plot height be extended
var additionalHeight = 0;
if (!SHOW_SUBTITLE) {
  additionalHeight = 25;
  bdSubtitle = null;
  svSubtitle = null;
  cpSubtitle = null;
  fiSubtitle = null;
  pdSubtitle = null;
  adSubtitle = null;
  rvSubtitle = null;
  fdSubtitle = null;
  tvSubtitle = null;
  atSubtitle = null;
}

/// for plot chosing
var notVisiblePlots = EDA ?
                      [{id:"BD", text: bdTitle + " [Local]"},
                       {id:"SV", text: svTitle + " [Local]"},
                       {id:"CP", text: cpTitle + " [Local]"},
                       {id:"FI", text: fiTitle + " [Global]"},
                       {id:"PD", text: pdTitle + " [Global]"},
                       {id:"AD", text: adTitle + " [Global]"},
                       {id:"RV", text: rvTitle + " [Global]"},
                       {id:"FD", text: fdTitle + " [EDA]"},
                       {id:"TV", text: tvTitle + " [EDA]"},
                       {id:"AT", text: atTitle + " [EDA]"}] :
                      [{id:"BD", text: bdTitle + " [Local]"},
                       {id:"SV", text: svTitle + " [Local]"},
                       {id:"CP", text: cpTitle + " [Local]"},
                       {id:"FI", text: fiTitle + " [Global]"},
                       {id:"PD", text: pdTitle + " [Global]"},
                       {id:"AD", text: adTitle + " [Global]"}];

var visiblePlots = [];

/// generate facet x,y coordinates with grid index
var facetData = [], id = 0;
for (let i = 0; i < dim[0]; i++) {
  for (let j = 0; j < dim[1]; j++) {
    facetData.push({x: 0 + j*plotWidth,
                    y: studioMargin.top + i*plotHeight,
                    index: id});
    id++;
  }
}

///:\\\
if (license) document.head.appendChild(document.createComment(license));
if (telemetry) startTelemetrySession();
initializeStudio();
///:\\\

function initializeStudio() {
  /// this function initializes modelStudio (used only once, at start)

  // center the ms
  d3.select("#" + WIDGET_ID)
    .style('position', 'absolute')
    .style('left', 0)
    .style('right', 0)
    .style('margin', 'auto');

  // top decorations
  var TOP_G = svg.append("g")
                 .attr("class", "TOP_G");

  TOP_G.append("text")
       .attr("class", "mainTitle")
       .attr("x", 15)
       .attr("y", 30)
       .text(msTitle);

  if (msSubtitle !== null) {
      TOP_G.append("text")
           .attr("class", "subTitle")
           .attr("x", 15)
           .attr("y", 40)
           .text(msSubtitle)
           .call(wrapText, studioWidth - 15);
  }

  TOP_G.append("line")
       .attr("class", "mainLine")
       .attr("x1", 10)
       .attr("x2", studioWidth - 10)
       .attr("y1", studioMargin.top - margin.big)
       .attr("y2", studioMargin.top - margin.big);

  ///:\\\ add select observation input
  let ddWidth = calculateTextWidth(dropDownData.map(e => e.text))*1.6 + 18; // 15px bold 600

  var input = d3.select("#" + WIDGET_ID)
                .append("select")
                .attr("id", "input")
                .style("position", "absolute") // to make input appear on top
                .style("left", (studioWidth - margin.big - ddWidth)+"px")
                .style("top", -studioHeight + 180)
                .style("font-size", "15px")
                .style("font-weight", 600)
                .style("color", "#371ea3");

  input.selectAll()
       .data(dropDownData)
       .enter()
       .append("option")
       .attr("value", d => d.id)
       .text(d => d.text)
       .style("font-size", "15px")
       .style("font-weight", 600)
       .style("color", "#371ea3");

  input.on("change", function() {

    // update observation specific plots
    updatePlots(event = "observationChange",
                variableName = null,
                observationId = this.value,
                plotId = null);
  });
  ///:\\\

  ///:\\\ add select variable input
  let ddWidthVar = calculateTextWidth(variableNames)*1.6 + 18; // 15px bold 600

  var inputVar = d3.select("#" + WIDGET_ID)
                   .append("select")
                   .attr("id", "inputVar")
                   .style("position", "absolute") // to make input appear on top
                   .style("left", (studioWidth - margin.big - ddWidthVar - margin.big - ddWidth)+"px")
                   .style("top", -studioHeight + 180)
                   .style("font-size", "15px")
                   .style("font-weight", 600)
                   .style("color", "#371ea3");

  inputVar.selectAll()
          .data(variableNames)
          .enter()
          .append("option")
          .attr("value", d => d)
          .text(d => d)
          .style("font-size", "15px")
          .style("font-weight", 600)
          .style("color", "#371ea3");

  inputVar.on("change", function() {

    // update variable specific plots
    updatePlots(event = "variableChange",
                variableName = this.value,
                observationId = null,
                plotId = null);
  });
  ///:\\\

  // bottom decorations
  var BOTTOM_G = svg.append("g")
                    .attr("class", "BOTTOM_G");

  BOTTOM_G.append("text")
          .attr("class", "footerTitle")
          .attr("x", studioWidth - 15 - getTextWidth(versionText, 12, 'Fira Sans, sans-serif'))
          .attr("y", studioHeight - studioMargin.bottom + 25)
          .text(versionText);

  BOTTOM_G.append("text")
          .attr("class", "footerTitle")
          .attr("x", 15)
          .attr("y", studioHeight - studioMargin.bottom + 25)
          .text(measureText);

  BOTTOM_G.append("line")
          .attr("class", "footerLine")
          .attr("x1", 10)
          .attr("x2", studioWidth - 10)
          .attr("y1", studioHeight - studioMargin.bottom + margin.big)
          .attr("y2", studioHeight - studioMargin.bottom + margin.big);

  // middle buttons
  var MIDDLE_G = svg.append("g")
                    .attr("class", "MIDDLE_G");

  var enterChoiceButtons = MIDDLE_G.selectAll()
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
  MIDDLE_G.selectAll()
          .data(facetData)
          .enter()
          .append("line")
          .attr("class", "mainLine")
          .attr("id", (d,i) => "enterChoiceButton"+i)
          .attr("x1", d => d.x + plotWidth/2)
          .attr("x2", d => d.x + plotWidth/2)
          .attr("y1", d => d.y + plotHeight/2 - margin.big)
          .attr("y2", d => d.y + plotHeight/2 + margin.big);

  MIDDLE_G.selectAll()
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
                    .on("click", function(d,i) {

                      // block other buttons
                      if (!IS_BUTTON_CLICKED) {
                        IS_BUTTON_CLICKED = true;
                        // allow for plot choice or exit choice
                        showChoiceButtons(this, i);
                      }
                    });

  var exitChoiceButtons = MIDDLE_G.selectAll()
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

  var exitPlotButtons = MIDDLE_G.selectAll()
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
                 .attr("dy", "1.05em")
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

    let chosePlotButtons = MIDDLE_G.append("g")
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
  
  for (let i = 0; i < openPlots.length; i++) {
    if (facetData.length > i) {
      svg.selectAll(".enterChoiceButton").filter("#enterChoiceButton"+i).dispatch('click');
      svg.select("#chosePlotButton"+i).select("#"+openPlots[i]).dispatch('click');
    }
  }
  if (facetData.length > openPlots.length) {
    svg.selectAll(".enterChoiceButton").filter("#enterChoiceButton"+openPlots.length).dispatch('click');
  }
}

///:\\\
let telemetrySession = null;
function startTelemetrySession() {
  fetch('https://arena.mini.pw.edu.pl/telemetry/session', {
    method: 'post',
    body: JSON.stringify({
      application: 'modelStudio',
      application_version: telemetry.version,
      data: JSON.stringify({
        ...telemetry
      })
    }),
    headers: {
      'Accept': 'plain/text',
      'Content-Type': 'application/json'
    },
  }).then(response => {
    return response.text()
  }).then(key => {
    telemetrySession = key
  }).catch(console.error)

  setInterval(() => {
    if (!telemetrySession) return
    fetch('https://arena.mini.pw.edu.pl/telemetry/state', {
      method: 'post',
      body: JSON.stringify({
        data: JSON.stringify({
          plots: visiblePlots.map(p => p.id)
        }),
        uuid: telemetrySession
      }),
      headers: {
        'Accept': 'plain/text',
        'Content-Type': 'application/json'
      },
    })
  }, 1000 * 20)
}

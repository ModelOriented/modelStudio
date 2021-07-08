//:\\\ usefull functions //:\\\

function getColors(n, type) {
  // get drWhy palette

  var temp = ["#8bdcbe", "#f05a71", "#371ea3", "#46bac2", "#ae2c87", "#ffa58c", "#4378bf"];
  var ret = [];

  if (type == "bar") {
    switch (n) {
      case 1:
        return ["#46bac2"];
      case 2:
        return ["#46bac2", "#4378bf"];
      case 3:
        return ["#8bdcbe", "#4378bf", "#46bac2"];
      case 4:
        return ["#46bac2", "#371ea3", "#8bdcbe", "#4378bf"];
      case 5:
        return ["#8bdcbe", "#f05a71", "#371ea3", "#46bac2", "#ffa58c"];
      case 6:
        return ["#8bdcbe", "#f05a71", "#371ea3", "#46bac2", "#ae2c87", "#ffa58c"];
      case 7:
        return temp;
      default:
        for (var i = 0; i <= n%7; i++) {
          ret = ret.concat(temp);
        }
        return ret;
    }
  } else if (type == "line") {
    switch (n) {
      case 1:
        return ["#46bac2"];
      case 2:
        return ["#8bdcbe", "#4378bf"];
      case 3:
        return ["#8bdcbe", "#f05a71", "#4378bf"];
      case 4:
        return ["#8bdcbe", "#f05a71", "#4378bf", "#ffa58c"];
      case 5:
        return ["#8bdcbe", "#f05a71", "#4378bf", "#ae2c87", "#ffa58c"];
      case 6:
        return ["#8bdcbe", "#f05a71", "#46bac2", "#ae2c87", "#ffa58c", "#4378bf"];
      case 7:
        return temp;
      default:
        for (var j = 0; j <= n%7; j++) {
          ret = ret.concat(temp);
        }
        return ret;
    }
  } else if (type == "point") {
    switch (n) {
      default:
        return ["#371ea3", "#46bac2", "#ceced9"];
    }
  } else if (type == "breakDown") {
    switch (n) {
      default:
        return ["#8bdcbe", "#f05a71", "#371ea3"];
    }
  }
}

function getTickValues(domain) {
  // find 5 nice ticks with max and min - do better than d3

  var tickValues = d3.ticks(domain[0], domain[1],5);

  switch (tickValues.length) {
    case 3:
      tickValues.unshift(domain[0]);
      tickValues.push(domain[1]);
      break;

    case 4:
      if(Math.abs(domain[0] - tickValues[0]) < Math.abs(domain[1] - tickValues[3])){
        tickValues.shift();
        tickValues.unshift(domain[0]);
        tickValues.push(domain[1]);
      } else {
        tickValues.pop();
        tickValues.push(domain[1]);
        tickValues.unshift(domain[0]);
      }
      break;

    case 5:
      tickValues.pop();
      tickValues.shift();
      tickValues.push(domain[1]);
      tickValues.unshift(domain[0]);
      break;

    case 6:
      if(Math.abs(domain[0] - tickValues[0]) < Math.abs(domain[1] - tickValues[5])){
        tickValues.pop();
        tickValues.shift();
        tickValues.shift();
        tickValues.push(domain[1]);
        tickValues.unshift(domain[0]);
      } else {
        tickValues.pop();
        tickValues.pop();
        tickValues.shift();
        tickValues.push(domain[1]);
        tickValues.unshift(domain[0]);
      }
      break;

    case 7:
      tickValues.pop();
      tickValues.pop();
      tickValues.shift();
      tickValues.shift();
      tickValues.push(domain[1]);
      tickValues.unshift(domain[0]);
      break;

    case 8:
      if(Math.abs(domain[0] - tickValues[0]) < Math.abs(domain[1] - tickValues[7])){
        tickValues.pop();
        tickValues.pop();
        tickValues.shift();
        tickValues.shift();
        tickValues.shift();
        tickValues.push(domain[1]);
        tickValues.unshift(domain[0]);
      } else {
        tickValues.pop();
        tickValues.pop();
        tickValues.pop();
        tickValues.shift();
        tickValues.shift();
        tickValues.push(domain[1]);
        tickValues.unshift(domain[0]);
      }
      break;
    }

  return tickValues;
}

function calculateTextWidth(text) {
  // calculate max width of 11px text array

  var temp = svg.selectAll()
                .data(text)
                .enter();

  var textWidth = [];

  temp.append("text")
      .attr("class", "toRemove")
      .text(function(d) { return d;})
      .style("font-size", "11px")
      .style('font-family', 'Fira Sans, sans-serif')
      .each(function(d,i) {
          var thisWidth = this.getComputedTextLength();
          textWidth.push(thisWidth);
      });

  svg.selectAll('.toRemove').remove();
  temp.remove();

  var maxLength = d3.max(textWidth);

  return maxLength;
}

function getTextWidth(text, fontSize, fontFace) {
  // calculate width of single text

  var canvas = document.createElement('canvas');
  var context = canvas.getContext('2d');
  context.font = fontSize + 'px ' + fontFace;
  return context.measureText(text).width;
}

function getMaxTextWidth(textArray, fontSize, fontFace) {
  let maxTextWidth = 0;
  for (let i = 0; i < textArray.length; i++) {
    let textWidth = getTextWidth(textArray[i], fontSize, fontFace)
    if (textWidth > maxTextWidth) {
      maxTextWidth = textWidth
    }
  }
  return maxTextWidth
}

function wrapText(text, width) {
  // this function wraps text
  text.each(function () {
      var text = d3.select(this).style('font-family', 'Fira Sans, sans-serif'),
          words = text.text().split(/\s+/).reverse(),
          word,
          line = [],
          lineNumber = 0,
          lineHeight = 1.05, // ems
          x = text.attr("x"),
          y = text.attr("y"),
          dy = 0, //parseFloat(text.attr("dy")),
          tspan = text.text(null)
                      .append("tspan")
                      .attr("x", x)
                      .attr("y", y)
                      .attr("dy", dy + "em");
      while (word = words.pop()) {
          line.push(word);
          tspan.text(line.join(" "));
          if (tspan.node().getComputedTextLength() > width) {
              line.pop();
              tspan.text(line.join(" "));
              line = [word];
              tspan = text.append("tspan")
                          .attr("x", x)
                          .attr("y", y)
                          .attr("dy", ++lineNumber * lineHeight + dy + "em")
                          .text(word);
          }
      }
  });
}

function wrapHtmlOutput(text) {
  var output = "";
  text.replace(/\(?[A-Z][^\.]+[\.!\?]\)?/g, function (sentence) {
      output += (sentence + '<br>');
  });
  return output;
}

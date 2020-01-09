//:\\\ here are functions for tooltips HTML //:\\\

function bdTooltipHtml(d) {
  var temp = "<center>";
  temp += d.tooltipText;
  temp += "</center>";
  return temp;
}

function cpStaticTooltipHtml(d) {
  // function formats tooltip text
  var temp = "";
  for (var [k, v] of Object.entries(d)) {
    if (k === "yhat") {
      k = "prediction";
      temp += "<center>" +  k + ": " + v + "</br>";
      temp += "</br>";
    } else {
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

function fiStaticTooltipHtml(d) {
    let sign;
    if (d.dropout_loss > d.full_model) sign = "+"; else sign = "";
    var temp =  "<center>" + "model loss after feature " + d.variable
      + "</br>" + "<center>" +
      " is permuted: " +  Math.round(d.dropout_loss * 1000)/1000
      + "</br>" + "<center>" + "drop-out loss change: " +
      sign + Math.round((d.dropout_loss-d.full_model)*1000)/1000;
    return temp;
}

function pdStaticTooltipHtml(d, variableName, yMean) {
  // function formats tooltip text
  var temp = "";
  for (var [k, v] of Object.entries(d)) {
    switch(k){
      case "xhat":
        temp += "<center>" +  variableName  + ": " + v + "</br>";
        break;
      case "yhat":
        temp += "<center>" +  "average prediction"  + ": " + v + "</br>";
        break;
      case "vname":
        break;
      default:
        temp += "<center>" +  k  + ": " + v + "</br>";
        break;
    }
  }

  temp += "</br><center>" +
          "mean observation prediction:" +
          "</br>" + yMean + "</br>";
  return temp;
}

function adStaticTooltipHtml(d, variableName, yMean) {
  // function formats tooltip text
  var temp = "";
  for (var [k, v] of Object.entries(d)) {
    switch(k){
      case "xhat":
        temp += "<center>" +  variableName  + ": " + v + "</br>";
        break;
      case "yhat":
        temp += "<center>" +  "accumulated prediction"  + ": " + v + "</br>";
        break;
      case "vname":
        break;
      default:
        temp += "<center>" +  k  + ": " + v + "</br>";
        break;
    }
  }

  temp += "</br><center>" +
          "mean observation prediction:" +
          "</br>" + yMean + "</br>";
  return temp;
}

function descTooltipHtml(d) {
  var temp = "<center>";
  temp += d.text;
  temp += "</center>";
  return temp;
}

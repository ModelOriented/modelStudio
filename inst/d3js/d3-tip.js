/* d3.tip Copyright (c) 2013 Justin Palmer Tooltips for d3.js SVG visualizations */
/// MADE SOME CHANGES

d3.functor = function functor(v) {
  return typeof v === "function" ? v : function() {
    return v;
  };
};

d3.tip = function() {

  var direction = d3_tip_direction,
      offset    = d3_tip_offset,
      html      = d3_tip_html,
      node      = initNode(),
      svg       = null,
      point     = null,
      target    = null;

  function tip(vis) {
    svg = getSVGNode(vis)
    point = svg.createSVGPoint()
    document.body.appendChild(node)
  }

  // Public - show the tooltip on the screen
  //
  // Returns a tip
  tip.show = function() {
    var args = Array.prototype.slice.call(arguments)
    if(args[args.length - 1] instanceof SVGElement) target = args.pop()

    var content = html.apply(this, args),
        poffset = offset.apply(this, args),
        dir     = direction.apply(this, args),
        nodel   = getNodeEl(),
        i       = directions.length,
        coords,
        scrollTop  = document.documentElement.scrollTop || document.body.scrollTop,
        scrollLeft = document.documentElement.scrollLeft || document.body.scrollLeft

    /// unclass all directions
    while(i--) nodel.classed(directions[i], false)

    ////////////////////////////////:::::::::////////////////////////////////
    // make sure that tip is pointing right direction (not outside of svg) \\
    // 'n' means that tooltip will go north from pointer

    // do not move this code V
    nodel.html(content)
          .style('position', 'absolute')
          .style('opacity', .8)
          .style('pointer-events', 'all')
    // do not move this code ^

    var tdir = dir;

    var divDim = node.getBoundingClientRect(),
        svgDim = svg.getBBox();

    // 20 is for 2x r2d3 margin and 7 was added empiricaly
    var sh = 20 + svgDim.height;// + 7; // this is modelSTudio plotHeight
    var sw = 20 + svgDim.width;
    var dh = divDim.height;
    var dw = divDim.width;
    var py = d3.event.pageY;
    var px = d3.event.pageX;

    // by default put tooltip 'n'
    var ttop = py - dh - 5;
    var tleft = px - dw/2;
    var tdir = "n";
    var tpdd = '6px 6px 13px 6px';

    if (px - dw/2 < 10) {
      tleft = px + 5;
      tdir = "ne";
      tpdd = '6px 6px 11px 11px';
      if (py - dh/2 < 10) {
        ttop = py - dh/2;
        tdir = "e";
        tpdd = '6px 6px 6px 13px';
      } else if (py - dh < 10) {
        ttop = py + 5;
        tdir = "se";
        tpdd = '11px 6px 6px 11px';
      }
    } else if (px + dw/2 > sw - 10) {
      tleft = px - dw - 5;
      ttop = py - dh - 5;
      tdir = "nw";
      tpdd = '6px 11px 11px 6px';
      if (py - dh/2 < 10) {
        ttop = py - dh/2;
        tdir = "w"
        tpdd = '6px 13px 6px 6px';
      } else if (py - dh < 10) {
        ttop = py + 5;
        tdir = "sw";
        tpdd = '11px 11px 6px 6px';
      }
      // because description is to long FIXME/TODO: more cases
      if (tleft < 5) {
        ttop = py + 5;
        tleft = px - dw/2;
        tdir = "s";
        tpdd = '13px 6px 6px 6px';
      }
    } else if (py - dh < 10) {
      ttop = py + 5;
      tleft = px - dw/2;
      tdir = "s";
      tpdd = '13px 6px 6px 6px';
    }

    nodel.classed(tdir, true)
          .style('top', (ttop + poffset[0]) + 'px')
          .style('left', (tleft + poffset[1]) + 'px')
          .style('padding', tpdd);

    ////////////////////////////////::::::::://///////////////////////////////

    //safeguard
    if (dw == 0) {
      return tip.hide()
    } else {
      return tip
    }
  }

  // Public - hide the tooltip
  //
  // Returns a tip
  tip.hide = function() {
    var nodel = getNodeEl()
    nodel
      .style('opacity', 0)
      .style('pointer-events', 'none')
    return tip
  }

  // Public: Proxy attr calls to the d3 tip container.  Sets or gets attribute value.
  //
  // n - name of the attribute
  // v - value of the attribute
  //
  // Returns tip or attribute value
  tip.attr = function(n, v) {
    if (arguments.length < 2 && typeof n === 'string') {
      return getNodeEl().attr(n)
    } else {
      var args =  Array.prototype.slice.call(arguments)
      d3.selection.prototype.attr.apply(getNodeEl(), args)
    }

    return tip
  }

  // Public: Proxy style calls to the d3 tip container.  Sets or gets a style value.
  //
  // n - name of the property
  // v - value of the property
  //
  // Returns tip or style property value
  tip.style = function(n, v) {
    // debugger;
    if (arguments.length < 2 && typeof n === 'string') {
      return getNodeEl().style(n)
    } else {
      var args = Array.prototype.slice.call(arguments);
      if (args.length === 1) {
        var styles = args[0];
        Object.keys(styles).forEach(function(key) {
          return d3.selection.prototype.style.apply(getNodeEl(), [key, styles[key]]);
        });
      }
    }

    return tip
  }

  // Public: Set or get the direction of the tooltip
  //
  // v - One of n(north), s(south), e(east), or w(west), nw(northwest),
  //     sw(southwest), ne(northeast) or se(southeast)
  //
  // Returns tip or direction
  tip.direction = function(v) {
    if (!arguments.length) return direction
    direction = v == null ? v : d3.functor(v)

    return tip
  }

  // Public: Sets or gets the offset of the tip
  //
  // v - Array of [x, y] offset
  //
  // Returns offset or
  tip.offset = function(v) {
    if (!arguments.length) return offset
    offset = v == null ? v : d3.functor(v)

    return tip
  }

  // Public: sets or gets the html value of the tooltip
  //
  // v - String value of the tip
  //
  // Returns html value or tip
  tip.html = function(v) {
    if (!arguments.length) return html
    html = v == null ? v : d3.functor(v)

    return tip
  }

  // Public: destroys the tooltip and removes it from the DOM
  //
  // Returns a tip
  tip.destroy = function() {
    if(node) {
      getNodeEl().remove();
      node = null;
    }
    return tip;
  }

  function d3_tip_direction() { return 'n' }
  function d3_tip_offset() { return [0, 0] }
  function d3_tip_html() { return ' ' }

  var direction_callbacks = {
    n:  direction_n,
    s:  direction_s,
    e:  direction_e,
    w:  direction_w,
    nw: direction_nw,
    ne: direction_ne,
    sw: direction_sw,
    se: direction_se
  };

  var directions = Object.keys(direction_callbacks);

  function direction_n() {
    var bbox = getScreenBBox()
    return {
      top:  bbox.n.y - node.offsetHeight,
      left: bbox.n.x - node.offsetWidth / 2
    }
  }

  function direction_s() {
    var bbox = getScreenBBox()
    return {
      top:  bbox.s.y,
      left: bbox.s.x - node.offsetWidth / 2
    }
  }

  function direction_e() {
    var bbox = getScreenBBox()
    return {
      top:  bbox.e.y - node.offsetHeight / 2,
      left: bbox.e.x
    }
  }

  function direction_w() {
    var bbox = getScreenBBox()
    return {
      top:  bbox.w.y - node.offsetHeight / 2,
      left: bbox.w.x - node.offsetWidth
    }
  }

  function direction_nw() {
    var bbox = getScreenBBox()
    return {
      top:  bbox.nw.y - node.offsetHeight,
      left: bbox.nw.x - node.offsetWidth
    }
  }

  function direction_ne() {
    var bbox = getScreenBBox()
    return {
      top:  bbox.ne.y - node.offsetHeight,
      left: bbox.ne.x
    }
  }

  function direction_sw() {
    var bbox = getScreenBBox()
    return {
      top:  bbox.sw.y,
      left: bbox.sw.x - node.offsetWidth
    }
  }

  function direction_se() {
    var bbox = getScreenBBox()
    return {
      top:  bbox.se.y,
      left: bbox.e.x
    }
  }

  function initNode() {
    var node = d3.select(document.createElement('div'))
    node
      .style('position', 'absolute')
      .style('top', 0)
      .style('opacity', 0)
      .style('pointer-events', 'none')
      .style('box-sizing', 'border-box')
      .style('line-heigh', 1.1)
      .style('background', "#000000")
      .style('color', '#fff')
      .style('font-size', '14px')
      .style('font-family', "'Roboto Condensed', sans-serif");

    return node.node()
  }


  function getSVGNode(el) {
    el = el.node()
    if(el.tagName.toLowerCase() === 'svg')
      return el

    return el.ownerSVGElement
  }

  function getNodeEl() {
    if(node === null) {
      node = initNode();
      // re-add node to DOM
      document.body.appendChild(node);
    };
    return d3.select(node);
  }

  // Returns an Object {n, s, e, w, nw, sw, ne, se}
  function getScreenBBox() {
    var targetel   = target || d3.event.target;

    while ('undefined' === typeof targetel.getScreenCTM && 'undefined' === targetel.parentNode) {
        targetel = targetel.parentNode;
    }

    var bbox       = {},
        matrix     = targetel.getScreenCTM(),
        tbbox      = targetel.getBBox(),
        width      = tbbox.width,
        height     = tbbox.height,
        x          = tbbox.x,
        y          = tbbox.y

    point.x = x
    point.y = y
    bbox.nw = point.matrixTransform(matrix)
    point.x += width
    bbox.ne = point.matrixTransform(matrix)
    point.y += height
    bbox.se = point.matrixTransform(matrix)
    point.x -= width
    bbox.sw = point.matrixTransform(matrix)
    point.y -= height / 2
    bbox.w  = point.matrixTransform(matrix)
    point.x += width
    bbox.e = point.matrixTransform(matrix)
    point.x -= width / 2
    point.y -= height / 2
    bbox.n = point.matrixTransform(matrix)
    point.y += height
    bbox.s = point.matrixTransform(matrix)

    return bbox
  }

  return tip
};

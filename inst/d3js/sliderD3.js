// https://github.com/johnwalley/d3-simple-slider v1.5.4 Copyright 2019 John Walley
(function (global, factory) {
typeof exports === 'object' && typeof module !== 'undefined' ? factory(exports, require('d3-array'), require('d3-axis'), require('d3-dispatch'), require('d3-drag'), require('d3-ease'), require('d3-scale'), require('d3-selection'), require('d3-transition')) :
typeof define === 'function' && define.amd ? define(['exports', 'd3-array', 'd3-axis', 'd3-dispatch', 'd3-drag', 'd3-ease', 'd3-scale', 'd3-selection', 'd3-transition'], factory) :
(global = global || self, factory(global.d3 = global.d3 || {}, global.d3, global.d3, global.d3, global.d3, global.d3, global.d3, global.d3));
}(this, function (exports, d3Array, d3Axis, d3Dispatch, d3Drag, d3Ease, d3Scale, d3Selection) { 'use strict';

var UPDATE_DURATION = 200;
var SLIDER_END_PADDING = 8;
var KEYBOARD_NUMBER_STEPS = 100;

var top = 1;
var right = 2;
var bottom = 3;
var left = 4;

function translateX(x) {
  return 'translate(' + x + ',0)';
}

function translateY(y) {
  return 'translate(0,' + y + ')';
}

function slider(orientation, scale) {
  scale = typeof scale !== 'undefined' ? scale : null;

  var value = [0];
  var defaultValue = [0];
  var domain = [0, 10];
  var width = 100;
  var height = 100;
  var displayValue = true;
  var handle = 'M-5.5,-5.5v10l6,5.5l6,-5.5v-10z';
  var step = null;
  var tickValues = null;
  var marks = null;
  var tickFormat = null;
  var ticks = null;
  var displayFormat = null;
  var fill = null;

  var listeners = d3Dispatch.dispatch('onchange', 'start', 'end', 'drag');

  var selection = null;
  var identityClamped = null;
  var handleIndex = null;

  var k = orientation === top || orientation === left ? -1 : 1;
  var x = orientation === left || orientation === right ? 'y' : 'x';
  var y = orientation === left || orientation === right ? 'x' : 'y';

  var transformAlong =
    orientation === top || orientation === bottom ? translateX : translateY;

  var transformAcross =
    orientation === top || orientation === bottom ? translateY : translateX;

  var axisFunction = null;

  switch (orientation) {
    case top:
      axisFunction = d3Axis.axisTop;
      break;
    case right:
      axisFunction = d3Axis.axisRight;
      break;
    case bottom:
      axisFunction = d3Axis.axisBottom;
      break;
    case left:
      axisFunction = d3Axis.axisLeft;
      break;
  }

  var handleSelection = null;
  var fillSelection = null;
  var textSelection = null;

  if (scale) {
    domain = [d3Array.min(scale.domain()), d3Array.max(scale.domain())];

    if (orientation === top || orientation === bottom) {
      width = d3Array.max(scale.range()) - d3Array.min(scale.range());
    } else {
      height = d3Array.max(scale.range()) - d3Array.min(scale.range());
    }

    scale = scale.clamp(true);
  }

  function slider(context) {
    selection = context.selection ? context.selection() : context;

    if (scale) {
      scale = scale.range([
        d3Array.min(scale.range()),
        d3Array.min(scale.range()) +
          (orientation === top || orientation === bottom ? width : height),
      ]);
    } else {
      scale = domain[0] instanceof Date ? d3Scale.scaleTime() : d3Scale.scaleLinear();

      scale = scale
        .domain(domain)
        .range(
          orientation === top || orientation === bottom
            ? [0, width]
            : [height, 0]
        )
        .clamp(true);
    }

    identityClamped = d3Scale.scaleLinear()
      .range(scale.range())
      .domain(scale.range())
      .clamp(true);

    // Ensure value is valid
    value = value.map(function(d) {
      return d3Scale.scaleLinear()
        .range(domain)
        .domain(domain)
        .clamp(true)(d);
    });

    tickFormat = tickFormat || scale.tickFormat();
    displayFormat = displayFormat || tickFormat || scale.tickFormat();

    var axis = selection.selectAll('.axis').data([null]);

    axis
      .enter()
      .append('g')
      .attr('transform', transformAcross(k * 7))
      .attr('class', 'axis');

    var sliderSelection = selection.selectAll('.slider').data([null]);

    var sliderEnter = sliderSelection
      .enter()
      .append('g')
      .attr('class', 'slider')
      .attr(
        'cursor',
        orientation === top || orientation === bottom
          ? 'ew-resize'
          : 'ns-resize'
      )
      .call(
        d3Drag.drag()
          .on('start', dragstarted)
          .on('drag', dragged)
          .on('end', dragended)
      );

    sliderEnter
      .append('line')
      .attr('class', 'track')
      .attr(x + '1', scale.range()[0] - k * SLIDER_END_PADDING)
      .attr('stroke', '#bbb')
      .attr('stroke-width', 6)
      .attr('stroke-linecap', 'round');

    sliderEnter
      .append('line')
      .attr('class', 'track-inset')
      .attr(x + '1', scale.range()[0] - k * SLIDER_END_PADDING)
      .attr('stroke', '#eee')
      .attr('stroke-width', 4)
      .attr('stroke-linecap', 'round');

    if (fill) {
      sliderEnter
        .append('line')
        .attr('class', 'track-fill')
        .attr(
          x + '1',
          value.length === 1
            ? scale.range()[0] - k * SLIDER_END_PADDING
            : scale(value[0])
        )
        .attr('stroke', fill)
        .attr('stroke-width', 4)
        .attr('stroke-linecap', 'round');
    }

    sliderEnter
      .append('line')
      .attr('class', 'track-overlay')
      .attr(x + '1', scale.range()[0] - k * SLIDER_END_PADDING)
      .attr('stroke', 'transparent')
      .attr('stroke-width', 40)
      .attr('stroke-linecap', 'round')
      .merge(sliderSelection.select('.track-overlay'));

    handleSelection = sliderEnter.selectAll('.parameter-value').data(value);

    var handleEnter = handleSelection
      .enter()
      .append('g')
      .attr('class', 'parameter-value')
      .attr('transform', function(d) {
        return transformAlong(scale(d));
      })
      .attr('font-family', 'sans-serif')
      .attr(
        'text-anchor',
        orientation === right
          ? 'start'
          : orientation === left
          ? 'end'
          : 'middle'
      );

    handleEnter
      .append('path')
      .attr('transform', 'rotate(' + (orientation + 1) * 90 + ')')
      .attr('d', handle)
      .attr('class', 'handle')
      .attr('aria-label', 'handle')
      .attr('aria-valuemax', domain[1])
      .attr('aria-valuemin', domain[0])
      .attr('aria-valuenow', value)
      .attr(
        'aria-orientation',
        orientation === left || orientation === right
          ? 'vertical'
          : 'horizontal'
      )
      .attr('focusable', 'true')
      .attr('tabindex', 0)
      .attr('fill', 'white')
      .attr('stroke', '#777')
      .on('keydown', function(d, i) {
        var change = step || (domain[1] - domain[0]) / KEYBOARD_NUMBER_STEPS;

        // TODO: Don't need to loop over value because we know which element needs to change
        function newValue(adjustedValue) {
          return value.map(function(d, j) {
            if (value.length === 2) {
              return j === i
                ? i === 0
                  ? Math.min(adjustedValue, alignedValue(value[1]))
                  : Math.max(adjustedValue, alignedValue(value[0]))
                : d;
            } else {
              return j === i ? adjustedValue : d;
            }
          });
        }

        switch (d3Selection.event.key) {
          case 'ArrowLeft':
          case 'ArrowDown':
            slider.value(newValue(+value[i] - change));
            d3Selection.event.preventDefault();
            break;
          case 'PageDown':
            slider.value(newValue(+value[i] - 2 * change));
            d3Selection.event.preventDefault();
            break;
          case 'ArrowRight':
          case 'ArrowUp':
            slider.value(newValue(+value[i] + change));
            d3Selection.event.preventDefault();
            break;
          case 'PageUp':
            slider.value(newValue(+value[i] + 2 * change));
            d3Selection.event.preventDefault();
            break;
          case 'Home':
            slider.value(newValue(domain[0]));
            d3Selection.event.preventDefault();
            break;
          case 'End':
            slider.value(newValue(domain[1]));
            d3Selection.event.preventDefault();
            break;
        }
      });

    if (displayValue && value.length === 1) {
      handleEnter
        .append('text')
        .attr('font-size', 10) // TODO: Remove coupling to font-size in d3-axis
        .attr(y, k * 27)
        .attr(
          'dy',
          orientation === top
            ? '0em'
            : orientation === bottom
            ? '.71em'
            : '.32em'
        )
        .text(tickFormat(value[0]));
    }

    context
      .select('.track')
      .attr(x + '2', scale.range()[1] + k * SLIDER_END_PADDING);

    context
      .select('.track-inset')
      .attr(x + '2', scale.range()[1] + k * SLIDER_END_PADDING);

    if (fill) {
      context
        .select('.track-fill')
        .attr(x + '2', value.length === 1 ? scale(value[0]) : scale(value[1]));
    }

    context
      .select('.track-overlay')
      .attr(x + '2', scale.range()[1] + k * SLIDER_END_PADDING);

    context.select('.axis').call(
      axisFunction(scale)
        .tickFormat(tickFormat)
        .ticks(ticks)
        .tickValues(tickValues)
    );

    // https://bl.ocks.org/mbostock/4323929
    selection
      .select('.axis')
      .select('.domain')
      .remove();

    context.select('.axis').attr('transform', transformAcross(k * 7));

    context
      .selectAll('.axis text')
      .attr('fill', '#aaa')
      .attr(y, k * 20)
      .attr(
        'dy',
        orientation === top ? '0em' : orientation === bottom ? '.71em' : '.32em'
      )
      .attr(
        'text-anchor',
        orientation === right
          ? 'start'
          : orientation === left
          ? 'end'
          : 'middle'
      );

    context.selectAll('.axis line').attr('stroke', '#aaa');

    context.selectAll('.parameter-value').attr('transform', function(d) {
      return transformAlong(scale(d));
    });

    fadeTickText();

    function computeDragNewValue(pos) {
      var adjustedValue = alignedValue(scale.invert(pos));
      return value.map(function(d, i) {
        if (value.length === 2) {
          return i === handleIndex
            ? handleIndex === 0
              ? Math.min(adjustedValue, alignedValue(value[1]))
              : Math.max(adjustedValue, alignedValue(value[0]))
            : d;
        } else {
          return i === handleIndex ? adjustedValue : d;
        }
      });
    }

    function dragstarted() {
      d3Selection.select(this).classed('active', true);

      var pos = identityClamped(
        orientation === bottom || orientation === top ? d3Selection.event.x : d3Selection.event.y
      );

      // Handle cases where both handles are at the same end of the slider
      if (value[0] === domain[0] && value[1] === domain[0]) {
        handleIndex = 1;
      } else if (value[0] === domain[1] && value[1] === domain[1]) {
        handleIndex = 0;
      } else {
        handleIndex = d3Array.scan(
          value.map(function(d) {
            return Math.abs(d - alignedValue(scale.invert(pos)));
          })
        );
      }

      var newValue = value.map(function(d, i) {
        return i === handleIndex ? alignedValue(scale.invert(pos)) : d;
      });

      updateHandle(newValue);
      listeners.call(
        'start',
        sliderSelection,
        newValue.length === 1 ? newValue[0] : newValue
      );
      updateValue(newValue, true);
    }

    function dragged() {
      var pos = identityClamped(
        orientation === bottom || orientation === top ? d3Selection.event.x : d3Selection.event.y
      );
      var newValue = computeDragNewValue(pos);

      updateHandle(newValue);
      listeners.call(
        'drag',
        sliderSelection,
        newValue.length === 1 ? newValue[0] : newValue
      );
      updateValue(newValue, true);
    }

    function dragended() {
      d3Selection.select(this).classed('active', false);

      var pos = identityClamped(
        orientation === bottom || orientation === top ? d3Selection.event.x : d3Selection.event.y
      );
      var newValue = computeDragNewValue(pos);

      updateHandle(newValue);
      listeners.call(
        'end',
        sliderSelection,
        newValue.length === 1 ? newValue[0] : newValue
      );
      updateValue(newValue, true);

      handleIndex = null;
    }

    textSelection = selection.select('.parameter-value text');
    fillSelection = selection.select('.track-fill');
  }

  function fadeTickText() {
    if (selection) {
      if (displayValue && value.length === 1) {
        var distances = [];

        selection.selectAll('.axis .tick').each(function(d) {
          distances.push(Math.abs(d - value[0]));
        });

        var index = d3Array.scan(distances);

        selection.selectAll('.axis .tick text').attr('opacity', function(d, i) {
          return i === index ? 0 : 1;
        });
      }
    }
  }

  function alignedValue(newValue) {
    if (step) {
      var valueModStep = (newValue - domain[0]) % step;
      var alignValue = newValue - valueModStep;

      if (valueModStep * 2 > step) {
        alignValue += step;
      }

      return newValue instanceof Date ? new Date(alignValue) : alignValue;
    }

    if (marks) {
      var index = d3Array.scan(
        marks.map(function(d) {
          return Math.abs(newValue - d);
        })
      );

      return marks[index];
    }

    return newValue;
  }

  function updateValue(newValue, notifyListener) {
    if (
      value[0] !== newValue[0] ||
      (value.length > 1 && value[1] !== newValue[1])
    ) {
      value = newValue;

      if (notifyListener) {
        listeners.call(
          'onchange',
          slider,
          newValue.length === 1 ? newValue[0] : newValue
        );
      }

      fadeTickText();
    }
  }

  function updateHandle(newValue, animate) {
    if (selection) {
      animate = typeof animate !== 'undefined' ? animate : false;

      if (animate) {
        selection
          .selectAll('.parameter-value')
          .data(newValue)
          .transition()
          .ease(d3Ease.easeQuadOut)
          .duration(UPDATE_DURATION)
          .attr('transform', function(d) {
            return transformAlong(scale(d));
          })
          .select('.handle')
          .attr('aria-valuenow', function(d) {
            return d;
          });

        if (fill) {
          fillSelection
            .transition()
            .ease(d3Ease.easeQuadOut)
            .duration(UPDATE_DURATION)
            .attr(
              x + '1',
              value.length === 1
                ? scale.range()[0] - k * SLIDER_END_PADDING
                : scale(newValue[0])
            )
            .attr(
              x + '2',
              value.length === 1 ? scale(newValue[0]) : scale(newValue[1])
            );
        }
      } else {
        selection
          .selectAll('.parameter-value')
          .data(newValue)
          .attr('transform', function(d) {
            return transformAlong(scale(d));
          })
          .select('.handle')
          .attr('aria-valuenow', function(d) {
            return d;
          });

        if (fill) {
          fillSelection
            .attr(
              x + '1',
              value.length === 1
                ? scale.range()[0] - k * SLIDER_END_PADDING
                : scale(newValue[0])
            )
            .attr(
              x + '2',
              value.length === 1 ? scale(newValue[0]) : scale(newValue[1])
            );
        }
      }

      if (displayValue) {
        textSelection.text(displayFormat(newValue[0]));
      }
    }
  }

  slider.min = function(_) {
    if (!arguments.length) return domain[0];
    domain[0] = _;
    return slider;
  };

  slider.max = function(_) {
    if (!arguments.length) return domain[1];
    domain[1] = _;
    return slider;
  };

  slider.domain = function(_) {
    if (!arguments.length) return domain;
    domain = _;
    return slider;
  };

  slider.width = function(_) {
    if (!arguments.length) return width;
    width = _;
    return slider;
  };

  slider.height = function(_) {
    if (!arguments.length) return height;
    height = _;
    return slider;
  };

  slider.tickFormat = function(_) {
    if (!arguments.length) return tickFormat;
    tickFormat = _;
    return slider;
  };

  slider.displayFormat = function(_) {
    if (!arguments.length) return displayFormat;
    displayFormat = _;
    return slider;
  };

  slider.ticks = function(_) {
    if (!arguments.length) return ticks;

    ticks = _;
    return slider;
  };

  slider.value = function(_) {
    if (!arguments.length) {
      if (value.length === 1) {
        return value[0];
      }

      return value;
    }

    var toArray = Array.isArray(_) ? _ : [_];
    toArray.sort(function(a, b) {
      return a - b;
    });
    var pos = toArray.map(scale).map(identityClamped);
    var newValue = pos.map(scale.invert).map(alignedValue);

    updateHandle(newValue, true);
    updateValue(newValue, true);

    return slider;
  };

  slider.silentValue = function(_) {
    if (!arguments.length) {
      if (value.length === 1) {
        return value[0];
      }

      return value;
    }

    var toArray = Array.isArray(_) ? _ : [_];
    toArray.sort(function(a, b) {
      return a - b;
    });
    var pos = toArray.map(scale).map(identityClamped);
    var newValue = pos.map(scale.invert).map(alignedValue);

    updateHandle(newValue, false);
    updateValue(newValue, false);

    return slider;
  };

  slider.default = function(_) {
    if (!arguments.length) {
      if (defaultValue.length === 1) {
        return defaultValue[0];
      }

      return defaultValue;
    }

    var toArray = Array.isArray(_) ? _ : [_];

    toArray.sort(function(a, b) {
      return a - b;
    });

    defaultValue = toArray;
    value = toArray;
    return slider;
  };

  slider.step = function(_) {
    if (!arguments.length) return step;
    step = _;
    return slider;
  };

  slider.tickValues = function(_) {
    if (!arguments.length) return tickValues;
    tickValues = _;
    return slider;
  };

  slider.marks = function(_) {
    if (!arguments.length) return marks;
    marks = _;
    return slider;
  };

  slider.handle = function(_) {
    if (!arguments.length) return handle;
    handle = _;
    return slider;
  };

  slider.displayValue = function(_) {
    if (!arguments.length) return displayValue;
    displayValue = _;
    return slider;
  };

  slider.fill = function(_) {
    if (!arguments.length) return fill;
    fill = _;
    return slider;
  };

  slider.on = function() {
    var value = listeners.on.apply(listeners, arguments);
    return value === listeners ? slider : value;
  };

  return slider;
}

function sliderHorizontal(scale) {
  return slider(bottom, scale);
}

function sliderVertical(scale) {
  return slider(left, scale);
}

function sliderTop(scale) {
  return slider(top, scale);
}

function sliderRight(scale) {
  return slider(right, scale);
}

function sliderBottom(scale) {
  return slider(bottom, scale);
}

function sliderLeft(scale) {
  return slider(left, scale);
}

exports.sliderHorizontal = sliderHorizontal;
exports.sliderVertical = sliderVertical;
exports.sliderTop = sliderTop;
exports.sliderRight = sliderRight;
exports.sliderBottom = sliderBottom;
exports.sliderLeft = sliderLeft;

Object.defineProperty(exports, '__esModule', { value: true });

}));

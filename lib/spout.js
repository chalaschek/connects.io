// Generated by CoffeeScript 1.3.3
var EventEmitter, Spout,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

EventEmitter = require("events").EventEmitter;

Spout = (function(_super) {

  __extends(Spout, _super);

  function Spout() {
    return Spout.__super__.constructor.apply(this, arguments);
  }

  return Spout;

})(EventEmitter);

module.exports = Spout;
String shortString(double v, {int fixed = 2}) {
  var vint = v.toInt();
  return v == vint ? vint.toString() : v.toStringAsFixed(fixed);
}

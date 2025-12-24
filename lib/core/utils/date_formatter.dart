String friendlyDate(DateTime dt) {
  final wk = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  return '${wk[dt.weekday % 7]} • ${dt.day}/${dt.month}/${dt.year}';
}

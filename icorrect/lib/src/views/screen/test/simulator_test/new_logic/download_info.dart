class DownloadInfo {
  double? _downloadPercent;
  int? _downloadIndex;
  int? _total;

  DownloadInfo(this._downloadIndex, this._downloadPercent, this._total);

  double? get downloadPercent => _downloadPercent ?? 0.0;

  String get strPercent => (_downloadPercent! * 100).toStringAsFixed(0);

  set downloadPercent(double? value) => _downloadPercent = value;

  get downloadIndex => _downloadIndex ?? 0;

  set downloadIndex(value) => _downloadIndex = value;

  get total => _total ?? 0;

  set total(value) => _total = value;
}

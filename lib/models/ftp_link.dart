class FtpLink {
  final String url;
  bool isWorking;
  int responseTime;
  DateTime lastChecked;

  FtpLink({
    required this.url,
    this.isWorking = false,
    this.responseTime = 0,
    DateTime? lastChecked,
  }) : lastChecked = lastChecked ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'isWorking': isWorking,
      'responseTime': responseTime,
      'lastChecked': lastChecked.toIso8601String(),
    };
  }

  factory FtpLink.fromJson(Map<String, dynamic> json) {
    return FtpLink(
      url: json['url'],
      isWorking: json['isWorking'] ?? false,
      responseTime: json['responseTime'] ?? 0,
      lastChecked: json['lastChecked'] != null
          ? DateTime.parse(json['lastChecked'])
          : DateTime.now(),
    );
  }
}

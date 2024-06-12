class Lead {
  final String name;
  final String email;

  Lead({required this.name, required this.email});

  factory Lead.fromJson(Map<String, dynamic> json) {
    return Lead(
      name: json['firstName'] ?? 'Unknown',
      email: json['email'] ?? 'No email',
    );
  }
}

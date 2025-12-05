class Like {
  final int id;
  final DateTime createdAt;
  final int userId;
  final int photoId;

  Like({
    required this.id,
    required this.createdAt,
    required this.userId,
    required this.photoId,
  });

  factory Like.fromJson(Map<String, dynamic> json) {
    return Like(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      userId: json['user_id'],
      photoId: json['photo_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'photo_id': photoId,
    };
  }
}
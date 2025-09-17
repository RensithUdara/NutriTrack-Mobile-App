class NonFoodResponse {
  final bool isFood;
  final String message;
  final String detectedObject;
  final String friendlyComment;

  NonFoodResponse({
    required this.isFood,
    required this.message,
    required this.detectedObject,
    required this.friendlyComment,
  });

  factory NonFoodResponse.fromJson(Map<String, dynamic> json) {
    return NonFoodResponse(
      isFood: json['isFood'] ?? false,
      message: json['message'] ?? '',
      detectedObject: json['detectedObject'] ?? '',
      friendlyComment: json['friendlyComment'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isFood': isFood,
      'message': message,
      'detectedObject': detectedObject,
      'friendlyComment': friendlyComment,
    };
  }
}

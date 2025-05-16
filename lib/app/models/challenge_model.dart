class ChallengeModel {
  final String id;
  final String title;
  final String description;
  final int reward;
  final int targetSteps;
  final int duration;
  final String type;
  final DateTime? startDate;
  final DateTime? endDate;
  final double progress;
  final bool isCompleted;

  ChallengeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.reward,
    required this.targetSteps,
    required this.duration,
    required this.type,
    this.startDate,
    this.endDate,
    this.progress = 0.0,
    this.isCompleted = false,
  });

  ChallengeModel copyWith({
    double? progress,
    bool? isCompleted,
  }) {
    return ChallengeModel(
      id: id,
      title: title,
      description: description,
      reward: reward,
      targetSteps: targetSteps,
      duration: duration,
      type: type,
      startDate: startDate,
      endDate: endDate,
      progress: progress ?? this.progress,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "title": title,
      "description": description,
      "reward": reward,
      "targetSteps": targetSteps,
      "duration": duration,
      "type": type,
      "startDate": startDate,
      "endDate": endDate,
      "progress": progress,
      "isCompleted": isCompleted,
    };
  }
}

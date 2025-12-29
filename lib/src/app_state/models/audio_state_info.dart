enum AudioOutputType { speaker, headphones, earpiece, bluetooth, unknown }

class AudioStateInfo {
  final int volumeLevel;
  final int maxVolume;
  final AudioOutputType outputType;
  final bool isMuted;
  final DateTime timestamp;

  const AudioStateInfo({
    required this.volumeLevel,
    required this.maxVolume,
    required this.outputType,
    required this.isMuted,
    required this.timestamp,
  });

  factory AudioStateInfo.initial() => AudioStateInfo(
        volumeLevel: 0,
        maxVolume: 15,
        outputType: AudioOutputType.unknown,
        isMuted: false,
        timestamp: DateTime.now(),
      );

  double get volumePercentage =>
      maxVolume > 0 ? (volumeLevel / maxVolume) * 100 : 0;

  AudioStateInfo copyWith({
    int? volumeLevel,
    int? maxVolume,
    AudioOutputType? outputType,
    bool? isMuted,
    DateTime? timestamp,
  }) =>
      AudioStateInfo(
        volumeLevel: volumeLevel ?? this.volumeLevel,
        maxVolume: maxVolume ?? this.maxVolume,
        outputType: outputType ?? this.outputType,
        isMuted: isMuted ?? this.isMuted,
        timestamp: timestamp ?? this.timestamp,
      );

  Map<String, dynamic> toMap() => {
        'volumeLevel': volumeLevel,
        'maxVolume': maxVolume,
        'volumePercentage': volumePercentage,
        'outputType': outputType.name,
        'isMuted': isMuted,
        'timestamp': timestamp.toIso8601String(),
      };

  @override
  String toString() =>
      'AudioStateInfo(volume: $volumeLevel/$maxVolume, output: ${outputType.name}, muted: $isMuted)';
}

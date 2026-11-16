import 'package:equatable/equatable.dart';
import '../../domain/entities/user_settings_entity.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

class SettingsLoaded extends SettingsState {
  final UserSettingsEntity settings;
  final bool isTestingVoice;

  const SettingsLoaded({
    required this.settings,
    this.isTestingVoice = false,
  });

  SettingsLoaded copyWith({
    UserSettingsEntity? settings,
    bool? isTestingVoice,
  }) {
    return SettingsLoaded(
      settings: settings ?? this.settings,
      isTestingVoice: isTestingVoice ?? this.isTestingVoice,
    );
  }

  @override
  List<Object?> get props => [settings, isTestingVoice];
}


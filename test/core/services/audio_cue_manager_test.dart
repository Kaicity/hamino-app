import 'package:flutter_test/flutter_test.dart';
import 'package:hamino_app/core/services/audio_cue_manager.dart';
import 'package:hamino_app/core/services/audio_focus_service.dart';
import 'package:hamino_app/core/services/audio_service_interface.dart';
import 'package:hamino_app/core/services/tts_service_interface.dart';
import 'package:hamino_app/features/workout_builder/domain/entities/exercise_entity.dart';
import 'package:hamino_app/features/workout_builder/domain/entities/workout_category.dart';
import 'package:hamino_app/features/workout_builder/domain/entities/workout_template_entity.dart';
import 'package:hamino_app/features/workout_player/presentation/bloc/workout_player_state.dart';

class FakeAudioService implements IAudioService {
  int beepShortCalls = 0;
  int beepHighCalls = 0;
  int whistleStartCalls = 0;
  int bellWorkCalls = 0;
  int chimeRestCalls = 0;
  int victoryFanfareCalls = 0;
  int stopCalls = 0;
  int disposeCalls = 0;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> playBeepShort() async {
    beepShortCalls++;
  }

  @override
  Future<void> playBeepHigh() async {
    beepHighCalls++;
  }

  @override
  Future<void> playWhistleStart() async {
    whistleStartCalls++;
  }

  @override
  Future<void> playBellWork() async {
    bellWorkCalls++;
  }

  @override
  Future<void> playChimeRest() async {
    chimeRestCalls++;
  }

  @override
  Future<void> playVictoryFanfare() async {
    victoryFanfareCalls++;
  }

  @override
  Future<void> stop() async {
    stopCalls++;
  }

  @override
  Future<void> dispose() async {
    disposeCalls++;
  }
}

class FakeTtsService implements ITtsService {
  final List<String> spokenTexts = [];
  int stopCalls = 0;
  String currentLang = 'vi-VN';

  @override
  Future<void> initialize() async {}

  @override
  Future<void> speak(String text, {bool awaitCompletion = false}) async {
    spokenTexts.add(text);
  }

  @override
  Future<void> stop() async {
    stopCalls++;
  }

  @override
  Future<void> setLanguage(String languageCode) async {
    currentLang = languageCode;
  }

  @override
  Future<void> setSpeechRate(double rate) async {}

  @override
  Future<void> setVolume(double volume) async {}

  @override
  Future<void> setPitch(double pitch) async {}

  @override
  Future<bool> isLanguageAvailable(String languageCode) async => true;
}

class FakeAudioFocusService extends Fake implements AudioFocusService {
  int activateCalls = 0;
  int deactivateCalls = 0;

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> activate() async {
    activateCalls++;
    return true;
  }

  @override
  Future<void> deactivate() async {
    deactivateCalls++;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeAudioService fakeAudio;
  late FakeTtsService fakeTts;
  late FakeAudioFocusService fakeFocus;
  late AudioCueManager cueManager;
  late WorkoutTemplateEntity testWorkout;

  setUp(() {
    fakeAudio = FakeAudioService();
    fakeTts = FakeTtsService();
    fakeFocus = FakeAudioFocusService();

    cueManager = AudioCueManager(
      audioService: fakeAudio,
      ttsService: fakeTts,
      audioFocusService: fakeFocus,
      defaultVoiceDelay: Duration.zero,
    );

    testWorkout = WorkoutTemplateEntity(
      id: 'test-w1',
      name: 'Calisthenics Beast',
      category: WorkoutCategory.emom,
      targetRounds: 3,
      prepareSeconds: 10,
      defaultRestSeconds: 30,
      createdAt: DateTime.now(),
      exercises: const [
        ExerciseEntity(
          id: 'e1',
          workoutId: 'test-w1',
          name: 'Pull-up',
          defaultReps: 10,
          orderIndex: 0,
        ),
        ExerciseEntity(
          id: 'e2',
          workoutId: 'test-w1',
          name: 'Plank Hold',
          defaultReps: 0,
          holdSeconds: 30,
          orderIndex: 1,
        ),
      ],
    );
  });

  tearDown(() async {
    await cueManager.dispose();
  });

  group('AudioCueManager (TASK-4.3)', () {
    test('PlayerPrepare: announces prepare voice and countdown beeps 3, 2, 1', () async {
      final prepareState = PlayerPrepare(
        workout: testWorkout,
        totalRounds: 3,
        currentRound: 1,
        currentExerciseIndex: 0,
        remainingSeconds: 5,
      );

      await cueManager.handleState(prepareState);

      // Verify prepare voice announced
      expect(fakeTts.spokenTexts, contains('Chuẩn bị: Pull-up'));
      expect(fakeFocus.activateCalls, 1);
      expect(fakeFocus.deactivateCalls, 1);

      // Tick remaining 4: no countdown beep yet
      await cueManager.handleState(prepareState.copyWith(remainingSeconds: 4));
      expect(fakeAudio.beepHighCalls, 0);

      // Tick remaining 3: beep high
      await cueManager.handleState(prepareState.copyWith(remainingSeconds: 3));
      expect(fakeAudio.beepHighCalls, 1);
      expect(fakeTts.stopCalls, 1); // No overlap: stops TTS before beep

      // Tick remaining 2: beep high
      await cueManager.handleState(prepareState.copyWith(remainingSeconds: 2));
      expect(fakeAudio.beepHighCalls, 2);

      // Tick remaining 1: beep high
      await cueManager.handleState(prepareState.copyWith(remainingSeconds: 1));
      expect(fakeAudio.beepHighCalls, 3);
    });

    test('PlayerWork: plays whistle start and announces round start', () async {
      final workState = PlayerWork(
        workout: testWorkout,
        currentRound: 1,
        totalRounds: 3,
        currentExerciseIndex: 0,
        elapsedSeconds: 0,
        totalElapsedSeconds: 10,
      );

      await cueManager.handleState(workState);

      expect(fakeAudio.whistleStartCalls, 1);
      expect(fakeTts.spokenTexts, contains('Hiệp 1, bắt đầu!'));
    });

    test('PlayerWork (Static Hold): plays countdown beeps at 3, 2, 1', () async {
      final holdState = PlayerWork(
        workout: testWorkout,
        currentRound: 1,
        totalRounds: 3,
        currentExerciseIndex: 1, // Plank Hold (isStaticHold = true)
        remainingSeconds: 4,
        elapsedSeconds: 26,
        totalElapsedSeconds: 50,
      );

      await cueManager.handleState(holdState);
      expect(fakeAudio.beepHighCalls, 0);

      await cueManager.handleState(holdState.copyWith(remainingSeconds: 3));
      expect(fakeAudio.beepHighCalls, 1);

      await cueManager.handleState(holdState.copyWith(remainingSeconds: 2));
      expect(fakeAudio.beepHighCalls, 2);

      await cueManager.handleState(holdState.copyWith(remainingSeconds: 1));
      expect(fakeAudio.beepHighCalls, 3);
    });

    test('PlayerRest: plays chime rest, announces rest duration, 10s warning, and 3-2-1 countdown', () async {
      final restState = PlayerRest(
        workout: testWorkout,
        currentRound: 1,
        totalRounds: 3,
        currentExerciseIndex: 0,
        nextRound: 1,
        nextExerciseIndex: 1,
        remainingSeconds: 30,
        totalElapsedSeconds: 60,
      );

      // Enters Rest
      await cueManager.handleState(restState);
      expect(fakeAudio.chimeRestCalls, 1);
      expect(fakeTts.spokenTexts, contains('Nghỉ 30 giây'));

      // Tick at 15s: no warning
      await cueManager.handleState(restState.copyWith(remainingSeconds: 15));
      expect(fakeAudio.beepShortCalls, 0);

      // Tick at 10s: rest warning + next exercise name
      await cueManager.handleState(restState.copyWith(remainingSeconds: 10));
      expect(fakeAudio.beepShortCalls, 1);
      expect(fakeTts.spokenTexts, contains('Còn 10 giây, chuẩn bị Plank Hold'));

      // Countdown at 3, 2, 1
      await cueManager.handleState(restState.copyWith(remainingSeconds: 3));
      await cueManager.handleState(restState.copyWith(remainingSeconds: 2));
      await cueManager.handleState(restState.copyWith(remainingSeconds: 1));
      expect(fakeAudio.beepHighCalls, 3);
    });

    test('PlayerCompleted: plays victory fanfare and congratulates athlete', () async {
      final completedState = PlayerCompleted(
        workout: testWorkout,
        totalElapsedSeconds: 300,
        totalRounds: 3,
        reason: CompletionReason.allRoundsFinished,
        completedRounds: 3,
        totalWorkSeconds: 240,
      );

      await cueManager.handleState(completedState);

      expect(fakeAudio.victoryFanfareCalls, 1);
      expect(fakeTts.spokenTexts, contains('Chúc mừng bạn đã hoàn thành bài tập xuất sắc!'));
    });

    test('PlayerPaused: stops TTS and deactivates audio focus', () async {
      final workState = PlayerWork(
        workout: testWorkout,
        currentRound: 1,
        totalRounds: 3,
        currentExerciseIndex: 0,
        elapsedSeconds: 10,
        totalElapsedSeconds: 20,
      );

      final pausedState = PlayerPaused(
        previousState: workState,
        workout: testWorkout,
        currentRound: 1,
        totalRounds: 3,
        currentExerciseIndex: 0,
        remainingSeconds: 0,
        elapsedSeconds: 10,
        totalElapsedSeconds: 20,
      );

      await cueManager.handleState(pausedState);
      expect(fakeTts.stopCalls, 1);
      expect(fakeFocus.deactivateCalls, 1);
    });

    test('Muting SFX and TTS respects toggles', () async {
      cueManager.isSfxEnabled = false;
      cueManager.isTtsEnabled = false;

      final workState = PlayerWork(
        workout: testWorkout,
        currentRound: 1,
        totalRounds: 3,
        currentExerciseIndex: 0,
        elapsedSeconds: 0,
        totalElapsedSeconds: 10,
      );

      await cueManager.handleState(workState);

      expect(fakeAudio.whistleStartCalls, 0);
      expect(fakeTts.spokenTexts, isEmpty);
    });

    test('English language produces English phrases', () async {
      cueManager.language = 'en-US';

      final workState = PlayerWork(
        workout: testWorkout,
        currentRound: 2,
        totalRounds: 3,
        currentExerciseIndex: 0,
        elapsedSeconds: 0,
        totalElapsedSeconds: 100,
      );

      await cueManager.handleState(workState);

      expect(fakeTts.spokenTexts, contains('Round 2, start!'));
    });
  });
}

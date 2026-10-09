import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/driver_home/domain/usecases/report_no_show_usecase.dart';

void main() {
  group('ReportNoShowUseCase', () {
    group('canReport', () {
      test('refuses just before 5 minutes of waiting', () {
        // Arrange
        const waited = Duration(minutes: 4, seconds: 59);

        // Act
        final canReport = ReportNoShowUseCase.canReport(waited: waited);

        // Assert
        expect(canReport, isFalse);
      });

      test('accepts at 5 minutes of waiting', () {
        // Arrange
        const waited = Duration(minutes: 5);

        // Act
        final canReport = ReportNoShowUseCase.canReport(waited: waited);

        // Assert
        expect(canReport, isTrue);
      });
    });

    group('waitLeft', () {
      test('counts down to 5 minutes from the arrival', () {
        // Arrange
        const waited = Duration(minutes: 1, seconds: 48);

        // Act
        final left = ReportNoShowUseCase.waitLeft(waited: waited);

        // Assert
        expect(left, const Duration(minutes: 3, seconds: 12));
      });

      test('never goes below zero once the wait is over', () {
        // Arrange
        const waited = Duration(minutes: 7);

        // Act
        final left = ReportNoShowUseCase.waitLeft(waited: waited);

        // Assert
        expect(left, Duration.zero);
      });
    });
  });
}

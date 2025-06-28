import 'package:flutter/material.dart';
import 'package:quizzler/main.dart';
import 'package:quizzler/utils/constants.dart';
import 'package:quizzler/utils/theme/theme_extention.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class AnalyticsQuickLookWidget extends StatelessWidget {
  // Example data for the chart
  final List<QuestionResult> data = [
    QuestionResult(question: 1, correct: 10, wrong: 5),
    QuestionResult(question: 2, correct: 8, wrong: 7),
    QuestionResult(question: 3, correct: 12, wrong: 3),
    QuestionResult(question: 4, correct: 15, wrong: 2),
    QuestionResult(question: 5, correct: 9, wrong: 6),
  ];

  final int totalParticipants = 25; // Total number of participants

  getWrongAnswersCount() => data.fold(0, (sum, qResult) => sum + qResult.wrong);
  getCorrectAnswersCount() => data.fold(0, (sum, qResult) => sum + qResult.correct);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SfCartesianChart(
            primaryXAxis: CategoryAxis(),
            series: <CartesianSeries>[
              ColumnSeries<QuestionResult, String>(
                dataSource: data,
                xValueMapper: (QuestionResult result, _) => 'Q${result.question}',
                yValueMapper: (QuestionResult result, _) => result.correct,
                color: context.correctColor,
              ),
              ColumnSeries<QuestionResult, String>(
                dataSource: data,
                xValueMapper: (QuestionResult result, _) => 'Q${result.question}',
                yValueMapper: (QuestionResult result, _) => result.wrong,
                color: context.wrongColor,
              ),
            ],
          ),
        ),

        SizedBox(height: SizeConstants.defaultPadding), // Spacing between chart and info row
        // Information Row
        SizedBox(
          height: 50.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Total Participants
              _buildInfoCell(
                context,
                label: 'Participants',
                value: totalParticipants.toString(),
                color: context.primaryColor,
              ),
              // Correct Answers (Example)
              _buildInfoCell(
                context,
                label: 'Correct',
                value: getCorrectAnswersCount().toString(),
                color: context.correctColor,
              ),
              // Wrong Answers (Example)
              _buildInfoCell(
                context,
                label: 'Wrong',
                value: getWrongAnswersCount().toString(),
                color: context.wrongColor,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper method to build an info cell
  Widget _buildInfoCell(
      BuildContext context, {
        required String label,
        required String value,
        required Color color,
      }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: context.thirdColor,
          ),
        ),
      ],
    );
  }

}

// Data model for question results
class QuestionResult {
  final int question;
  final int correct;
  final int wrong;

  QuestionResult({
    required this.question,
    required this.correct,
    required this.wrong,
  });
}
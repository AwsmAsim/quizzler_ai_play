import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GenerateQuestionService {
  final String apiKey = dotenv.env['OPENAI_API_KEY'] ?? 'Placeholder';
  final String apiUrl = "https://api.openai.com/v1/chat/completions";
  String sampleResp = """
{
  "id": "chatcmpl-AyxS8AuizpVnePc7a96mgqe5Cl3s0",
  "object": "chat.completion",
  "created": 1739091580,
  "model": "gpt-4o-mini-2024-07-18",
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content": "{\n    \"questions\": [\n        {\n            \"id\": \"q1\",\n            \"question\": \"What is the basic unit of life?\",\n            \"options\": [\n                {\"id\": \"A\", \"text\": \"Atom\"},\n                {\"id\": \"B\", \"text\": \"Molecule\"},\n                {\"id\": \"C\", \"text\": \"Cell\"},\n                {\"id\": \"D\", \"text\": \"Tissue\"}\n            ],\n            \"correct_answer\": \"C\",\n            \"explanation\": \"Cells are the smallest units that can carry out all life processes, making them the basic building blocks of all living organisms.\",\n            \"difficulty\": \"Medium\",\n            \"time\": 60\n        },\n        {\n            \"id\": \"q2\",\n            \"question\": \"Which part of the cell contains the genetic material?\",\n            \"options\": [\n                {\"id\": \"A\", \"text\": \"Cytoplasm\"},\n                {\"id\": \"B\", \"text\": \"Cell membrane\"},\n                {\"id\": \"C\", \"text\": \"Nucleus\"},\n                {\"id\": \"D\", \"text\": \"Ribosome\"}\n            ],\n            \"correct_answer\": \"C\",\n            \"explanation\": \"The nucleus is the part of the cell that houses the genetic material (DNA), controlling the cell's activities and heredity.\",\n            \"difficulty\": \"Medium\",\n            \"time\": 60\n        },\n        {\n            \"id\": \"q3\",\n            \"question\": \"Which of the following structures is responsible for protein synthesis?\",\n            \"options\": [\n                {\"id\": \"A\", \"text\": \"Mitochondria\"},\n                {\"id\": \"B\", \"text\": \"Ribosomes\"},\n                {\"id\": \"C\", \"text\": \"Lysosomes\"},\n                {\"id\": \"D\", \"text\": \"Endoplasmic reticulum\"}\n            ],\n            \"correct_answer\": \"B\",\n            \"explanation\": \"Ribosomes are the cellular structures that synthesize proteins by translating messenger RNA.\",\n            \"difficulty\": \"Medium\",\n            \"time\": 60\n        },\n        {\n            \"id\": \"q4\",\n            \"question\": \"What is the jelly-like substance inside a cell called?\",\n            \"options\": [\n                {\"id\": \"A\", \"text\": \"Plasma\"},\n                {\"id\": \"B\", \"text\": \"Cytoplasm\"},\n                {\"id\": \"C\", \"text\": \"Nucleoplasm\"},\n                {\"id\": \"D\", \"text\": \"Stroma\"}\n            ],\n            \"correct_answer\": \"B\",\n            \"explanation\": \"Cytoplasm is the gel-like fluid inside the cell, where cell structures are suspended, and many cellular processes occur.\",\n            \"difficulty\": \"Medium\",\n            \"time\": 60\n        }\n    ]\n}",
        "refusal": null
      },
      "logprobs": null,
      "finish_reason": "stop"
    }
  ],
  "usage": {
    "prompt_tokens": 398,
    "completion_tokens": 581,
    "total_tokens": 979,
    "prompt_tokens_details": {
      "cached_tokens": 0,
      "audio_tokens": 0
    },
    "completion_tokens_details": {
      "reasoning_tokens": 0,
      "audio_tokens": 0,
      "accepted_prediction_tokens": 0,
      "rejected_prediction_tokens": 0
    }
  },
  "service_tier": "default",
  "system_fingerprint": "fp_72ed7ab54c"
}
  """;

  // Method to save prompt and response to a JSON file
  Future<void> _saveToJsonFile(
      {required Map<String, dynamic> promptData,
      required String response,
      String filename = 'quizzler_api_logs.json'}) async {
    try {
      // Get the documents directory
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$filename';
      final file = File(filePath);

      // Create log entry with timestamp
      final logEntry = {
        'timestamp': DateTime.now().toIso8601String(),
        'prompt': promptData,
        'response': response,
      };

      // Check if file exists and read existing content
      List<dynamic> existingLogs = [];
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.isNotEmpty) {
          existingLogs = jsonDecode(content);
        }
      }

      // Add new log and write back to file
      existingLogs.add(logEntry);
      await file.writeAsString(jsonEncode(existingLogs));

      log('API interaction logged to $filePath');
    } catch (e) {
      log('Error saving to JSON file: $e');
    }
  }

  Future<String> generateMCQs({
    required String topic,
    required String ageGroup,
    required String keywords,
    required String difficultyLevel,
    required String language,
    required int timeLimit,
    int noOfQuestions = 10,
  }) async {
    // await Future.delayed(Duration(seconds: 1));
    // final jsonResponse1 = jsonDecode(sampleResp);
    // log("JSON Decoding ends");
    // return jsonResponse1['choices'][0]['message']['content'];

    if (apiKey == 'Placeholder' || apiKey.isEmpty) {
      throw Exception(
          'API key is not configured. Please set your OpenAI API key.');
    }

    try {
      // Prepare the JSON payload for the OpenAI API
      log("Fetching From OpenAI Starts");
      final Map<String, dynamic> payload = {
        "model": "gpt-4o-mini", // Specify the model
        "messages": [
          {
            "role": "system",
            "content":
                "You are an expert at creating Multiple Choice Questions (MCQs). Generate questions based on these specifications:"
          },
          {
            "role": "user",
            "content": "# Input Parameters\n"
                "Topic: $topic\n"
                "Age Group: $ageGroup\n"
                "Keywords: $keywords\n"
                "Difficulty: $difficultyLevel\n"
                "Language: $language\n"
                "Time Limit: $timeLimit\n"
                "# Requirements\n"
                "- Generate questions in JSON format\n"
                "- Generate ${noOfQuestions} questions\n"
                "- Each question must have exactly 4 options\n"
                "- Avoid political, controversial, or sensitive topics\n"
                "- Keep questions factual and objective\n"
                "- Focus on academic and practical knowledge\n"
                "- Match difficulty level to age group\n"
                "- Stay within specified time limit\n"
                "- Include clear explanations\n"
                "# Output Format\n"
                "{\n"
                '    "questions": [\n'
                '        {\n'
                '            "id": "q1",\n'
                '            "question": "question_text",\n'
                '            "options": [\n'
                '                {"id": "A", "text": "option_1"},\n'
                '                {"id": "B", "text": "option_2"},\n'
                '                {"id": "C", "text": "option_3"},\n'
                '                {"id": "D", "text": "option_4"}\n'
                '            ],\n'
                '            "correct_answer": "correct_option_id",\n'
                '            "explanation": "why_this_answer_is_correct",\n'
                '            "difficulty": "difficulty_level",\n'
                '            "time": time_in_seconds\n'
                '        }\n'
                '    ]\n'
                '}\n'
                "# Guidelines\n"
                "1. Questions:\n"
                "   - Clear and unambiguous\n"
                "   - Relevant to topic and keywords\n"
                "   - Age-appropriate language\n"
                "   - No trick questions\n"
                "2. Options:\n"
                "   - All options plausible\n"
                "   - Similar length\n"
                "   - No 'all/none of the above'\n"
                "   - Random correct answer placement\n"
                "3. Difficulty Levels:\n"
                "   - Easy: Basic recall\n"
                "   - Medium: Understanding and application\n"
                "   - Hard: Analysis\n"
                "   - Expert: Complex problem-solving\n"
                "4. Explanations:\n"
                "   - Brief but clear\n"
                "   - Explain why correct answer is right\n"
                "   - Educational value"
          }
        ],
      };

      final Map<String, dynamic> promptData = {
        'topic': topic,
        'ageGroup': ageGroup,
        'keywords': keywords,
        'difficultyLevel': difficultyLevel,
        'language': language,
        'timeLimit': timeLimit,
        'payload': payload,
      };

      // Send the POST request to the OpenAI API
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $apiKey",
        },
        body: jsonEncode(payload),
      );

      log("Fetching Ends");

      // Parse the response
      if (response.statusCode == 200) {
        log("Fetching ends");
        log(response.body.toString());
        final jsonResponse = jsonDecode(response.body);
        log("JSON Decoding ends");
        await _saveToJsonFile(
          promptData: promptData,
          response: response.body,
        );
        return jsonResponse['choices'][0]['message']['content'];
      } else if (response.statusCode == 429) {
        throw Exception(
            'Our servers are currently busy. Please try again in a few moments.');
      } else {
        throw Exception(
            "Failed to generate questions. Status code: ${response.statusCode}. Please try again later.");
      }
    } catch (e) {
      log("Error while fetching questions: $e");
      throw Exception("An unexpected error occurred: $e");
    }
  }

  Future<String> generateMCQsForTesting({
    required String topic,
    required String ageGroup,
    required String keywords,
    required String difficultyLevel,
    required String language,
    required int timeLimit,
    int noOfQuestions = 10,
  }) async {
    // Simulate a 429 Too Many Requests error for testing purposes
    throw Exception(
        'Our servers are currently busy. Please try again in a few moments.');
  }
}

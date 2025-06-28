// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:quizzler/utils/constants.dart';
// import 'package:quizzler/utils/theme/theme_extention.dart';

// class QuestionsListPage extends StatefulWidget {
//   @override
//   _QuestionsListPageState createState() => _QuestionsListPageState();
// }

// class _QuestionsListPageState extends State<QuestionsListPage> {
//   List<Question> questions = [
//     Question(
//       id: 1,
//       type: QuestionType.mcq,
//       question: "What is the capital of France?",
//       options: ["London", "Paris", "Berlin", "Madrid"],
//     ),
//     Question(
//       id: 2,
//       type: QuestionType.fillBlank,
//       question: "The chemical symbol for gold is ___",
//     ),
//     Question(
//       id: 3,
//       type: QuestionType.match,
//       pairs: [
//         {"Apple": "Fruit"},
//         {"Carrot": "Vegetable"},
//         {"Dog": "Animal"},
//       ],
//     ),
//     // Add 2 more sample questions
//   ];

//   void _editQuestionText(int index, String newText) {
//     setState(() {
//       questions[index] = questions[index].copyWith(question: newText);
//     });
//   }

//   void _deleteQuestion(int index) {
//     setState(() {
//       questions.removeAt(index);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Questions List"),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.save, color: context.ctaColor),
//             onPressed: () {},
//           ),
//         ],
//       ),
//       body: ListView.builder(
//         padding: EdgeInsets.all(16),
//         itemCount: questions.length + 1,
//         itemBuilder: (context, index) {

//           if(index == questions.length)
//             return Container(
//               height: 40.0,
//               width: double.infinity,
//               child: Container(
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Container(
//                       padding: EdgeInsets.all(SizeConstants.defaultPadding/3),
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(100),
//                         border: Border.all(color: context.ctaColor)
//                       ),
//                         child: Icon(Icons.add, color: context.ctaColor,)),
//                   ],
//                 ),
//               ),
//             );

//           final question = questions[index];
//           return Card(
//             margin: EdgeInsets.only(bottom: 16),
//             child: Padding(
//               padding: EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _buildQuestionHeader(question, index),
//                   SizedBox(height: 12),
//                   _buildQuestionContent(question, index),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildQuestionHeader(Question question, int index) {
//     return Row(
//       children: [
//         Expanded(
//           child: GestureDetector(
//             onTap: () => _showEditDialog(index, question.question),
//             child: Text(
//               "${index + 1}. ${question.question}",
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//             ),
//           ),
//         ),
//         PopupMenuButton(
//           icon: Icon(Icons.more_vert, color: context.ctaColor),
//           itemBuilder: (context) => [
//             PopupMenuItem(child: Text("Delete Question"), value: 'delete'),
//             PopupMenuItem(child: Text("Change Type"), value: 'type'),
//           ],
//           onSelected: (value) {
//             if (value == 'delete') _deleteQuestion(index);
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildQuestionContent(Question question, int index) {
//     switch (question.type) {
//       case QuestionType.mcq:
//         return Column(
//           children: question.options.map((option) {
//             return Padding(
//               padding: EdgeInsets.symmetric(vertical: 4),
//               child: Row(
//                 children: [
//                   Radio(
//                     value: null,
//                     groupValue: null,
//                     onChanged: (_) {},
//                     fillColor: MaterialStateProperty.resolveWith<Color>(
//                           (states) => context.ctaColor,
//                     ),
//                   ),
//                   Expanded(
//                     child: GestureDetector(
//                       onTap: () => _showEditDialog(index, option),
//                       child: Text(option),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }).toList(),
//         );
//       case QuestionType.fillBlank:
//         return TextFormField(
//           decoration: InputDecoration(
//             hintText: "Enter your answer",
//             border: UnderlineInputBorder(),
//           ),
//         );
//       case QuestionType.match:
//         return _buildMatchFollowing(question);
//       default:
//         return SizedBox.shrink();
//     }
//   }

//   Widget _buildMatchFollowing(Question question) {
//     List<String> leftItems = question.pairs.map((p) => p.keys.first).toList();
//     List<String> rightItems = question.pairs.map((p) => p.values.first).toList();

//     return Row(
//       children: [
//         // Fixed left side
//         Expanded(
//           child: ListView.builder(
//             shrinkWrap: true,
//             physics: NeverScrollableScrollPhysics(),
//             itemCount: leftItems.length,
//             itemBuilder: (context, index) => ListTile(
//               title: Text(leftItems[index]),
//             ),
//           ),
//         ),
//         SizedBox(width: 16),
//         // Draggable right side
//         Expanded(
//           child: ReorderableListView.builder(
//             shrinkWrap: true,
//             physics: NeverScrollableScrollPhysics(),
//             itemCount: rightItems.length,
//             itemBuilder: (context, index) => ListTile(
//               key: ValueKey(index),
//               leading: Icon(Icons.drag_handle, color: context.ctaColor),
//               title: Text(rightItems[index]),
//             ),
//             onReorder: (oldIndex, newIndex) {
//               setState(() {
//                 if (oldIndex < newIndex) newIndex -= 1;
//                 final movedItem = rightItems.removeAt(oldIndex);
//                 rightItems.insert(newIndex, movedItem);

//                 // Update pairs with new combinations
//                 question.pairs.clear();
//                 for (int i = 0; i < leftItems.length; i++) {
//                   question.pairs.add({leftItems[i]: rightItems[i]});
//                 }

//                 // Print current matches
//                 print("Current Matches:");
//                 for (var pair in question.pairs) {
//                   print("${pair.keys.first} → ${pair.values.first}");
//                 }
//               });
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   void _showEditDialog(int index, String currentText) {
//     TextEditingController controller = TextEditingController(text: currentText);
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text("Edit Text"),
//         content: TextField(controller: controller),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text("Cancel"),
//           ),
//           TextButton(
//             onPressed: () {
//               _editQuestionText(index, controller.text);
//               Navigator.pop(context);
//             },
//             child: Text("Save"),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class Question {
//   final int id;
//   final QuestionType type;
//   final String question;
//   final List<String> options;
//   final List<Map<String, String>> pairs;

//   Question({
//     required this.id,
//     required this.type,
//     this.question = "",
//     this.options = const [],
//     this.pairs = const [],
//   });

//   Question copyWith({
//     String? question,
//     List<String>? options,
//     List<Map<String, String>>? pairs,
//   }) {
//     return Question(
//       id: id,
//       type: type,
//       question: question ?? this.question,
//       options: options ?? this.options,
//       pairs: pairs ?? this.pairs,
//     );
//   }
// }

// enum QuestionType { mcq, fillBlank, match }

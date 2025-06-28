import 'package:flutter/material.dart';
import 'package:quizzler/utils/constants.dart';
import 'package:quizzler/utils/theme/theme_extention.dart';

class LeaderboardOverlay extends StatelessWidget {
  final List<Map<String, dynamic>> leaderboardData;

  const LeaderboardOverlay({
    Key? key,
    required this.leaderboardData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('leaderboardData');
    print(leaderboardData);

    return Container(
      color: Colors.black.withOpacity(0.85),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Leaderboard',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: context.primaryColor,
                  fontFamily: 'poppins',
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Top 5 Players',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontFamily: 'poppins',
                ),
              ),
              SizedBox(height: 20),

              // Header row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    SizedBox(width: 40),
                    Expanded(
                      child: Text(
                        'Player',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                          fontFamily: 'poppins',
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 80,
                      child: Text(
                        'Points',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                          fontFamily: 'poppins',
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Divider(color: Colors.grey[300]),

              // Leaderboard entries
              ...List.generate(
                leaderboardData.length,
                (index) => _buildLeaderboardItem(
                  context,
                  index + 1,
                  leaderboardData[index]['user_display_name'] ?? 'Unknown',
                  leaderboardData[index]['points'] ?? 0,
                ),
              ),

              SizedBox(height: 20),
              Text(
                'Next question in 5 seconds...',
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600],
                  fontFamily: 'poppins',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderboardItem(
      BuildContext context, int position, String username, int points) {
    Color positionColor;
    Widget positionWidget;

    // Style based on position
    switch (position) {
      case 1:
        positionColor = Colors.amber;
        positionWidget =
            Icon(Icons.emoji_events, color: positionColor, size: 24);
        break;
      case 2:
        positionColor = Colors.grey[400]!;
        positionWidget =
            Icon(Icons.emoji_events, color: positionColor, size: 22);
        break;
      case 3:
        positionColor = Colors.brown[300]!;
        positionWidget =
            Icon(Icons.emoji_events, color: positionColor, size: 20);
        break;
      default:
        positionColor = Colors.grey[700]!;
        positionWidget = Text(
          '$position',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: positionColor,
            fontFamily: 'poppins',
          ),
        );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Center(child: positionWidget),
          ),
          Expanded(
            child: Text(
              username,
              style: TextStyle(
                fontWeight: position <= 3 ? FontWeight.bold : FontWeight.normal,
                fontSize: position == 1 ? 16 : 14,
                color: Colors.black87,
                fontFamily: 'poppins',
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 80,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: context.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$points',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: context.primaryColor,
                  fontFamily: 'poppins',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

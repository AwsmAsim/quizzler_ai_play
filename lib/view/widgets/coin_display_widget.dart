import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizzler/controller/coin_controller.dart';

class CoinDisplayWidget extends StatelessWidget {
  const CoinDisplayWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final coinController = Get.find<CoinController>();

    return Obx(() => Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.monetization_on, color: Colors.amber, size: 20),
              SizedBox(width: 8),
              Text(
                'Coins: ${coinController.coins.value}',
                style: TextStyle(
                  fontFamily: 'poppins',
                  fontSize: 16,
                  color: Colors.blue.shade900,
                ),
              ),
            ],
          ),
        ));
  }
}

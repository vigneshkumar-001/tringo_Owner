import 'package:flutter/material.dart';
import 'package:tringo_vendor/Core/Const/app_color.dart';
import 'package:tringo_vendor/Core/Utility/common_Container.dart';

class ShopInfo extends StatefulWidget {
  const ShopInfo({super.key});

  @override
  State<ShopInfo> createState() => _ShopInfoState();
}

class _ShopInfoState extends State<ShopInfo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
                          CommonContainer.topLeftArrow(onTap: () {}),
                          SizedBox(width: 30),
                          Text(
                            'Register Shop - Individual',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColor.eerieBlack,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

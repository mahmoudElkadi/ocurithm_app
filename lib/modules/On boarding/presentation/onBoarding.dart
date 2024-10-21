import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:ocurithm/core/utils/app_style.dart';
import 'package:ocurithm/core/utils/colors.dart';
import 'package:ocurithm/core/widgets/height_spacer.dart';
import 'package:ocurithm/modules/Login/presentation/view/login_view.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../core/Network/shared.dart';

class BoardingModel {
  final String image;
  final String title;
  final String body;

  BoardingModel({
    required this.image,
    required this.title,
    required this.body,
  });
}

bool isLast = false;

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  var boardController = PageController();

  List<BoardingModel> boarding = [
    BoardingModel(
        image: 'assets/icons/1.svg',
        title: 'Eye Safety First',
        body: "You can't always tell when an eye is injured. \n some injuries are only obvious when \n they get really serious."),
    BoardingModel(image: 'assets/icons/2.svg', title: 'Book An Appointment', body: 'Book an Appointment with the \n best eye care doctor.'),
    BoardingModel(image: 'assets/icons/2.svg', title: 'Get The Best Treatment', body: 'Get the best treatment through \n our clinics. '),
  ];

  void submit() async {
    await CacheHelper.saveBoolean(key: 'onBoarding', value: true).then((value) {
      if (value == true) {
        Get.offAll(() => const LoginView());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              //color: Colors.red,
              height: MediaQuery.of(context).size.height * 0.7,
              child: PageView.builder(
                onPageChanged: (int index) {
                  if (index == boarding.length - 1) {
                    setState(() {
                      isLast = true;
                    });
                  } else {
                    isLast = false;
                  }
                },
                physics: const BouncingScrollPhysics(),
                controller: boardController,
                itemBuilder: (context, index) => buildBoardingItem(boarding[index]),
                itemCount: boarding.length,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const HeightSpacer(size: 10),
            SmoothPageIndicator(
                controller: boardController,
                count: boarding.length,
                effect: ExpandingDotsEffect(
                    dotColor: Colors.grey.shade300,
                    dotHeight: 5,
                    activeDotColor: Colors.blue,
                    expansionFactor: 2,
                    dotWidth: 23,
                    spacing: 5,
                    radius: 5)),
            const HeightSpacer(size: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      submit();
                    },
                    child: Text(
                      "Skip",
                      style: appStyle(context, 18, Colorz.grey, FontWeight.w600),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (isLast == false) {
                        boardController.nextPage(
                            duration: const Duration(
                              milliseconds: 750,
                            ),
                            curve: Curves.fastOutSlowIn);
                      } else {
                        submit();
                      }
                    },
                    child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colorz.blue,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 25,
                        )),
                  )
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account?  ", style: appStyle(context, 18, Colorz.grey, FontWeight.w600)),
                  InkWell(
                      onTap: () {
                        submit();
                      },
                      child: Ink(child: Text("Sign In", style: appStyle(context, 18, Colors.blue, FontWeight.w600))))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildBoardingItem(BoardingModel model) => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: SvgPicture.asset(
              model.image,
              //   // width: MediaQuery.sizeOf(context).width * 0.9,
              //   // height: MediaQuery.of(context).size.height * 0.5,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  model.title,
                  style: appStyle(context, 22, Colors.black, FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                const HeightSpacer(size: 20),
                Text(model.body, style: appStyle(context, 18, Colors.grey, FontWeight.w400), textAlign: TextAlign.center),
              ],
            ),
          ),
        ],
      );
}

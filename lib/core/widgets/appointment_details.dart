import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/app_style.dart';
import 'height_spacer.dart';

Future<String?> showAppointmentDetails(context, Map<String, dynamic> patientData) {
  return showDialog<String>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: Container(
            height: MediaQuery.sizeOf(context).height * 0.6,
            padding: const EdgeInsets.all(16.0),
            width: MediaQuery.sizeOf(context).width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
            child: Column(
              children: [
                Text(
                  "Appointment Details",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                ),
                HeightSpacer(size: 20),
                Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 9, horizontal: 10),
                        width: MediaQuery.sizeOf(context).width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: Text(
                          "Name : ${patientData['name'].toString()} ",
                          textAlign: TextAlign.start,
                          style: appStyle(context, 16, Colors.black, FontWeight.w600),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 15,
                      top: 0,
                      child: SvgPicture.asset(
                        'assets/icons/phone_icon.svg',
                      ),
                    )
                  ],
                ),
                HeightSpacer(size: 10),
                Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 9, horizontal: 10),
                        width: MediaQuery.sizeOf(context).width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: GestureDetector(
                          onTap: () async {
                            String url = "tel:" + patientData['phoneNumber'];
                            if (!kIsWeb && await canLaunchUrl(Uri.parse(url))) {
                              await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Could not call ${patientData["phoneNumber"]}'),
                                ),
                              );
                            }
                          },
                          child: Text(
                            patientData['phoneNumber'].toString(),
                            style: appStyle(context, 18, Colors.grey.shade900, FontWeight.w600),
                            textAlign: TextAlign.start,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 15,
                      top: 0,
                      child: SvgPicture.asset(
                        'assets/icons/phone_icon.svg',
                      ),
                    )
                  ],
                ),
                HeightSpacer(size: 10),
                Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 9, horizontal: 10),
                        width: MediaQuery.sizeOf(context).width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: Text(
                          "branch :  ${patientData['branch'].toString()} ",
                          textAlign: TextAlign.start,
                          style: appStyle(context, 16, Colors.black, FontWeight.w600),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 15,
                      top: 0,
                      child: SvgPicture.asset(
                        'assets/icons/name_icon.svg',
                      ),
                    )
                  ],
                ),
                HeightSpacer(size: 10),
                Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 9, horizontal: 10),
                        width: MediaQuery.sizeOf(context).width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: Text(
                          "ID :  ${patientData['manualId'].toString()} ",
                          textAlign: TextAlign.start,
                          style: appStyle(context, 16, Colors.black, FontWeight.w600),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 15,
                      top: 0,
                      child: SvgPicture.asset(
                        'assets/icons/name_icon.svg',
                      ),
                    )
                  ],
                ),
                HeightSpacer(size: 10),
                Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 9, horizontal: 10),
                        width: MediaQuery.sizeOf(context).width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: Text(
                          "Examination type : ${patientData['examination_type'].toString()} ",
                          textAlign: TextAlign.start,
                          style: appStyle(context, 16, Colors.black, FontWeight.w600),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 15,
                      top: 0,
                      child: SvgPicture.asset(
                        'package:ocurithm/assets/icons/branch.svg',
                      ),
                    )
                  ],
                ),
                Spacer(),
                Padding(
                    padding: EdgeInsets.only(right: 22),
                    child: ElevatedButton(
                      child: Text(
                        "Close",
                        style: appStyle(context, 18, Colors.white, FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () async {
                        Navigator.of(context).pop();
                      },
                    )),
                HeightSpacer(size: 25),
              ],
            ),
          ),
        );
      },
    ),
  );
}

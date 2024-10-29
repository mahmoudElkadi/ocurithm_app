import 'package:flutter/material.dart';

import '../utils/colors.dart';

class CustomPagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;

  const CustomPagination({
    Key? key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isRTL = Directionality.of(context) == TextDirection.rtl;

    List<Widget> pageNumbers = [];
    if (totalPages <= 3) {
      for (int i = 1; i <= totalPages; i++) {
        pageNumbers.add(_buildPageNumber(context, i));
      }
    } else {
      if (currentPage > 1) {
        pageNumbers.add(_buildPageNumber(context, currentPage - 1));
      }
      pageNumbers.add(_buildPageNumber(context, currentPage));
      if (currentPage < totalPages) {
        pageNumbers.add(_buildPageNumber(context, currentPage + 1));
      }
      if (totalPages > 5 && totalPages > currentPage + 4) {
        pageNumbers.add(_buildEllipsisWidget(context));
        pageNumbers.add(_buildPageNumber(context, currentPage + 4));
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildCircularButton(
          context: context,
          icon: isRTL ? Icons.last_page : Icons.first_page,
          onPressed: currentPage > 1 ? () => onPageChanged(1) : null,
        ),
        _buildCircularButton(
          context: context,
          icon: isRTL ? Icons.chevron_right : Icons.chevron_left,
          onPressed: currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
        ),
        ...pageNumbers,
        _buildCircularButton(
          context: context,
          icon: isRTL ? Icons.chevron_left : Icons.chevron_right,
          onPressed: currentPage < totalPages ? () => onPageChanged(currentPage + 1) : null,
        ),
        _buildCircularButton(
          context: context,
          icon: isRTL ? Icons.first_page : Icons.last_page,
          onPressed: currentPage < totalPages ? () => onPageChanged(totalPages) : null,
        ),
      ],
    );
  }

  Widget _buildCircularButton({
    required BuildContext context,
    required IconData icon,
    VoidCallback? onPressed,
  }) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: 30,
          height: 30,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: onPressed != null ? Colors.white : Colors.grey[200],
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: onPressed != null ? Colorz.primaryColor : Colors.grey,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildPageNumber(BuildContext context, int pageNumber) {
    final bool isCurrentPage = pageNumber == currentPage;
    return GestureDetector(
      onTap: isCurrentPage ? null : () => onPageChanged(pageNumber),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: isCurrentPage ? Colorz.primaryColor : Colors.transparent,
          border: Border.all(color: isCurrentPage ? Colorz.primaryColor : Colors.grey.shade300),
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.grey.withOpacity(0.3),
          //     spreadRadius: 1,
          //     blurRadius: 3,
          //     offset: const Offset(0, 2),
          //   ),
          // ],
        ),
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          clipBehavior: Clip.hardEdge,
          child: Center(
            child: Text(
              pageNumber.toString(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: isCurrentPage ? FontWeight.bold : FontWeight.normal,
                color: isCurrentPage ? Colors.white : Colorz.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEllipsisWidget(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        '...',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colorz.grey,
        ),
      ),
    );
  }
}

// class CustomPagination extends StatelessWidget {
//   final int currentPage;
//   final int totalPages;
//   final Function(int) onPageChanged;
//
//   const CustomPagination({
//     Key? key,
//     required this.currentPage,
//     required this.totalPages,
//     required this.onPageChanged,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final bool isRTL = Directionality.of(context) == TextDirection.rtl;
//
//     List<Widget> pageNumbers = [];
//     if (totalPages <= 3) {
//       // Show all pages if total pages are 3 or less
//       for (int i = 1; i <= totalPages; i++) {
//         pageNumbers.add(_buildPageNumber(context, i));
//       }
//     } else {
//       if (currentPage > 3) {
//         // Show the first page
//         pageNumbers.add(_buildPageNumber(context, 1));
//
//         // Add ellipsis if necessary
//         if (currentPage > 4) {
//           pageNumbers.add(_buildEllipsisWidget(context));
//         }
//
//         // Show pages around the current page
//         int startPage = currentPage - 1;
//         int endPage = currentPage + 1;
//
//         // Ensure we do not exceed total pages
//         if (endPage > totalPages - 2) {
//           endPage = totalPages - 2;
//         }
//         for (int i = startPage; i <= endPage; i++) {
//           pageNumbers.add(_buildPageNumber(context, i));
//         }
//
//         // Add ellipsis if necessary
//         if (endPage < totalPages - 2) {
//           pageNumbers.add(_buildEllipsisWidget(context));
//         }
//       } else {
//         // Show the first 3 pages
//         for (int i = 1; i <= 3; i++) {
//           pageNumbers.add(_buildPageNumber(context, i));
//         }
//
//         // Add ellipsis and then skip two pages if necessary
//         if (totalPages > 5) {
//           pageNumbers.add(_buildEllipsisWidget(context));
//           pageNumbers.add(_buildPageNumber(context, currentPage + 2));
//         }
//       }
//     }
//
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         _buildCircularButton(
//           context: context,
//           icon: isRTL ? Icons.last_page : Icons.first_page,
//           onPressed: currentPage > 1 ? () => onPageChanged(1) : null,
//         ),
//         _buildCircularButton(
//           context: context,
//           icon: isRTL ? Icons.chevron_right : Icons.chevron_left,
//           onPressed: currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
//         ),
//         ...pageNumbers,
//         _buildCircularButton(
//           context: context,
//           icon: isRTL ? Icons.chevron_left : Icons.chevron_right,
//           onPressed: currentPage < totalPages ? () => onPageChanged(currentPage + 2 ) : null,
//         ),
//         _buildCircularButton(
//           context: context,
//           icon: isRTL ? Icons.first_page : Icons.last_page,
//           onPressed: currentPage < totalPages ? () => onPageChanged(totalPages) : null,
//         ),
//       ],
//     );
//   }
//
//   Widget _buildCircularButton({
//     required BuildContext context,
//     required IconData icon,
//     VoidCallback? onPressed,
//   }) {
//     return Directionality(
//       textDirection: TextDirection.ltr,
//       child: GestureDetector(
//         onTap: onPressed,
//         child: Container(
//           width: 35,
//           height: 35,
//           margin: const EdgeInsets.symmetric(horizontal: 4),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(10),
//             color: onPressed != null ? Colors.white : Colors.grey[200],
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.grey.withOpacity(0.3),
//                 spreadRadius: 1,
//                 blurRadius: 3,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           child: Icon(
//             icon,
//             color: onPressed != null ? Colorz.green : Colors.grey,
//             size: 20,
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildPageNumber(BuildContext context, int pageNumber) {
//     final bool isCurrentPage = pageNumber == currentPage;
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 4),
//       width: 35,
//       height: 35,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(10),
//         color: isCurrentPage ? Colorz.green : Colors.transparent,
//         border: Border.all(color: isCurrentPage ? Colorz.green : Colorz.grey300),
//       ),
//       child: Material(
//         color: Colors.transparent,
//         shape: const CircleBorder(),
//         clipBehavior: Clip.hardEdge,
//         child: GestureDetector(
//           onTap: () {
//             if (!isCurrentPage) {
//               print('Page selected: $pageNumber'); // Debugging output
//               onPageChanged(pageNumber);
//             }
//           },
//           child: Center(
//             child: Text(
//               pageNumber.toString(),
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: isCurrentPage ? FontWeight.bold : FontWeight.normal,
//                 color: isCurrentPage ? Colors.white : Colorz.grey,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//

// }

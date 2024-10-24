import 'package:flutter/material.dart';

class SocialDivider extends StatelessWidget {
  const SocialDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width * 0.3;
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: width,
          height: 1,
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 32.0),
        Image.asset('assets/icons/compartir.png'),
        const SizedBox(width: 32.0),
        Image.asset('assets/icons/wpp.png'),
        const SizedBox(width: 32.0),
        Image.asset('assets/icons/x.png'),
        const SizedBox(width: 32.0),
        Image.asset('assets/icons/in.png'),
        const SizedBox(width: 32.0),
        Image.asset('assets/icons/fb.png'),
        const SizedBox(width: 32.0),
        Container(
          width: width,
          height: 1,
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

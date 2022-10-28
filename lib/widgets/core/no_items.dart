import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NoItemsWidget extends StatelessWidget {
  static const String routeName = '/NoDataPage';
  const NoItemsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: SvgPicture.asset(
            'assets/images/no_items.svg',
            height: 0.15 * deviceSize.height,
          ),
        ),
        SizedBox(height: 0.025 * deviceSize.height),
        Text(AppLocalizations.of(context).noItems),
      ],
    );
  }
}

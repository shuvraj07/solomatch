import 'package:material_ui/material_ui.dart';

/// The SoloMatch logo (`assets/branding/logo.png`, transparent background).
/// The launcher icon and launch screen are generated from the same artwork;
/// see the flutter_launcher_icons / flutter_native_splash sections of
/// pubspec.yaml.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 48});

  static const asset = 'assets/branding/logo.png';

  final double size;

  @override
  Widget build(BuildContext context) => Image.asset(
    asset,
    key: const Key('appLogo'),
    width: size,
    height: size,
    filterQuality: FilterQuality.medium,
    semanticLabel: 'SoloMatch',
  );
}

import 'package:flutter/widgets.dart';
import 'package:monolib_flutter/monolib_flutter.dart';

class DefaultFrame extends StatelessWidget {
  final Widget child;
  final DefaultFrameSize size;

  const DefaultFrame({super.key, required this.size, required this.child});

  @override
  Widget build(BuildContext context) => Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: size.width),
          child: child,
        ),
      );
}

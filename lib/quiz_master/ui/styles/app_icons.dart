import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class AppIcons {
  // Social Media Icons
  static HugeIcon linkedIn(BuildContext context) => HugeIcon(
    icon: HugeIcons.strokeRoundedLinkedin02,
    color: Theme.of(context).colorScheme.inverseSurface,
  );

  static HugeIcon xTwitter(BuildContext context) => HugeIcon(
    icon: HugeIcons.strokeRoundedNewTwitter,
    color: Theme.of(context).colorScheme.inverseSurface,
  );

  static HugeIcon gitHub(BuildContext context) => HugeIcon(
    icon: HugeIcons.strokeRoundedGithub,
    color: Theme.of(context).colorScheme.inverseSurface,
  );
  static HugeIcon cancel(BuildContext context) => HugeIcon(
    icon: HugeIcons.strokeRoundedCancel01,
    color: Theme.of(context).colorScheme.inverseSurface,
  );
  //OTHERS

  static HugeIcon congrats(BuildContext context) => HugeIcon(
    icon: HugeIcons.strokeRoundedParty,
    color: Theme.of(context).colorScheme.inverseSurface,
  );
  static HugeIcon equal(BuildContext context) => HugeIcon(
    icon: HugeIcons.strokeRoundedEqualSign,
    color: Theme.of(context).colorScheme.inverseSurface,
  );
}

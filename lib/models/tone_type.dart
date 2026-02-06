import 'package:flutter/material.dart';
import '../core/constants/colors.dart';

enum ToneType {
  professional,
  friendly,
  concise,
  urgent,
  assertive,
}

extension ToneTypeExtension on ToneType {
  String get label {
    switch (this) {
      case ToneType.professional:
        return 'Professional';
      case ToneType.friendly:
        return 'Friendly';
      case ToneType.concise:
        return 'Concise';
      case ToneType.urgent:
        return 'Urgent';
      case ToneType.assertive:
        return 'Assertive';
    }
  }

  IconData get icon {
    switch (this) {
      case ToneType.professional:
        return Icons.business_center;
      case ToneType.friendly:
        return Icons.waving_hand;
      case ToneType.concise:
        return Icons.rocket_launch;
      case ToneType.urgent:
        return Icons.notifications_active;
      case ToneType.assertive:
        return Icons.psychology; // or campaign
    }
  }

  Color get color {
    switch (this) {
      case ToneType.professional:
        return AppColors.toneProfessional;
      case ToneType.friendly:
        return AppColors.toneFriendly;
      case ToneType.concise:
        return AppColors.toneConcise;
      case ToneType.urgent:
        return AppColors.toneUrgent;
      case ToneType.assertive:
        return AppColors.toneAssertive;
    }
  }
}

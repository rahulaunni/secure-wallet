import 'package:flutter/material.dart';

import 'package:swallet/theme/swallet_theme.dart';
import 'package:swallet/utils/size_config.dart';
import 'package:swallet/widgets/buttons/custom_back_button.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  final bool isDark;
  final String appVersion;
  final VoidCallback? onClose;

  const PrivacyPolicyScreen({
    super.key,
    required this.isDark,
    required this.appVersion,
    this.onClose,
  });

  static const String _lastUpdated = 'May 31, 2026';

  @override
  Widget build(BuildContext context) {
    final palette = SwalletPalette(isDark);

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(w(24), w(16), w(24), 0),
              child: _buildTopBar(palette, context),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(w(24), w(20), w(24), w(24)),
                child: SelectableText(
                  _privacyPolicyText(appVersion),
                  style: SwalletText.body.copyWith(
                    color: palette.text,
                    height: 1.55,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(SwalletPalette palette, BuildContext context) {
    return Row(
      children: [
        CustomBackButton(
          isDark: isDark,
          onTap: onClose ?? () => Navigator.of(context).pop(),
        ),
        SizedBox(width: w(4)),
        Expanded(
          child: SizedBox(
            height: w(56),
            child: Align(
              alignment: Alignment.center,
              child: Text(
                'Privacy Policy',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: SwalletText.title.copyWith(
                  color: palette.text,
                  fontSize: sp(16),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: w(44), height: w(40)),
      ],
    );
  }

  String _privacyPolicyText(String version) {
    return '''
# About Swallet

Version: $version

Swallet is a privacy-focused digital card wallet designed to help you securely organize and manage your cards in one place.

Built with an offline-first philosophy, Swallet operates entirely on your device without relying on cloud services, external servers, or user accounts. Your cards, customizations, and data remain under your control and are stored locally on your device.

Swallet provides a premium card management experience with support for extensive card customization, hundreds of banks across multiple countries, secure card storage, and fast access to important card information whenever you need it.

Whether you're organizing credit cards, debit cards, or other payment cards, Swallet is designed to offer a simple, elegant, and reliable experience while respecting your privacy.

No accounts. No cloud storage. No subscriptions. No data collection.

Just your cards, securely stored on your device.

---

# Privacy Policy

Last Updated: $_lastUpdated

Swallet respects your privacy and is designed around a simple principle: your data belongs to you.

This Privacy Policy explains how information is handled when using the Swallet application.

## Information Collection

Swallet does not collect, transmit, store, sell, rent, or share your personal information, card information, or app data with external servers.

No account registration is required to use the application.

## Offline-First Design

Swallet is a completely offline application.

The app does not require an internet connection to function. All card information, customizations, and app data are stored locally on your device and remain accessible without network access.

Swallet does not upload your card information, personal data, or app content to any cloud service or external server.

## Local Data Storage

All information entered into Swallet is stored locally on your device.

This includes, but is not limited to:

* Card names
* Card numbers
* Card holder names
* Expiry dates
* CVV information
* Bank selections
* Card customizations
* Card images
* App preferences

Swallet uses local device storage and Hive-based data management to securely organize and access your information while remaining completely offline.

## Data Ownership

You retain full ownership and control of all information stored within Swallet.

Your data remains on your device unless you explicitly choose to export or share information using features provided within the application.

## Analytics and Tracking

Swallet does not use advertising trackers to monitor your activity.

Swallet does not collect behavioral analytics related to your cards or personal information.

Swallet does not track how you use your card data.

## Third-Party Sharing

Swallet does not share your information with third parties.

No card information or personal information is transmitted to advertisers, marketing providers, analytics companies, or external organizations.

## Security

Swallet stores information locally on your device and does not transmit card data to external servers.

Users are responsible for protecting access to their devices through available security measures such as device passwords, PINs, biometrics, or other security mechanisms supported by their device.

## Data Deletion

Because all data is stored locally on your device, you can remove your information at any time by:

* Deleting individual cards
* Clearing application data
* Uninstalling the application

Removing the application from your device may permanently remove locally stored data.

## Children's Privacy

Swallet is not directed toward children under the age of 13 and does not knowingly collect personal information from children.

## Changes to This Policy

If this Privacy Policy is updated in future versions of the application, the updated version will be made available within the app.

## Contact

If you have questions regarding this Privacy Policy, support information can be found within the application settings.

---

By using Swallet, you acknowledge that your data is stored locally on your device and that no card information is transmitted to external servers by the application.
''';
  }
}

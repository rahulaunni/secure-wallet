import '../data/bank_assets.dart';
import '../data/local_bank_logo_assets.dart';

class BankAssetResolver {
  /// ------------------------------------------------------------
  /// ALIASES → CANONICAL IDS (FILENAMES)
  /// ------------------------------------------------------------
  /// This maps the "Short ID" used in code to the "Filename" in assets.
  static const Map<String, String> _aliases = {
    // ===== PRIVATE BANKS =====
    'axis': 'axis_bank',
    'bandhan': 'bandhan_bank',
    'csb': 'csb_bank',
    'citibank': 'citibank',
    'city_union': 'city_union_bank',
    'dcb': 'dcb_bank',
    'dhanlaxmi': 'dhanlaxmi_bank',
    'federal': 'federal_bank',
    'hdfc': 'hdfc_bank',
    'icici': 'icici_bank',
    'indusind': 'indusind_bank',
    'idfc': 'idfc_first_bank',
    'idfc_first': 'idfc_first_bank', // Safety alias
    'indian_bank': 'indian_bank',
    'jammu_kashmir': 'jammu_and_kashmir_bank',
    'karnataka': 'karnataka_bank',
    'karur_vysya': 'karur_vysya_bank',
    'kotak': 'kotak_mahindra_bank',
    'rbl': 'rbl_bank',
    'south_indian': 'south_indian_bank',
    'standard_chartered': 'standard_chartered_bank',
    'tmb': 'tamilnad_mercantile_bank',
    'yes': 'yes_bank',
    'yes_bank': 'yes_bank', // Safety alias
    'idbi': 'idbi_bank',

    // ===== PSU BANKS =====
    'au_small_finance': 'au_small_finance_bank',
    'bank_of_baroda': 'bank_of_baroda',
    'bob': 'bank_of_baroda', // Safety alias
    'bank_of_india': 'bank_of_india',
    'bank_of_maharashtra': 'bank_of_maharashtra',
    'canara': 'canara_bank',
    'central_bank': 'central_bank_of_india',
    'indian_overseas': 'indian_overseas_bank',
    'iob': 'indian_overseas_bank', // Safety alias
    'punjab_sind': 'punjab_and_sind_bank',
    'pnb': 'punjab_national_bank',
    'sbi': 'state_bank_of_india',
    'state_bank': 'state_bank_of_india', // Safety alias
    'uco': 'uco_bank',
    'union': 'union_bank',
    'union_bank': 'union_bank', // Safety alias
  };

  /// ------------------------------------------------------------
  /// DISPLAY NAMES (FOR UI)
  /// ------------------------------------------------------------
  static const Map<String, String> _displayNames = {
    // Private
    'axis_bank': 'Axis Bank',
    'bandhan_bank': 'Bandhan Bank',
    'csb_bank': 'CSB Bank',
    'citibank': 'Citibank',
    'city_union_bank': 'City Union Bank',
    'dcb_bank': 'DCB Bank',
    'dhanlaxmi_bank': 'Dhanlaxmi Bank',
    'federal_bank': 'Federal Bank',
    'hdfc_bank': 'HDFC Bank',
    'icici_bank': 'ICICI Bank',
    'indian_bank': 'Indian Bank',
    'indusind_bank': 'IndusInd Bank',
    'idfc_first_bank': 'IDFC First Bank',
    'jammu_and_kashmir_bank': 'Jammu and Kashmir Bank',
    'karnataka_bank': 'Karnataka Bank',
    'karur_vysya_bank': 'Karur Vysya Bank',
    'kotak_mahindra_bank': 'Kotak Mahindra Bank',
    'rbl_bank': 'RBL Bank',
    'south_indian_bank': 'South Indian Bank',
    'standard_chartered_bank': 'Standard Chartered Bank',
    'tamilnad_mercantile_bank': 'Tamilnad Mercantile Bank',
    'yes_bank': 'Yes Bank',
    'idbi_bank': 'IDBI Bank',

    // PSU
    'au_small_finance_bank': 'AU Small Finance Bank',
    'bank_of_baroda': 'Bank of Baroda',
    'bank_of_india': 'Bank of India',
    'bank_of_maharashtra': 'Bank of Maharashtra',
    'canara_bank': 'Canara Bank',
    'central_bank_of_india': 'Central Bank of India',
    'indian_overseas_bank': 'Indian Overseas Bank',
    'punjab_and_sind_bank': 'Punjab and Sind Bank',
    'punjab_national_bank': 'Punjab National Bank',
    'state_bank_of_india': 'State Bank of India',
    'uco_bank': 'UCO Bank',
    'union_bank': 'Union Bank',
  };

  /// ------------------------------------------------------------
  /// RESOLVE INPUT → CANONICAL CID
  /// ------------------------------------------------------------
  static String resolveCid(String input) {
    final key = input.toLowerCase().trim();
    return _aliases[key] ?? key;
  }

  /// ------------------------------------------------------------
  /// DISPLAY NAME
  /// ------------------------------------------------------------
  static String displayName(String cid) {
    if (cid == BankAssets.otherBankId) {
      return 'Other';
    }

    final importedBank = BankAssets.importedBankForId(cid);
    if (importedBank != null) {
      return importedBank.name;
    }

    final resolved = resolveCid(cid);
    return _displayNames[resolved] ??
        resolved
            .replaceAll('_', ' ')
            .split(' ')
            .map((e) => e.isNotEmpty ? e[0].toUpperCase() + e.substring(1) : '')
            .join(' ');
  }

  /// ------------------------------------------------------------
  /// ✅ IMAGE PATH (SINGLE SOURCE OF TRUTH)
  /// ------------------------------------------------------------
  static String bankImagePath(String cid) {
    return logoPath(cid) ?? 'assets/icons/banks/india/${resolveCid(cid)}.svg';
  }

  /// ------------------------------------------------------------
  /// ✅ ICON PATH (FOR ADD CARD SHEET)
  /// ------------------------------------------------------------
  static String bankIconPath(String cid) {
    return bankImagePath(cid);
  }

  static String? logoPath(String cid) {
    final resolved = resolveCid(cid);

    final indiaExtension = LocalBankLogoAssets.indiaLogoExtensions[resolved];
    if (indiaExtension != null) {
      return 'assets/icons/banks/india/$resolved.$indiaExtension';
    }

    final extension = LocalBankLogoAssets.importedLogoExtensions[resolved];
    if (extension != null) {
      final parts = resolved.split('__');
      if (parts.length == 2) {
        return 'assets/icons/banks/${parts[0]}/${parts[1]}.$extension';
      }
    }

    return null;
  }

  static bool hasLocalLogo(String cid) {
    return logoPath(cid) != null;
  }

  static String initials(String cid) {
    final words = displayName(cid)
        .replaceAll(RegExp(r'[^A-Za-z0-9 ]'), ' ')
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();

    if (words.isEmpty) {
      return 'BK';
    }

    if (words.length == 1) {
      final end = words.first.length >= 2 ? 2 : 1;
      return words.first.substring(0, end).toUpperCase();
    }

    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }
}

import 'package:flutter/material.dart';

// Explicit card-style gradients for imported banks. The first two stops are
// brand/editable colors audited from each bank's official website and local
// logo asset, with a darker third stop tuned for readable card surfaces.
// India is intentionally excluded here because native Indian bank gradients
// are maintained in card_visuals.dart.
const Map<String, List<Color>> importedBankGradients = {
  'argentina__bbva_argentina': [
    Color(0xFF001391),
    Color(0xFF85C8FF),
    Color(0xFF10194B),
  ],
  'argentina__banco_ciudad': [
    Color(0xFF005BAA),
    Color(0xFF00AEEF),
    Color(0xFF043547),
  ],
  'argentina__banco_credicoop': [
    Color(0xFFFFCB05),
    Color(0xFF00A651),
    Color(0xFF30300A),
  ],
  'argentina__banco_galicia': [
    Color(0xFFFA6400),
    Color(0xFF632B05),
    Color(0xFF462B04),
  ],
  'argentina__banco_macro': [
    Color(0xFF053575),
    Color(0xFF376DB8),
    Color(0xFF071439),
  ],
  'argentina__banco_provincia': [
    Color(0xFF007A3D),
    Color(0xFF0982CD),
    Color(0xFF022B2E),
  ],
  'argentina__banco_de_la_naci_n': [
    Color(0xFF0072BC),
    Color(0xFF053656),
    Color(0xFF031A37),
  ],
  'argentina__brubank': [
    Color(0xFF614AD9),
    Color(0xFF3D2081),
    Color(0xFF281249),
  ],
  'argentina__icbc_argentina': [
    Color(0xFFCB0202),
    Color(0xFF7A0000),
    Color(0xFF3F0A03),
  ],
  'argentina__santander_r_o': [
    Color(0xFFEC0000),
    Color(0xFFFF3B30),
    Color(0xFF5E0805),
  ],
  'australia__anz': [
    Color(0xFF0072AC),
    Color(0xFF004165),
    Color(0xFF032C34),
  ],
  'australia__bank_of_china_australia': [
    Color(0xFFE60012),
    Color(0xFFFFD7D7),
    Color(0xFF6B0609),
  ],
  'australia__bank_australia': [
    Color(0xFFE6007E),
    Color(0xFFEF7D00),
    Color(0xFF650617),
  ],
  'australia__bank_of_queensland': [
    Color(0xFFFFC20D),
    Color(0xFF0069F2),
    Color(0xFF2A2D16),
  ],
  'australia__bendigo_bank': [
    Color(0xFF870E40),
    Color(0xFFDE313B),
    Color(0xFF430715),
  ],
  'australia__commonwealth_bank': [
    Color(0xFFFFCC00),
    Color(0xFF874400),
    Color(0xFF322D08),
  ],
  'australia__ing_australia': [
    Color(0xFFFF6200),
    Color(0xFF525199),
    Color(0xFF4C2712),
  ],
  'australia__hsbc_australia': [
    Color(0xFFDB0011),
    Color(0xFF83000A),
    Color(0xFF430404),
  ],
  'australia__macquarie_bank': [
    Color(0xFF0C6CCE),
    Color(0xFF064384),
    Color(0xFF042544),
  ],
  'australia__nab': [
    Color(0xFF3A4F59),
    Color(0xFFC20000),
    Color(0xFF2C1110),
  ],
  'australia__suncorp_bank': [
    Color(0xFFFFCB05),
    Color(0xFFDDEEFF),
    Color(0xFF433309),
  ],
  'australia__up_bank': [
    Color(0xFFFFEE52),
    Color(0xFF1E1E1E),
    Color(0xFF2C2D10),
  ],
  'australia__westpac': [
    Color(0xFFDA1710),
    Color(0xFF1F1C4F),
    Color(0xFF3A070C),
  ],
  'austria__bawag': [
    Color(0xFF990000),
    Color(0xFF015374),
    Color(0xFF260A0A),
  ],
  'austria__bks_bank': [
    Color(0xFFE50251),
    Color(0xFF422373),
    Color(0xFF420319),
  ],
  'austria__btv': [
    Color(0xFF004166),
    Color(0xFF336785),
    Color(0xFF05232D),
  ],
  'austria__bank_austria': [
    Color(0xFF007A91),
    Color(0xFF247B43),
    Color(0xFF032D31),
  ],
  'austria__erste_group': [
    Color(0xFF2870ED),
    Color(0xFFA3B5C9),
    Color(0xFF0D3A63),
  ],
  'austria__hypo_vorarlberg': [
    Color(0xFF0079C2),
    Color(0xFF00B2FF),
    Color(0xFF042A4E),
  ],
  'austria__oberbank': [
    Color(0xFF007BFF),
    Color(0xFFDC3545),
    Color(0xFF1A224C),
  ],
  'austria__rlb_o': [
    Color(0xFFFFED00),
    Color(0xFF000000),
    Color(0xFF272507),
  ],
  'austria__raiffeisen_bank': [
    Color(0xFFFEE600),
    Color(0xFF2B2D33),
    Color(0xFF2E2C08),
  ],
  'austria__volksbank': [
    Color(0xFF4392F1),
    Color(0xFF1E69C8),
    Color(0xFF092861),
  ],
  'belgium__argenta': [
    Color(0xFF004A65),
    Color(0xFF00A160),
    Color(0xFF022627),
  ],
  'belgium__bnp_paribas_fortis': [
    Color(0xFF00A76D),
    Color(0xFF7FCBAE),
    Color(0xFF0F482D),
  ],
  'belgium__belfius': [
    Color(0xFFC30045),
    Color(0xFFAD0CDF),
    Color(0xFF45042A),
  ],
  'belgium__beobank': [
    Color(0xFF572381),
    Color(0xFFC80E15),
    Color(0xFF34081D),
  ],
  'belgium__crelan': [
    Color(0xFFC3D100),
    Color(0xFF7FAD00),
    Color(0xFF3E4704),
  ],
  'belgium__ing_belgium': [
    Color(0xFF349651),
    Color(0xFFDFEDF8),
    Color(0xFF224E2E),
  ],
  'belgium__kbc': [
    Color(0xFF0097DB),
    Color(0xFF0D2A50),
    Color(0xFF03213E),
  ],
  'belgium__keytrade_bank': [
    Color(0xFF03B3D9),
    Color(0xFF045667),
    Color(0xFF032A40),
  ],
  'belgium__vdk_bank': [
    Color(0xFFE84E0F),
    Color(0xFFFBBA00),
    Color(0xFF5A2D05),
  ],
  'brazil__btg_pactual': [
    Color(0xFF001E61),
    Color(0xFF008000),
    Color(0xFF022424),
  ],
  'brazil__banco_inter': [
    Color(0xFFFF8700),
    Color(0xFF72370E),
    Color(0xFF4B3104),
  ],
  'brazil__banco_safra': [
    Color(0xFF1E536B),
    Color(0xFFD4AD68),
    Color(0xFF19392B),
  ],
  'brazil__banco_santander_brasil': [
    Color(0xFFCC0000),
    Color(0xFF739E41),
    Color(0xFF440A06),
  ],
  'brazil__banco_do_brasil': [
    Color(0xFFF8DD00),
    Color(0xFF005AA9),
    Color(0xFF2A2D11),
  ],
  'brazil__bradesco': [
    Color(0xFFCC092F),
    Color(0xFF610517),
    Color(0xFF3E030C),
  ],
  'brazil__c6_bank': [
    Color(0xFFC5A560),
    Color(0xFF111111),
    Color(0xFF342616),
  ],
  'brazil__caixa': [
    Color(0xFFF7941D),
    Color(0xFF005CA9),
    Color(0xFF3E2D1C),
  ],
  'brazil__ita_unibanco': [
    Color(0xFFFF6200),
    Color(0xFFFFCC00),
    Color(0xFF5C3B05),
  ],
  'brazil__nubank': [
    Color(0xFF490B75),
    Color(0xFFECD9FF),
    Color(0xFF381E45),
  ],
  'canada__atb_financial': [
    Color(0xFF3CA3FF),
    Color(0xFFDFF0FF),
    Color(0xFF06346B),
  ],
  'canada__bmo': [
    Color(0xFF0075BE),
    Color(0xFFED1B2F),
    Color(0xFF211A39),
  ],
  'canada__cibc': [
    Color(0xFFBDBCBC),
    Color(0xFFC41F3E),
    Color(0xFF4F2121),
  ],
  'canada__desjardins': [
    Color(0xFF00874E),
    Color(0xFF053E26),
    Color(0xFF02271D),
  ],
  'canada__eq_bank': [
    Color(0xFF513BFC),
    Color(0xFFC33991),
    Color(0xFF240F58),
  ],
  'canada__laurentian_bank': [
    Color(0xFFFDB812),
    Color(0xFF9FD5FC),
    Color(0xFF3C340F),
  ],
  'canada__national_bank_of_canada': [
    Color(0xFF00314D),
    Color(0xFFE41C23),
    Color(0xFF230E13),
  ],
  'canada__royal_bank_of_canada': [
    Color(0xFFFFD200),
    Color(0xFF005DAA),
    Color(0xFF2C2C11),
  ],
  'canada__scotiabank': [
    Color(0xFFED0722),
    Color(0xFFAD0000),
    Color(0xFF4E0406),
  ],
  'canada__td_bank': [
    Color(0xFF038203),
    Color(0xFFFF9500),
    Color(0xFF293203),
  ],
  'canada__tangerine': [
    Color(0xFFF2691D),
    Color(0xFF006FD6),
    Color(0xFF411E1D),
  ],
  'canada__wealthsimple': [
    Color(0xFFB99A5B),
    Color(0xFF111111),
    Color(0xFF312A15),
  ],
  'chile__bci': [
    Color(0xFF2772CC),
    Color(0xFF37474F),
    Color(0xFF0E1C3F),
  ],
  'chile__banco_bice': [
    Color(0xFF0D00A6),
    Color(0xFFD51E53),
    Color(0xFF260335),
  ],
  'chile__banco_falabella': [
    Color(0xFF2900A6),
    Color(0xFFD51E6E),
    Color(0xFF2D0338),
  ],
  'chile__banco_security': [
    Color(0xFF6A2E92),
    Color(0xFF232272),
    Color(0xFF1A0D36),
  ],
  'chile__banco_de_chile': [
    Color(0xFF3B82F6),
    Color(0xFFC13D09),
    Color(0xFF261F44),
  ],
  'chile__bancoestado': [
    Color(0xFFEE801D),
    Color(0xFFD70032),
    Color(0xFF5F2707),
  ],
  'chile__consorcio': [
    Color(0xFF003058),
    Color(0xFF0352E5),
    Color(0xFF031C34),
  ],
  'chile__ita_chile': [
    Color(0xFFEC7000),
    Color(0xFF003399),
    Color(0xFF3B1D13),
  ],
  'chile__santander_chile': [
    Color(0xFFEC0000),
    Color(0xFFFF3B30),
    Color(0xFF5E0509),
  ],
  'chile__scotiabank_chile': [
    Color(0xFFD8261C),
    Color(0xFF655445),
    Color(0xFF45180D),
  ],
  'china__agricultural_bank_of_china': [
    Color(0xFFAABBCC),
    Color(0xFFEB401C),
    Color(0xFF4F2221),
  ],
  'china__bank_of_china': [
    Color(0xFFD28F1E),
    Color(0xFFA71E32),
    Color(0xFF4D2B0B),
  ],
  'china__bank_of_communications': [
    Color(0xFFDE9510),
    Color(0xFF612C05),
    Color(0xFF432B04),
  ],
  'china__citic_bank': [
    Color(0xFFE8313E),
    Color(0xFF337AB7),
    Color(0xFF421A26),
  ],
  'china__china_construction_bank': [
    Color(0xFF005BAC),
    Color(0xFF031C38),
    Color(0xFF021C2F),
  ],
  'china__china_merchants_bank': [
    Color(0xFFA30030),
    Color(0xFF5C89EA),
    Color(0xFF37112E),
  ],
  'china__icbc': [
    Color(0xFFBC0021),
    Color(0xFFFF0000),
    Color(0xFF4D0414),
  ],
  'china__ping_an_bank': [
    Color(0xFFFF4800),
    Color(0xFF006441),
    Color(0xFF3F2407),
  ],
  'china__postal_savings_bank': [
    Color(0xFF333333),
    Color(0xFF18AE66),
    Color(0xFF0D271A),
  ],
  'china__spdb': [
    Color(0xFF004790),
    Color(0xFF000073),
    Color(0xFF030C30),
  ],
  'colombia__bbva_colombia': [
    Color(0xFF001391),
    Color(0xFF85C8FF),
    Color(0xFF10264B),
  ],
  'colombia__banco_av_villas': [
    Color(0xFF007BFF),
    Color(0xFFDC3545),
    Color(0xFF1A254C),
  ],
  'colombia__banco_agrario': [
    Color(0xFF003399),
    Color(0xFF00BCD4),
    Color(0xFF031D3F),
  ],
  'colombia__banco_popular': [
    Color(0xFF27C112),
    Color(0xFF105163),
    Color(0xFF093C15),
  ],
  'colombia__banco_de_bogot': [
    Color(0xFF80ACFF),
    Color(0xFF0B5FFF),
    Color(0xFF06336B),
  ],
  'colombia__banco_de_occidente': [
    Color(0xFF80ACFF),
    Color(0xFF0B5FFF),
    Color(0xFF061E6B),
  ],
  'colombia__bancolombia': [
    Color(0xFF003344),
    Color(0xFF00C389),
    Color(0xFF022625),
  ],
  'colombia__davivienda': [
    Color(0xFF007BFF),
    Color(0xFF000000),
    Color(0xFF032239),
  ],
  'colombia__nequi': [
    Color(0xFFDA0081),
    Color(0xFFECE7F5),
    Color(0xFF640D4D),
  ],
  'colombia__davibank': [
    Color(0xFFD81E05),
    Color(0xFFF79FA3),
    Color(0xFF661809),
  ],
  'czech_republic__air_bank': [
    Color(0xFF99CC33),
    Color(0xFF1E3300),
    Color(0xFF243A09),
  ],
  'czech_republic__creditas': [
    Color(0xFF113A7E),
    Color(0xFFD7142C),
    Color(0xFF260E25),
  ],
  'czech_republic__fio_banka': [
    Color(0xFF00408A),
    Color(0xFF8FBE00),
    Color(0xFF122D1F),
  ],
  'czech_republic__komer_n_banka': [
    Color(0xFFE60028),
    Color(0xFF000000),
    Color(0xFF33030E),
  ],
  'czech_republic__moneta': [
    Color(0xFF007BFF),
    Color(0xFFDC3545),
    Color(0xFF1A234C),
  ],
  'czech_republic__raiffeisenbank_cz': [
    Color(0xFFFEE600),
    Color(0xFF2B2D33),
    Color(0xFF2B2D08),
  ],
  'czech_republic__unicredit_bank_cr': [
    Color(0xFFE00A1E),
    Color(0xFF337AB7),
    Color(0xFF3F111A),
  ],
  'czech_republic__mbank_cz': [
    Color(0xFF0266B2),
    Color(0xFF00801F),
    Color(0xFF022D28),
  ],
  'czech_republic__sob': [
    Color(0xFF0A77A9),
    Color(0xFF003366),
    Color(0xFF031E36),
  ],
  'czech_republic__esk_spo_itelna': [
    Color(0xFF00497B),
    Color(0xFFD0021B),
    Color(0xFF210F23),
  ],
  'denmark__danske_bank': [
    Color(0xFF003F63),
    Color(0xFF222299),
    Color(0xFF03132F),
  ],
  'denmark__jyske_bank': [
    Color(0xFFC6570C),
    Color(0xFF8B0047),
    Color(0xFF460F0A),
  ],
  'denmark__lunar': [
    Color(0xFFAB3EFF),
    Color(0xFF00D63C),
    Color(0xFF20254D),
  ],
  'denmark__nykredit': [
    Color(0xFF07094A),
    Color(0xFF6A07A6),
    Color(0xFF18022A),
  ],
  'denmark__ringkj_bing_landbobank': [
    Color(0xFFEF7D1B),
    Color(0xFF07174A),
    Color(0xFF3C1F0E),
  ],
  'denmark__spar_nord': [
    Color(0xFF07094A),
    Color(0xFF4A07A6),
    Color(0xFF0C022A),
  ],
  'denmark__sparekassen_kronjylland': [
    Color(0xFF5E5E34),
    Color(0xFF990B13),
    Color(0xFF2F120D),
  ],
  'denmark__sydbank': [
    Color(0xFFC6240C),
    Color(0xFF8B0027),
    Color(0xFF46050F),
  ],
  'egypt__aaib': [
    Color(0xFF133120),
    Color(0xFFD6A739),
    Color(0xFF26250E),
  ],
  'egypt__bank_of_alexandria': [
    Color(0xFF0B4A35),
    Color(0xFF337AB7),
    Color(0xFF082929),
  ],
  'egypt__banque_misr': [
    Color(0xFF5897FB),
    Color(0xFF116600),
    Color(0xFF142E3E),
  ],
  'egypt__banque_du_caire': [
    Color(0xFFF36227),
    Color(0xFFC09300),
    Color(0xFF591D05),
  ],
  'egypt__cib_egypt': [
    Color(0xFFF58423),
    Color(0xFFCE1611),
    Color(0xFF5C2906),
  ],
  'egypt__credit_agricole_egypt': [
    Color(0xFF3399FF),
    Color(0xFFFF6900),
    Color(0xFF22244B),
  ],
  'egypt__hsbc_egypt': [
    Color(0xFFDB0011),
    Color(0xFF83000A),
    Color(0xFF430414),
  ],
  'egypt__faisal_islamic_bank': [
    Color(0xFF007AFF),
    Color(0xFF28A745),
    Color(0xFF043748),
  ],
  'egypt__housing_and_development_bank': [
    Color(0xFF3E7A33),
    Color(0xFF007BFF),
    Color(0xFF0C3133),
  ],
  'egypt__national_bank_of_egypt': [
    Color(0xFF03A84E),
    Color(0xFF011B12),
    Color(0xFF022A18),
  ],
  'egypt__qnb_alahli': [
    Color(0xFF85878B),
    Color(0xFFCE4811),
    Color(0xFF42241E),
  ],
  'finland__aktia': [
    Color(0xFF222288),
    Color(0xFF00EB64),
    Color(0xFF062E31),
  ],
  'finland__danske_bank_finland': [
    Color(0xFF003F63),
    Color(0xFF081DB7),
    Color(0xFF031030),
  ],
  'finland__handelsbanken_finland': [
    Color(0xFF005FA5),
    Color(0xFF043B62),
    Color(0xFF032733),
  ],
  'finland__nordea_finland': [
    Color(0xFF00019F),
    Color(0xFFDCEDFF),
    Color(0xFF171953),
  ],
  'finland__op': [
    Color(0xFFFF6A10),
    Color(0xFFD00000),
    Color(0xFF590D05),
  ],
  'finland__omasp': [
    Color(0xFF00BBFF),
    Color(0xFF0066CC),
    Color(0xFF043355),
  ],
  'finland__pop_bank': [
    Color(0xFF5D85F4),
    Color(0xFF97B1F8),
    Color(0xFF06306B),
  ],
  'finland__s_bank': [
    Color(0xFF222288),
    Color(0xFF007841),
    Color(0xFF06202B),
  ],
  'finland__savings_banks_group': [
    Color(0xFF222288),
    Color(0xFF068840),
    Color(0xFF07202B),
  ],
  'finland__landsbanken': [
    Color(0xFF003280),
    Color(0xFF00B3EF),
    Color(0xFF03213D),
  ],
  'france__bnp_paribas': [
    Color(0xFF00915A),
    Color(0xFF03422A),
    Color(0xFF022A20),
  ],
  'france__boursorama_banque': [
    Color(0xFF9E9E9E),
    Color(0xFFC6C6C6),
    Color(0xFF4D2823),
  ],
  'france__cic': [
    Color(0xFFFE330F),
    Color(0xFF018289),
    Color(0xFF3F1B14),
  ],
  'france__cr_dit_agricole': [
    Color(0xFF003344),
    Color(0xFF007461),
    Color(0xFF021E24),
  ],
  'france__cr_dit_mutuel': [
    Color(0xFF0058A8),
    Color(0xFF0093EB),
    Color(0xFF042646),
  ],
  'france__groupe_bpce': [
    Color(0xFF581D74),
    Color(0xFFEDEAF8),
    Color(0xFF372048),
  ],
  'france__hello_bank': [
    Color(0xFF0080A6),
    Color(0xFF0AD2E1),
    Color(0xFF044045),
  ],
  'france__lcl': [
    Color(0xFFF44336),
    Color(0xFFFFD740),
    Color(0xFF6B1706),
  ],
  'france__la_banque_postale': [
    Color(0xFF39A8E5),
    Color(0xFF003DA5),
    Color(0xFF0A3751),
  ],
  'france__soci_t_g_n_rale': [
    Color(0xFFE60028),
    Color(0xFF000000),
    Color(0xFF420D03),
  ],
  'germany__commerzbank': [
    Color(0xFFFBB809),
    Color(0xFF002530),
    Color(0xFF2A1E09),
  ],
  'germany__dkb': [
    Color(0xFF0976D6),
    Color(0xFF0F2F47),
    Color(0xFF03273E),
  ],
  'germany__dz_bank': [
    Color(0xFF0066B3),
    Color(0xFFF37021),
    Color(0xFF192339),
  ],
  'germany__deutsche_bank': [
    Color(0xFF0550D1),
    Color(0xFF1E2A78),
    Color(0xFF041344),
  ],
  'germany__ing_diba': [
    Color(0xFFFF6200),
    Color(0xFFD70000),
    Color(0xFF570C05),
  ],
  'germany__kfw': [
    Color(0xFF7B59FF),
    Color(0xFF00375B),
    Color(0xFF171650),
  ],
  'germany__lbbw': [
    Color(0xFF123250),
    Color(0xFF37C391),
    Color(0xFF0A2A29),
  ],
  'germany__n26': [
    Color(0xFFA8DED8),
    Color(0xFFC89D58),
    Color(0xFF2F4D23),
  ],
  'germany__postbank': [
    Color(0xFF0A3478),
    Color(0xFF3B5D93),
    Color(0xFF081734),
  ],
  'germany__targobank': [
    Color(0xFF002F5F),
    Color(0xFF26CAFF),
    Color(0xFF03273D),
  ],
  'greece__alpha_bank': [
    Color(0xFF11366B),
    Color(0xFF3F97DE),
    Color(0xFF0A233C),
  ],
  'greece__crediabank': [
    Color(0xFF001EBA),
    Color(0xFF4A92E5),
    Color(0xFF072450),
  ],
  'greece__chania_bank': [
    Color(0xFFEC6E00),
    Color(0xFFE62700),
    Color(0xFF542004),
  ],
  'greece__eurobank': [
    Color(0xFF0050B5),
    Color(0xFF827048),
    Color(0xFF102638),
  ],
  'greece__national_bank_of_greece': [
    Color(0xFF003C49),
    Color(0xFF1299A2),
    Color(0xFF022429),
  ],
  'greece__optima_bank': [
    Color(0xFF0D46AF),
    Color(0xFF032338),
    Color(0xFF031D32),
  ],
  'greece__piraeus_bank': [
    Color(0xFF00B2FF),
    Color(0xFF002F30),
    Color(0xFF033840),
  ],
  'greece__viva_wallet': [
    Color(0xFF41B5FF),
    Color(0xFFA0A8BA),
    Color(0xFF0C4F64),
  ],
  'hungary__cib_bank': [
    Color(0xFF0B4A35),
    Color(0xFF110B0B),
    Color(0xFF062013),
  ],
  'hungary__erste_bank_hungary': [
    Color(0xFF2870ED),
    Color(0xFFA3B5C9),
    Color(0xFF0D2463),
  ],
  'hungary__gr_nit_bank': [
    Color(0xFF695FFF),
    Color(0xFF04041E),
    Color(0xFF151344),
  ],
  'hungary__k_and_h_bank': [
    Color(0xFF007BFF),
    Color(0xFFDC3545),
    Color(0xFF1A1A4C),
  ],
  'hungary__mbh_bank': [
    Color(0xFF8F1C6B),
    Color(0xFFFFB010),
    Color(0xFF4B1718),
  ],
  'hungary__magnet_bank': [
    Color(0xFF5C812E),
    Color(0xFFB4E378),
    Color(0xFF304319),
  ],
  'hungary__otp_bank': [
    Color(0xFF52AE30),
    Color(0xFFFF435A),
    Color(0xFF3B3A15),
  ],
  'hungary__raiffeisen_hungary': [
    Color(0xFFFEE600),
    Color(0xFF2B2D33),
    Color(0xFF2E2308),
  ],
  'hungary__unicredit_hungary': [
    Color(0xFFE00A1E),
    Color(0xFF337AB7),
    Color(0xFF3F111D),
  ],
  'indonesia__bca': [
    Color(0xFF1473E6),
    Color(0xFF093967),
    Color(0xFF042A47),
  ],
  'indonesia__bni': [
    Color(0xFFE72B00),
    Color(0xFFB00047),
    Color(0xFF530709),
  ],
  'indonesia__bri': [
    Color(0xFFE72E00),
    Color(0xFFB00049),
    Color(0xFF531407),
  ],
  'indonesia__bank_danamon': [
    Color(0xFF0D6EFD),
    Color(0xFFDC3545),
    Color(0xFF1B1C4C),
  ],
  'indonesia__bank_mandiri': [
    Color(0xFFFFB700),
    Color(0xFF65B6F0),
    Color(0xFF363613),
  ],
  'indonesia__bank_tabungan_negara': [
    Color(0xFF0050A4),
    Color(0xFFFF8A00),
    Color(0xFF173431),
  ],
  'indonesia__bank_syariah_indonesia': [
    Color(0xFFE70100),
    Color(0xFFB0002C),
    Color(0xFF4C0C04),
  ],
  'indonesia__cimb_niaga': [
    Color(0xFF0D6EFD),
    Color(0xFFFFC107),
    Color(0xFF1F3C45),
  ],
  'indonesia__ocbc_nisp': [
    Color(0xFF0D6EFD),
    Color(0xFFDC3545),
    Color(0xFF221B4C),
  ],
  'indonesia__permatabank': [
    Color(0xFF0064FF),
    Color(0xFF0048B7),
    Color(0xFF041E52),
  ],
  'ireland__aib': [
    Color(0xFFB9BABD),
    Color(0xFF4D2476),
    Color(0xFF30224C),
  ],
  'ireland__an_post_money': [
    Color(0xFF006150),
    Color(0xFF00A76A),
    Color(0xFF022D20),
  ],
  'ireland__avant_money': [
    Color(0xFFFF821C),
    Color(0xFF169B99),
    Color(0xFF433B19),
  ],
  'ireland__bank_of_ireland': [
    Color(0xFF0000FF),
    Color(0xFF053C59),
    Color(0xFF050446),
  ],
  'ireland__bunq_ireland': [
    Color(0xFF0099FF),
    Color(0xFFFF6A00),
    Color(0xFF1E3043),
  ],
  'ireland__credit_union': [
    Color(0xFF017597),
    Color(0xFF4D5A70),
    Color(0xFF092136),
  ],
  'ireland__n26_ireland': [
    Color(0xFF48AC98),
    Color(0xFF111111),
    Color(0xFF112D25),
  ],
  'ireland__permanent_tsb': [
    Color(0xFF07272D),
    Color(0xFFFC4C02),
    Color(0xFF281409),
  ],
  'ireland__revolut_ireland': [
    Color(0xFF0075EB),
    Color(0xFF111111),
    Color(0xFF032139),
  ],
  'israel__bank_hapoalim': [
    Color(0xFFED1D24),
    Color(0xFF002FB8),
    Color(0xFF3B0B22),
  ],
  'israel__bank_leumi': [
    Color(0xFF2D2F88),
    Color(0xFF4169B2),
    Color(0xFF11143D),
  ],
  'israel__bank_massad': [
    Color(0xFF264769),
    Color(0xFF5DBB63),
    Color(0xFF142E2C),
  ],
  'israel__bank_of_jerusalem': [
    Color(0xFFBF8B30),
    Color(0xFFCA0101),
    Color(0xFF4E1D08),
  ],
  'israel__discount_bank': [
    Color(0xFF36B455),
    Color(0xFF2F3242),
    Color(0xFF113420),
  ],
  'israel__esh_bank': [
    Color(0xFF826CDD),
    Color(0xFFD5DAF6),
    Color(0xFF20115F),
  ],
  'israel__fibi': [
    Color(0xFF264769),
    Color(0xFF3C7FC3),
    Color(0xFF0F1E38),
  ],
  'israel__mercantile': [
    Color(0xFF00A661),
    Color(0xFF6924E8),
    Color(0xFF0C2A3B),
  ],
  'israel__mizrahi_tefahot': [
    Color(0xFF8D7A7A),
    Color(0xFFD5D5D5),
    Color(0xFF4D2323),
  ],
  'israel__one_zero': [
    Color(0xFF00306E),
    Color(0xFF00ACA5),
    Color(0xFF022A2F),
  ],
  'israel__pepper': [
    Color(0xFFFF6900),
    Color(0xFFFF424D),
    Color(0xFF672005),
  ],
  'italy__bnl': [
    Color(0xFF04A47B),
    Color(0xFFE20613),
    Color(0xFF183116),
  ],
  'italy__bper_banca': [
    Color(0xFF005157),
    Color(0xFF65B6F0),
    Color(0xFF0C303A),
  ],
  'italy__banca_mediolanum': [
    Color(0xFF192D6E),
    Color(0xFFDC3545),
    Color(0xFF281025),
  ],
  'italy__banco_bpm': [
    Color(0xFF042F5F),
    Color(0xFF008066),
    Color(0xFF021D24),
  ],
  'italy__credem': [
    Color(0xFFFFF047),
    Color(0xFF00421E),
    Color(0xFF2F2D0F),
  ],
  'italy__finecobank': [
    Color(0xFF0F8BC1),
    Color(0xFFDDEEBB),
    Color(0xFF1A4352),
  ],
  'italy__intesa_sanpaolo': [
    Color(0xFF258900),
    Color(0xFFFA9600),
    Color(0xFF2D3303),
  ],
  'italy__mediobanca': [
    Color(0xFF003366),
    Color(0xFFE8C77C),
    Color(0xFF173334),
  ],
  'italy__monte_dei_paschi_di_siena': [
    Color(0xFF92062A),
    Color(0xFFF0AD4E),
    Color(0xFF491D12),
  ],
  'italy__unicredit': [
    Color(0xFFE00A1E),
    Color(0xFFAACCCC),
    Color(0xFF581527),
  ],
  'japan__aozora_bank': [
    Color(0xFF05489B),
    Color(0xFF1B7CF5),
    Color(0xFF041B49),
  ],
  'japan__japan_post_bank': [
    Color(0xFF009900),
    Color(0xFFE0E3D4),
    Color(0xFF244A1A),
  ],
  'japan__mufg_bank': [
    Color(0xFFE60000),
    Color(0xFF2A3F98),
    Color(0xFF3F061F),
  ],
  'japan__mizuho_bank': [
    Color(0xFFBC0026),
    Color(0xFF111111),
    Color(0xFF2F0206),
  ],
  'japan__rakuten_bank': [
    Color(0xFFBF0000),
    Color(0xFFFF1212),
    Color(0xFF500409),
  ],
  'japan__resona_bank': [
    Color(0xFF0CA26C),
    Color(0xFFF7920E),
    Color(0xFF233F18),
  ],
  'japan__smbc': [
    Color(0xFF004831),
    Color(0xFFC4D700),
    Color(0xFF183209),
  ],
  'japan__shinsei_bank': [
    Color(0xFF2071BD),
    Color(0xFFB0BDCC),
    Color(0xFF183A53),
  ],
  'japan__sony_bank': [
    Color(0xFF006B4E),
    Color(0xFF002B69),
    Color(0xFF021F24),
  ],
  'japan__sumitomo_mitsui_trust': [
    Color(0xFFCCCCCC),
    Color(0xFF006680),
    Color(0xFF23434D),
  ],
  'kenya__absa_kenya': [
    Color(0xFFEB3158),
    Color(0xFFFA551E),
    Color(0xFF6B1006),
  ],
  'kenya__co_operative_bank': [
    Color(0xFF198754),
    Color(0xFF003388),
    Color(0xFF042929),
  ],
  'kenya__diamond_trust_bank': [
    Color(0xFF00660B),
    Color(0xFFBB0012),
    Color(0xFF221C05),
  ],
  'kenya__equity_bank': [
    Color(0xFFFF6200),
    Color(0xFF07174A),
    Color(0xFF402108),
  ],
  'kenya__i_and_m_bank': [
    Color(0xFFAEAEAE),
    Color(0xFFE30613),
    Color(0xFF531D23),
  ],
  'kenya__kcb_bank': [
    Color(0xFF80BC00),
    Color(0xFF003B4D),
    Color(0xFF163709),
  ],
  'kenya__ncba_bank': [
    Color(0xFF3AB3E5),
    Color(0xFF003388),
    Color(0xFF0A3B4D),
  ],
  'kenya__stanbic_bank_ke': [
    Color(0xFFC6C6C6),
    Color(0xFF005CA4),
    Color(0xFF22404E),
  ],
  'kenya__standard_chartered_ke': [
    Color(0xFF008738),
    Color(0xFF0C77B9),
    Color(0xFF033027),
  ],
  'malaysia__affin_bank': [
    Color(0xFF0021A0),
    Color(0xFFCC0014),
    Color(0xFF23062B),
  ],
  'malaysia__alliance_bank': [
    Color(0xFF224E84),
    Color(0xFFB52025),
    Color(0xFF211229),
  ],
  'malaysia__ambank': [
    Color(0xFFFF0009),
    Color(0xFFFFC7CB),
    Color(0xFF6B0806),
  ],
  'malaysia__bank_islam': [
    Color(0xFFA2000E),
    Color(0xFF003388),
    Color(0xFF280618),
  ],
  'malaysia__bank_of_china_malaysia': [
    Color(0xFFE60012),
    Color(0xFF260004),
    Color(0xFF390311),
  ],
  'malaysia__bank_rakyat': [
    Color(0xFF003864),
    Color(0xFF0071A5),
    Color(0xFF02162D),
  ],
  'malaysia__cimb': [
    Color(0xFF780000),
    Color(0xFFFF0000),
    Color(0xFF3E0309),
  ],
  'malaysia__hong_leong_bank': [
    Color(0xFFACACAC),
    Color(0xFF002D62),
    Color(0xFF1E3042),
  ],
  'malaysia__hsbc_malaysia': [
    Color(0xFFDB0011),
    Color(0xFF83000A),
    Color(0xFF430504),
  ],
  'malaysia__maybank': [
    Color(0xFFFED136),
    Color(0xFF000000),
    Color(0xFF2B220B),
  ],
  'malaysia__ocbc_malaysia': [
    Color(0xFF2979FF),
    Color(0xFF366492),
    Color(0xFF0C2E56),
  ],
  'malaysia__public_bank': [
    Color(0xFFCC0000),
    Color(0xFFF27474),
    Color(0xFF590B0F),
  ],
  'malaysia__rhb_bank': [
    Color(0xFFEF3E42),
    Color(0xFF0067B1),
    Color(0xFF3C1A2B),
  ],
  'malaysia__standard_chartered_malaysia': [
    Color(0xFF0473EA),
    Color(0xFF38D200),
    Color(0xFF06383C),
  ],
  'malaysia__uob_malaysia': [
    Color(0xFFD71920),
    Color(0xFF003B70),
    Color(0xFF350C0F),
  ],
  'mexico__bbva_m_xico': [
    Color(0xFF001391),
    Color(0xFF85C8FF),
    Color(0xFF101C4B),
  ],
  'mexico__bancoppel': [
    Color(0xFFEED124),
    Color(0xFF006FB9),
    Color(0xFF252E16),
  ],
  'mexico__banco_azteca': [
    Color(0xFF17A54D),
    Color(0xFFFA6262),
    Color(0xFF233B1A),
  ],
  'mexico__banorte': [
    Color(0xFF323E48),
    Color(0xFFEB0029),
    Color(0xFF300C15),
  ],
  'mexico__citibanamex': [
    Color(0xFF82A7D9),
    Color(0xFF008294),
    Color(0xFF18454F),
  ],
  'mexico__hsbc_m_xico': [
    Color(0xFFDB0011),
    Color(0xFF83000A),
    Color(0xFF430408),
  ],
  'mexico__inbursa': [
    Color(0xFF000254),
    Color(0xFF0D6EFD),
    Color(0xFF030C37),
  ],
  'mexico__klar': [
    Color(0xFF17818F),
    Color(0xFFD6AE60),
    Color(0xFF1C3F2D),
  ],
  'mexico__santander_m_xico': [
    Color(0xFFEC0000),
    Color(0xFF3366FF),
    Color(0xFF420C28),
  ],
  'mexico__scotiabank_m_xico': [
    Color(0xFFD81E05),
    Color(0xFF0081AB),
    Color(0xFF361719),
  ],
  'morocco__al_barid_bank': [
    Color(0xFFFFD42D),
    Color(0xFFC13727),
    Color(0xFF3E2A09),
  ],
  'morocco__attijariwafa_bank': [
    Color(0xFFF9B42E),
    Color(0xFFEE5E49),
    Color(0xFF6B4406),
  ],
  'morocco__bank_of_africa': [
    Color(0xFF003399),
    Color(0xFF499ED7),
    Color(0xFF072046),
  ],
  'morocco__banque_populaire': [
    Color(0xFF0072C6),
    Color(0xFFE67E04),
    Color(0xFF192E38),
  ],
  'morocco__cfg_bank': [
    Color(0xFFE6332A),
    Color(0xFF8C2214),
    Color(0xFF4E0C09),
  ],
  'morocco__cr_dit_agricole_du_maroc': [
    Color(0xFF003399),
    Color(0xFF007732),
    Color(0xFF022229),
  ],
  'morocco__cr_dit_du_maroc': [
    Color(0xFFE7004C),
    Color(0xFFAACCCC),
    Color(0xFF5A1224),
  ],
  'morocco__soci_t_g_n_rale_maroc': [
    Color(0xFFE60028),
    Color(0xFF000000),
    Color(0xFF330313),
  ],
  'netherlands__abn_amro': [
    Color(0xFF00716B),
    Color(0xFF003737),
    Color(0xFF022422),
  ],
  'netherlands__asn_bank': [
    Color(0xFF1F7D65),
    Color(0xFFF5A623),
    Color(0xFF2D391A),
  ],
  'netherlands__ing_group': [
    Color(0xFFFF6200),
    Color(0xFF07174A),
    Color(0xFF401008),
  ],
  'netherlands__knab': [
    Color(0xFFAC285A),
    Color(0xFF063B47),
    Color(0xFF2C1020),
  ],
  'netherlands__rabobank': [
    Color(0xFF0059FF),
    Color(0xFFC21000),
    Color(0xFF1C143F),
  ],
  'netherlands__triodos_bank': [
    Color(0xFF004B32),
    Color(0xFF3C132E),
    Color(0xFF0A1C1C),
  ],
  'netherlands__bunq': [
    Color(0xFF0099FF),
    Color(0xFFFF6A00),
    Color(0xFF1E3B43),
  ],
  'new_zealand__anz_nz': [
    Color(0xFF006BDE),
    Color(0xFF8ADAF9),
    Color(0xFF073766),
  ],
  'new_zealand__bank_of_china_nz': [
    Color(0xFFA71E32),
    Color(0xFFFF6633),
    Color(0xFF500F17),
  ],
  'new_zealand__asb': [
    Color(0xFFFCBD1B),
    Color(0xFF0064AC),
    Color(0xFF292A15),
  ],
  'new_zealand__bnz': [
    Color(0xFFFAA819),
    Color(0xFF002F6B),
    Color(0xFF3E2C12),
  ],
  'new_zealand__co_operative_bank': [
    Color(0xFF288641),
    Color(0xFF8BD5EE),
    Color(0xFF1A4239),
  ],
  'new_zealand__heartland_bank': [
    Color(0xFF0D6EFD),
    Color(0xFFFFC107),
    Color(0xFF1F3245),
  ],
  'new_zealand__kiwibank': [
    Color(0xFF19E480),
    Color(0xFF258752),
    Color(0xFF084D1F),
  ],
  'new_zealand__rabobank_nz': [
    Color(0xFF0058FF),
    Color(0xFF1E2141),
    Color(0xFF041F46),
  ],
  'new_zealand__sbs_bank': [
    Color(0xFFFF6801),
    Color(0xFFFFE5C8),
    Color(0xFF6B4306),
  ],
  'new_zealand__tsb_bank': [
    Color(0xFF007C4E),
    Color(0xFF00B18F),
    Color(0xFF03342B),
  ],
  'new_zealand__westpac_nz': [
    Color(0xFFDA1710),
    Color(0xFF991AD6),
    Color(0xFF4D0621),
  ],
  'nigeria__access_bank': [
    Color(0xFF007BFF),
    Color(0xFFDC3545),
    Color(0xFF1A214C),
  ],
  'nigeria__fcmb': [
    Color(0xFFFAB613),
    Color(0xFF5C2682),
    Color(0xFF322110),
  ],
  'nigeria__fidelity_bank': [
    Color(0xFF002082),
    Color(0xFF6BC048),
    Color(0xFF0D262B),
  ],
  'nigeria__first_bank': [
    Color(0xFF003B65),
    Color(0xFFF0BD2D),
    Color(0xFF253116),
  ],
  'nigeria__gtco': [
    Color(0xFFE04403),
    Color(0xFFD80027),
    Color(0xFF560805),
  ],
  'nigeria__stanbic_ibtc': [
    Color(0xFFC6C6C6),
    Color(0xFF005CA4),
    Color(0xFF22394E),
  ],
  'nigeria__sterling_bank': [
    Color(0xFFDB1D1D),
    Color(0xFF6EC1E4),
    Color(0xFF491D26),
  ],
  'nigeria__uba': [
    Color(0xFF006E87),
    Color(0xFF111111),
    Color(0xFF022424),
  ],
  'nigeria__union_bank': [
    Color(0xFF007487),
    Color(0xFF111111),
    Color(0xFF021D24),
  ],
  'nigeria__zenith_bank': [
    Color(0xFF2A6496),
    Color(0xFF428BCA),
    Color(0xFF102E44),
  ],
  'norway__dnb': [
    Color(0xFFFF0000),
    Color(0xFF007272),
    Color(0xFF3F170D),
  ],
  'norway__klp': [
    Color(0xFF3FA7FF),
    Color(0xFFE41B65),
    Color(0xFF1C1D54),
  ],
  'norway__nordea_norway': [
    Color(0xFF00019F),
    Color(0xFFDCEDFF),
    Color(0xFF172053),
  ],
  'norway__obos_banken': [
    Color(0xFF8DD4BD),
    Color(0xFFC0385D),
    Color(0xFF4D2325),
  ],
  'norway__sparebank_1': [
    Color(0xFFE60000),
    Color(0xFF00235B),
    Color(0xFF38030E),
  ],
  'norway__storebrand': [
    Color(0xFFFF3C3C),
    Color(0xFFFFDFDF),
    Color(0xFF6B0C06),
  ],
  'norway__agder_sparebank': [
    Color(0xFF222299),
    Color(0xFF00383D),
    Color(0xFF06142F),
  ],
  'norway__aurskog_sparebank': [
    Color(0xFF222299),
    Color(0xFF223300),
    Color(0xFF0B0E26),
  ],
  'norway__berg_sparebank': [
    Color(0xFF222299),
    Color(0xFF00383D),
    Color(0xFF06132F),
  ],
  'norway__bien_sparebank': [
    Color(0xFF222299),
    Color(0xFFF6A800),
    Color(0xFF341725),
  ],
  'norway__bjugn_sparebank': [
    Color(0xFF222299),
    Color(0xFF00383D),
    Color(0xFF06082F),
  ],
  'norway__etnedal_sparebank': [
    Color(0xFF222299),
    Color(0xFF00383D),
    Color(0xFF06102F),
  ],
  'norway__evje_og_hornnes_sparebank': [
    Color(0xFF222299),
    Color(0xFF223300),
    Color(0xFF0B1126),
  ],
  'norway__gildeskal_sparebank': [
    Color(0xFF222299),
    Color(0xFF00383D),
    Color(0xFF060E2F),
  ],
  'norway__grong_sparebank': [
    Color(0xFF222299),
    Color(0xFF00383D),
    Color(0xFF06122F),
  ],
  'norway__grue_sparebank': [
    Color(0xFF222299),
    Color(0xFF119977),
    Color(0xFF082238),
  ],
  'norway__haltdalen_sparebank': [
    Color(0xFF222299),
    Color(0xFF00383D),
    Color(0xFF040425),
  ],
  'norway__haugesund_sparebank': [
    Color(0xFF222299),
    Color(0xFF2E47E5),
    Color(0xFF0B0D48),
  ],
  'norway__hegra_sparebank': [
    Color(0xFF222299),
    Color(0xFF00383D),
    Color(0xFF05062B),
  ],
  'norway__holand_og_setskog_sparebank': [
    Color(0xFFC1CD23),
    Color(0xFF006227),
    Color(0xFF2B420B),
  ],
  'norway__jbf': [
    Color(0xFF222299),
    Color(0xFF00383D),
    Color(0xFF1A0742),
  ],
  'norway__jaren_sparebank': [
    Color(0xFF222299),
    Color(0xFF223300),
    Color(0xFF0B0B26),
  ],
  'norway__kvinesdal_sparebank': [
    Color(0xFFFD5000),
    Color(0xFF222299),
    Color(0xFF441313),
  ],
  'norway__marker_og_eidsberg_sparebank': [
    Color(0xFF222299),
    Color(0xFF223300),
    Color(0xFF0C0B26),
  ],
  'norway__melhusbanken': [
    Color(0xFF222299),
    Color(0xFF00383D),
    Color(0xFF050930),
  ],
  'norway__odal_sparebank': [
    Color(0xFF222299),
    Color(0xFF17550E),
    Color(0xFF091028),
  ],
  'norway__oppdalsbanken': [
    Color(0xFF222299),
    Color(0xFFF6A22D),
    Color(0xFF341732),
  ],
  'norway__orkla_sparebank': [
    Color(0xFF222299),
    Color(0xFF00383D),
    Color(0xFF05052B),
  ],
  'norway__penni': [
    Color(0xFF222299),
    Color(0xFFC793FF),
    Color(0xFF1E174F),
  ],
  'norway__rogaland_sparebank': [
    Color(0xFF222299),
    Color(0xFF119977),
    Color(0xFF081F38),
  ],
  'norway__romerike_sparebank': [
    Color(0xFF222299),
    Color(0xFF00383D),
    Color(0xFF060B2F),
  ],
  'norway__rorosbanken': [
    Color(0xFF222299),
    Color(0xFFA84731),
    Color(0xFF25102E),
  ],
  'norway__skagerrak_sparebank': [
    Color(0xFF222299),
    Color(0xFF00383D),
    Color(0xFF06152F),
  ],
  'norway__skudenes_aakra_sparebank': [
    Color(0xFF222299),
    Color(0xFF119977),
    Color(0xFF082438),
  ],
  'norway__skue_sparebank': [
    Color(0xFF222299),
    Color(0xFF223300),
    Color(0xFF0E0920),
  ],
  'norway__sogn_sparebank': [
    Color(0xFF222299),
    Color(0xFF00383D),
    Color(0xFF040727),
  ],
  'norway__soknedal_sparebank': [
    Color(0xFF222299),
    Color(0xFF223300),
    Color(0xFF0B1226),
  ],
  'norway__sparebanken_narvik': [
    Color(0xFF222299),
    Color(0xFF00383D),
    Color(0xFF060425),
  ],
  'norway__strommen_sparebank': [
    Color(0xFF224488),
    Color(0xFF223300),
    Color(0xFF0B1B22),
  ],
  'norway__tinde_sparebank': [
    Color(0xFF222299),
    Color(0xFF056854),
    Color(0xFF061332),
  ],
  'norway__trogstad_sparebank': [
    Color(0xFF222299),
    Color(0xFF223300),
    Color(0xFF0B1026),
  ],
  'norway__trondelag_sparebank': [
    Color(0xFF222299),
    Color(0xFF00383D),
    Color(0xFF0C0530),
  ],
  'norway__valdres_sparebank': [
    Color(0xFF222299),
    Color(0xFF00383D),
    Color(0xFF06092F),
  ],
  'norway__valle_sparebank': [
    Color(0xFF222299),
    Color(0xFF00383D),
    Color(0xFF060A2F),
  ],
  'norway__vekselbanken': [
    Color(0xFF9AC499),
    Color(0xFF222299),
    Color(0xFF1F3045),
  ],
  'norway__orskog_sparebank': [
    Color(0xFF222299),
    Color(0xFF00383D),
    Color(0xFF060F2F),
  ],
  'oman__ahlibank_oman': [
    Color(0xFF002F5A),
    Color(0xFF1C5E9D),
    Color(0xFF02112E),
  ],
  'oman__bank_muscat': [
    Color(0xFFEE3423),
    Color(0xFF0072C6),
    Color(0xFF3B1923),
  ],
  'oman__bank_of_baroda': [
    Color(0xFFF26522),
    Color(0xFF162B75),
    Color(0xFF401A16),
  ],
  'oman__bank_dhofar': [
    Color(0xFF61B214),
    Color(0xFF14A44D),
    Color(0xFF21450D),
  ],
  'oman__bank_nizwa': [
    Color(0xFFFFC709),
    Color(0xFF929292),
    Color(0xFF3A2A0D),
  ],
  'oman__first_abu_dhabi_bank': [
    Color(0xFF003DA6),
    Color(0xFFE7EBFF),
    Color(0xFF173957),
  ],
  'oman__hbl': [
    Color(0xFF008469),
    Color(0xFFC81063),
    Color(0xFF151C2F),
  ],
  'oman__national_bank_of_oman': [
    Color(0xFF0A52D4),
    Color(0xFFA94442),
    Color(0xFF171D3F),
  ],
  'oman__oman_arab_bank': [
    Color(0xFF005AA9),
    Color(0xFF649AD1),
    Color(0xFF0B2249),
  ],
  'oman__qnb_oman': [
    Color(0xFF85878B),
    Color(0xFF008442),
    Color(0xFF193925),
  ],
  'oman__sohar_international': [
    Color(0xFFFF6C2A),
    Color(0xFFDEE2E6),
    Color(0xFF6B1706),
  ],
  'oman__standard_chartered_oman': [
    Color(0xFF0473EA),
    Color(0xFF7BB6F5),
    Color(0xFF052E68),
  ],
  'oman__state_bank_of_india': [
    Color(0xFF223366),
    Color(0xFF223300),
    Color(0xFF0C161A),
  ],
  'pakistan__allied_bank': [
    Color(0xFF013B82),
    Color(0xFFF36F21),
    Color(0xFF2C142D),
  ],
  'pakistan__askari_bank': [
    Color(0xFFC6C6C6),
    Color(0xFF014120),
    Color(0xFF20472E),
  ],
  'pakistan__bank_alfalah': [
    Color(0xFFAEAEAE),
    Color(0xFF014131),
    Color(0xFF1C3F34),
  ],
  'pakistan__bank_of_punjab': [
    Color(0xFF014137),
    Color(0xFF009E10),
    Color(0xFF022415),
  ],
  'pakistan__hbl': [
    Color(0xFF014139),
    Color(0xFF009E0C),
    Color(0xFF022414),
  ],
  'pakistan__habibmetro': [
    Color(0xFF01413E),
    Color(0xFF009E01),
    Color(0xFF02240F),
  ],
  'pakistan__mcb_bank': [
    Color(0xFF01413E),
    Color(0xFF009E02),
    Color(0xFF022409),
  ],
  'pakistan__meezan_bank': [
    Color(0xFF215B41),
    Color(0xFF009E3D),
    Color(0xFF062E15),
  ],
  'pakistan__national_bank_of_pakistan': [
    Color(0xFFCCDC56),
    Color(0xFF009A52),
    Color(0xFF203512),
  ],
  'pakistan__ubl': [
    Color(0xFF01413D),
    Color(0xFF009E03),
    Color(0xFF02240F),
  ],
  'peru__bbva_per': [
    Color(0xFF001391),
    Color(0xFF85C8FF),
    Color(0xFF10154B),
  ],
  'peru__bcp': [
    Color(0xFF004192),
    Color(0xFFF96A53),
    Color(0xFF231835),
  ],
  'peru__banbif': [
    Color(0xFF20A6FF),
    Color(0xFF924FF5),
    Color(0xFF06206B),
  ],
  'peru__banco_falabella_per': [
    Color(0xFF3B9326),
    Color(0xFFED0025),
    Color(0xFF331E0C),
  ],
  'peru__banco_pichincha': [
    Color(0xFF26A3DD),
    Color(0xFF0F265C),
    Color(0xFF083344),
  ],
  'peru__banco_ripley': [
    Color(0xFFF2AD4B),
    Color(0xFFE22D36),
    Color(0xFF6A1C06),
  ],
  'peru__banco_de_la_naci_n': [
    Color(0xFFE11E00),
    Color(0xFFFFD147),
    Color(0xFF5F1F05),
  ],
  'peru__interbank': [
    Color(0xFFD96B10),
    Color(0xFF8A156F),
    Color(0xFF4B1C10),
  ],
  'peru__mibanco': [
    Color(0xFF009439),
    Color(0xFFFE7A15),
    Color(0xFF2C370E),
  ],
  'peru__scotiabank_per': [
    Color(0xFFD81E05),
    Color(0xFF8230DF),
    Color(0xFF490B1B),
  ],
  'philippines__bdo_unibank': [
    Color(0xFF1100A8),
    Color(0xFFCE116C),
    Color(0xFF1E0337),
  ],
  'philippines__bpi': [
    Color(0xFFB11116),
    Color(0xFF0697A3),
    Color(0xFF2F1519),
  ],
  'philippines__china_bank': [
    Color(0xFF0D6EFD),
    Color(0xFFDC3545),
    Color(0xFF1B214C),
  ],
  'philippines__eastwest_bank': [
    Color(0xFF5B3F3F),
    Color(0xFF151515),
    Color(0xFF1D0E0D),
  ],
  'philippines__hsbc_philippines': [
    Color(0xFFDB0011),
    Color(0xFF83000A),
    Color(0xFF43040C),
  ],
  'philippines__landbank': [
    Color(0xFF6BBF59),
    Color(0xFF1C4900),
    Color(0xFF1A3B12),
  ],
  'philippines__metrobank': [
    Color(0xFF079ED8),
    Color(0xFF001A88),
    Color(0xFF042145),
  ],
  'philippines__pnb': [
    Color(0xFF30CDD7),
    Color(0xFF10357F),
    Color(0xFF0A3C48),
  ],
  'philippines__rcbc': [
    Color(0xFF3783D9),
    Color(0xFF002F6C),
    Color(0xFF0A2946),
  ],
  'philippines__security_bank': [
    Color(0xFF000CA8),
    Color(0xFFCE1150),
    Color(0xFF200335),
  ],
  'philippines__unionbank': [
    Color(0xFFFF7E29),
    Color(0xFF2400A8),
    Color(0xFF451A20),
  ],
  'poland__alior_bank': [
    Color(0xFF494747),
    Color(0xFFD6D6D6),
    Color(0xFF42241E),
  ],
  'poland__bnp_paribas_poland': [
    Color(0xFF00834F),
    Color(0xFF0D6EFD),
    Color(0xFF032636),
  ],
  'poland__bank_millennium': [
    Color(0xFFBD004F),
    Color(0xFF1C5CAD),
    Color(0xFF330B31),
  ],
  'poland__bank_pekao': [
    Color(0xFFD91918),
    Color(0xFFEDEAE7),
    Color(0xFF620E0E),
  ],
  'poland__citi_handlowy': [
    Color(0xFF056DAE),
    Color(0xFFD60000),
    Color(0xFF1B152E),
  ],
  'poland__credit_agricole_poland': [
    Color(0xFF006B3F),
    Color(0xFFB5D334),
    Color(0xFF183B13),
  ],
  'poland__ing_bank_l_ski': [
    Color(0xFFFF6200),
    Color(0xFF07174A),
    Color(0xFF463207),
  ],
  'poland__pko_bank_polski': [
    Color(0xFF003574),
    Color(0xFFCC7A09),
    Color(0xFF1E2912),
  ],
  'poland__santander_bank_polska': [
    Color(0xFF2870ED),
    Color(0xFF0A285C),
    Color(0xFF081F48),
  ],
  'poland__velobank': [
    Color(0xFF00B140),
    Color(0xFF00608A),
    Color(0xFF033519),
  ],
  'poland__mbank': [
    Color(0xFF0065B1),
    Color(0xFF00801F),
    Color(0xFF022C28),
  ],
  'portugal__activobank': [
    Color(0xFF00B9FF),
    Color(0xFF0D6EFD),
    Color(0xFF05325E),
  ],
  'portugal__banco_ctt': [
    Color(0xFFEB3436),
    Color(0xFFFFEEAA),
    Color(0xFF6B2806),
  ],
  'portugal__bankinter_portugal': [
    Color(0xFF006635),
    Color(0xFFFF0071),
    Color(0xFF2A131D),
  ],
  'portugal__caixa_geral_de_dep_sitos': [
    Color(0xFF0071CE),
    Color(0xFF0A243E),
    Color(0xFF032938),
  ],
  'portugal__cr_dito_agr_cola': [
    Color(0xFF00A661),
    Color(0xFF223311),
    Color(0xFF033112),
  ],
  'portugal__eurobic': [
    Color(0xFF5B87DA),
    Color(0xFF1DA7EE),
    Color(0xFF0B3165),
  ],
  'portugal__millennium_bcp': [
    Color(0xFFD1005D),
    Color(0xFF2E3641),
    Color(0xFF3A0517),
  ],
  'portugal__novo_banco': [
    Color(0xFF009F98),
    Color(0xFF007BFF),
    Color(0xFF043645),
  ],
  'portugal__santander_totta': [
    Color(0xFFEC0000),
    Color(0xFF990000),
    Color(0xFF4A040C),
  ],
  'qatar__ahlibank': [
    Color(0xFF002F5A),
    Color(0xFF1C5E9D),
    Color(0xFF021C2E),
  ],
  'qatar__commercial_bank': [
    Color(0xFF0D6EFD),
    Color(0xFFFFC107),
    Color(0xFF1F3845),
  ],
  'qatar__doha_bank': [
    Color(0xFF8A2315),
    Color(0xFF4C1044),
    Color(0xFF2E0811),
  ],
  'qatar__hsbc_qatar': [
    Color(0xFFDB0011),
    Color(0xFF83000A),
    Color(0xFF430405),
  ],
  'qatar__dukhan_bank': [
    Color(0xFFC7C7C6),
    Color(0xFF003399),
    Color(0xFF23304D),
  ],
  'qatar__masraf_al_rayan': [
    Color(0xFF0076A5),
    Color(0xFF06B1D6),
    Color(0xFF042B43),
  ],
  'qatar__qiib': [
    Color(0xFF337AB7),
    Color(0xFFA94442),
    Color(0xFF1C213D),
  ],
  'qatar__qnb': [
    Color(0xFF868685),
    Color(0xFF8A3315),
    Color(0xFF3B291B),
  ],
  'qatar__standard_chartered_qatar': [
    Color(0xFF0072CE),
    Color(0xFF6DB33F),
    Color(0xFF0D3D3D),
  ],
  'qatar__qatar_first_bank': [
    Color(0xFF003388),
    Color(0xFF0D6EFD),
    Color(0xFF042443),
  ],
  'qatar__qatar_islamic_bank': [
    Color(0xFF1A7BB2),
    Color(0xFF32C5FF),
    Color(0xFF0A3852),
  ],
  'saudi_arabia__al_rajhi_bank': [
    Color(0xFF0038FF),
    Color(0xFFD80027),
    Color(0xFF160A45),
  ],
  'saudi_arabia__alinma_bank': [
    Color(0xFF116600),
    Color(0xFF023956),
    Color(0xFF03230B),
  ],
  'saudi_arabia__arab_national_bank': [
    Color(0xFF0B5FFF),
    Color(0xFF80ACFF),
    Color(0xFF06206B),
  ],
  'saudi_arabia__bank_albilad': [
    Color(0xFFCF202E),
    Color(0xFFF6B333),
    Color(0xFF5C2B0A),
  ],
  'saudi_arabia__banque_saudi_fransi': [
    Color(0xFF006C64),
    Color(0xFF003B19),
    Color(0xFF022418),
  ],
  'saudi_arabia__riyad_bank': [
    Color(0xFFB0B0B0),
    Color(0xFF0B5FFF),
    Color(0xFF182458),
  ],
  'saudi_arabia__sabb': [
    Color(0xFFE20613),
    Color(0xFF882200),
    Color(0xFF490405),
  ],
  'saudi_arabia__saudi_investment_bank': [
    Color(0xFF006C40),
    Color(0xFF011B13),
    Color(0xFF022416),
  ],
  'saudi_arabia__saudi_national_bank': [
    Color(0xFF0D6EFD),
    Color(0xFFDC3545),
    Color(0xFF1C1B4C),
  ],
  'saudi_arabia__stc_pay': [
    Color(0xFF007BFF),
    Color(0xFF4F008C),
    Color(0xFF081254),
  ],
  'singapore__bank_of_singapore': [
    Color(0xFF0D6EFD),
    Color(0xFFDC3545),
    Color(0xFF291642),
  ],
  'singapore__bank_of_china_singapore': [
    Color(0xFFE60012),
    Color(0xFF9F0010),
    Color(0xFF490413),
  ],
  'singapore__citibank_sg': [
    Color(0xFF0465A7),
    Color(0xFF4B5563),
    Color(0xFF092C38),
  ],
  'singapore__dbs_bank': [
    Color(0xFFFF3333),
    Color(0xFF337AB7),
    Color(0xFF471A1D),
  ],
  'singapore__gxs_bank': [
    Color(0xFF771FFF),
    Color(0xFFAF89F4),
    Color(0xFF33066B),
  ],
  'singapore__hsbc_sg': [
    Color(0xFFDB0011),
    Color(0xFF83000A),
    Color(0xFF430411),
  ],
  'singapore__icbc_singapore': [
    Color(0xFFBC0021),
    Color(0xFFFF0000),
    Color(0xFF4D0415),
  ],
  'singapore__maybank_sg': [
    Color(0xFFFF6200),
    Color(0xFF000000),
    Color(0xFF391D03),
  ],
  'singapore__ocbc_bank': [
    Color(0xFF007BFF),
    Color(0xFFDC3545),
    Color(0xFF2D1542),
  ],
  'singapore__standard_chartered_sg': [
    Color(0xFF0473EA),
    Color(0xFF38D200),
    Color(0xFF063A3C),
  ],
  'singapore__trust_bank': [
    Color(0xFF8210F5),
    Color(0xFFD4B0F8),
    Color(0xFF33066B),
  ],
  'singapore__uob': [
    Color(0xFFFF6200),
    Color(0xFF07174A),
    Color(0xFF401208),
  ],
  'south_africa__absa': [
    Color(0xFFEB3158),
    Color(0xFFFA551E),
    Color(0xFF6B0606),
  ],
  'south_africa__african_bank': [
    Color(0xFF00A3E0),
    Color(0xFF83D0F5),
    Color(0xFF075565),
  ],
  'south_africa__bidvest_bank': [
    Color(0xFFADAFB2),
    Color(0xFF0D6EFD),
    Color(0xFF183E58),
  ],
  'south_africa__capitec_bank': [
    Color(0xFF007A5D),
    Color(0xFFFF9C12),
    Color(0xFF263615),
  ],
  'south_africa__discovery_bank': [
    Color(0xFF114B8A),
    Color(0xFFF41C5E),
    Color(0xFF281331),
  ],
  'south_africa__fnb': [
    Color(0xFF01AAAD),
    Color(0xFFFF9900),
    Color(0xFF1F442B),
  ],
  'south_africa__investec': [
    Color(0xFF005F7A),
    Color(0xFFFF3E12),
    Color(0xFF2F1A15),
  ],
  'south_africa__nedbank': [
    Color(0xFF00633A),
    Color(0xFFFF6912),
    Color(0xFF27290E),
  ],
  'south_africa__standard_bank': [
    Color(0xFFC6C6C6),
    Color(0xFF005CA4),
    Color(0xFF22364E),
  ],
  'south_africa__tymebank': [
    Color(0xFF0D6EFD),
    Color(0xFFFFC107),
    Color(0xFF1F3545),
  ],
  'south_korea__busan_bank': [
    Color(0xFF0E0078),
    Color(0xFFC60C88),
    Color(0xFF1A022F),
  ],
  'south_korea__hana_bank': [
    Color(0xFF008485),
    Color(0xFF27B2A5),
    Color(0xFF033B2F),
  ],
  'south_korea__ibk': [
    Color(0xFF3682D5),
    Color(0xFFC0D6EE),
    Color(0xFF104261),
  ],
  'south_korea__k_bank': [
    Color(0xFFFF0000),
    Color(0xFFFFA500),
    Color(0xFF5C0C05),
  ],
  'south_korea__kb_kookmin_bank': [
    Color(0xFFFFCC00),
    Color(0xFFFFE85A),
    Color(0xFF413508),
  ],
  'south_korea__kakaobank': [
    Color(0xFF007BFF),
    Color(0xFF00D080),
    Color(0xFF043D4B),
  ],
  'south_korea__nh_nonghyup_bank': [
    Color(0xFFFF6200),
    Color(0xFF07174A),
    Color(0xFF401C08),
  ],
  'south_korea__shinhan_bank': [
    Color(0xFFD99103),
    Color(0xFF3579D4),
    Color(0xFF3E341C),
  ],
  'south_korea__toss_bank': [
    Color(0xFF3182F6),
    Color(0xFFF04452),
    Color(0xFF221F4F),
  ],
  'south_korea__woori_bank': [
    Color(0xFF0869AB),
    Color(0xFF69C7DE),
    Color(0xFF0D384C),
  ],
  'spain__abanca': [
    Color(0xFF4F76BD),
    Color(0xFF89BDFF),
    Color(0xFF132C5D),
  ],
  'spain__bbva': [
    Color(0xFF001391),
    Color(0xFF85C8FF),
    Color(0xFF1D0E48),
  ],
  'spain__banco_sabadell': [
    Color(0xFF006DFF),
    Color(0xFF000000),
    Color(0xFF031F39),
  ],
  'spain__banco_santander': [
    Color(0xFFEC0000),
    Color(0xFF3366FF),
    Color(0xFF420C1B),
  ],
  'spain__bankinter': [
    Color(0xFFAA3915),
    Color(0xFFF18500),
    Color(0xFF4C2504),
  ],
  'spain__caixabank': [
    Color(0xFF007EAE),
    Color(0xFFF4C53D),
    Color(0xFF1D4031),
  ],
  'spain__ibercaja': [
    Color(0xFFFF670F),
    Color(0xFFF6BB42),
    Color(0xFF673905),
  ],
  'spain__kutxabank': [
    Color(0xFFE1001B),
    Color(0xFF000000),
    Color(0xFF320603),
  ],
  'spain__openbank': [
    Color(0xFF002B45),
    Color(0xFFFF0049),
    Color(0xFF270819),
  ],
  'spain__unicaja_banco': [
    Color(0xFF005265),
    Color(0xFF278600),
    Color(0xFF042819),
  ],
  'sweden__avanza': [
    Color(0xFF00C281),
    Color(0xFF054C54),
    Color(0xFF033727),
  ],
  'sweden__handelsbanken': [
    Color(0xFF005FA5),
    Color(0xFF043B62),
    Color(0xFF031D33),
  ],
  'sweden__ica_banken': [
    Color(0xFFE13205),
    Color(0xFF0068A8),
    Color(0xFF381716),
  ],
  'sweden__klarna': [
    Color(0xFFD80027),
    Color(0xFF0052B4),
    Color(0xFF35092A),
  ],
  'sweden__l_nsf_rs_kringar_bank': [
    Color(0xFF005AA0),
    Color(0xFFC8041E),
    Color(0xFF1E132D),
  ],
  'sweden__marginalen_bank': [
    Color(0xFF0FA8FF),
    Color(0xFFB2E3FF),
    Color(0xFF06526B),
  ],
  'sweden__nordea_sweden': [
    Color(0xFF00019F),
    Color(0xFFDCEDFF),
    Color(0xFF171A53),
  ],
  'sweden__seb': [
    Color(0xFF41B0EE),
    Color(0xFF007AC7),
    Color(0xFF094C5B),
  ],
  'sweden__skandiabanken': [
    Color(0xFF009776),
    Color(0xFF004B4A),
    Color(0xFF022C25),
  ],
  'sweden__swedbank': [
    Color(0xFFDA532C),
    Color(0xFFFDB913),
    Color(0xFF5F2706),
  ],
  'switzerland__bcv': [
    Color(0xFF009D4D),
    Color(0xFF569FF7),
    Color(0xFF0A3F32),
  ],
  'switzerland__julius_baer': [
    Color(0xFF141E55),
    Color(0xFF003399),
    Color(0xFF030F2C),
  ],
  'switzerland__lombard_odier': [
    Color(0xFFDC3545),
    Color(0xFF007BFF),
    Color(0xFF391A37),
  ],
  'switzerland__migros_bank': [
    Color(0xFF144B3C),
    Color(0xFFD8051A),
    Color(0xFF261013),
  ],
  'switzerland__pictet': [
    Color(0xFF804940),
    Color(0xFFAACCAA),
    Color(0xFF41311D),
  ],
  'switzerland__postfinance': [
    Color(0xFF004B5A),
    Color(0xFFFF9396),
    Color(0xFF192437),
  ],
  'switzerland__raiffeisen': [
    Color(0xFF7B6E4C),
    Color(0xFF116600),
    Color(0xFF242B10),
  ],
  'switzerland__ubs': [
    Color(0xFFDA0000),
    Color(0xFF8A000A),
    Color(0xFF440E04),
  ],
  'switzerland__valiant_bank': [
    Color(0xFF007BFF),
    Color(0xFFDC3545),
    Color(0xFF1A1E4C),
  ],
  'switzerland__zkb': [
    Color(0xFF003CB4),
    Color(0xFF00BEC8),
    Color(0xFF043044),
  ],
  'thailand__bangkok_bank': [
    Color(0xFF0064FF),
    Color(0xFF003399),
    Color(0xFF04224E),
  ],
  'thailand__bank_of_china_thailand': [
    Color(0xFFAD182E),
    Color(0xFF2EB0A4),
    Color(0xFF361821),
  ],
  'thailand__cimb_thai': [
    Color(0xFF790008),
    Color(0xFFEC1C24),
    Color(0xFF3F0403),
  ],
  'thailand__citi_thailand': [
    Color(0xFF004B93),
    Color(0xFFED1B2E),
    Color(0xFF27132C),
  ],
  'thailand__cardx': [
    Color(0xFFF6A69A),
    Color(0xFFFF0000),
    Color(0xFF6B0906),
  ],
  'thailand__central_the_1_card': [
    Color(0xFF0D6EFD),
    Color(0xFFFFC107),
    Color(0xFF243055),
  ],
  'thailand__kasikornbank': [
    Color(0xFF009B3B),
    Color(0xFF887369),
    Color(0xFF11381C),
  ],
  'thailand__kiatnakin_phatra': [
    Color(0xFF001A7D),
    Color(0xFFDA1C1D),
    Color(0xFF230821),
  ],
  'thailand__krungsri': [
    Color(0xFFFFD400),
    Color(0xFF6F5F5E),
    Color(0xFF34310B),
  ],
  'thailand__krungthai_bank': [
    Color(0xFF17007D),
    Color(0xFFDA1C5C),
    Color(0xFF23022C),
  ],
  'thailand__ktc': [
    Color(0xFFCF3339),
    Color(0xFF17B221),
    Color(0xFF37250F),
  ],
  'thailand__scb': [
    Color(0xFF7A58BF),
    Color(0xFF302272),
    Color(0xFF251641),
  ],
  'thailand__tisco_bank': [
    Color(0xFFE1251B),
    Color(0xFF1C007D),
    Color(0xFF3C061F),
  ],
  'thailand__uob_thailand': [
    Color(0xFFD71920),
    Color(0xFF003B7A),
    Color(0xFF350C1E),
  ],
  'thailand__ttb': [
    Color(0xFF0050F0),
    Color(0xFFF68B1F),
    Color(0xFF1E2A43),
  ],
  'turkey__akbank': [
    Color(0xFF0072C6),
    Color(0xFFC6EFEF),
    Color(0xFF10425E),
  ],
  'turkey__denizbank': [
    Color(0xFFD11241),
    Color(0xFF8095A8),
    Color(0xFF47161F),
  ],
  'turkey__garanti_bbva': [
    Color(0xFF004481),
    Color(0xFF1973B8),
    Color(0xFF03273A),
  ],
  'turkey__halkbank': [
    Color(0xFF005697),
    Color(0xFFFF9C27),
    Color(0xFF193730),
  ],
  'turkey__kuveyt_t_rk': [
    Color(0xFF225522),
    Color(0xFF0D6EFD),
    Color(0xFF08202F),
  ],
  'turkey__qnb_finansbank': [
    Color(0xFF868685),
    Color(0xFF870052),
    Color(0xFF391A2B),
  ],
  'turkey__vak_fbank': [
    Color(0xFF007BFF),
    Color(0xFF225522),
    Color(0xFF032242),
  ],
  'turkey__yap_kredi': [
    Color(0xFF004990),
    Color(0xFF0CA2F2),
    Color(0xFF042743),
  ],
  'turkey__ziraat_bank': [
    Color(0xFFE10514),
    Color(0xFFE8EDF0),
    Color(0xFF64110C),
  ],
  'turkey__i_bank': [
    Color(0xFF013682),
    Color(0xFF223311),
    Color(0xFF041623),
  ],
  'uae__adcb': [
    Color(0xFF007360),
    Color(0xFFCE116B),
    Color(0xFF18152F),
  ],
  'uae__abu_dhabi_islamic_bank': [
    Color(0xFF00AFEF),
    Color(0xFF014787),
    Color(0xFF043748),
  ],
  'uae__bank_of_baroda_uae': [
    Color(0xFFF26522),
    Color(0xFFFF0000),
    Color(0xFF612105),
  ],
  'uae__citibank_uae': [
    Color(0xFF0465A7),
    Color(0xFF4B5563),
    Color(0xFF092238),
  ],
  'uae__commercial_bank_of_dubai': [
    Color(0xFF00736D),
    Color(0xFFCE117D),
    Color(0xFF181733),
  ],
  'uae__dubai_islamic_bank': [
    Color(0xFF153E35),
    Color(0xFFAA2236),
    Color(0xFF220F12),
  ],
  'uae__emirates_nbd': [
    Color(0xFFAACCCC),
    Color(0xFFDC3545),
    Color(0xFF4D2326),
  ],
  'uae__first_abu_dhabi_bank': [
    Color(0xFFEF2E24),
    Color(0xFF003DA6),
    Color(0xFF3B1118),
  ],
  'uae__hsbc_uae': [
    Color(0xFFDB0011),
    Color(0xFF83000A),
    Color(0xFF3A1103),
  ],
  'uae__mashreq': [
    Color(0xFFE84B25),
    Color(0xFFF8B00B),
    Color(0xFF603005),
  ],
  'uae__rakbank': [
    Color(0xFF007AFF),
    Color(0xFFDC3545),
    Color(0xFF1A204C),
  ],
  'uae__sharjah_islamic_bank': [
    Color(0xFF007369),
    Color(0xFFCE1178),
    Color(0xFF171631),
  ],
  'uae__standard_chartered_uae': [
    Color(0xFF0473EA),
    Color(0xFF38D200),
    Color(0xFF05163D),
  ],
  'uae__wio_bank': [
    Color(0xFF5700FF),
    Color(0xFF101F4B),
    Color(0xFF0A0448),
  ],
  'united_kingdom__barclays': [
    Color(0xFF00395D),
    Color(0xFFAFFDFD),
    Color(0xFF16313E),
  ],
  'united_kingdom__hsbc_uk': [
    Color(0xFFDB0011),
    Color(0xFF83000A),
    Color(0xFF430604),
  ],
  'united_kingdom__halifax': [
    Color(0xFF005EB8),
    Color(0xFFFAD267),
    Color(0xFF1D3D41),
  ],
  'united_kingdom__lloyds_bank': [
    Color(0xFF024731),
    Color(0xFF11B67A),
    Color(0xFF022C1D),
  ],
  'united_kingdom__metro_bank': [
    Color(0xFF2548AF),
    Color(0xFFD91C28),
    Color(0xFF251232),
  ],
  'united_kingdom__monzo': [
    Color(0xFF218FB7),
    Color(0xFFFF4F40),
    Color(0xFF1E2543),
  ],
  'united_kingdom__natwest': [
    Color(0xFFC20000),
    Color(0xFF3C1053),
    Color(0xFF360304),
  ],
  'united_kingdom__nationwide': [
    Color(0xFF2952B2),
    Color(0xFFDA1E28),
    Color(0xFF271533),
  ],
  'united_kingdom__revolut': [
    Color(0xFFFF6200),
    Color(0xFF07174A),
    Color(0xFF401508),
  ],
  'united_kingdom__santander_uk': [
    Color(0xFFEC0000),
    Color(0xFF007BFF),
    Color(0xFF3B0F2A),
  ],
  'united_kingdom__standard_chartered': [
    Color(0xFFFF6200),
    Color(0xFF07174A),
    Color(0xFF401408),
  ],
  'united_kingdom__starling_bank': [
    Color(0xFF321E37),
    Color(0xFF24D2BE),
    Color(0xFF0F252B),
  ],
  'united_states__ally_bank': [
    Color(0xFF954293),
    Color(0xFFFFADFD),
    Color(0xFF521E4D),
  ],
  'united_states__american_express': [
    Color(0xFF006FCF),
    Color(0xFF56A1E3),
    Color(0xFF093455),
  ],
  'united_states__bmo_us': [
    Color(0xFF0075BE),
    Color(0xFFED1B2F),
    Color(0xFF1A1A39),
  ],
  'united_states__bank_of_america': [
    Color(0xFF0053C2),
    Color(0xFFC41230),
    Color(0xFF1F1338),
  ],
  'united_states__capital_one': [
    Color(0xFF0276B1),
    Color(0xFFCC2427),
    Color(0xFF181835),
  ],
  'united_states__citibank': [
    Color(0xFF056DAE),
    Color(0xFF002A54),
    Color(0xFF032634),
  ],
  'united_states__jpmorgan_chase': [
    Color(0xFF005EB8),
    Color(0xFF002F6C),
    Color(0xFF031938),
  ],
  'united_states__navy_federal': [
    Color(0xFF0F3D70),
    Color(0xFF0667BA),
    Color(0xFF032037),
  ],
  'united_states__pnc_bank': [
    Color(0xFF004C97),
    Color(0xFFEF6A00),
    Color(0xFF22152F),
  ],
  'united_states__td_bank_us': [
    Color(0xFF038203),
    Color(0xFFFF9500),
    Color(0xFF253203),
  ],
  'united_states__truist': [
    Color(0xFF6200EE),
    Color(0xFF018786),
    Color(0xFF10154F),
  ],
  'united_states__u_s_bank': [
    Color(0xFFCF2A36),
    Color(0xFF235AE4),
    Color(0xFF391429),
  ],
  'united_states__wells_fargo': [
    Color(0xFFD71E28),
    Color(0xFF5A469B),
    Color(0xFF430E27),
  ],
  'vietnam__acb': [
    Color(0xFF0070FF),
    Color(0xFF323F4B),
    Color(0xFF04194A),
  ],
  'vietnam__agribank': [
    Color(0xFFAE1C3F),
    Color(0xFFFFDE2F),
    Color(0xFF532710),
  ],
  'vietnam__bidv': [
    Color(0xFF003344),
    Color(0xFFFFB92C),
    Color(0xFF2A2A13),
  ],
  'vietnam__hdbank': [
    Color(0xFFF00020),
    Color(0xFFFFD643),
    Color(0xFF690806),
  ],
  'vietnam__hsbc_vietnam': [
    Color(0xFFDB0011),
    Color(0xFF83000A),
    Color(0xFF492603),
  ],
  'vietnam__mb_bank': [
    Color(0xFFA0D2FF),
    Color(0xFF141ED2),
    Color(0xFF073069),
  ],
  'vietnam__sacombank': [
    Color(0xFFBABABA),
    Color(0xFF2A81D0),
    Color(0xFF203250),
  ],
  'vietnam__shinhan_bank_vietnam': [
    Color(0xFF0046AD),
    Color(0xFF55A5FF),
    Color(0xFF092951),
  ],
  'vietnam__standard_chartered_vietnam': [
    Color(0xFF008738),
    Color(0xFF0473EA),
    Color(0xFF022E2F),
  ],
  'vietnam__techcombank': [
    Color(0xFFED1C24),
    Color(0xFF0A84FF),
    Color(0xFF3D162A),
  ],
  'vietnam__vpbank': [
    Color(0xFF00B74F),
    Color(0xFF2E3A5B),
    Color(0xFF043621),
  ],
  'vietnam__uob_vietnam': [
    Color(0xFFD71920),
    Color(0xFF003B70),
    Color(0xFF350C19),
  ],
  'vietnam__vietcombank': [
    Color(0xFF0D6EFD),
    Color(0xFFDC3545),
    Color(0xFF1E1B4C),
  ],
  'vietnam__vietinbank': [
    Color(0xFF005993),
    Color(0xFF2563EB),
    Color(0xFF041946),
  ],
};

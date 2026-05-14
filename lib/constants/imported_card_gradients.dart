import 'package:flutter/material.dart';

// Explicit card-style gradients for imported banks. The first two stops are
// brand/editable colors collected from each bank's official website,
// linked official CSS/SVG logo assets, or known brand palettes when a site
// blocks color extraction. India is intentionally excluded here because
// native Indian bank gradients are maintained in card_visuals.dart.
const Map<String, List<Color>> importedBankGradients = {
  'argentina__banco_ciudad': [
    Color(0xFF005BAA),
    Color(0xFF00AEEF),
    Color(0xFF042B4E),
  ],
  'argentina__banco_credicoop': [
    Color(0xFF009FE3),
    Color(0xFF4CAF5C),
    Color(0xFF064E6C),
  ],
  'argentina__banco_de_la_naci_n': [
    Color(0xFF0072BC),
    Color(0xFF00A9B7),
    Color(0xFF053656),
  ],
  'argentina__banco_galicia': [
    Color(0xFFFA6400),
    Color(0xFFF19600),
    Color(0xFF632B05),
  ],
  'argentina__banco_macro': [
    Color(0xFF053575),
    Color(0xFF376DB8),
    Color(0xFF031E41),
  ],
  'argentina__banco_provincia': [
    Color(0xFF007A3D),
    Color(0xFF00A651),
    Color(0xFF034122),
  ],
  'argentina__bbva_argentina': [
    Color(0xFF004481),
    Color(0xFF0045AF),
    Color(0xFF02182C),
  ],
  'argentina__brubank': [
    Color(0xFF614AD9),
    Color(0xFF7C5CFF),
    Color(0xFF211367),
  ],
  'argentina__icbc_argentina': [
    Color(0xFFCB0202),
    Color(0xFF7A0000),
    Color(0xFF240202),
  ],
  'argentina__santander_r_o': [
    Color(0xFFEC0000),
    Color(0xFFFF3B30),
    Color(0xFF740606),
  ],
  'australia__anz': [
    Color(0xFF004165),
    Color(0xFF007DBA),
    Color(0xFF01121B),
  ],
  'australia__bank_of_china_australia': [
    Color(0xFFE60012),
    Color(0xFFFFD7D7),
    Color(0xFF300006),
  ],
  'australia__bank_australia': [
    Color(0xFFDC188B),
    Color(0xFF003764),
    Color(0xFF02121F),
  ],
  'australia__bank_of_queensland': [
    Color(0xFF0069F2),
    Color(0xFF69A8F9),
    Color(0xFF052C60),
  ],
  'australia__bendigo_bank': [
    Color(0xFF870E40),
    Color(0xFFDE313B),
    Color(0xFF4C0623),
  ],
  'australia__commonwealth_bank': [
    Color(0xFF1175B5),
    Color(0xFFE1001A),
    Color(0xFF6B0611),
  ],
  'australia__ing_australia': [
    Color(0xFFFF6200),
    Color(0xFF525199),
    Color(0xFF2A2951),
  ],
  'australia__hsbc_australia': [
    Color(0xFFDB0011),
    Color(0xFF3A3A3A),
    Color(0xFF1C0E12),
  ],
  'australia__macquarie_bank': [
    Color(0xFF111111),
    Color(0xFF7A7D80),
    Color(0xFF110B0B),
  ],
  'australia__nab': [
    Color(0xFFC20000),
    Color(0xFFE9600E),
    Color(0xFF540404),
  ],
  'australia__suncorp_bank': [
    Color(0xFF008C80),
    Color(0xFF004346),
    Color(0xFF011A1B),
  ],
  'australia__up_bank': [
    Color(0xFFFF705C),
    Color(0xFFFFEE52),
    Color(0xFF741406),
  ],
  'australia__westpac': [
    Color(0xFFDA1710),
    Color(0xFF181B25),
    Color(0xFF11131C),
  ],
  'austria__bank_austria': [
    Color(0xFFE2001A),
    Color(0xFFB00014),
    Color(0xFF55040E),
  ],
  'austria__bawag': [
    Color(0xFF015374),
    Color(0xFF4772AA),
    Color(0xFF043144),
  ],
  'austria__bks_bank': [
    Color(0xFF005CA9),
    Color(0xFF003F7D),
    Color(0xFF03213E),
  ],
  'austria__btv': [
    Color(0xFF0095B7),
    Color(0xFF002E49),
    Color(0xFF021926),
  ],
  'austria__erste_group': [
    Color(0xFF00497B),
    Color(0xFF0078B4),
    Color(0xFF042E4B),
  ],
  'austria__hypo_vorarlberg': [
    Color(0xFF0079C2),
    Color(0xFF005A91),
    Color(0xFF043451),
  ],
  'austria__oberbank': [
    Color(0xFF00509B),
    Color(0xFF5BBAD5),
    Color(0xFF04294C),
  ],
  'austria__raiffeisen_bank': [
    Color(0xFFFFD400),
    Color(0xFF111111),
    Color(0xFF170E0E),
  ],
  'austria__rlb_o': [
    Color(0xFF21517A),
    Color(0xFFB1C1CE),
    Color(0xFF0C1F2F),
  ],
  'austria__volksbank': [
    Color(0xFF4392F1),
    Color(0xFF1E69C8),
    Color(0xFF0D3467),
  ],
  'belgium__argenta': [
    Color(0xFF004A65),
    Color(0xFF00A160),
    Color(0xFF02222E),
  ],
  'belgium__belfius': [
    Color(0xFFC30045),
    Color(0xFFAD0CDF),
    Color(0xFF540421),
  ],
  'belgium__beobank': [
    Color(0xFF572381),
    Color(0xFFC50E00),
    Color(0xFF2F1247),
  ],
  'belgium__bnp_paribas_fortis': [
    Color(0xFF00915A),
    Color(0xFF00A76D),
    Color(0xFF045134),
  ],
  'belgium__crelan': [
    Color(0xFF00AE53),
    Color(0xFF84BD00),
    Color(0xFF044A26),
  ],
  'belgium__ing_belgium': [
    Color(0xFFFF6200),
    Color(0xFF07174A),
    Color(0xFF030D2E),
  ],
  'belgium__kbc': [
    Color(0xFF0057A8),
    Color(0xFF00AEEF),
    Color(0xFF042443),
  ],
  'belgium__keytrade_bank': [
    Color(0xFF03B3D9),
    Color(0xFF045667),
    Color(0xFF02191D),
  ],
  'belgium__vdk_bank': [
    Color(0xFFE84E0F),
    Color(0xFF8D1922),
    Color(0xFF570D13),
  ],
  'brazil__banco_do_brasil': [
    Color(0xFFF8DD00),
    Color(0xFF005AA9),
    Color(0xFF042643),
  ],
  'brazil__banco_inter': [
    Color(0xFFFF8700),
    Color(0xFF0D6EFD),
    Color(0xFF062E6B),
  ],
  'brazil__banco_safra': [
    Color(0xFF00977E),
    Color(0xFFFF7829),
    Color(0xFF045346),
  ],
  'brazil__banco_santander_brasil': [
    Color(0xFFEC0000),
    Color(0xFFFF3B30),
    Color(0xFF6C0606),
  ],
  'brazil__bradesco': [
    Color(0xFFCC092F),
    Color(0xFFE1173F),
    Color(0xFF610517),
  ],
  'brazil__btg_pactual': [
    Color(0xFF001E61),
    Color(0xFF293B8F),
    Color(0xFF020E27),
  ],
  'brazil__c6_bank': [
    Color(0xFF111111),
    Color(0xFFC5A560),
    Color(0xFF110B0B),
  ],
  'brazil__caixa': [
    Color(0xFF005CA9),
    Color(0xFFF39200),
    Color(0xFF042643),
  ],
  'brazil__ita_unibanco': [
    Color(0xFFEC7000),
    Color(0xFF003399),
    Color(0xFF041D4F),
  ],
  'brazil__nubank': [
    Color(0xFF820AD1),
    Color(0xFF9B5A00),
    Color(0xFF44066E),
  ],
  'canada__atb_financial': [
    Color(0xFFD77819),
    Color(0xFF00AAA9),
    Color(0xFF6E3C0A),
  ],
  'canada__bmo': [
    Color(0xFF0079C1),
    Color(0xFFED1B2F),
    Color(0xFF043049),
  ],
  'canada__cibc': [
    Color(0xFFC41F3E),
    Color(0xFF8B1D41),
    Color(0xFF400C1D),
  ],
  'canada__desjardins': [
    Color(0xFF00874E),
    Color(0xFF053E26),
    Color(0xFF03321E),
  ],
  'canada__eq_bank': [
    Color(0xFF513BFC),
    Color(0xFFC33991),
    Color(0xFF130674),
  ],
  'canada__laurentian_bank': [
    Color(0xFFFDB812),
    Color(0xFF9FD5FC),
    Color(0xFF745406),
  ],
  'canada__national_bank_of_canada': [
    Color(0xFF00314D),
    Color(0xFF1572C5),
    Color(0xFF021723),
  ],
  'canada__royal_bank_of_canada': [
    Color(0xFF005DAA),
    Color(0xFFFFD200),
    Color(0xFF05355C),
  ],
  'canada__scotiabank': [
    Color(0xFFED0722),
    Color(0xFF0077B5),
    Color(0xFF032B3F),
  ],
  'canada__tangerine': [
    Color(0xFFF2691D),
    Color(0xFF3A3835),
    Color(0xFF18140E),
  ],
  'canada__td_bank': [
    Color(0xFF038203),
    Color(0xFF1A5336),
    Color(0xFF081D12),
  ],
  'canada__wealthsimple': [
    Color(0xFF111111),
    Color(0xFFB99A5B),
    Color(0xFF110B0B),
  ],
  'chile__banco_bice': [
    Color(0xFF0D00A6),
    Color(0xFFD51E53),
    Color(0xFF08033D),
  ],
  'chile__banco_de_chile': [
    Color(0xFF0200A6),
    Color(0xFFD51E49),
    Color(0xFF050455),
  ],
  'chile__banco_falabella': [
    Color(0xFF2900A6),
    Color(0xFFD51E6E),
    Color(0xFF12033D),
  ],
  'chile__banco_security': [
    Color(0xFF6A2E92),
    Color(0xFF232272),
    Color(0xFF0B0B28),
  ],
  'chile__bancoestado': [
    Color(0xFFFF8700),
    Color(0xFF894B06),
    Color(0xFF552F04),
  ],
  'chile__bci': [
    Color(0xFF000CA6),
    Color(0xFFD51E3B),
    Color(0xFF03073D),
  ],
  'chile__consorcio': [
    Color(0xFF003058),
    Color(0xFF84BD00),
    Color(0xFF03223C),
  ],
  'chile__ita_chile': [
    Color(0xFFEC7000),
    Color(0xFF003399),
    Color(0xFF052159),
  ],
  'chile__santander_chile': [
    Color(0xFFEC0000),
    Color(0xFFFF3B30),
    Color(0xFF620505),
  ],
  'chile__scotiabank_chile': [
    Color(0xFFD8261C),
    Color(0xFFEFAD00),
    Color(0xFF6F110C),
  ],
  'china__agricultural_bank_of_china': [
    Color(0xFFEB401C),
    Color(0xFF333333),
    Color(0xFF221515),
  ],
  'china__bank_of_china': [
    Color(0xFFD28F1E),
    Color(0xFFFF6633),
    Color(0xFF742206),
  ],
  'china__bank_of_communications': [
    Color(0xFFDE9510),
    Color(0xFFFF6B00),
    Color(0xFF612C05),
  ],
  'china__china_construction_bank': [
    Color(0xFF005BAC),
    Color(0xFF003B7A),
    Color(0xFF031C38),
  ],
  'china__china_merchants_bank': [
    Color(0xFFA30030),
    Color(0xFF333333),
    Color(0xFF251616),
  ],
  'china__citic_bank': [
    Color(0xFFE8313E),
    Color(0xFF337AB7),
    Color(0xFF194061),
  ],
  'china__icbc': [
    Color(0xFFBC0021),
    Color(0xFFFF6200),
    Color(0xFF690617),
  ],
  'china__ping_an_bank': [
    Color(0xFFFF4800),
    Color(0xFF006441),
    Color(0xFF011B12),
  ],
  'china__postal_savings_bank': [
    Color(0xFF333333),
    Color(0xFF18AE66),
    Color(0xFF180F0F),
  ],
  'china__spdb': [
    Color(0xFF004790),
    Color(0xFF000073),
    Color(0xFF030339),
  ],
  'colombia__banco_agrario': [
    Color(0xFF4D8020),
    Color(0xFF8DB61E),
    Color(0xFF223A0D),
  ],
  'colombia__banco_av_villas': [
    Color(0xFF0D6EFD),
    Color(0xFF009CD9),
    Color(0xFF063374),
  ],
  'colombia__banco_de_bogot': [
    Color(0xFF80ACFF),
    Color(0xFF0B5FFF),
    Color(0xFF062C74),
  ],
  'colombia__banco_de_occidente': [
    Color(0xFF80ACFF),
    Color(0xFF0B5FFF),
    Color(0xFF073180),
  ],
  'colombia__banco_popular': [
    Color(0xFF27C112),
    Color(0xFF105163),
    Color(0xFF082F39),
  ],
  'colombia__bancolombia': [
    Color(0xFF003344),
    Color(0xFF00C389),
    Color(0xFF01141B),
  ],
  'colombia__bbva_colombia': [
    Color(0xFF070E46),
    Color(0xFF85C8FF),
    Color(0xFF030727),
  ],
  'colombia__davivienda': [
    Color(0xFF007BFF),
    Color(0xFFDC3545),
    Color(0xFF600E16),
  ],
  'colombia__nequi': [
    Color(0xFF200020),
    Color(0xFFDA0081),
    Color(0xFF220222),
  ],
  'colombia__davibank': [
    Color(0xFFED0722),
    Color(0xFFC4182B),
    Color(0xFF4A0711),
  ],
  'czech_republic__air_bank': [
    Color(0xFF99CC33),
    Color(0xFF1E3300),
    Color(0xFF101B01),
  ],
  'czech_republic__creditas': [
    Color(0xFF113A7E),
    Color(0xFFD7142C),
    Color(0xFF05132B),
  ],
  'czech_republic__esk_spo_itelna': [
    Color(0xFF00497B),
    Color(0xFFD0021B),
    Color(0xFF021D2E),
  ],
  'czech_republic__fio_banka': [
    Color(0xFF00458A),
    Color(0xFF8FBE00),
    Color(0xFF031F3A),
  ],
  'czech_republic__komer_n_banka': [
    Color(0xFFE00000),
    Color(0xFF0052B4),
    Color(0xFF031E3F),
  ],
  'czech_republic__mbank_cz': [
    Color(0xFF0077BD),
    Color(0xFFE41E0A),
    Color(0xFF06456A),
  ],
  'czech_republic__moneta': [
    Color(0xFF007BFF),
    Color(0xFFDC3545),
    Color(0xFF6A1019),
  ],
  'czech_republic__raiffeisenbank_cz': [
    Color(0xFFFEE600),
    Color(0xFF00997D),
    Color(0xFF044F42),
  ],
  'czech_republic__sob': [
    Color(0xFF0099CC),
    Color(0xFF003366),
    Color(0xFF032342),
  ],
  'czech_republic__unicredit_bank_cr': [
    Color(0xFF337AB7),
    Color(0xFF333333),
    Color(0xFF2B1A1A),
  ],
  'denmark__danske_bank': [
    Color(0xFF003778),
    Color(0xFF222299),
    Color(0xFF0F0F4B),
  ],
  'denmark__jyske_bank': [
    Color(0xFFC6570C),
    Color(0xFF8B0047),
    Color(0xFF440425),
  ],
  'denmark__lunar': [
    Color(0xFFC63A0C),
    Color(0xFF8B0035),
    Color(0xFF4E0420),
  ],
  'denmark__nykredit': [
    Color(0xFF07094A),
    Color(0xFF0F1E82),
    Color(0xFF02031B),
  ],
  'denmark__ringkj_bing_landbobank': [
    Color(0xFFFF6200),
    Color(0xFF07174A),
    Color(0xFF02081B),
  ],
  'denmark__spar_nord': [
    Color(0xFF07094A),
    Color(0xFF0F1E82),
    Color(0xFF03042E),
  ],
  'denmark__sparekassen_kronjylland': [
    Color(0xFF5E5E34),
    Color(0xFF990B13),
    Color(0xFF540409),
  ],
  'denmark__sydbank': [
    Color(0xFFC6240C),
    Color(0xFF8B0027),
    Color(0xFF360311),
  ],
  'egypt__aaib': [
    Color(0xFFC8A900),
    Color(0xFF133120),
    Color(0xFF0B1F14),
  ],
  'egypt__bank_of_alexandria': [
    Color(0xFFEA600E),
    Color(0xFFFFF000),
    Color(0xFF742F06),
  ],
  'egypt__banque_du_caire': [
    Color(0xFFF68B1F),
    Color(0xFF316DA2),
    Color(0xFF1A3C5B),
  ],
  'egypt__banque_misr': [
    Color(0xFF871E35),
    Color(0xFF007BFF),
    Color(0xFF310A12),
  ],
  'egypt__cib_egypt': [
    Color(0xFFCE1611),
    Color(0xFF111111),
    Color(0xFF110B0B),
  ],
  'egypt__credit_agricole_egypt': [
    Color(0xFF579AF6),
    Color(0xFF428BCA),
    Color(0xFF194061),
  ],
  'egypt__hsbc_egypt': [
    Color(0xFFDB0011),
    Color(0xFF4A4A4A),
    Color(0xFF210C0F),
  ],
  'egypt__faisal_islamic_bank': [
    Color(0xFFFFFF00),
    Color(0xFF003C15),
    Color(0xFF022A10),
  ],
  'egypt__housing_and_development_bank': [
    Color(0xFF3E7A33),
    Color(0xFF007BFF),
    Color(0xFF162D12),
  ],
  'egypt__national_bank_of_egypt': [
    Color(0xFF03A84E),
    Color(0xFF006643),
    Color(0xFF011B12),
  ],
  'egypt__qnb_alahli': [
    Color(0xFFCE4811),
    Color(0xFF111111),
    Color(0xFF110B0B),
  ],
  'finland__aktia': [
    Color(0xFF00EB64),
    Color(0xFF00B3FF),
    Color(0xFF065374),
  ],
  'finland__danske_bank_finland': [
    Color(0xFF222288),
    Color(0xFF003778),
    Color(0xFF11114B),
  ],
  'finland__handelsbanken_finland': [
    Color(0xFF005FA5),
    Color(0xFF043B62),
    Color(0xFF021625),
  ],
  'finland__landsbanken': [
    Color(0xFF003280),
    Color(0xFF00B3EF),
    Color(0xFF031B3F),
  ],
  'finland__nordea_finland': [
    Color(0xFF00005E),
    Color(0xFFDCEDFF),
    Color(0xFF030335),
  ],
  'finland__omasp': [
    Color(0xFF1DCA7A),
    Color(0xFF00BBFF),
    Color(0xFF065774),
  ],
  'finland__op': [
    Color(0xFFEE5A00),
    Color(0xFFCD212E),
    Color(0xFF5B0D13),
  ],
  'finland__pop_bank': [
    Color(0xFF5D85F4),
    Color(0xFF652B8E),
    Color(0xFF250F35),
  ],
  'finland__s_bank': [
    Color(0xFF004628),
    Color(0xFF00AA46),
    Color(0xFF022516),
  ],
  'finland__savings_banks_group': [
    Color(0xFF222288),
    Color(0xFF224466),
    Color(0xFF12124F),
  ],
  'france__bnp_paribas': [
    Color(0xFF00915A),
    Color(0xFF00A76D),
    Color(0xFF03422A),
  ],
  'france__boursorama_banque': [
    Color(0xFF009DE0),
    Color(0xFF003883),
    Color(0xFF04244F),
  ],
  'france__cic': [
    Color(0xFF0F228B),
    Color(0xFF038189),
    Color(0xFF040B31),
  ],
  'france__cr_dit_agricole': [
    Color(0xFF003344),
    Color(0xFF007461),
    Color(0xFF032632),
  ],
  'france__cr_dit_mutuel': [
    Color(0xFF0058A8),
    Color(0xFF4170A9),
    Color(0xFF031F39),
  ],
  'france__groupe_bpce': [
    Color(0xFF581D74),
    Color(0xFF333333),
    Color(0xFF221515),
  ],
  'france__hello_bank': [
    Color(0xFF073145),
    Color(0xFF72EAFE),
    Color(0xFF042230),
  ],
  'france__la_banque_postale': [
    Color(0xFF003DA5),
    Color(0xFF003E60),
    Color(0xFF021A27),
  ],
  'france__lcl': [
    Color(0xFFF44336),
    Color(0xFFFFD740),
    Color(0xFF740E06),
  ],
  'france__soci_t_g_n_rale': [
    Color(0xFFF05B6F),
    Color(0xFF010035),
    Color(0xFF02021D),
  ],
  'germany__commerzbank': [
    Color(0xFFFFD700),
    Color(0xFF002E3C),
    Color(0xFF02212A),
  ],
  'germany__deutsche_bank': [
    Color(0xFF0550D1),
    Color(0xFF1E2A78),
    Color(0xFF0A0F2E),
  ],
  'germany__dkb': [
    Color(0xFF111111),
    Color(0xFFFFBD00),
    Color(0xFF170E0E),
  ],
  'germany__dz_bank': [
    Color(0xFFF08200),
    Color(0xFFFFCC99),
    Color(0xFF5A3305),
  ],
  'germany__ing_diba': [
    Color(0xFFFF6200),
    Color(0xFF07174A),
    Color(0xFF020920),
  ],
  'germany__kfw': [
    Color(0xFF005A8C),
    Color(0xFF54B3E2),
    Color(0xFF032A40),
  ],
  'germany__lbbw': [
    Color(0xFF123250),
    Color(0xFF37C391),
    Color(0xFF050E17),
  ],
  'germany__n26': [
    Color(0xFFA8DED8),
    Color(0xFFC89D58),
    Color(0xFF5E451D),
  ],
  'germany__postbank': [
    Color(0xFF0A3478),
    Color(0xFFFFCC00),
    Color(0xFF031531),
  ],
  'germany__targobank': [
    Color(0xFF002F5F),
    Color(0xFF26CAFF),
    Color(0xFF03213F),
  ],
  'greece__aegean_baltic_bank': [
    Color(0xFF100DAF),
    Color(0xFF00717A),
    Color(0xFF07055F),
  ],
  'greece__alpha_bank': [
    Color(0xFF0D3AAF),
    Color(0xFF00527A),
    Color(0xFF052064),
  ],
  'greece__crediabank': [
    Color(0xFF003C64),
    Color(0xFFE85B2A),
    Color(0xFF071B2F),
  ],
  'greece__chania_bank': [
    Color(0xFF003B05),
    Color(0xFFEF6E2D),
    Color(0xFF011B04),
  ],
  'greece__eurobank': [
    Color(0xFF0D0DAF),
    Color(0xFF006F7A),
    Color(0xFF060669),
  ],
  'greece__national_bank_of_greece': [
    Color(0xFF003C49),
    Color(0xFF1299A2),
    Color(0xFF02242B),
  ],
  'greece__optima_bank': [
    Color(0xFF0D46AF),
    Color(0xFF004B7A),
    Color(0xFF032338),
  ],
  'greece__piraeus_bank': [
    Color(0xFF00B2FF),
    Color(0xFF002F30),
    Color(0xFF022424),
  ],
  'greece__viva_wallet': [
    Color(0xFF41B5FF),
    Color(0xFFA0A8BA),
    Color(0xFF2F384C),
  ],
  'hungary__cetelem_hungary': [
    Color(0xFF007E84),
    Color(0xFFCD2A90),
    Color(0xFF033E41),
  ],
  'hungary__cib_bank': [
    Color(0xFF0B4A35),
    Color(0xFF262626),
    Color(0xFF110B0B),
  ],
  'hungary__erste_bank_hungary': [
    Color(0xFF0B1F42),
    Color(0xFF2870ED),
    Color(0xFF040B19),
  ],
  'hungary__gr_nit_bank': [
    Color(0xFF695FFF),
    Color(0xFF04041E),
    Color(0xFF030319),
  ],
  'hungary__k_and_h_bank': [
    Color(0xFF008462),
    Color(0xFFCD2A65),
    Color(0xFF5C112C),
  ],
  'hungary__magnet_bank': [
    Color(0xFF5C812E),
    Color(0xFFB4E378),
    Color(0xFF273713),
  ],
  'hungary__mbh_bank': [
    Color(0xFF8F1C6B),
    Color(0xFFD34141),
    Color(0xFF390A2A),
  ],
  'hungary__otp_bank': [
    Color(0xFF52AE30),
    Color(0xFFFF435A),
    Color(0xFF740614),
  ],
  'hungary__raiffeisen_hungary': [
    Color(0xFF007BFF),
    Color(0xFFFECA00),
    Color(0xFF063B74),
  ],
  'hungary__unicredit_hungary': [
    Color(0xFF337AB7),
    Color(0xFF333333),
    Color(0xFF1B1111),
  ],
  'indonesia__bank_danamon': [
    Color(0xFFE84E15),
    Color(0xFF0D6EFD),
    Color(0xFF052C66),
  ],
  'indonesia__bank_mandiri': [
    Color(0xFFE72000),
    Color(0xFFB00040),
    Color(0xFF5A0524),
  ],
  'indonesia__bank_syariah_indonesia': [
    Color(0xFFE70100),
    Color(0xFFB0002C),
    Color(0xFF5A051A),
  ],
  'indonesia__bank_tabungan_negara': [
    Color(0xFF0050A4),
    Color(0xFFFF8A00),
    Color(0xFF00376F),
  ],
  'indonesia__bca': [
    Color(0xFF1473E6),
    Color(0xFF0066AE),
    Color(0xFF05395E),
  ],
  'indonesia__bni': [
    Color(0xFFE72B00),
    Color(0xFFB00047),
    Color(0xFF64052B),
  ],
  'indonesia__bri': [
    Color(0xFFE72E00),
    Color(0xFFB00049),
    Color(0xFF4B0422),
  ],
  'indonesia__cimb_niaga': [
    Color(0xFF0D6EFD),
    Color(0xFFEC2428),
    Color(0xFF063170),
  ],
  'indonesia__ocbc_nisp': [
    Color(0xFFE31B23),
    Color(0xFF111111),
    Color(0xFF110B0B),
  ],
  'indonesia__permatabank': [
    Color(0xFFE75400),
    Color(0xFFB00062),
    Color(0xFF5F0537),
  ],
  'ireland__aib': [
    Color(0xFF7F2B7B),
    Color(0xFF00856A),
    Color(0xFF321031),
  ],
  'ireland__an_post_money': [
    Color(0xFF169B84),
    Color(0xFFFF5E3E),
    Color(0xFF0A5548),
  ],
  'ireland__avant_money': [
    Color(0xFF169B99),
    Color(0xFFFF433E),
    Color(0xFF740906),
  ],
  'ireland__bank_of_ireland': [
    Color(0xFF0000FF),
    Color(0xFF000066),
    Color(0xFF01011B),
  ],
  'ireland__bunq_ireland': [
    Color(0xFF0080FF),
    Color(0xFFFF00AA),
    Color(0xFF063D74),
  ],
  'ireland__credit_union': [
    Color(0xFF017597),
    Color(0xFF19B6BD),
    Color(0xFF033340),
  ],
  'ireland__ebs': [
    Color(0xFFBB0036),
    Color(0xFF357541),
    Color(0xFF5F051F),
  ],
  'ireland__n26_ireland': [
    Color(0xFF111111),
    Color(0xFF48AC98),
    Color(0xFF140C0C),
  ],
  'ireland__permanent_tsb': [
    Color(0xFF16909B),
    Color(0xFFFF3E49),
    Color(0xFF0A4F55),
  ],
  'ireland__revolut_ireland': [
    Color(0xFF111111),
    Color(0xFF0075EB),
    Color(0xFF110B0B),
  ],
  'israel__bank_hapoalim': [
    Color(0xFF002FB8),
    Color(0xFF00B8EF),
    Color(0xFF04164A),
  ],
  'israel__bank_leumi': [
    Color(0xFF0D54D8),
    Color(0xFFFFFA90),
    Color(0xFF062A6D),
  ],
  'israel__bank_massad': [
    Color(0xFF006A45),
    Color(0xFF5DBB63),
    Color(0xFF083C2A),
  ],
  'israel__bank_of_jerusalem': [
    Color(0xFF12192E),
    Color(0xFF2C4284),
    Color(0xFF080B14),
  ],
  'israel__bank_yahav': [
    Color(0xFF4CB245),
    Color(0xFF2D5998),
    Color(0xFF122642),
  ],
  'israel__discount_bank': [
    Color(0xFF36B455),
    Color(0xFF68C950),
    Color(0xFF1A5C2A),
  ],
  'israel__esh_bank': [
    Color(0xFF111827),
    Color(0xFF7C3AED),
    Color(0xFF2563EB),
  ],
  'israel__fibi': [
    Color(0xFF264769),
    Color(0xFF3C7FC3),
    Color(0xFF152A3F),
  ],
  'israel__mercantile': [
    Color(0xFF36B455),
    Color(0xFF00A661),
    Color(0xFF033822),
  ],
  'israel__mizrahi_tefahot': [
    Color(0xFFF87D28),
    Color(0xFF3D444B),
    Color(0xFF1F2832),
  ],
  'israel__one_zero': [
    Color(0xFFAAF23D),
    Color(0xFF25D366),
    Color(0xFF0F632E),
  ],
  'israel__pepper': [
    Color(0xFFFF6900),
    Color(0xFF0693E3),
    Color(0xFF064C74),
  ],
  'italy__banca_mediolanum': [
    Color(0xFF192D6E),
    Color(0xFF1E96D7),
    Color(0xFF0D183E),
  ],
  'italy__banco_bpm': [
    Color(0xFF042F5F),
    Color(0xFF008066),
    Color(0xFF020F1F),
  ],
  'italy__bnl': [
    Color(0xFF1B4437),
    Color(0xFFAFF452),
    Color(0xFF081410),
  ],
  'italy__bper_banca': [
    Color(0xFF005157),
    Color(0xFF65B6F0),
    Color(0xFF022123),
  ],
  'italy__credem': [
    Color(0xFF20623B),
    Color(0xFF0D6EFD),
    Color(0xFF0C2818),
  ],
  'italy__finecobank': [
    Color(0xFFFDC82F),
    Color(0xFF00549F),
    Color(0xFF042849),
  ],
  'italy__intesa_sanpaolo': [
    Color(0xFF258900),
    Color(0xFFFA9600),
    Color(0xFF164804),
  ],
  'italy__mediobanca': [
    Color(0xFF003366),
    Color(0xFFE8C77C),
    Color(0xFF010E1B),
  ],
  'italy__monte_dei_paschi_di_siena': [
    Color(0xFF99042F),
    Color(0xFFF0AD4E),
    Color(0xFF4C0419),
  ],
  'italy__unicredit': [
    Color(0xFF00AFD0),
    Color(0xFFD73928),
    Color(0xFF651910),
  ],
  'japan__aozora_bank': [
    Color(0xFF05489B),
    Color(0xFF1B7CF5),
    Color(0xFF052C5C),
  ],
  'japan__japan_post_bank': [
    Color(0xFF009900),
    Color(0xFFFF0000),
    Color(0xFF740606),
  ],
  'japan__mizuho_bank': [
    Color(0xFFBC0026),
    Color(0xFF111111),
    Color(0xFF110B0B),
  ],
  'japan__mufg_bank': [
    Color(0xFFE60000),
    Color(0xFF333333),
    Color(0xFF1B1111),
  ],
  'japan__rakuten_bank': [
    Color(0xFFBF0000),
    Color(0xFFFF1212),
    Color(0xFF490404),
  ],
  'japan__resona_bank': [
    Color(0xFFE4002B),
    Color(0xFF111111),
    Color(0xFF110B0B),
  ],
  'japan__shinsei_bank': [
    Color(0xFFBC3200),
    Color(0xFF111111),
    Color(0xFF110B0B),
  ],
  'japan__smbc': [
    Color(0xFF004831),
    Color(0xFFC4D700),
    Color(0xFF033424),
  ],
  'japan__sony_bank': [
    Color(0xFFBC0012),
    Color(0xFF111111),
    Color(0xFF110B0B),
  ],
  'japan__sumitomo_mitsui_trust': [
    Color(0xFF006680),
    Color(0xFFA3BCC6),
    Color(0xFF043B49),
  ],
  'kenya__absa_kenya': [
    Color(0xFFFA551E),
    Color(0xFFEB3158),
    Color(0xFF6C081D),
  ],
  'kenya__co_operative_bank': [
    Color(0xFF323A45),
    Color(0xFF22B339),
    Color(0xFF12171D),
  ],
  'kenya__diamond_trust_bank': [
    Color(0xFF00660B),
    Color(0xFFBB0012),
    Color(0xFF022005),
  ],
  'kenya__equity_bank': [
    Color(0xFFFF6200),
    Color(0xFF07174A),
    Color(0xFF040F33),
  ],
  'kenya__family_bank': [
    Color(0xFF007BFF),
    Color(0xFF364AA7),
    Color(0xFF17214E),
  ],
  'kenya__i_and_m_bank': [
    Color(0xFFE30613),
    Color(0xFFF6A800),
    Color(0xFF570509),
  ],
  'kenya__kcb_bank': [
    Color(0xFF006630),
    Color(0xFFBB004B),
    Color(0xFF033D1E),
  ],
  'kenya__ncba_bank': [
    Color(0xFF334AFF),
    Color(0xFF003388),
    Color(0xFF042151),
  ],
  'kenya__stanbic_bank_ke': [
    Color(0xFF0062E1),
    Color(0xFF0A2240),
    Color(0xFF071A31),
  ],
  'kenya__standard_chartered_ke': [
    Color(0xFF008738),
    Color(0xFF0C77B9),
    Color(0xFF043655),
  ],
  'malaysia__affin_bank': [
    Color(0xFF0021A0),
    Color(0xFFCC0014),
    Color(0xFF030E3A),
  ],
  'malaysia__alliance_bank': [
    Color(0xFFB52025),
    Color(0xFF002659),
    Color(0xFF021329),
  ],
  'malaysia__ambank': [
    Color(0xFFFF0009),
    Color(0xFFFFF100),
    Color(0xFF660509),
  ],
  'malaysia__bank_islam': [
    Color(0xFF007BFF),
    Color(0xFFDC3545),
    Color(0xFF650F17),
  ],
  'malaysia__bank_of_china_malaysia': [
    Color(0xFFE60012),
    Color(0xFFB81C2B),
    Color(0xFF260004),
  ],
  'malaysia__bank_rakyat': [
    Color(0xFF84BA3F),
    Color(0xFF0071A5),
    Color(0xFF032E42),
  ],
  'malaysia__cimb': [
    Color(0xFFBA0019),
    Color(0xFF780000),
    Color(0xFF280202),
  ],
  'malaysia__hong_leong_bank': [
    Color(0xFF002D62),
    Color(0xFFFF0000),
    Color(0xFF020F1E),
  ],
  'malaysia__hsbc_malaysia': [
    Color(0xFFDB0011),
    Color(0xFF2F2F2F),
    Color(0xFF1D1010),
  ],
  'malaysia__maybank': [
    Color(0xFFFFCC00),
    Color(0xFF111111),
    Color(0xFF110B0B),
  ],
  'malaysia__ocbc_malaysia': [
    Color(0xFFE31B23),
    Color(0xFF1F1F1F),
    Color(0xFF290B0F),
  ],
  'malaysia__public_bank': [
    Color(0xFFFF0000),
    Color(0xFF111827),
    Color(0xFF0C121E),
  ],
  'malaysia__rhb_bank': [
    Color(0xFF0067B1),
    Color(0xFFEF3E42),
    Color(0xFF053C64),
  ],
  'malaysia__standard_chartered_malaysia': [
    Color(0xFF00A3E0),
    Color(0xFF6DB33F),
    Color(0xFF053B4A),
  ],
  'malaysia__uob_malaysia': [
    Color(0xFFD71920),
    Color(0xFF003B70),
    Color(0xFF061D36),
  ],
  'mexico__banco_azteca': [
    Color(0xFF17A54D),
    Color(0xFFFA6262),
    Color(0xFF0B5F2B),
  ],
  'mexico__bancoppel': [
    Color(0xFF005B63),
    Color(0xFFCE116B),
    Color(0xFF021C1F),
  ],
  'mexico__banorte': [
    Color(0xFF006263),
    Color(0xFFCE115F),
    Color(0xFF033B3C),
  ],
  'mexico__bbva_m_xico': [
    Color(0xFF070E46),
    Color(0xFF85C8FF),
    Color(0xFF02051A),
  ],
  'mexico__citibanamex': [
    Color(0xFFFF1B44),
    Color(0xFF003746),
    Color(0xFF01161B),
  ],
  'mexico__hsbc_m_xico': [
    Color(0xFFDB0011),
    Color(0xFF333333),
    Color(0xFF221515),
  ],
  'mexico__inbursa': [
    Color(0xFF000254),
    Color(0xFF0D6EFD),
    Color(0xFF030435),
  ],
  'mexico__klar': [
    Color(0xFF1C1C1C),
    Color(0xFFD6AE60),
    Color(0xFF110B0B),
  ],
  'mexico__santander_m_xico': [
    Color(0xFFEC0000),
    Color(0xFFFF3B30),
    Color(0xFF580505),
  ],
  'mexico__scotiabank_m_xico': [
    Color(0xFFD81E05),
    Color(0xFF8230DF),
    Color(0xFF3A0E6C),
  ],
  'morocco__al_barid_bank': [
    Color(0xFFC13727),
    Color(0xFF006227),
    Color(0xFF033617),
  ],
  'morocco__attijariwafa_bank': [
    Color(0xFFC14227),
    Color(0xFF006221),
    Color(0xFF022D11),
  ],
  'morocco__bank_of_africa': [
    Color(0xFF003D7C),
    Color(0xFF06BDC7),
    Color(0xFF032242),
  ],
  'morocco__banque_populaire': [
    Color(0xFF0072C6),
    Color(0xFFE67E04),
    Color(0xFF053C64),
  ],
  'morocco__bmci': [
    Color(0xFFCCFFFF),
    Color(0xFFFE7D15),
    Color(0xFF743706),
  ],
  'morocco__cfg_bank': [
    Color(0xFF00A8FF),
    Color(0xFF003388),
    Color(0xFF02112B),
  ],
  'morocco__cih_bank': [
    Color(0xFFC16127),
    Color(0xFF006210),
    Color(0xFF022D09),
  ],
  'morocco__cr_dit_agricole_du_maroc': [
    Color(0xFF007732),
    Color(0xFFE30613),
    Color(0xFF033B1B),
  ],
  'morocco__cr_dit_du_maroc': [
    Color(0xFF262338),
    Color(0xFF0071CE),
    Color(0xFF1A1828),
  ],
  'morocco__soci_t_g_n_rale_maroc': [
    Color(0xFFE60028),
    Color(0xFF111111),
    Color(0xFF110B0B),
  ],
  'netherlands__abn_amro': [
    Color(0xFF00716B),
    Color(0xFF222222),
    Color(0xFF110B0B),
  ],
  'netherlands__asn_bank': [
    Color(0xFF1F7D65),
    Color(0xFFF5A623),
    Color(0xFF114E3E),
  ],
  'netherlands__bunq': [
    Color(0xFF0080FF),
    Color(0xFFFF00AA),
    Color(0xFF074380),
  ],
  'netherlands__ing_group': [
    Color(0xFFFF6200),
    Color(0xFF07174A),
    Color(0xFF030C29),
  ],
  'netherlands__knab': [
    Color(0xFFE4002B),
    Color(0xFF111111),
    Color(0xFF191010),
  ],
  'netherlands__rabobank': [
    Color(0xFFFF8D00),
    Color(0xFF21548B),
    Color(0xFF0D233C),
  ],
  'netherlands__triodos_bank': [
    Color(0xFF3C132E),
    Color(0xFF004B32),
    Color(0xFF2D0D22),
  ],
  'new_zealand__anz_nz': [
    Color(0xFF006BDE),
    Color(0xFF8ADAF9),
    Color(0xFF063B74),
  ],
  'new_zealand__bank_of_china_nz': [
    Color(0xFFE60012),
    Color(0xFF7A0010),
    Color(0xFF250005),
  ],
  'new_zealand__asb': [
    Color(0xFF001F7D),
    Color(0xFFCC1431),
    Color(0xFF031039),
  ],
  'new_zealand__bnz': [
    Color(0xFF00177D),
    Color(0xFFCC143B),
    Color(0xFF040F43),
  ],
  'new_zealand__co_operative_bank': [
    Color(0xFF029F48),
    Color(0xFF8BD5EE),
    Color(0xFF044E25),
  ],
  'new_zealand__heartland_bank': [
    Color(0xFF0D6EFD),
    Color(0xFFFFC107),
    Color(0xFF063374),
  ],
  'new_zealand__kiwibank': [
    Color(0xFF00207D),
    Color(0xFFCC1430),
    Color(0xFF020E2F),
  ],
  'new_zealand__rabobank_nz': [
    Color(0xFF1D007D),
    Color(0xFFCC147D),
    Color(0xFF130448),
  ],
  'new_zealand__sbs_bank': [
    Color(0xFFFF6801),
    Color(0xFFFFE5C8),
    Color(0xFF743306),
  ],
  'new_zealand__tsb_bank': [
    Color(0xFF07007D),
    Color(0xFFCC1461),
    Color(0xFF08044C),
  ],
  'new_zealand__westpac_nz': [
    Color(0xFFDA1710),
    Color(0xFFE31B23),
    Color(0xFF740A06),
  ],
  'nigeria__access_bank': [
    Color(0xFFEE7E01),
    Color(0xFF014086),
    Color(0xFF042447),
  ],
  'nigeria__fcmb': [
    Color(0xFF007087),
    Color(0xFF111111),
    Color(0xFF110B0B),
  ],
  'nigeria__fidelity_bank': [
    Color(0xFF002082),
    Color(0xFF0866FF),
    Color(0xFF03113B),
  ],
  'nigeria__first_bank': [
    Color(0xFF003B65),
    Color(0xFFF0BD2D),
    Color(0xFF021C2E),
  ],
  'nigeria__gtco': [
    Color(0xFFDD4F05),
    Color(0xFF424A52),
    Color(0xFF1B242C),
  ],
  'nigeria__stanbic_ibtc': [
    Color(0xFF0062E1),
    Color(0xFF0A2240),
    Color(0xFF030D19),
  ],
  'nigeria__sterling_bank': [
    Color(0xFF569FF7),
    Color(0xFF6EC1E4),
    Color(0xFF063874),
  ],
  'nigeria__uba': [
    Color(0xFF006E87),
    Color(0xFF111111),
    Color(0xFF110B0B),
  ],
  'nigeria__union_bank': [
    Color(0xFF007487),
    Color(0xFF111111),
    Color(0xFF110B0B),
  ],
  'nigeria__zenith_bank': [
    Color(0xFF007487),
    Color(0xFF111111),
    Color(0xFF191010),
  ],
  'norway__dnb': [
    Color(0xFF00343E),
    Color(0xFFA5E1D2),
    Color(0xFF01171B),
  ],
  'norway__eika': [
    Color(0xFF006A5B),
    Color(0xFF07409B),
    Color(0xFF041D45),
  ],
  'norway__klp': [
    Color(0xFF3FA7FF),
    Color(0xFFE41B65),
    Color(0xFF62092A),
  ],
  'norway__nordea_norway': [
    Color(0xFF00005E),
    Color(0xFFDCEDFF),
    Color(0xFF020226),
  ],
  'norway__obos_banken': [
    Color(0xFF0047BA),
    Color(0xFFC0385D),
    Color(0xFF052B68),
  ],
  'norway__sbanken': [
    Color(0xFF222163),
    Color(0xFF18172A),
    Color(0xFF11101E),
  ],
  'norway__sparebank_1': [
    Color(0xFFBA0C29),
    Color(0xFF00235B),
    Color(0xFF021129),
  ],
  'norway__sparebanken_s_r': [
    Color(0xFF231464),
    Color(0xFFD82A07),
    Color(0xFF100931),
  ],
  'norway__sparebanken_vest': [
    Color(0xFFFF4238),
    Color(0xFF222F49),
    Color(0xFF101624),
  ],
  'norway__storebrand': [
    Color(0xFF310502),
    Color(0xFF0D6EFD),
    Color(0xFF1B0301),
  ],
  'oman__ahlibank_oman': [
    Color(0xFF00846C),
    Color(0xFFC81067),
    Color(0xFF5D052F),
  ],
  'oman__bank_dhofar': [
    Color(0xFF61B214),
    Color(0xFF005F75),
    Color(0xFF03343F),
  ],
  'oman__bank_muscat': [
    Color(0xFFEE3423),
    Color(0xFF0072C6),
    Color(0xFF05365A),
  ],
  'oman__bank_nizwa': [
    Color(0xFF6E2585),
    Color(0xFFFFCB05),
    Color(0xFF32103D),
  ],
  'oman__bank_of_baroda': [
    Color(0xFFF26522),
    Color(0xFF007BFF),
    Color(0xFF063B74),
  ],
  'oman__first_abu_dhabi_bank': [
    Color(0xFF003DA6),
    Color(0xFF2A5082),
    Color(0xFF031738),
  ],
  'oman__hbl': [
    Color(0xFF008469),
    Color(0xFFC81063),
    Color(0xFF4F0426),
  ],
  'oman__national_bank_of_oman': [
    Color(0xFF0A52D4),
    Color(0xFF900D10),
    Color(0xFF340305),
  ],
  'oman__oman_arab_bank': [
    Color(0xFF1863DC),
    Color(0xFF0056A7),
    Color(0xFF031F39),
  ],
  'oman__qnb_oman': [
    Color(0xFF008442),
    Color(0xFFC81034),
    Color(0xFF590515),
  ],
  'oman__sohar_international': [
    Color(0xFFFF6B00),
    Color(0xFF893D06),
    Color(0xFF502404),
  ],
  'oman__standard_chartered_oman': [
    Color(0xFF0473EA),
    Color(0xFF061D33),
    Color(0xFF03111E),
  ],
  'oman__state_bank_of_india': [
    Color(0xFF1557A8),
    Color(0xFF2A2075),
    Color(0xFF161041),
  ],
  'pakistan__allied_bank': [
    Color(0xFF01411C),
    Color(0xFF009E49),
    Color(0xFF022812),
  ],
  'pakistan__askari_bank': [
    Color(0xFF014120),
    Color(0xFF009E40),
    Color(0xFF021E0F),
  ],
  'pakistan__bank_alfalah': [
    Color(0xFF014131),
    Color(0xFF009E1D),
    Color(0xFF011B14),
  ],
  'pakistan__bank_of_punjab': [
    Color(0xFF014137),
    Color(0xFF009E10),
    Color(0xFF011B17),
  ],
  'pakistan__habibmetro': [
    Color(0xFF01413E),
    Color(0xFF009E01),
    Color(0xFF022321),
  ],
  'pakistan__hbl': [
    Color(0xFF014139),
    Color(0xFF009E0C),
    Color(0xFF011B17),
  ],
  'pakistan__mcb_bank': [
    Color(0xFF01413E),
    Color(0xFF009E02),
    Color(0xFF03312F),
  ],
  'pakistan__meezan_bank': [
    Color(0xFF014121),
    Color(0xFF009E3D),
    Color(0xFF011B0E),
  ],
  'pakistan__national_bank_of_pakistan': [
    Color(0xFF014140),
    Color(0xFF049E00),
    Color(0xFF011B1A),
  ],
  'pakistan__ubl': [
    Color(0xFF01413D),
    Color(0xFF009E03),
    Color(0xFF021E1C),
  ],
  'peru__banbif': [
    Color(0xFF20A6FF),
    Color(0xFF924FF5),
    Color(0xFF330674),
  ],
  'peru__banco_de_la_naci_n': [
    Color(0xFFE11E00),
    Color(0xFFFFD147),
    Color(0xFF741506),
  ],
  'peru__banco_falabella_per': [
    Color(0xFF347B23),
    Color(0xFFBDD004),
    Color(0xFF1F4C14),
  ],
  'peru__banco_pichincha': [
    Color(0xFFD93610),
    Color(0xFF8A1555),
    Color(0xFF360721),
  ],
  'peru__banco_ripley': [
    Color(0xFFD92D10),
    Color(0xFF8A1550),
    Color(0xFF4D0A2C),
  ],
  'peru__bbva_per': [
    Color(0xFF004481),
    Color(0xFF1464A5),
    Color(0xFF021627),
  ],
  'peru__bcp': [
    Color(0xFFD93810),
    Color(0xFF8A1555),
    Color(0xFF510A31),
  ],
  'peru__interbank': [
    Color(0xFFD96B10),
    Color(0xFF8A156F),
    Color(0xFF560B44),
  ],
  'peru__mibanco': [
    Color(0xFFF14649),
    Color(0xFF224433),
    Color(0xFF102118),
  ],
  'peru__scotiabank_per': [
    Color(0xFFD81E05),
    Color(0xFF8230DF),
    Color(0xFF400F77),
  ],
  'philippines__bdo_unibank': [
    Color(0xFF1100A8),
    Color(0xFFCE116C),
    Color(0xFF0E055B),
  ],
  'philippines__bpi': [
    Color(0xFFB11116),
    Color(0xFFFFDC52),
    Color(0xFF4D0608),
  ],
  'philippines__china_bank': [
    Color(0xFF0D6EFD),
    Color(0xFFDC3545),
    Color(0xFF6A1019),
  ],
  'philippines__eastwest_bank': [
    Color(0xFF151515),
    Color(0xFF5B3F3F),
    Color(0xFF110B0B),
  ],
  'philippines__hsbc_philippines': [
    Color(0xFFDB0011),
    Color(0xFF404040),
    Color(0xFF260A0D),
  ],
  'philippines__landbank': [
    Color(0xFF6BBF59),
    Color(0xFF3399FF),
    Color(0xFF063D74),
  ],
  'philippines__metrobank': [
    Color(0xFF059ED8),
    Color(0xFF001A88),
    Color(0xFF030C34),
  ],
  'philippines__pnb': [
    Color(0xFF000AA8),
    Color(0xFFCE1152),
    Color(0xFF050A5B),
  ],
  'philippines__rcbc': [
    Color(0xFF3783D9),
    Color(0xFF002F6C),
    Color(0xFF031E40),
  ],
  'philippines__security_bank': [
    Color(0xFF000CA8),
    Color(0xFFCE1150),
    Color(0xFF040843),
  ],
  'philippines__unionbank': [
    Color(0xFF2400A8),
    Color(0xFFCE117F),
    Color(0xFF14044D),
  ],
  'poland__alior_bank': [
    Color(0xFF79003C),
    Color(0xFFFFC326),
    Color(0xFF460424),
  ],
  'poland__bank_millennium': [
    Color(0xFFBD004F),
    Color(0xFFF55050),
    Color(0xFF5B0529),
  ],
  'poland__bank_pekao': [
    Color(0xFFD91918),
    Color(0xFFB2A100),
    Color(0xFF580808),
  ],
  'poland__bnp_paribas_poland': [
    Color(0xFF00834F),
    Color(0xFF0D6EFD),
    Color(0xFF034128),
  ],
  'poland__citi_handlowy': [
    Color(0xFF056DAE),
    Color(0xFF255BE3),
    Color(0xFF0C286F),
  ],
  'poland__credit_agricole_poland': [
    Color(0xFF006B3F),
    Color(0xFFB5D334),
    Color(0xFF022A19),
  ],
  'poland__ing_bank_l_ski': [
    Color(0xFFFF6200),
    Color(0xFF07174A),
    Color(0xFF02081A),
  ],
  'poland__mbank': [
    Color(0xFF0065B1),
    Color(0xFF00FF00),
    Color(0xFF053B64),
  ],
  'poland__pko_bank_polski': [
    Color(0xFF003574),
    Color(0xFFCC7A09),
    Color(0xFF031E3F),
  ],
  'poland__santander_bank_polska': [
    Color(0xFFEC0000),
    Color(0xFFFF3B30),
    Color(0xFF800707),
  ],
  'poland__velobank': [
    Color(0xFF00B140),
    Color(0xFF00608A),
    Color(0xFF032D3F),
  ],
  'portugal__activobank': [
    Color(0xFF00B9FF),
    Color(0xFF002436),
    Color(0xFF01121B),
  ],
  'portugal__banco_bpi': [
    Color(0xFFFF6600),
    Color(0xFF0077BC),
    Color(0xFF053856),
  ],
  'portugal__banco_ctt': [
    Color(0xFFEB3436),
    Color(0xFF0089EC),
    Color(0xFF72080A),
  ],
  'portugal__bankinter_portugal': [
    Color(0xFF006635),
    Color(0xFFFF0071),
    Color(0xFF022514),
  ],
  'portugal__caixa_geral_de_dep_sitos': [
    Color(0xFF0071CE),
    Color(0xFF0A243E),
    Color(0xFF030E19),
  ],
  'portugal__cr_dito_agr_cola': [
    Color(0xFF00A661),
    Color(0xFFFF9F1A),
    Color(0xFF033822),
  ],
  'portugal__eurobic': [
    Color(0xFF5B87DA),
    Color(0xFF1DA7EE),
    Color(0xFF153166),
  ],
  'portugal__millennium_bcp': [
    Color(0xFF2E3641),
    Color(0xFFD1005D),
    Color(0xFF1A212B),
  ],
  'portugal__novo_banco': [
    Color(0xFF009F98),
    Color(0xFF007BFF),
    Color(0xFF063B74),
  ],
  'portugal__santander_totta': [
    Color(0xFFEC0000),
    Color(0xFF990000),
    Color(0xFF4F0404),
  ],
  'qatar__ahlibank': [
    Color(0xFF9DC2DD),
    Color(0xFF428FC7),
    Color(0xFF1A4360),
  ],
  'qatar__al_khaliji': [
    Color(0xFF8A1D15),
    Color(0xFF4C1042),
    Color(0xFF250720),
  ],
  'qatar__commercial_bank': [
    Color(0xFF0D6EFD),
    Color(0xFFFFC107),
    Color(0xFF052C66),
  ],
  'qatar__doha_bank': [
    Color(0xFF8A2315),
    Color(0xFF4C1044),
    Color(0xFF360A30),
  ],
  'qatar__hsbc_qatar': [
    Color(0xFFDB0011),
    Color(0xFF525252),
    Color(0xFF220A0D),
  ],
  'qatar__dukhan_bank': [
    Color(0xFF4197CB),
    Color(0xFF24366F),
    Color(0xFF131D3E),
  ],
  'qatar__masraf_al_rayan': [
    Color(0xFF0076A5),
    Color(0xFF06B1D6),
    Color(0xFF032938),
  ],
  'qatar__qatar_first_bank': [
    Color(0xFF226D7A),
    Color(0xFF22B8D1),
    Color(0xFF113C44),
  ],
  'qatar__qatar_islamic_bank': [
    Color(0xFF1A7BB2),
    Color(0xFF32C5FF),
    Color(0xFF0A3853),
  ],
  'qatar__qiib': [
    Color(0xFFCF102D),
    Color(0xFF337AB7),
    Color(0xFF6A0615),
  ],
  'qatar__qnb': [
    Color(0xFF8A3315),
    Color(0xFF4C104B),
    Color(0xFF250725),
  ],
  'qatar__standard_chartered_qatar': [
    Color(0xFF0072CE),
    Color(0xFF6DB33F),
    Color(0xFF032E53),
  ],
  'saudi_arabia__al_rajhi_bank': [
    Color(0xFF221AFB),
    Color(0xFFD80027),
    Color(0xFF0A0674),
  ],
  'saudi_arabia__alinma_bank': [
    Color(0xFF002134),
    Color(0xFF0D6EFD),
    Color(0xFF01111B),
  ],
  'saudi_arabia__arab_national_bank': [
    Color(0xFF0B5FFF),
    Color(0xFF80ACFF),
    Color(0xFF062C74),
  ],
  'saudi_arabia__bank_albilad': [
    Color(0xFFCF202E),
    Color(0xFFF6B333),
    Color(0xFF580B12),
  ],
  'saudi_arabia__banque_saudi_fransi': [
    Color(0xFF006C64),
    Color(0xFF003B19),
    Color(0xFF011B0C),
  ],
  'saudi_arabia__riyad_bank': [
    Color(0xFF0B5FFF),
    Color(0xFF80ACFF),
    Color(0xFF073180),
  ],
  'saudi_arabia__sabb': [
    Color(0xFFDB0011),
    Color(0xFF333333),
    Color(0xFF2B1A1A),
  ],
  'saudi_arabia__saudi_investment_bank': [
    Color(0xFF006C40),
    Color(0xFF003B2A),
    Color(0xFF011B13),
  ],
  'saudi_arabia__saudi_national_bank': [
    Color(0xFF006C4A),
    Color(0xFF003B25),
    Color(0xFF022518),
  ],
  'saudi_arabia__stc_pay': [
    Color(0xFF007BFF),
    Color(0xFF4F008C),
    Color(0xFF250340),
  ],
  'singapore__bank_of_singapore': [
    Color(0xFF0D6EFD),
    Color(0xFFDC3545),
    Color(0xFF75121C),
  ],
  'singapore__bank_of_china_singapore': [
    Color(0xFFE60012),
    Color(0xFF9F0010),
    Color(0xFF210004),
  ],
  'singapore__citibank_sg': [
    Color(0xFF0465A7),
    Color(0xFF255BE3),
    Color(0xFF04304E),
  ],
  'singapore__dbs_bank': [
    Color(0xFFFF3333),
    Color(0xFF2E2E2E),
    Color(0xFF251717),
  ],
  'singapore__gxs_bank': [
    Color(0xFF771FFF),
    Color(0xFFAF89F4),
    Color(0xFF310674),
  ],
  'singapore__hsbc_sg': [
    Color(0xFFDB0011),
    Color(0xFF333333),
    Color(0xFF251616),
  ],
  'singapore__icbc_singapore': [
    Color(0xFFC7000B),
    Color(0xFFFFCC00),
    Color(0xFF5A0308),
  ],
  'singapore__maybank_sg': [
    Color(0xFFFF6200),
    Color(0xFF07174A),
    Color(0xFF040F35),
  ],
  'singapore__ocbc_bank': [
    Color(0xFF007BFF),
    Color(0xFFDC3545),
    Color(0xFF691018),
  ],
  'singapore__standard_chartered_sg': [
    Color(0xFF0473EA),
    Color(0xFF38D200),
    Color(0xFF06376D),
  ],
  'singapore__trust_bank': [
    Color(0xFF009DDC),
    Color(0xFF001B30),
    Color(0xFF01101B),
  ],
  'singapore__uob': [
    Color(0xFFFF6200),
    Color(0xFF07174A),
    Color(0xFF041037),
  ],
  'south_africa__absa': [
    Color(0xFFFA551E),
    Color(0xFFEB3158),
    Color(0xFF72081E),
  ],
  'south_africa__african_bank': [
    Color(0xFF007A5B),
    Color(0xFFFF9F12),
    Color(0xFF022E23),
  ],
  'south_africa__bidvest_bank': [
    Color(0xFF3B82F6),
    Color(0xFF1D4ED8),
    Color(0xFF0C246A),
  ],
  'south_africa__capitec_bank': [
    Color(0xFF007A5D),
    Color(0xFFFF9C12),
    Color(0xFF044636),
  ],
  'south_africa__discovery_bank': [
    Color(0xFF114B8A),
    Color(0xFF00D6FF),
    Color(0xFF051D36),
  ],
  'south_africa__fnb': [
    Color(0xFF009999),
    Color(0xFFFF9900),
    Color(0xFF055959),
  ],
  'south_africa__investec': [
    Color(0xFF005F7A),
    Color(0xFFFF3E12),
    Color(0xFF03303C),
  ],
  'south_africa__nedbank': [
    Color(0xFF00797A),
    Color(0xFFFF6912),
    Color(0xFF044646),
  ],
  'south_africa__standard_bank': [
    Color(0xFF0062E1),
    Color(0xFF0A2240),
    Color(0xFF041324),
  ],
  'south_africa__tymebank': [
    Color(0xFF0D6EFD),
    Color(0xFFFFC107),
    Color(0xFF073880),
  ],
  'south_korea__busan_bank': [
    Color(0xFF0E0078),
    Color(0xFFC60C88),
    Color(0xFF070228),
  ],
  'south_korea__hana_bank': [
    Color(0xFF008485),
    Color(0xFF27B2A5),
    Color(0xFF044B4B),
  ],
  'south_korea__ibk': [
    Color(0xFF0066CC),
    Color(0xFF333333),
    Color(0xFF221515),
  ],
  'south_korea__k_bank': [
    Color(0xFF0561AA),
    Color(0xFF454D5B),
    Color(0xFF1B222C),
  ],
  'south_korea__kakaobank': [
    Color(0xFF007BFF),
    Color(0xFF00D080),
    Color(0xFF063B74),
  ],
  'south_korea__kb_kookmin_bank': [
    Color(0xFFFFCC00),
    Color(0xFFFFF7D9),
    Color(0xFF6B5606),
  ],
  'south_korea__nh_nonghyup_bank': [
    Color(0xFFFF6200),
    Color(0xFF07174A),
    Color(0xFF030B24),
  ],
  'south_korea__shinhan_bank': [
    Color(0xFFD99103),
    Color(0xFF3579D4),
    Color(0xFF133562),
  ],
  'south_korea__toss_bank': [
    Color(0xFF3182F6),
    Color(0xFFF04452),
    Color(0xFF74060F),
  ],
  'south_korea__woori_bank': [
    Color(0xFF0083C8),
    Color(0xFF20509F),
    Color(0xFF0F2A57),
  ],
  'spain__abanca': [
    Color(0xFF333333),
    Color(0xFF5B87DA),
    Color(0xFF1E1313),
  ],
  'spain__banco_sabadell': [
    Color(0xFF006DFF),
    Color(0xFFFC00F4),
    Color(0xFF06336F),
  ],
  'spain__banco_santander': [
    Color(0xFFEC0000),
    Color(0xFF0052B4),
    Color(0xFF042852),
  ],
  'spain__bankinter': [
    Color(0xFFAA3915),
    Color(0xFFF18500),
    Color(0xFF531A08),
  ],
  'spain__bbva': [
    Color(0xFF004481),
    Color(0xFF1464A5),
    Color(0xFF042645),
  ],
  'spain__caixabank': [
    Color(0xFF007EAE),
    Color(0xFF337AB7),
    Color(0xFF04374A),
  ],
  'spain__ibercaja': [
    Color(0xFF0168FF),
    Color(0xFFFF4242),
    Color(0xFF063374),
  ],
  'spain__kutxabank': [
    Color(0xFFAA2515),
    Color(0xFFF1A100),
    Color(0xFF5D1209),
  ],
  'spain__openbank': [
    Color(0xFF002B45),
    Color(0xFFFF0049),
    Color(0xFF01111B),
  ],
  'spain__unicaja_banco': [
    Color(0xFF278600),
    Color(0xFF005265),
    Color(0xFF01161B),
  ],
  'sweden__avanza': [
    Color(0xFF00C281),
    Color(0xFF031D20),
    Color(0xFF02181A),
  ],
  'sweden__handelsbanken': [
    Color(0xFF005FA5),
    Color(0xFF043B62),
    Color(0xFF03253D),
  ],
  'sweden__ica_banken': [
    Color(0xFF0033A7),
    Color(0xFFFE8400),
    Color(0xFF03153E),
  ],
  'sweden__klarna': [
    Color(0xFFD80027),
    Color(0xFF0B051D),
    Color(0xFF090418),
  ],
  'sweden__l_nsf_rs_kringar_bank': [
    Color(0xFF005AA0),
    Color(0xFFC8041E),
    Color(0xFF031F36),
  ],
  'sweden__marginalen_bank': [
    Color(0xFFF79E1B),
    Color(0xFF008458),
    Color(0xFF033726),
  ],
  'sweden__nordea_sweden': [
    Color(0xFF00005E),
    Color(0xFFDCEDFF),
    Color(0xFF030330),
  ],
  'sweden__seb': [
    Color(0xFF41B0EE),
    Color(0xFF007AC7),
    Color(0xFF064369),
  ],
  'sweden__skandiabanken': [
    Color(0xFF000BA7),
    Color(0xFFFE5000),
    Color(0xFF040847),
  ],
  'sweden__swedbank': [
    Color(0xFFF47920),
    Color(0xFFFDB913),
    Color(0xFF6A3006),
  ],
  'switzerland__bcv': [
    Color(0xFF009D4D),
    Color(0xFF569FF7),
    Color(0xFF033E20),
  ],
  'switzerland__julius_baer': [
    Color(0xFF141E55),
    Color(0xFF003399),
    Color(0xFF0A0F2E),
  ],
  'switzerland__lombard_odier': [
    Color(0xFF5796C6),
    Color(0xFF007BFF),
    Color(0xFF063B74),
  ],
  'switzerland__migros_bank': [
    Color(0xFF144B3C),
    Color(0xFFD8051A),
    Color(0xFF0A2920),
  ],
  'switzerland__pictet': [
    Color(0xFF3D3A31),
    Color(0xFF804940),
    Color(0xFF1E1B12),
  ],
  'switzerland__postfinance': [
    Color(0xFF004B5A),
    Color(0xFFD80909),
    Color(0xFF01161B),
  ],
  'switzerland__raiffeisen': [
    Color(0xFF1A1A1A),
    Color(0xFFB90000),
    Color(0xFF110B0B),
  ],
  'switzerland__ubs': [
    Color(0xFFE30613),
    Color(0xFF111111),
    Color(0xFF170E0E),
  ],
  'switzerland__valiant_bank': [
    Color(0xFF007BFF),
    Color(0xFFDC3545),
    Color(0xFF6B1019),
  ],
  'switzerland__zkb': [
    Color(0xFF000078),
    Color(0xFF003CB4),
    Color(0xFF03033C),
  ],
  'thailand__bangkok_bank': [
    Color(0xFF09007D),
    Color(0xFFDA1C49),
    Color(0xFF09044C),
  ],
  'thailand__bank_of_china_thailand': [
    Color(0xFFE60012),
    Color(0xFF8F0012),
    Color(0xFF2D0007),
  ],
  'thailand__cimb_thai': [
    Color(0xFFBA0019),
    Color(0xFF780000),
    Color(0xFF2D0202),
  ],
  'thailand__kasikornbank': [
    Color(0xFF001F7D),
    Color(0xFFDA221C),
    Color(0xFF020C2A),
  ],
  'thailand__kiatnakin_phatra': [
    Color(0xFF001A7D),
    Color(0xFFDA1C1D),
    Color(0xFF041248),
  ],
  'thailand__krungsri': [
    Color(0xFF1F007D),
    Color(0xFFDA1C66),
    Color(0xFF100339),
  ],
  'thailand__krungthai_bank': [
    Color(0xFF17007D),
    Color(0xFFDA1C5C),
    Color(0xFF0E033E),
  ],
  'thailand__scb': [
    Color(0xFF7A58BF),
    Color(0xFF302272),
    Color(0xFF1B1344),
  ],
  'thailand__tisco_bank': [
    Color(0xFF1C007D),
    Color(0xFFDA1C62),
    Color(0xFF0B022A),
  ],
  'thailand__ttb': [
    Color(0xFF0050F0),
    Color(0xFFF68B1F),
    Color(0xFF062B74),
  ],
  'thailand__uob_thailand': [
    Color(0xFFD71920),
    Color(0xFF003B7A),
    Color(0xFF04264B),
  ],
  'turkey__akbank': [
    Color(0xFFDC0005),
    Color(0xFF0072C6),
    Color(0xFF6E0608),
  ],
  'turkey__denizbank': [
    Color(0xFFD11241),
    Color(0xFF0033A0),
    Color(0xFF051F57),
  ],
  'turkey__garanti_bbva': [
    Color(0xFF004481),
    Color(0xFF1464A5),
    Color(0xFF042B4E),
  ],
  'turkey__halkbank': [
    Color(0xFF005697),
    Color(0xFFFF9C27),
    Color(0xFF03233B),
  ],
  'turkey__i_bank': [
    Color(0xFF003A72),
    Color(0xFFEF2D73),
    Color(0xFF02172A),
  ],
  'turkey__kuveyt_t_rk': [
    Color(0xFF16A086),
    Color(0xFF0D6EFD),
    Color(0xFF063374),
  ],
  'turkey__qnb_finansbank': [
    Color(0xFF870052),
    Color(0xFF030E34),
    Color(0xFF01071B),
  ],
  'turkey__vak_fbank': [
    Color(0xFFFDB913),
    Color(0xFF007BFF),
    Color(0xFF063B74),
  ],
  'turkey__yap_kredi': [
    Color(0xFF004990),
    Color(0xFF0CA2F2),
    Color(0xFF02192E),
  ],
  'turkey__ziraat_bank': [
    Color(0xFFE10514),
    Color(0xFF445056),
    Color(0xFF24333A),
  ],
  'uae__abu_dhabi_islamic_bank': [
    Color(0xFF0D6EFD),
    Color(0xFFFFC107),
    Color(0xFF063170),
  ],
  'uae__bank_of_baroda_uae': [
    Color(0xFFFF5F00),
    Color(0xFF003D7C),
    Color(0xFF061E3A),
  ],
  'uae__citibank_uae': [
    Color(0xFF056DAE),
    Color(0xFFED1C24),
    Color(0xFF062F4B),
  ],
  'uae__adcb': [
    Color(0xFF007360),
    Color(0xFFCE116B),
    Color(0xFF04483D),
  ],
  'uae__commercial_bank_of_dubai': [
    Color(0xFF00736D),
    Color(0xFFCE117D),
    Color(0xFF033936),
  ],
  'uae__dubai_islamic_bank': [
    Color(0xFF153E35),
    Color(0xFF007945),
    Color(0xFF0A1E1A),
  ],
  'uae__emirates_nbd': [
    Color(0xFF072447),
    Color(0xFF2765FF),
    Color(0xFF020D1A),
  ],
  'uae__first_abu_dhabi_bank': [
    Color(0xFF003DA6),
    Color(0xFF2A5082),
    Color(0xFF042051),
  ],
  'uae__hsbc_uae': [
    Color(0xFFDB0011),
    Color(0xFF383838),
    Color(0xFF28090D),
  ],
  'uae__mashreq': [
    Color(0xFFFF7524),
    Color(0xFFFFDC00),
    Color(0xFF742F06),
  ],
  'uae__rakbank': [
    Color(0xFF0D6EFD),
    Color(0xFFDC3545),
    Color(0xFF691018),
  ],
  'uae__sharjah_islamic_bank': [
    Color(0xFF007369),
    Color(0xFFCE1178),
    Color(0xFF044842),
  ],
  'uae__standard_chartered_uae': [
    Color(0xFF0072CE),
    Color(0xFF00A3E0),
    Color(0xFF042C4D),
  ],
  'uae__wio_bank': [
    Color(0xFF5700FF),
    Color(0xFF101F4B),
    Color(0xFF09122D),
  ],
  'united_kingdom__barclays': [
    Color(0xFF001276),
    Color(0xFF00395D),
    Color(0xFF040E49),
  ],
  'united_kingdom__halifax': [
    Color(0xFF005EB8),
    Color(0xFF071D49),
    Color(0xFF020A1A),
  ],
  'united_kingdom__hsbc_uk': [
    Color(0xFFDB0011),
    Color(0xFF333333),
    Color(0xFF180F0F),
  ],
  'united_kingdom__lloyds_bank': [
    Color(0xFF11B67A),
    Color(0xFF006A4D),
    Color(0xFF033527),
  ],
  'united_kingdom__metro_bank': [
    Color(0xFF2548AF),
    Color(0xFFD91C28),
    Color(0xFF0E1D49),
  ],
  'united_kingdom__monzo': [
    Color(0xFF218FB7),
    Color(0xFF091723),
    Color(0xFF050F17),
  ],
  'united_kingdom__nationwide': [
    Color(0xFF011546),
    Color(0xFF2952B2),
    Color(0xFF031134),
  ],
  'united_kingdom__natwest': [
    Color(0xFF5E10B1),
    Color(0xFF007BFF),
    Color(0xFF30065C),
  ],
  'united_kingdom__revolut': [
    Color(0xFFFF6200),
    Color(0xFF07174A),
    Color(0xFF05123F),
  ],
  'united_kingdom__santander_uk': [
    Color(0xFFEC0000),
    Color(0xFF007BFF),
    Color(0xFF740606),
  ],
  'united_kingdom__standard_chartered': [
    Color(0xFFFF6200),
    Color(0xFF07174A),
    Color(0xFF06164D),
  ],
  'united_kingdom__starling_bank': [
    Color(0xFF321E37),
    Color(0xFF4FFFEA),
    Color(0xFF150C17),
  ],
  'united_states__ally_bank': [
    Color(0xFF300942),
    Color(0xFF954293),
    Color(0xFF1E052A),
  ],
  'united_states__american_express': [
    Color(0xFF006FCF),
    Color(0xFF00175A),
    Color(0xFF020E2E),
  ],
  'united_states__bank_of_america': [
    Color(0xFF0053C2),
    Color(0xFF012169),
    Color(0xFF041744),
  ],
  'united_states__bmo_us': [
    Color(0xFF0079C1),
    Color(0xFFED1B2F),
    Color(0xFF054267),
  ],
  'united_states__capital_one': [
    Color(0xFFCC2427),
    Color(0xFF0276B1),
    Color(0xFF520D0E),
  ],
  'united_states__citibank': [
    Color(0xFF056DAE),
    Color(0xFF002A54),
    Color(0xFF010E1B),
  ],
  'united_states__discover': [
    Color(0xFFFF6000),
    Color(0xFF2477AB),
    Color(0xFF0C2E43),
  ],
  'united_states__jpmorgan_chase': [
    Color(0xFF005EB8),
    Color(0xFF128842),
    Color(0xFF053562),
  ],
  'united_states__navy_federal': [
    Color(0xFF0667BA),
    Color(0xFF0F3D70),
    Color(0xFF07203C),
  ],
  'united_states__pnc_bank': [
    Color(0xFF0005B8),
    Color(0xFFE31884),
    Color(0xFF040545),
  ],
  'united_states__td_bank_us': [
    Color(0xFF038203),
    Color(0xFF1A5336),
    Color(0xFF0F3421),
  ],
  'united_states__truist': [
    Color(0xFF6200EE),
    Color(0xFF2E1A47),
    Color(0xFF0D0715),
  ],
  'united_states__u_s_bank': [
    Color(0xFF235AE4),
    Color(0xFF00004E),
    Color(0xFF030332),
  ],
  'united_states__wells_fargo': [
    Color(0xFFD71E28),
    Color(0xFF3B3331),
    Color(0xFF201614),
  ],
  'vietnam__acb': [
    Color(0xFF0070FF),
    Color(0xFF323F4B),
    Color(0xFF1D262F),
  ],
  'vietnam__agribank': [
    Color(0xFF003344),
    Color(0xFF9E2B47),
    Color(0xFF02181F),
  ],
  'vietnam__bidv': [
    Color(0xFF003344),
    Color(0xFFFFB92C),
    Color(0xFF032632),
  ],
  'vietnam__hdbank': [
    Color(0xFFF00020),
    Color(0xFF0D6EFD),
    Color(0xFF063374),
  ],
  'vietnam__hsbc_vietnam': [
    Color(0xFFDB0011),
    Color(0xFF464646),
    Color(0xFF1E0C0F),
  ],
  'vietnam__mb_bank': [
    Color(0xFF222266),
    Color(0xFF225500),
    Color(0xFF101032),
  ],
  'vietnam__sacombank': [
    Color(0xFF2A81D0),
    Color(0xFF0058A0),
    Color(0xFF05355C),
  ],
  'vietnam__shinhan_bank_vietnam': [
    Color(0xFF0046AD),
    Color(0xFF55A5FF),
    Color(0xFF032557),
  ],
  'vietnam__standard_chartered_vietnam': [
    Color(0xFF0072CE),
    Color(0xFF6DB33F),
    Color(0xFF073A58),
  ],
  'vietnam__techcombank': [
    Color(0xFFED1C24),
    Color(0xFF0A84FF),
    Color(0xFF650609),
  ],
  'vietnam__vietcombank': [
    Color(0xFF074C31),
    Color(0xFF0D6EFD),
    Color(0xFF021C12),
  ],
  'vietnam__vietinbank': [
    Color(0xFF005993),
    Color(0xFF2563EB),
    Color(0xFF04304D),
  ],
  'vietnam__vpbank': [
    Color(0xFF00B74F),
    Color(0xFF1D4289),
    Color(0xFF0D1F43),
  ],
  'vietnam__uob_vietnam': [
    Color(0xFFD71920),
    Color(0xFF003B70),
    Color(0xFF071A2E),
  ],
};

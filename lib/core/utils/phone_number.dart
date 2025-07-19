import 'dart:developer';

import 'package:phone_numbers_parser/phone_numbers_parser.dart';

class PhoneNumberService {
  static Map<String, String> parsePhone(String? fullPhoneNumber) {
    if (fullPhoneNumber == null || fullPhoneNumber.isEmpty) {
      return {'countryCode': 'EG', 'phoneNumber': ''};
    }

    try {
      final phoneNumber = PhoneNumber.parse(fullPhoneNumber);
      log(phoneNumber.nsn.toString());
      log(phoneNumber.toString());
      return {
        'countryCode': phoneNumber.isoCode.name,
        'phoneNumber': phoneNumber.nsn, // National significant number
      };
    } catch (e) {
      // Fallback to manual parsing if package fails
      log(e.toString());
      return _parsePhoneManually(fullPhoneNumber);
    }
  }

  static Map<String, String> _parsePhoneManually(String? fullPhoneNumber) {
    if (fullPhoneNumber == null || fullPhoneNumber.isEmpty) {
      return {'countryCode': 'EG', 'phoneNumber': ''};
    }

    String phone = fullPhoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Comprehensive country code mapping
    Map<String, String> countryCodes = {
      '+1': 'US', // USA/Canada
      '+7': 'RU', // Russia/Kazakhstan
      '+20': 'EG', // Egypt
      '+27': 'ZA', // South Africa
      '+30': 'GR', // Greece
      '+31': 'NL', // Netherlands
      '+32': 'BE', // Belgium
      '+33': 'FR', // France
      '+34': 'ES', // Spain
      '+36': 'HU', // Hungary
      '+39': 'IT', // Italy
      '+40': 'RO', // Romania
      '+41': 'CH', // Switzerland
      '+43': 'AT', // Austria
      '+44': 'GB', // United Kingdom
      '+45': 'DK', // Denmark
      '+46': 'SE', // Sweden
      '+47': 'NO', // Norway
      '+48': 'PL', // Poland
      '+49': 'DE', // Germany
      '+51': 'PE', // Peru
      '+52': 'MX', // Mexico
      '+53': 'CU', // Cuba
      '+54': 'AR', // Argentina
      '+55': 'BR', // Brazil
      '+56': 'CL', // Chile
      '+57': 'CO', // Colombia
      '+58': 'VE', // Venezuela
      '+60': 'MY', // Malaysia
      '+61': 'AU', // Australia
      '+62': 'ID', // Indonesia
      '+63': 'PH', // Philippines
      '+64': 'NZ', // New Zealand
      '+65': 'SG', // Singapore
      '+66': 'TH', // Thailand
      '+81': 'JP', // Japan
      '+82': 'KR', // South Korea
      '+84': 'VN', // Vietnam
      '+86': 'CN', // China
      '+90': 'TR', // Turkey
      '+91': 'IN', // India
      '+92': 'PK', // Pakistan
      '+93': 'AF', // Afghanistan
      '+94': 'LK', // Sri Lanka
      '+95': 'MM', // Myanmar
      '+98': 'IR', // Iran
      '+212': 'MA', // Morocco
      '+213': 'DZ', // Algeria
      '+216': 'TN', // Tunisia
      '+218': 'LY', // Libya
      '+220': 'GM', // Gambia
      '+221': 'SN', // Senegal
      '+222': 'MR', // Mauritania
      '+223': 'ML', // Mali
      '+224': 'GN', // Guinea
      '+225': 'CI', // Ivory Coast
      '+226': 'BF', // Burkina Faso
      '+227': 'NE', // Niger
      '+228': 'TG', // Togo
      '+229': 'BJ', // Benin
      '+230': 'MU', // Mauritius
      '+231': 'LR', // Liberia
      '+232': 'SL', // Sierra Leone
      '+233': 'GH', // Ghana
      '+234': 'NG', // Nigeria
      '+235': 'TD', // Chad
      '+236': 'CF', // Central African Republic
      '+237': 'CM', // Cameroon
      '+238': 'CV', // Cape Verde
      '+239': 'ST', // São Tomé and Príncipe
      '+240': 'GQ', // Equatorial Guinea
      '+241': 'GA', // Gabon
      '+242': 'CG', // Republic of the Congo
      '+243': 'CD', // Democratic Republic of the Congo
      '+244': 'AO', // Angola
      '+245': 'GW', // Guinea-Bissau
      '+246': 'IO', // British Indian Ocean Territory
      '+248': 'SC', // Seychelles
      '+249': 'SD', // Sudan
      '+250': 'RW', // Rwanda
      '+251': 'ET', // Ethiopia
      '+252': 'SO', // Somalia
      '+253': 'DJ', // Djibouti
      '+254': 'KE', // Kenya
      '+255': 'TZ', // Tanzania
      '+256': 'UG', // Uganda
      '+257': 'BI', // Burundi
      '+258': 'MZ', // Mozambique
      '+260': 'ZM', // Zambia
      '+261': 'MG', // Madagascar
      '+262': 'RE', // Réunion
      '+263': 'ZW', // Zimbabwe
      '+264': 'NA', // Namibia
      '+265': 'MW', // Malawi
      '+266': 'LS', // Lesotho
      '+267': 'BW', // Botswana
      '+268': 'SZ', // Eswatini
      '+269': 'KM', // Comoros
      '+290': 'SH', // Saint Helena
      '+291': 'ER', // Eritrea
      '+297': 'AW', // Aruba
      '+298': 'FO', // Faroe Islands
      '+299': 'GL', // Greenland
      '+350': 'GI', // Gibraltar
      '+351': 'PT', // Portugal
      '+352': 'LU', // Luxembourg
      '+353': 'IE', // Ireland
      '+354': 'IS', // Iceland
      '+355': 'AL', // Albania
      '+356': 'MT', // Malta
      '+357': 'CY', // Cyprus
      '+358': 'FI', // Finland
      '+359': 'BG', // Bulgaria
      '+370': 'LT', // Lithuania
      '+371': 'LV', // Latvia
      '+372': 'EE', // Estonia
      '+373': 'MD', // Moldova
      '+374': 'AM', // Armenia
      '+375': 'BY', // Belarus
      '+376': 'AD', // Andorra
      '+377': 'MC', // Monaco
      '+378': 'SM', // San Marino
      '+380': 'UA', // Ukraine
      '+381': 'RS', // Serbia
      '+382': 'ME', // Montenegro
      '+383': 'XK', // Kosovo
      '+385': 'HR', // Croatia
      '+386': 'SI', // Slovenia
      '+387': 'BA', // Bosnia and Herzegovina
      '+389': 'MK', // North Macedonia
      '+420': 'CZ', // Czech Republic
      '+421': 'SK', // Slovakia
      '+423': 'LI', // Liechtenstein
      '+500': 'FK', // Falkland Islands
      '+501': 'BZ', // Belize
      '+502': 'GT', // Guatemala
      '+503': 'SV', // El Salvador
      '+504': 'HN', // Honduras
      '+505': 'NI', // Nicaragua
      '+506': 'CR', // Costa Rica
      '+507': 'PA', // Panama
      '+508': 'PM', // Saint Pierre and Miquelon
      '+509': 'HT', // Haiti
      '+590': 'GP', // Guadeloupe
      '+591': 'BO', // Bolivia
      '+592': 'GY', // Guyana
      '+593': 'EC', // Ecuador
      '+594': 'GF', // French Guiana
      '+595': 'PY', // Paraguay
      '+596': 'MQ', // Martinique
      '+597': 'SR', // Suriname
      '+598': 'UY', // Uruguay
      '+599': 'CW', // Curaçao
      '+670': 'TL', // East Timor
      '+672': 'NF', // Norfolk Island
      '+673': 'BN', // Brunei
      '+674': 'NR', // Nauru
      '+675': 'PG', // Papua New Guinea
      '+676': 'TO', // Tonga
      '+677': 'SB', // Solomon Islands
      '+678': 'VU', // Vanuatu
      '+679': 'FJ', // Fiji
      '+680': 'PW', // Palau
      '+681': 'WF', // Wallis and Futuna
      '+682': 'CK', // Cook Islands
      '+683': 'NU', // Niue
      '+1684': 'AS', // American Samoa
      '+685': 'WS', // Samoa
      '+686': 'KI', // Kiribati
      '+687': 'NC', // New Caledonia
      '+688': 'TV', // Tuvalu
      '+689': 'PF', // French Polynesia
      '+690': 'TK', // Tokelau
      '+691': 'FM', // Micronesia
      '+692': 'MH', // Marshall Islands
      '+850': 'KP', // North Korea
      '+852': 'HK', // Hong Kong
      '+853': 'MO', // Macau
      '+855': 'KH', // Cambodia
      '+856': 'LA', // Laos
      '+880': 'BD', // Bangladesh
      '+886': 'TW', // Taiwan
      '+960': 'MV', // Maldives
      '+961': 'LB', // Lebanon
      '+962': 'JO', // Jordan
      '+963': 'SY', // Syria
      '+964': 'IQ', // Iraq
      '+965': 'KW', // Kuwait
      '+966': 'SA', // Saudi Arabia
      '+967': 'YE', // Yemen
      '+968': 'OM', // Oman
      '+970': 'PS', // Palestine
      '+971': 'AE', // United Arab Emirates
      '+972': 'IL', // Israel
      '+973': 'BH', // Bahrain
      '+974': 'QA', // Qatar
      '+975': 'BT', // Bhutan
      '+976': 'MN', // Mongolia
      '+977': 'NP', // Nepal
      '+992': 'TJ', // Tajikistan
      '+993': 'TM', // Turkmenistan
      '+994': 'AZ', // Azerbaijan
      '+995': 'GE', // Georgia
      '+996': 'KG', // Kyrgyzstan
      '+998': 'UZ', // Uzbekistan
      '+1268': 'AG', // Anguilla
      '+1264': 'AG', // Antigua and Barbuda
    };

    // Try to match the longest possible country code first
    for (int i = 5; i >= 2; i--) {
      if (phone.length >= i) {
        String potentialCode = phone.substring(0, i);
        if (countryCodes.containsKey(potentialCode)) {
          return {
            'countryCode': countryCodes[potentialCode]!,
            'phoneNumber': phone.substring(i),
          };
        }
      }
    }

    // Default fallback
    return {
      'countryCode': 'EG',
      'phoneNumber': phone.startsWith('+') ? phone.substring(1) : phone,
    };
  }
}

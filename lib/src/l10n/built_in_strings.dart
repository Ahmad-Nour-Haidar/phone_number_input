import 'phone_input_strings.dart';

const PhoneInputStrings _chineseTraditional = PhoneInputStrings(
  hint: '電話號碼',
  invalidNumber: '電話號碼無效',
  requiredNumber: '請輸入電話號碼',
  searchLabel: '依國家/地區名稱或國碼搜尋',
);

const PhoneInputStrings _norwegian = PhoneInputStrings(
  hint: 'Telefonnummer',
  invalidNumber: 'Ugyldig telefonnummer',
  requiredNumber: 'Skriv inn et telefonnummer',
  searchLabel: 'Søk etter land eller landskode',
);

/// The built-in texts, keyed by language tag.
const Map<String, PhoneInputStrings> builtInStrings = {
  'en': PhoneInputStrings(),
  'ar': PhoneInputStrings(
    hint: 'رقم الهاتف',
    invalidNumber: 'رقم الهاتف غير صالح',
    requiredNumber: 'أدخل رقم الهاتف',
    searchLabel: 'ابحث باسم الدولة أو رمز الاتصال',
  ),
  'de': PhoneInputStrings(
    hint: 'Telefonnummer',
    invalidNumber: 'Ungültige Telefonnummer',
    requiredNumber: 'Telefonnummer eingeben',
    searchLabel: 'Nach Land oder Ländervorwahl suchen',
  ),
  'el': PhoneInputStrings(
    hint: 'Αριθμός τηλεφώνου',
    invalidNumber: 'Μη έγκυρος αριθμός τηλεφώνου',
    requiredNumber: 'Εισαγάγετε αριθμό τηλεφώνου',
    searchLabel: 'Αναζήτηση με όνομα χώρας ή κωδικό κλήσης',
  ),
  'es': PhoneInputStrings(
    hint: 'Número de teléfono',
    invalidNumber: 'Número de teléfono no válido',
    requiredNumber: 'Introduce un número de teléfono',
    searchLabel: 'Buscar por país o prefijo',
  ),
  'fa': PhoneInputStrings(
    hint: 'شماره تلفن',
    invalidNumber: 'شماره تلفن نامعتبر است',
    requiredNumber: 'شماره تلفن را وارد کنید',
    searchLabel: 'جستجو با نام کشور یا کد کشور',
  ),
  'fr': PhoneInputStrings(
    hint: 'Numéro de téléphone',
    invalidNumber: 'Numéro de téléphone invalide',
    requiredNumber: 'Saisissez un numéro de téléphone',
    searchLabel: 'Rechercher par pays ou indicatif',
  ),
  'hi': PhoneInputStrings(
    hint: 'फ़ोन नंबर',
    invalidNumber: 'अमान्य फ़ोन नंबर',
    requiredNumber: 'फ़ोन नंबर दर्ज करें',
    searchLabel: 'देश के नाम या कंट्री कोड से खोजें',
  ),
  'id': PhoneInputStrings(
    hint: 'Nomor telepon',
    invalidNumber: 'Nomor telepon tidak valid',
    requiredNumber: 'Masukkan nomor telepon',
    searchLabel: 'Cari berdasarkan nama negara atau kode negara',
  ),
  'it': PhoneInputStrings(
    hint: 'Numero di telefono',
    invalidNumber: 'Numero di telefono non valido',
    requiredNumber: 'Inserisci un numero di telefono',
    searchLabel: 'Cerca per paese o prefisso',
  ),
  'ja': PhoneInputStrings(
    hint: '電話番号',
    invalidNumber: '無効な電話番号です',
    requiredNumber: '電話番号を入力してください',
    searchLabel: '国名または国番号で検索',
  ),
  'ko': PhoneInputStrings(
    hint: '전화번호',
    invalidNumber: '유효하지 않은 전화번호입니다',
    requiredNumber: '전화번호를 입력하세요',
    searchLabel: '국가 이름 또는 국가 번호로 검색',
  ),
  'nl': PhoneInputStrings(
    hint: 'Telefoonnummer',
    invalidNumber: 'Ongeldig telefoonnummer',
    requiredNumber: 'Voer een telefoonnummer in',
    searchLabel: 'Zoeken op land of landcode',
  ),
  'no': _norwegian,
  'nb': _norwegian,
  'nn': _norwegian,
  'pl': PhoneInputStrings(
    hint: 'Numer telefonu',
    invalidNumber: 'Nieprawidłowy numer telefonu',
    requiredNumber: 'Wpisz numer telefonu',
    searchLabel: 'Szukaj według kraju lub numeru kierunkowego',
  ),
  'pt': PhoneInputStrings(
    hint: 'Número de telefone',
    invalidNumber: 'Número de telefone inválido',
    requiredNumber: 'Digite um número de telefone',
    searchLabel: 'Pesquisar por país ou código do país',
  ),
  'ro': PhoneInputStrings(
    hint: 'Număr de telefon',
    invalidNumber: 'Număr de telefon invalid',
    requiredNumber: 'Introduceți un număr de telefon',
    searchLabel: 'Căutați după țară sau prefix',
  ),
  'ru': PhoneInputStrings(
    hint: 'Номер телефона',
    invalidNumber: 'Недопустимый номер телефона',
    requiredNumber: 'Введите номер телефона',
    searchLabel: 'Поиск по названию страны или коду',
  ),
  'sk': PhoneInputStrings(
    hint: 'Telefónne číslo',
    invalidNumber: 'Neplatné telefónne číslo',
    requiredNumber: 'Zadajte telefónne číslo',
    searchLabel: 'Hľadať podľa krajiny alebo predvoľby',
  ),
  'tr': PhoneInputStrings(
    hint: 'Telefon numarası',
    invalidNumber: 'Geçersiz telefon numarası',
    requiredNumber: 'Bir telefon numarası girin',
    searchLabel: 'Ülke adı veya ülke koduyla ara',
  ),
  'ur': PhoneInputStrings(
    hint: 'فون نمبر',
    invalidNumber: 'غلط فون نمبر',
    requiredNumber: 'فون نمبر درج کریں',
    searchLabel: 'ملک کے نام یا کنٹری کوڈ سے تلاش کریں',
  ),
  'zh': PhoneInputStrings(
    hint: '电话号码',
    invalidNumber: '电话号码无效',
    requiredNumber: '请输入电话号码',
    searchLabel: '按国家/地区名称或区号搜索',
  ),
  'zh-Hant': _chineseTraditional,
  'zh-TW': _chineseTraditional,
  'zh-HK': _chineseTraditional,
  'yue': _chineseTraditional,
};

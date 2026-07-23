import 'package:intl/intl.dart';

class AppFormatters {
  AppFormatters._();

  static final _fcfa = NumberFormat.decimalPattern('fr_FR');

  static String fcfa(num valeur) => '${_fcfa.format(valeur.round())} FCFA';

  static String prixKg(num valeur) => '${_fcfa.format(valeur.round())} FCFA/kg';

  static final _dateCourte = DateFormat('d MMM', 'fr_FR');

  static String dateCourte(DateTime date) => _dateCourte.format(date);

  static final _dateLongue = DateFormat('EEEE d MMMM y', 'fr_FR');

  static String dateLongue(DateTime date) => _dateLongue.format(date);
}

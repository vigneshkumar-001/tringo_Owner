// enum BusinessType { individual, company }
//
// class RegistrationSession {
//   RegistrationSession._();
//   static final RegistrationSession instance = RegistrationSession._();
//
//   BusinessType? businessType;
//
//   void reset() {
//     businessType = null;
//   }
// }
enum BusinessType { individual, company }

class RegistrationSession {
  RegistrationSession._();
  static final RegistrationSession instance = RegistrationSession._();

  BusinessType? businessType;

  /// Treat only 'company' as premium. Null/individual -> non-premium.
  bool get isPremium => businessType == BusinessType.company;

  void reset() {
    businessType = null;
  }
}

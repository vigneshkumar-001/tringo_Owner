// enum BusinessType {
//   individual,
//   company;
//
//   String get label => switch (this) {
//     BusinessType.individual => 'Individual',
//     BusinessType.company => 'Company',
//   };
// }
//
// class RegistrationSession {
//   RegistrationSession._();
//   static final RegistrationSession instance = RegistrationSession._();
//
//   BusinessType? businessType;
//
//   /// Treat only 'company' as premium. Null/individual -> non-premium.
//   bool get isPremium => businessType == BusinessType.company;
//
//   void reset() {
//     businessType = null;
//   }
// }
// registration_session.dart

enum BusinessType { individual, company }

class RegistrationSession {
  RegistrationSession._internal();
  static final RegistrationSession instance = RegistrationSession._internal();

  BusinessType? businessType;

  // 🔥 NEW: helper getters
  bool get isIndividualBusiness => businessType == BusinessType.individual;
  bool get isCompanyBusiness => businessType == BusinessType.company;

  // bool get isNonPremium => businessType == BusinessType.individual;
  // bool get isPremium => businessType == BusinessType.company;

  void reset() {
    businessType = null;
    // baaki fields reset...
  }
}

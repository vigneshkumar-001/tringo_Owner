enum BusinessType {
  individual,
  company;

  String get label => switch (this) {
    BusinessType.individual => 'Individual',
    BusinessType.company => 'Company',
  };
}

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

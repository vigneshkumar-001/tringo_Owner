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

  void reset() {
    businessType = null;
  }
}

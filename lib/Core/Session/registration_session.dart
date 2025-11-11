enum BusinessType { individual, company }

class RegistrationSession {
  RegistrationSession._();
  static final RegistrationSession instance = RegistrationSession._();

  BusinessType? businessType;

  void reset() {
    businessType = null;
  }
}

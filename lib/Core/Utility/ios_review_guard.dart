import 'dart:io';

import 'package:flutter/foundation.dart';

bool get isIOSReviewBuild => !kIsWeb && Platform.isIOS;

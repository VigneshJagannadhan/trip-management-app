/// VALIDATOR FUNCTION FOR EMAIL TEXT FIELDS
String? validatePhone(String? value) {
  if (value == null || value.isEmpty) {
    return 'Mobile Number is required.';
  }
  if (value.length != 10) {
    return 'Phone number must be 10 digits';
  }
  return null;
}

String? validatePhoneRegistration(String? value, bool hasVerified) {
  if (value == null || value.isEmpty) {
    return 'Mobile Number is required.';
  }
  if (value.length != 10) {
    return 'Phone number must be 10 digits';
  }
  if (!hasVerified) {
    return 'Verify your phone to continue';
  }
  return null;
}

/// VALIDATOR FUNCTION FOR REGISTRATION PASSWORD TEXT FIELDS
String? validatePasswordRegistration(String? value) {
  RegExp regexA = RegExp(r'^(?=.*?[A-Z])');
  RegExp regexB = RegExp(r'^(?=.*?[a-z])');
  RegExp regexC = RegExp(r'^(?=.*?[0-9])');
  RegExp regexSpecial = RegExp(r'^(?=.*?[!@#\$&*~])');
  RegExp regexDot = RegExp(r'\.');

  if (value == null || value.isEmpty) {
    return 'Enter a valid password';
  } else if (!regexA.hasMatch(value)) {
    return 'Password must contain an upper case letter';
  } else if (!regexB.hasMatch(value)) {
    return 'Password must contain a lower case letter';
  } else if (!regexC.hasMatch(value)) {
    return 'Password must contain a number';
  } else if (!regexSpecial.hasMatch(value)) {
    return 'Password must contain at least one special character';
  } else if (regexDot.hasMatch(value)) {
    return 'Password must not contain a dot (.) character';
  } else if (value.length < 8) {
    return 'Password must be at least 8 characters';
  } else {
    return null;
  }
}

/// VALIDATOR FUNCTION FOR REGISTRATION PASSWORD TEXT FIELDS
String? validateOldPassword(String? value) {
  RegExp regexA = RegExp(r'^(?=.*?[A-Z])');
  RegExp regexB = RegExp(r'^(?=.*?[a-z])');
  RegExp regexC = RegExp(r'^(?=.*?[0-9])');
  RegExp regexSpecial = RegExp(r'^(?=.*?[!@#\$&*~])');
  RegExp regexDot = RegExp(r'\.');

  if (value == null || value.isEmpty) {
    return 'Enter old password';
  } else if (!regexA.hasMatch(value)) {
    return 'Password must contain an upper case letter';
  } else if (!regexB.hasMatch(value)) {
    return 'Password must contain a lower case letter';
  } else if (!regexC.hasMatch(value)) {
    return 'Password must contain a number';
  } else if (!regexSpecial.hasMatch(value)) {
    return 'Password must contain at least one special character';
  } else if (regexDot.hasMatch(value)) {
    return 'Password must not contain a dot (.) character';
  } else if (value.length < 8) {
    return 'Password must be at least 8 characters';
  } else {
    return null;
  }
}

/// VALIDATOR FUNCTION FOR PASSWORD TEXT FIELDS
String? validatePasswordLogin(String? value) {
  if ((value?.length ?? 0) < 8) {
    return 'Password must be atleast 8 characters';
  } else {
    return null;
  }
}

/// VALIDATOR FUNCTION FOR  NAME TEXT FIELDS
String? validateName(String? value) {
  if (value == null || value == '') {
    return 'Enter your name';
  }
  return null;
}

/// VALIDATOR FUNCTION FOR  NOTES
String? validateNotes(String? value) {
  if (value == null || value == '') {
    return 'Enter your notes';
  }
  return null;
}

/// VALIDATOR FUNCTION FOR  Feedback
String? validateFeedback(String? value) {
  if (value == null || value == '') {
    return 'Enter your feedback';
  }
  return null;
}

/// VALIDATOR FUNCTION FOR  RELATIONSHIP TEXT FIELDS
String? validateRelationship(String? value) {
  if (value == null || value == '') {
    return 'Specify your relationship with the person';
  }
  return null;
}

/// VALIDATOR FUNCTION FOR FIRST NAME TEXT FIELDS
String? validateFirstName(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Enter your first name';
  }

  final nameRegExp = RegExp(r'^[a-zA-Z]+$');
  if (!nameRegExp.hasMatch(value)) {
    return 'Only alphabets are allowed';
  }

  return null;
}

/// VALIDATOR FUNCTION FOR LAST NAME TEXT FIELDS
String? validateLastName(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Enter your last name';
  }

  final nameRegExp = RegExp(r'^[a-zA-Z]+$');
  if (!nameRegExp.hasMatch(value)) {
    return 'Only alphabets are allowed';
  }

  return null;
}

/// VALIDATOR FUNCTION FOR COMPANY TAX NUMBER TEXT FIELDS
String? validateCompanyWebsite(String? value) {
  if (value == null || value == '') {
    return 'Enter the company website';
  }
  return null;
}

/// VALIDATOR FUNCTION FOR TYPE OF BUSINESS
validateBusinessType(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please select an option';
  }
  return null;
}

/// VALIDATOR FUNCTION FOR STATE
String? validateState(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please select your state';
  }
  return null;
}

/// VALIDATOR FUNCTION FOR START DATE
String? validateStartDate(DateTime? value) {
  if (value == null) {
    return "Select a start date";
  }
  return null;
}

/// VALIDATOR FUNCTION FOR START DATE
String? validateEndDate(DateTime? value) {
  if (value == null) {
    return "Select a end date";
  }
  return null;
}

/// VALIDATOR FUNCTION FOR NAME TEXT FIELDS
String? validateCompanyName(String? value) {
  if (value == null || value == '') {
    return 'Enter your company name';
  }
  return null;
}

/// VALIDATOR FUNCTION FOR EMAIL TEXT FIELDS
// String? validateEmail(String? value) {
//   if (value == null || value.isEmpty) {
//     return 'Email is required.';
//   }
//   const pattern = r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-z]{2,7}$';
//   final regExp = RegExp(pattern);
//   if (!regExp.hasMatch(value.trim())) {
//     return 'Enter a valid email address.';
//   }
//   return null;
// }

String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'Email is required.';
  }
  const pattern = r'^[\w.+-]+@([\w-]+\.)+[a-z]{2,7}$';
  final regExp = RegExp(pattern);
  if (!regExp.hasMatch(value.trim())) {
    return 'Enter a valid email address.';
  }
  return null;
}

String? validateEmailWithNull(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }
  const pattern = r'^[\w.+-]+@([\w-]+\.)+[a-z]{2,7}$';
  final regExp = RegExp(pattern);
  if (!regExp.hasMatch(value.trim())) {
    return 'Enter a valid email address.';
  }
  return null;
}

String? validateEmailRegistration(String? value, bool hasVerified) {
  if (value == null || value.isEmpty) {
    return 'Email is required.';
  }
  const pattern = r'^[\w.+-]+@([\w-]+\.)+[a-z]{2,7}$';
  final regExp = RegExp(pattern);
  if (!regExp.hasMatch(value.trim())) {
    return 'Enter a valid email address.';
  }
  if (!hasVerified) {
    return 'Verify your email to continue';
  }
  return null;
}

/// VALIDATOR FUNCTION FOR NAME TEXT FIELDS
String? validateLocation(String? value) {
  if (value == null || value == '') {
    return 'Enter your location';
  }
  return null;
}

/// VALIDATOR FUNCTION FOR ADDRESS
String? validateAddress(String? value) {
  if (value == null || value.isEmpty) {
    return 'Enter the address';
  }
  return null;
}

/// VALIDATOR FUNCTION FOR WORK TYPE
String? validateWorkType(String? value) {
  if (value == null || value.isEmpty) {
    return 'Select a worktype';
  }
  return null;
}

/// VALIDATOR FUNCTION FOR ADDRESS
String? validateTaskDetails(String? value) {
  if (value == null || value.isEmpty) {
    return 'Enter a valid task detail';
  }
  return null;
}

/// VALIDATOR FUNCTION FOR STREET
String? validateStreet(String? value) {
  if (value == null || value.isEmpty) {
    return 'Enter the street name';
  }
  return null;
}

/// VALIDATOR FUNCTION FOR CITY
String? validateCity(String? value) {
  if (value == null || value.isEmpty) {
    return 'Enter the city name';
  }
  return null;
}

/// VALIDATOR FUNCTION FOR CITY
String? validateCategoryName(String? value) {
  if (value == null || value.isEmpty) {
    return 'Enter the category name';
  }
  return null;
}

/// VALIDATOR FUNCTION FOR CITY
String? validateCategoryDescription(String? value) {
  if (value == null || value.isEmpty) {
    return 'Enter the category description';
  }
  return null;
}

/// VALIDATOR FUNCTION FOR TITLE
String? validateTitle(String? value) {
  if (value == null || value.isEmpty) {
    return 'Enter the title';
  }
  return null;
}

/// VALIDATOR FUNCTION FOR ZIP (NUMBER)
String? validateZip(String? value) {
  if (value == null || value.isEmpty) {
    return 'Enter the zip code';
  }
  final zip = int.tryParse(value);
  if (zip == null || zip <= 0) {
    return 'Enter a valid positive number for the zip code';
  }
  return null;
}

/// VALIDATOR FUNCTION FOR APPROX MONTHLY EVENTS (INTEGER)
String? validateMonthlyEvents(String? value) {
  if (value == null || value.isEmpty) {
    return 'Enter the number of approx events per year';
  }
  final events = int.tryParse(value);
  if (events == null || events <= 0) {
    return 'Enter a valid positive integer for events per year';
  }
  return null;
}

/// VALIDATOR FUNCTION FOR EVENT PAY (INTEGER)
String? validateEventPay(String? value) {
  if (value == null || value.isEmpty) {
    return 'Enter the event pay';
  }
  return null;
}

/// VALIDATOR FUNCTION FOR STAFF CATEGORIES
String? validateStaffCategoriesMap(
  Set<Map<String, dynamic>> selectedOptions, {
  String fieldName = 'options',
}) {
  if (selectedOptions.isEmpty) {
    return 'Please select at least one $fieldName.';
  }

  // Optionally, you can add additional validation for each selected option
  // For example, check if there is a certain field or value present within the map:
  for (var option in selectedOptions) {
    if (option["label"] == null || option["label"]!.isEmpty) {
      return 'Please ensure each selected $fieldName has a valid label.';
    }
  }

  return null;
}

/// VALIDATOR FUNCTION FOR OTP FIELDS
String? validateOTP(String? value) {
  if (value == null || value.isEmpty) {
    return 'Enter your otp to continue';
  }
  if (value.length != 4) {
    return 'Enter a valid OTP';
  }
  return null;
}

/// VALIDATOR FUNCTION FOR INVITE CODE
String? validateInviteCode(String? value) {
  if (value == null || value.isEmpty) {
    return 'Enter your invite code';
  }
  if (value.length != 6) {
    return 'Enter a valid Invite Code';
  }
  return null;
}

/// VALIDATOR FUNCTION FOR OTP FIELDS
String? validateTextField(String? value) {
  if (value == null || value.isEmpty) {
    return 'This field is required';
  }
  return null;
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tringo_vendor/Core/Const/app_color.dart';
import 'package:tringo_vendor/Core/Const/app_images.dart';

class CommonContainer {
  static topLeftArrow({required VoidCallback onTap}) {
    return Row(
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColor.leftArrow,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            child: Image.asset(
              height: 14,
              width: 14,
              AppImages.leftArrow,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }

  static Widget fillingContainer({
    String? text,
    Key? fieldKey,
    TextEditingController? controller,
    String? imagePath,
    bool verticalDivider = true,
    Function(String)? onChanged,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    VoidCallback? onDetailsTap,
    double imageHight = 30,
    double imageWidth = 11,
    int? maxLine,
    int flex = 4,
    bool isTamil = false,
    bool isAadhaar = false,
    bool isDOB = false,
    bool isMobile = false,
    bool isPincode = false,
    bool readOnly = false,
    bool isDropdown = false,
    List<String>? dropdownItems,
    BuildContext? context,
    FormFieldValidator<String>? validator,
    FocusNode? focusNode,
    Color borderColor = AppColor.red,
    Color? imageColor,
    VoidCallback? onFieldTap,
  }) {
    return FormField<String>(
      validator: validator,
      key: fieldKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      builder: (state) {
        final hasError = state.hasError;

        // -------------------- DOB Picker --------------------
        Future<void> _handleDobTap() async {
          if (!isDOB || context == null) return;

          final DateTime startDate = DateTime(2021, 6, 1);
          final DateTime endDate = DateTime(2022, 5, 31);
          final DateTime initialDate = DateTime(2021, 6, 2);

          final pickedDate = await showDatePicker(
            context: context!,
            initialDate: initialDate,
            firstDate: DateTime(2020),
            lastDate: DateTime(2025),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  dialogBackgroundColor: AppColor.scaffoldColor,
                  colorScheme: ColorScheme.light(
                    primary: AppColor.lightSkyBlue,
                    onPrimary: Colors.white,
                    onSurface: AppColor.black,
                  ),
                  textButtonTheme: TextButtonThemeData(
                    style: TextButton.styleFrom(
                      foregroundColor: AppColor.lightSkyBlue,
                    ),
                  ),
                ),
                child: child!,
              );
            },
          );

          if (pickedDate != null) {
            if (pickedDate.isBefore(startDate) || pickedDate.isAfter(endDate)) {
              ScaffoldMessenger.of(context!).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Invalid Date of Birth!\nPlease select a date between 01-06-2021 and 31-05-2022.',
                  ),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 3),
                ),
              );
            } else {
              controller?.text =
              "${pickedDate.day.toString().padLeft(2, '0')}-"
                  "${pickedDate.month.toString().padLeft(2, '0')}-"
                  "${pickedDate.year}";
              state.didChange(controller?.text ?? '');
            }
          }
        }

        // -------------------- Tap Handling --------------------
        void _handleTap() {
          if (isDOB) {
            _handleDobTap();
          } else if (isDropdown &&
              dropdownItems != null &&
              dropdownItems!.isNotEmpty) {
            _showDropdownBottomSheet(context!, dropdownItems!, controller, state);
          } else {
            onFieldTap?.call();
          }
        }

        // -------------------- Input Formatter Handling --------------------
        final effectiveInputFormatters = isMobile || isAadhaar || isPincode
            ? <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(
            isMobile ? 10 : (isAadhaar ? 12 : 6),
          ),
        ]
            : (inputFormatters ?? const []);

        // -------------------- UI --------------------
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: _handleTap,
              behavior: HitTestBehavior.opaque,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: AppColor.lightGray,
                  border: Border.all(
                    color: hasError ? AppColor.red : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 15,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: flex,
                        child: AbsorbPointer(
                          absorbing: isDOB || readOnly || isDropdown,
                          child: TextFormField(
                            focusNode: focusNode,
                            readOnly: readOnly || isDropdown,
                            controller: controller,
                            maxLines: maxLine,
                            maxLength: isMobile
                                ? 10
                                : (isAadhaar ? 12 : (isPincode ? 6 : null)),
                            keyboardType: keyboardType,
                            inputFormatters: effectiveInputFormatters,
                            style: GoogleFonts.mulish(
                              fontSize: 14,
                              color: AppColor.black,
                            ),
                            decoration: const InputDecoration(
                              hintText: '',
                              counterText: '',
                              contentPadding:
                              EdgeInsets.symmetric(horizontal: 10),
                              border: InputBorder.none,
                              isDense: true,
                              errorText: null,
                            ),
                            showCursor: !(isDOB || readOnly || isDropdown),
                            enableInteractiveSelection:
                            !(isDOB || readOnly || isDropdown),
                            onChanged: (v) {
                              state.didChange(v);
                              onChanged?.call(v);
                            },
                          ),
                        ),
                      ),
                      if (verticalDivider)
                        Container(
                          width: 2,
                          height: 30,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.grey.shade200,
                                Colors.grey.shade300,
                                Colors.grey.shade200,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      const SizedBox(width: 20),
                      if (imagePath != null)
                        InkWell(
                          onTap: () {
                            controller?.clear();
                            state.didChange('');
                            onDetailsTap?.call();
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(right: 15),
                            child: Image.asset(
                              imagePath,
                              height: imageHight,
                              width: imageWidth,
                              color: imageColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            if (hasError)
              Padding(
                padding: const EdgeInsets.only(left: 12.0, top: 4),
                child: Text(
                  state.errorText!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
          ],
        );
      },
    );
  }

  // -------------------- Common Dropdown Bottom Sheet --------------------
  static void _showDropdownBottomSheet(
      BuildContext context,
      List<String> items,
      TextEditingController? controller,
      FormFieldState<String> state,
      ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return ListView.separated(
          shrinkWrap: true,
          itemCount: items.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final value = items[index];
            final isSelected = controller?.text == value;
            return ListTile(
              title: Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                  isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppColor.lightSkyBlue : Colors.black,
                ),
              ),
              onTap: () {
                controller?.text = value;
                state.didChange(value);
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }
}

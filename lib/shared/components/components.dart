import 'package:flutter/material.dart';

import 'constants.dart';

// Reusable Navigate Function and return to the previous screen
void navigateTo(context, widget) => Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => widget,
      ),
    );

// Reusable Navigate Function and remove the previous screen
void navigateAndFinish(context, widget) => Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => widget,
      ),
      (route) => false,
    );

// Reusable TextFormField Function with validator
Widget defaultTextFormField({
  required TextEditingController? controller,
  required TextInputType keyboardType,
  required String? label,
  TextStyle? textStyle,
  VoidCallback? onTap,
  required String? Function(String?)? validator,
  Function(String)? onSubmitted,
  bool secure = false,
  IconData? prefix,
  Color? prefixColor,
  IconData? suffix,
  Color? suffixColor,
  VoidCallback? suffixPressed,
  bool? isClickable,
}) =>
    TextFormField(
      style: textStyle,
      controller: controller,
      keyboardType: keyboardType,
      onTap: onTap,
      enabled: isClickable,
      validator: validator,
      obscureText: secure,
      onFieldSubmitted: onSubmitted,
      decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(
            prefix,
            color: prefixColor,
          ),
          suffixIcon: IconButton(
            icon: Icon(suffix),
            onPressed: suffixPressed,
            color: suffixColor,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0),
          )),
    );

Widget defaultButton({
  required VoidCallback onPressed,
  required String text,
  Color? backgroundColor,
}) =>
    Container(
      //height: 50.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          textStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          shape: const BeveledRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
          ),
        ),
        child: Text(
          text,
        ),
      ),
    );

// Custom ElevatedButton with icon

Widget customElevatedButton({
  required VoidCallback onTap,
  required String label,
  required IconData icon,
  Color backgroundColor = KDeleteButtonColor,
  Color foregroundColor = Colors.red,
  double radius = 10,
  double fontSize = 20,
}) =>
    ElevatedButton.icon(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(radius))),
        shadowColor: Colors.lightBlue,
        textStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
      label: Text(
        label,
      ),
      icon: Icon(
        icon,
      ),
    );

// Custom TextButton with icon

Widget customTextButtonIcon({
  required VoidCallback onTap,
  required String label,
  required IconData icon,
  Color backgroundColor = KDeleteButtonColor,
  Color foregroundColor = Colors.red,
  double radius = 10,
  double fontSize = 20,
}) =>
    TextButton.icon(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(radius))),
        shadowColor: Colors.lightBlue,
        textStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
      label: Text(
        label,
      ),
      icon: Icon(
        icon,
      ),
    );

Widget customCard({
  required VoidCallback onTap,
  required String title,
}) =>
    Container(
      padding: const EdgeInsets.all(5.0),
      margin: const EdgeInsets.all(5.0),
      height: 200.0,
      width: 180.0,
      child: InkWell(
        onTap: onTap,
        child: Card(
          elevation: 15.0,
          child: Center(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );


// Alert Dialog
Future<void> dialogBuilder({
  required BuildContext context,
  required VoidCallback enableOnTap,
  required VoidCallback disableOnTap,
  required String title,
  required String disableTitle,
  required String enableTitle,
  required Widget contentWidget,
}) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title:  Text(title),
        content: contentWidget,
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            onPressed: disableOnTap,
            child: Text(disableTitle),
          ),
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            onPressed: enableOnTap,
            child: Text(enableTitle),
          ),
        ],
      );
    },
  );
}


Widget customListTile(
{
  required context,
  VoidCallback? listTileOnTap,
  VoidCallback? trailingOnPress,
  Widget? leadingWidget,
  required String title,
  String subTitle = '',
  Color titleColor = Colors.black,
  Color subTitleColor = Colors.grey,
  double titleFontSize = 18,
  double subTitleFontSize = 14,
  IconData trailingIcon = Icons.arrow_back_ios_new_outlined,
  double trailingIconSize = 20,
  Color trailingIconColor = Colors.black,

}) => ListTile(
  onTap: listTileOnTap,
  leading: leadingWidget,
  title: Text(
    title,
    style: TextStyle(
      fontSize: titleFontSize,
      fontWeight: FontWeight.w500,
      color: titleColor,
    ),
  ),
  subtitle: Text(
    subTitle,
    style: TextStyle(
      fontSize: subTitleFontSize,
      color: subTitleColor,
    ),
  ),
  trailing: IconButton(
    onPressed: trailingOnPress,
    icon: Icon(
      trailingIcon,
      size: trailingIconSize,
      color: trailingIconColor,
    ),
  ),
);
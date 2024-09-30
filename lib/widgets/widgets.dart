import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

//Widget loading Aplikasi
Widget wAppLoading(BuildContext context) {
  return Container(
    color: Theme.of(context).scaffoldBackgroundColor,
    child: const Center(
      child: CircularProgressIndicator(),
    ),
  );
}

Future wPushTo(BuildContext context, Widget widget) async {
  return Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => widget),
  );
}

Future wPushReplaceTo(BuildContext context, Widget widget) {
  return Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => widget),
  );
}

Widget wInputSumbit(String title, void Function() onPressed) {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white, // Butonun arkaplan rengi
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(10), // Butonun köşe yuvarlama değeri
        ),
      ),
      onPressed: onPressed,
      child: Text(title),
    ),
  );
}

ToastFuture wShowToast(String msg, BuildContext context) {
  return showToast(
    msg,
    context: context,
    backgroundColor: Colors.black,
    textStyle: const TextStyle(color: Colors.white),
  );
}

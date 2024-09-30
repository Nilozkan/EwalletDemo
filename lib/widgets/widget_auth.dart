import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

Widget wAuthTitle({title, subtitle}) {
  return Container(
    padding: const EdgeInsets.only(bottom: 20),
    child:
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      Text(
        title,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
      const SizedBox(
        height: 3,
      ),
      Text(subtitle)
    ]),
  );
}

Widget wTextDivider() {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 20),
    child: const Row(
      children: <Widget>[
        Expanded(child: Divider()),
        Padding(
          padding: EdgeInsets.all(10),
          child: Text(
            'OR CONNECT WITH',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
        Expanded(child: Divider())
      ],
    ),
  );
}

Widget wGoogleSignIn(void Function() onPressed) {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(MdiIcons.google, size: 20),
        label: const Text('Google')),
  );
}

Widget wTextLink(String text, String title, void Function() onTap) {
  return Container(
    margin: const EdgeInsets.only(top: 40),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(text),
        GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(10),
              color: Colors.transparent,
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ))
      ],
    ),
  );
}

import 'package:flutter/material.dart';

Future<void> showErrorDialog(BuildContext context, String erorrText) {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(
                Icons.warning_sharp,
                color: Colors.red,
              ),
              Text(
                "Something went wrong",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            erorrText,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
          actions: <Widget>[
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Close")),
          ],
        );
      });
}

Future<bool> showLogOutDialog(BuildContext context) {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Sign Out",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          content: const Text(
            "Are you sure you want to sign out?",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text("Cancel")),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text("Log Out")),
          ],
        );
      }).then((value) => value ?? false);
}

Future<bool> showDisabledDialog(BuildContext context) {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 163, 11, 0),
          title: const Text(
            "Disabled Account",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            "You should go to payment page\nThank You.",
            style: TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text(
                  "Close",
                  style: TextStyle(color: Colors.white),
                )),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text(
                  "Payment Page",
                  style: TextStyle(
                    color: Color.fromARGB(255, 119, 255, 124),
                    fontWeight: FontWeight.bold,
                  ),
                )),
          ],
        );
      }).then((value) => value ?? false);
}

Future<bool> showDeletePostDialog(BuildContext context) {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Delete",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          content: const Text(
            "Are tou sure you want to delete this post?",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    Text(
                      "Delete",
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                )),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text("Cancel")),
          ],
        );
      }).then((value) => value ?? false);
}

import 'package:flutter/material.dart';
import 'package:icon_decoration/icon_decoration.dart';
import 'package:the_governors/constants/routes.dart';
import 'package:the_governors/services/auth/auth_service.dart';
import 'package:the_governors/utilities/show_error_dialog.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  List<String> titles = [];
  List icons = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    titles.add("Meet");
    titles.add("Chat");
    titles.add("Rewards");

    titles.add("Gallery");
    titles.add("Charity");
    titles.add("Copy&Paste");
    titles.add("Discounts");
    titles.add("Log Out");

    icons.add(
      Icons.video_call_outlined,
    );
    icons.add(
      Icons.wechat,
    );
    icons.add(
      Icons.workspace_premium,
    );
    icons.add(
      Icons.perm_media_outlined,
    );
    icons.add(
      Icons.volunteer_activism_outlined,
    );
    icons.add(
      Icons.copy,
    );
    icons.add(
      Icons.discount_outlined,
    );
    icons.add(
      Icons.logout_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.builder(
        padding: const EdgeInsets.symmetric(vertical: 50.0, horizontal: 20.0),
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2,
          mainAxisSpacing: 20.0,
          crossAxisSpacing: 10.0,
        ),
        itemCount: titles.length,
        itemBuilder: (context, index) {
          return Container(
            decoration: index == 7
                ? BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                        Color.fromARGB(255, 255, 136, 136),
                        Color.fromARGB(255, 150, 0, 0),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(32))
                : BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                        Color.fromARGB(255, 255, 209, 123),
                        Color.fromARGB(255, 238, 127, 0),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(32),
                  ),
            child: TextButton(
              onPressed: () async {
                switch (index) {
                  case 0:
                    print("0");
                  case 1:
                    await Navigator.of(context).pushNamed(chatUserRoute);
                  case 2:
                    await Navigator.of(context).pushNamed(rewardsUserRoute);
                  case 3:
                    await Navigator.of(context).pushNamed(galleryUserRoute);
                  case 4:
                    await Navigator.of(context).pushNamed(charityUserRoute);
                  case 5:
                    await Navigator.of(context).pushNamed(copyPasteUserRoute);
                  case 6:
                    await Navigator.of(context).pushNamed(discountUserRoute);
                  case 7:
                    final shouldLogOut = await showLogOutDialog(context);
                    if (shouldLogOut) {
                      await AuthService.firebase().logOut();
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          loginRoute, (route) => false);
                    }
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  DecoratedIcon(
                    icon: Icon(
                      icons[index],
                      size: 40.0,
                    ),
                    decoration: const IconDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color.fromARGB(255, 146, 146, 146),
                          Color.fromARGB(255, 0, 0, 0),
                        ],
                      ),
                      border:
                          IconBorder(color: Color.fromARGB(255, 238, 255, 0)),
                    ),
                  ),
                  const SizedBox(
                    width: 8.0,
                  ),
                  Text(
                    titles[index],
                    style: const TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontWeight: FontWeight.bold,
                        fontFamily: "Anta",
                        fontSize: 16.0),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

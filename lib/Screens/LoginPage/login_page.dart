import 'package:fitness/Screens/LoginPage/login_form.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            leading: Navigator.canPop(context)
                ? IconButton(
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                    icon: Icon(Icons.arrow_back_ios_new),
                  )
                : null,
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(100),
              child: Column(
                children: [
                  Text(
                    "Log in",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35),
                  ),
                  Text("Enter your email and password to login"),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(child: LoginForm()),
        ],
      ),
    );
  }
}

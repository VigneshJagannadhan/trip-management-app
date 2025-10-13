import 'package:flutter/material.dart';
import 'package:trippify/presentation/views/home/home_view_tab.dart';

class HomeView extends StatefulWidget {
  static const String route = '/home';
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: HomeViewTab());
  }
}

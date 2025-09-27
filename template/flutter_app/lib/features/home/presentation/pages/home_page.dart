import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/palette.dart';
import '../cubit/home_cubit.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static const String route = 'flowers';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => home_cubit()..fetchFlowers(),
      child: Scaffold(
        appBar: AppBar(),
        body: BlocBuilder<home_cubit, HomeState>(
          builder: (context, state) {
            if(state.isLoading){
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if(state.errorMessage != null){
              return Center(
                child: Text(
                  state.errorMessage!,
                  style: TextStyle(
                    color: context.palette.onBackground,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }
            return ListView.builder(
              itemCount: state.flowers.length,
              itemBuilder: (context, index) {
                final flower = state.flowers[index];
                return ListTile(
                  leading: Text(flower.emoji, style: TextStyle(fontSize: 24),),
                  title: Text(
                    flower.name,
                    style: TextStyle(
                      color: context.palette.onBackground,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              },
            );

          },
        ),
      ),
    );
  }
}

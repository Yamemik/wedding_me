import 'package:flutter/material.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              // header
              //const PopularStoriesSection(),
              // body
              //const PhotoSection(),
            ],
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(icon: Icon(Icons.search), onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=> HomeScreen()));
                }),
              // IconButton(icon: Icon(Icons.photo_album), onPressed: () {
              //   Navigator.push(context, MaterialPageRoute(builder: (context)=> AlbumListScreen(userId: "1",)));
              // }),
              IconButton(icon: Icon(Icons.add_a_photo), onPressed: () {}),
              IconButton(icon: Icon(Icons.person), onPressed: () {}),
            ],
          ),
        )
    );
  }
}

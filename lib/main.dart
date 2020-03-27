import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter_puzzle/puzzlepiece.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Material App',
        home: MyHomePage());
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  final int rows = 3;
  final int cols = 3;

  MyHomePage({Key key, this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File _image;
  List<Widget> pieces = [];

  Future getImage(ImageSource source) async {
    var image = await ImagePicker.pickImage(source: source);

    if (image != null) {
      setState(() {
        _image = image;
        pieces.clear();
      });

      splitImage(Image.file(image));
    }
  }

  //functions declaration
  //Function 1:
  // we need to find out the image size, to be used in the PuzzlePiece widget
  Future<Size> getImageSize(Image image) async {
    final Completer<Size> completer = Completer<Size>();

    image.image.resolve(const ImageConfiguration()).addListener(
      (ImageInfo info, bool _) {
        completer.complete(Size(
          info.image.width.toDouble(),
          info.image.height.toDouble(),
        ));
      },
    );
    final Size imageSize = await completer.future;
    return imageSize;
  }

  //function 2:
  // here we will split the image into small pieces using the rows and columns defined above; each piece will be added to a stack
  void splitImage(Image image) async {
    Size imageSize = await getImageSize(image);

    for (int x = 0; x < widget.rows; x++) {
      for (int y = 0; y < widget.cols; y++) {
        setState(() {
          pieces.add(PuzzlePiece(
              key: GlobalKey(),
              image: image,
              imageSize: imageSize,
              row: x,
              col: y,
              maxRow: widget.rows,
              maxCol: widget.cols));
        });
      }
    }
  }

  //end functions declaration

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Puzzle'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.camera),
              onPressed: () {
                showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: Icon(Icons.camera),
                              title: Text('Camera'),
                              onTap: () {
                                getImage(ImageSource.camera);
                                // this is how you dismiss the modal bottom sheet after making a choice
                                Navigator.pop(context);
                              },
                            ),
                            ListTile(
                              leading: Icon(Icons.image),
                              title: Text('Gallery'),
                              onTap: () {
                                getImage(ImageSource.gallery);
                                // dismiss the modal sheet
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      );
                    });
              })
        ],
      ),
      body: Center(
        child: SafeArea(
          child: Center(
            child: _image == null
                ? Text('No image selected.')
                : Stack(children: pieces)
          ),
        ),
      ),
    );
  }
}

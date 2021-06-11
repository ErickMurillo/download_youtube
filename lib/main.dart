import 'dart:io';

import 'package:downloads_path_provider/downloads_path_provider.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final imgUrl =
      "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4";
  bool downloading = false;
  var progressString = "";

  VideoPlayerController _videoPlayerController2;
  ChewieController _chewieController;

  @override
  void initState() {
    super.initState();
    // _videoPlayerController2 = VideoPlayerController.network(
    //     'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4');
    // final _videoPlayerController2 =
    //     VideoPlayerController.asset('/Downloads/video360p.mp4');
    // _videoPlayerController2 = VideoPlayerController.asset(
    //     '/storage/emulated/0/Download/FZ22abbMuJg.webm');
    final File file = File('/storage/emulated/0/Download/FZ22abbMuJg.mp4');

    _videoPlayerController2 = VideoPlayerController.file(file);

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController2,
      autoPlay: true,
      looping: true,
    );
  }

  @override
  void dispose() {
    _videoPlayerController2.dispose();
    _chewieController.dispose();
    super.dispose();
  }

//   Future<void> downloadFile() async {
//     Dio dio = Dio();

//     try {
//       //   var dir = await getApplicationDocumentsDirectory();
//       await Permission.storage.request();
//       var dir = await DownloadsPathProvider.downloadsDirectory;

//       print("path ${dir.path}");
//       await dio.download(imgUrl, "${dir.path}/demo.mp4",
//           onReceiveProgress: (rec, total) {
//         // print("Rec: $rec , Total: $total");

//         setState(() {
//           downloading = true;
//           progressString = ((rec / total) * 100).toStringAsFixed(0) + "%";
//         });
//       });
//       path = "${dir.path}/demo.mp4";
//     } catch (e) {
//       print(e);
//     }

//     setState(() {
//       downloading = false;
//       progressString = "Completed";
//     });
//     print("Download completed");
//   }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
                onPressed: () async {
                  //   downloadFile();
                  var yt = YoutubeExplode();
                  var id = 'qKOPl7PHvfw';
                  var video = await yt.videos.get(id);

                  // Display info about this video.
                  await showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        content: Text(
                            'Title: ${video.title}, Duration: ${video.duration}'),
                      );
                    },
                  );

                  // Request permission to write in an external directory.
                  // (In this case downloads)
                  await Permission.storage.request();

                  // Get the streams manifest and the audio track.
                  var manifest = await yt.videos.streamsClient.getManifest(id);
                  var audio = manifest.muxed.first;

                  // Build the directory.
                  var dir = await DownloadsPathProvider.downloadsDirectory;
                  var filePath = path.join(dir.uri.toFilePath(),
                      '${video.id}.${audio.container.name}');

                  // Open the file to write.
                  var file = File(filePath);
                  var fileStream = file.openWrite();

                  // Pipe all the content of the stream into our file.
                  await yt.videos.streamsClient.get(audio).pipe(fileStream);
                  /*
                  If you want to show a % of download, you should listen
                  to the stream instead of using `pipe` and compare
                  the current downloaded streams to the totalBytes,
                  see an example ii example/video_download.dart
                   */

                  // Close the file.
                  await fileStream.flush();
                  await fileStream.close();

                  // Show that the file was downloaded.
                  await showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        content: Text(
                            'Download completed and saved to: ${filePath}'),
                      );
                    },
                  );
                },
                child: Text('Descargar')),

            Center(
              child: downloading
                  ? Container(
                      height: 120.0,
                      width: 200.0,
                      child: Card(
                        color: Colors.black,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            CircularProgressIndicator(),
                            SizedBox(
                              height: 20.0,
                            ),
                            Text(
                              "Downloading File: $progressString",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  : Text("No Data"),
            ),
            // Expanded(
            //   child: Center(
            //     child: Chewie(
            //       controller: _chewieController,
            //     ),
            //   ),
            // ),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

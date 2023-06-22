import 'dart:io';
import 'package:firebase_app/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: MyHomePage()
    );
  }
}

class MyHomePage extends StatefulWidget {

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File?  file;
  UploadTask? task;
  Future selectFile() async{
    final result = await FilePicker.platform.pickFiles(allowMultiple:false );
    if(result == null) return;
    final path  = result.files.single.path;
    setState(() {
      file = File(path!);
    });
  }

  Future<void> uploadFile() async {
    if (file == null) return;
    final fileName = basename(file!.path);
    final destination = 'files/$fileName';
    task = MyFirebaseStorage.uploadFile(destination, file!);
    if (task == null) return;

    await task!.whenComplete(() async {
      final snapt = await task;
      final url = await snapt!.ref.getDownloadURL();
      print(url);
    });
  }

  Widget UploadStatus (UploadTask task) =>
      StreamBuilder<TaskSnapshot>(
        stream: task!.snapshotEvents,
          builder: (context,snapshot){
            if(snapshot.hasData){
              final snap = snapshot.data!;
              final progress =  snap.bytesTransferred / snap.totalBytes;
              final upLoadPercent = (progress* 100).toStringAsFixed(2);
              return Text("$upLoadPercent %");
            }
            else{
              return Container();
            }
          }
      );

  @override
  Widget build(BuildContext context) {
    final fileName = file != null ? basename(file!.path) : 'No file selected';
    return Scaffold(
      appBar: AppBar(
        title: Text("Uploading Files to Firebase"),
      ),
      body:
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(onPressed: () {
                selectFile();
              }, child: Text("Select File"),),
              Text(fileName),
              ElevatedButton(onPressed: () {uploadFile();}, child: Text("Upload File")),
           task != null ? UploadStatus(task!) : Container(),

            ],
          ),
        )
    );
  }
}


import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';

class MyHomePage extends StatefulWidget {
  final CameraDescription camera;
  const MyHomePage({
    required this.camera, super.key
    });

  @override
  State<MyHomePage> createState() =>
      _MyHomePageState();
}

class _MyHomePageState
    extends State<MyHomePage> {
  // Controller for the camera
  late CameraController _controller;
  // Future to wait for the controller to initialize
  late Future<void> _initializeControllerFuture;
  // Controller for the frequency text input field
  final TextEditingController _frequencyController = TextEditingController(text: '10'); // Default to 10 seconds
  
  // Timer for periodic photos
  Timer? _timer;
  // To keep track of the last photo taken
  XFile? _lastImage;
  // To manage the state of the Start/Stop button
  bool _isTakingPictures = false;

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // you must create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // VERY IMPORTANT: Dispose of the controllers when the widget is disposed.
    // This frees up resources.
    _controller.dispose();
    _frequencyController.dispose();
    _timer?.cancel(); // Cancel the timer if it's active
    super.dispose();
  }
  
  // --- Logic for taking pictures ---
  
  void _startOrStopPeriodicPhotos() {
    if (_isTakingPictures) {
      // If we are currently taking pictures, stop.
      setState(() {
        _isTakingPictures = false;
      });
      _timer?.cancel();
      print("Stopped taking periodic photos.");
    } else {
      // If we are not taking pictures, start.
      setState(() {
        _isTakingPictures = true;
      });
      
      // Get the frequency from the text field
      final frequency = int.tryParse(_frequencyController.text) ?? 10; // Default to 10 if input is invalid
      print("Starting to take a photo every $frequency seconds.");

      // Create a periodic timer
      _timer = Timer.periodic(Duration(seconds: frequency), (timer) {
        _takePicture();
      });
    }
  }

  Future<void> _takePicture() async {
    // A try-catch block is important for handling camera errors.
    try {
      // Ensure that the camera is initialized.
      await _initializeControllerFuture;

      // Attempt to take a picture and get the file `image`
      // where it was saved.
      final image = await _controller.takePicture();
      
      print("Picture taken and saved to ${image.path}");

      // If the picture was taken, update the UI to display it.
      setState(() {
        _lastImage = image;
      });
    } catch (e) {
      // If an error occurs, log the error to the console.
      print("Error taking picture: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Periodic Camera')),
      // The body of our Scaffold
      body: Column(
        children: [
          // This is the Camera Preview section
          // It uses a FutureBuilder to display a loading indicator while the camera is initializing
          Expanded(
            flex: 3, // Give more space to the camera preview
            child: FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  // If the Future is complete, display the preview.
                  return CameraPreview(_controller);
                } else {
                  // Otherwise, display a loading indicator.
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          
          // This is the control panel section
          Expanded(
            flex: 2, // Give less space to the controls
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Row for frequency input
                  Row(
                    children: [
                      const Text("Frequency (seconds):", style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _frequencyController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  // The Start/Stop Button
                  ElevatedButton(
                    onPressed: _startOrStopPeriodicPhotos,
                    child: Text(_isTakingPictures ? 'Stop Taking Photos' : 'Start Taking Photos'),
                    style: ElevatedButton.styleFrom(
                      iconColor: _isTakingPictures ? Colors.red : Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                  ),

                  // Display for the last taken image
                  if (_lastImage != null)
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(top: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        // Image.file is used to display an image from a local file path
                        child: Image.file(File(_lastImage!.path)),
                      ),
                    )
                  else
                    const Text("No image taken yet."),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

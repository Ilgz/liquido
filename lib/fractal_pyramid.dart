import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_shaders/flutter_shaders.dart';
import 'package:noise_meter/noise_meter.dart';

// This shader was taken from ShaderToy
// Origin of Shader: https://www.shadertoy.com/view/tsXBzS
class PyramidShader extends StatefulWidget {
  const PyramidShader({Key? key}) : super(key: key);

  @override
  State<PyramidShader> createState() => _PyramidShaderState();
}

class _PyramidShaderState extends State<PyramidShader>
    with SingleTickerProviderStateMixin {
  double time = 0;
  double colorValue = 0;
  late final Ticker _ticker;

  //Micro
  bool _isRecording = false;
  late StreamSubscription<NoiseReading> _noiseSubscription;
  late NoiseMeter _noiseMeter = new NoiseMeter(onError);
  double speed = 0.002;

  @override
  void initState() {
    super.initState();
    start();
    _ticker = createTicker((elapsed) {
      //   time += 0.01;
      time += speed;
      setState(() {});
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void start() async {
    try {
      _noiseSubscription = _noiseMeter.noiseStream.listen(onData);
    } catch (exception) {
      print(exception);
    }
  }

  void onData(NoiseReading noiseReading) {
    speed =
        noiseReading.meanDecibel > 80 ? 0.2 : noiseReading.meanDecibel / 10000;
    print(noiseReading.meanDecibel);
    if (!this._isRecording) {
      this._isRecording = true;
    }

    /// Do someting with the noiseReading object
    print(noiseReading.toString());
  }

  void onError(Object error) {
    print(error.toString());
    _isRecording = false;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          ShaderBuilder(
            assetKey: 'shaders/demo.glsl',
            child: SizedBox(width: size.width, height: size.height),
            (context, shader, child) {
              return AnimatedSampler(
                child: child!,
                (ui.Image image, Size size, Canvas canvas) {
                  shader
                    ..setFloat(0, time)
                    ..setFloat(1, size.width)
                    ..setFloat(2, size.height)
                    ..setFloat(
                        3, colorValue >= 0.95 ? colorValue - 0.05 : colorValue);
                  canvas.drawPaint(Paint()..shader = shader);
                },
              );
            },
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: SizedBox(
                width: MediaQuery.of(context).size.width - 24,
                child: SliderTheme(
                  data: SliderThemeData(
                    activeTickMarkColor: Colors.transparent,
                    disabledInactiveTickMarkColor: Colors.transparent,
                    disabledActiveTickMarkColor: Colors.transparent,
                    inactiveTickMarkColor: Colors.transparent,
                      thumbColor: Colors.green,
                      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6)),
                  child: Slider(
                      value: colorValue,
                      activeColor: hsvToRgb(
                          colorValue >= 0.95 ? colorValue - 0.05 : colorValue,
                          1,
                          1),
                      divisions: 100,

                      label: null,
                      onChanged: (value) {
                        setState(() {
                          colorValue = value;
                        });
                      }),
                ),
              ),
            ),
          ),
          IgnorePointer(
            ignoring: true, // Allow touch events to pass through
            child: Opacity(
              opacity: 0.25, // Adjust the opacity value as needed
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color hsvToRgb(double hue, double saturation, double value) {
    final hsvColor = HSVColor.fromAHSV(1.0, hue * 360, saturation, value);
    final rgbColor = hsvColor.toColor();
    return rgbColor;
  }
}

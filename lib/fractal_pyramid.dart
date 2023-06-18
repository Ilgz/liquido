import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

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
  double colorValue=0;
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
   //   time += 0.01;
     time += 0.01;
      setState(() {});
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
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
                    ..setFloat(3,colorValue)
                  ;
                  canvas.drawPaint(Paint()..shader = shader);
                },
              );
            },
          ),
          Slider(value: colorValue,onChanged: (value){
            setState(() {
              print(value);
              colorValue=value;
            });
          })
        ],
      ),
    );
  }
}
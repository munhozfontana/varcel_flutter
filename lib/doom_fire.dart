import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:varcel_flutter/fire_palete.dart';

enum LevelFire {
  low(value: 15),
  medium(value: 8),
  hight(value: 2);

  const LevelFire({required this.value});

  final int value;
}

class DoomFire extends StatefulWidget {
  const DoomFire({Key? key}) : super(key: key);

  @override
  State<DoomFire> createState() => _DoomFireState();
}

class _DoomFireState extends State<DoomFire> {
  List<int> firePixelsArray = [];
  var fireWidth = 100;
  var fireHeight = 100;
  LevelFire level = LevelFire.low;
  int count = 0;

  bool isDebug = false;
  Ticker? _ticker;

  @override
  void initState() {
    super.initState();
    createFireDataSructure();
    createFireSource();

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (count == 0) {
        level = LevelFire.low;
      }
      if (count == 1) {
        level = LevelFire.medium;
      }
      if (count >= 2) {
        level = LevelFire.hight;
      }

      if (count > 0) {
        count--;
      }
    });

    _ticker = Ticker(
      (elapsed) {
        setState(() {
          calculateFirePropagation();
        });
      },
    );

    _ticker?.start();
  }

  @override
  void dispose() {
    _ticker?.dispose();
    super.dispose();
  }

  updadeFireIntesityPerPixel(int currentPixel) {
    var belowPixelIndex = currentPixel + fireWidth;

    if (belowPixelIndex >= fireWidth * fireHeight) {
      return;
    }

    var decal = (Random().nextInt(level.value)).floor();

    var belowPixelFireIntesity = firePixelsArray[belowPixelIndex];
    var newFireIntesity = belowPixelFireIntesity - decal >= 0
        ? belowPixelFireIntesity - decal
        : 0;

    firePixelsArray[currentPixel + decal] = newFireIntesity;
  }

  createFireDataSructure() {
    var numberOfPiexels = fireWidth * fireHeight;
    firePixelsArray = List.generate(numberOfPiexels, (index) => 0);
  }

  calculateFirePropagation() {
    for (var column = 0; column < fireWidth; column++) {
      for (var row = 0; row < fireHeight; row++) {
        var pixelIndex = column + (fireWidth * row);
        updadeFireIntesityPerPixel(pixelIndex);
      }
    }
  }

  createFireSource() {
    for (var column = 0; column < fireWidth; column++) {
      var overflowIndexPixel = fireWidth * fireHeight;
      var pixelIndex = (overflowIndexPixel - fireWidth) + column;
      firePixelsArray[pixelIndex] = 36;
    }
  }

  renderFire() {
    return Center(
      child: Column(
        children: List.generate(
          fireHeight,
          (row) => Expanded(
            child: Row(
              children: List.generate(
                fireWidth,
                (column) {
                  var pixelIndex = (column + (fireWidth * row));
                  var fireIntesity = firePixelsArray[pixelIndex];
                  return Expanded(
                    child: Container(
                      decoration: isDebug
                          ? BoxDecoration(
                              color: FIRE_PALETTE[fireIntesity],
                              border: Border.all(width: 1),
                            )
                          : BoxDecoration(
                              color: FIRE_PALETTE[fireIntesity],
                            ),
                      child: isDebug
                          ? Center(child: Text(fireIntesity.toString()))
                          : null,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Center(
            child:
                Title(color: Colors.red, child: const Text('Click on fire!!!')),
          ),
          GestureDetector(
            onTap: () {
              if (count <= 5) {
                count++;
              }
            },
            child: Center(
              child: Container(
                color: Colors.black,
                width: 500,
                height: 500,
                child: renderFire(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

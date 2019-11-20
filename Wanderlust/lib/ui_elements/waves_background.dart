import 'package:flutter/material.dart';
import 'dart:math' as Math;
import 'package:simple_animations/simple_animations/controlled_animation.dart';




class WavesBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Math.Random generator = Math.Random();
    double Function(double min, double max) random = (min,max) => (max-min)*generator.nextDouble()+min; 
    const Color orange = Color.fromRGBO(244,81,30,1);
    const double speedFactor = 0.6;

    return Stack(
      children: <Widget>[
        onBottom(AnimatedWave(
          height: 180,
          speed: 1.0*speedFactor,
          color: orange.withAlpha(random(180,240).floor()),
        )),
        onBottom(AnimatedWave(
          height: 120,
          speed: 0.9*speedFactor,
          offset: Math.pi,
          color: orange.withAlpha(random(180,240).floor()),
        )),
        onBottom(AnimatedWave(
          height: 220,
          speed: 1.2*speedFactor,
          offset: Math.pi / 2,
          color: orange,
        )),
      ],
    );
  }

  onBottom(Widget child) => Positioned.fill(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: child,
        ),
      );
}

class AnimatedWave extends StatelessWidget {
  final double height;
  final double speed;
  final double offset;
  final Color color;

  AnimatedWave({this.height, this.speed, this.offset = 0.0, this.color});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        height: MediaQuery.of(context).size.height*0.8,// height,
        width: constraints.biggest.width,
        child: ControlledAnimation(
            playback: Playback.LOOP,
            duration: Duration(milliseconds: (5000 / speed).round()),
            tween: Tween(begin: 0.0, end: 2 * Math.pi),
            builder: (context, value) {
              return CustomPaint(
                foregroundPainter: CurvePainter(value + offset, height, color),
              );
            }),
      );
    });
  }
}

class CurvePainter extends CustomPainter {
  final double value;
  final double height;
  final Color color;

  CurvePainter(this.value, this.height, this.color);

  Paint _createPaint(Path path) {
    LinearGradient gradient = LinearGradient(
      colors: <Color>[
        color,
        Color.fromRGBO(109,76,65,1).withAlpha(color.alpha)
      ],
      begin: Alignment.topRight,
      end: Alignment.bottomCenter
    );

    Paint paint = new Paint()..shader = gradient.createShader(path.getBounds());
    return paint;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();

    final y1 = Math.sin(value);
    final y2 = Math.sin(value + Math.pi / 2);
    final y3 = Math.sin(value + Math.pi);

    final startPointY = height * (0.5 + 0.4 * y1);
    final controlPointY = height * (0.5 + 0.4 * y2);
    final endPointY = height * (0.5 + 0.4 * y3);

    path.moveTo(size.width * 0, startPointY);
    path.quadraticBezierTo(
        size.width * 0.5, controlPointY, size.width, endPointY);
    
    path.lineTo(size.width, height);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    final paint = _createPaint(path);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}


/*

class WavesBackground extends StatelessWidget {
  final int numWaves;
  final List<WaveBackground> wavesbg = [];
  final Size generatorContraints;

  WavesBackground(this.numWaves, this.generatorContraints, {Key key}) : super(key: key) {
    for (int i = 0; i < numWaves; i++) {
      if (i==0) {
        wavesbg.add(WaveBackground(wave: Wave.random(generatorContraints, Color.fromRGBO(244,81,30,1))));
      } else {
        wavesbg.add(WaveBackground(wave: Wave.random(generatorContraints)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: wavesbg,
      fit: StackFit.passthrough,
    );
  }
}



class Wave {

  final double    period;       //in pixel width
  final double    velocity;     //in pixel per second   
  final Color     color;        //color of wave
  final double    yOffset;      //offset from top in pixel
  final double    heightFactor; //max. & (-min) value of sine
  final double    xStartOffset;

  Wave({@required this.period,
        @required this.velocity,
        @required this.color,
        @required this.yOffset,
        @required this.heightFactor,
        @required this.xStartOffset
  });

  static Wave random(Size contraints, [Color c]) {
    Math.Random generator = Math.Random();
    double Function(double min, double max) random = (min,max) => (max-min)*generator.nextDouble()+min; 
    const Color orange = Color.fromRGBO(244,81,30,1);

    double period = random(contraints.width, contraints.width*4)*0.8;
    double velocity = random(150,300)*0.4;
    if (random(0,2)>1) velocity = -velocity;
    Color color = c!=null? c
                : orange.withAlpha(random(180,240).floor());
                //: Color.lerp(orange, Colors.white, random(0.1,0.6)).withAlpha(random(180,240).floor());
    const double offsetSpace = 40.0;
    final double offsetHeight = contraints.height*0.3;
    double yOffset = random(offsetHeight-offsetSpace,offsetHeight+offsetSpace);
    double heightFactor = random(30,80);
    double xStartOffset = random(0,contraints.width);
    Wave wave = Wave(
      period: period,
      color: color,
      heightFactor: heightFactor,
      velocity: velocity,
      yOffset: yOffset,
      xStartOffset: xStartOffset
    );
    return wave;
  }

  double calculateWithoutTime(double x) {
    return Math.sin(x*Math.pi*2/period)*heightFactor+yOffset;
  }

  double calculateWithTime(double x, double passedMilliseconds) {
    double xOff = velocity * (passedMilliseconds/1000.0);
    return calculateWithoutTime(x+xOff);
  }

}

class WavePainter extends CustomPainter {
  final Wave wave;
  final double passedMilliseconds;
  WavePainter(this.wave,this.passedMilliseconds);

  @override
  void paint(Canvas canvas, Size size) {
    
    //create path

    Path path = Path();

    path.moveTo(0, size.height);
    for (double x = 0; x <= size.width; x+=20.0) {
      path.lineTo(x, wave.calculateWithTime(x, passedMilliseconds));
    }
    path.lineTo(size.width, wave.calculateWithTime(size.width, passedMilliseconds));
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    //create paint

    //Paint paint = Paint();
    //paint.color = wave.color;

    LinearGradient gradient = LinearGradient(
      colors: <Color>[
        wave.color,
        Color.fromRGBO(109,76,65,1).withAlpha(wave.color.alpha)
      ],
      begin: Alignment.topRight,
      end: Alignment.bottomCenter
    );

    Paint paint = new Paint()..shader = gradient.createShader(path.getBounds());

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    if (oldDelegate == null || !(oldDelegate is WavePainter)) return true;
    return this.passedMilliseconds-(oldDelegate as WavePainter).passedMilliseconds > 30;
  }

}


class WaveBackground extends StatefulWidget {
  final Wave wave;
  WaveBackground({this.wave});

  @override
  _WaveBackgroundState createState() => _WaveBackgroundState();
}

class _WaveBackgroundState extends State<WaveBackground>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;
  Animation<double> animation;
  
  double get passedMilliseconds {
    return animation.value;
  }

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: Duration(days: 365)
    )..addListener(() => setState(() {}));
    animation = Tween<double>(
      begin: 0.0,
      end: 365.0 * 24.0 * 60.0 * 60.0 * 1000.0,
    ).animate(animationController);
    
    animationController.forward();

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        animationController.repeat();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: WavePainter(widget.wave,passedMilliseconds),
    );
  }
}



*/
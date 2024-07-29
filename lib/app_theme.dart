import 'package:booking_system_flutter/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

class AnimtedContainer2 extends StatefulWidget {
  final bool? On;
  AnimtedContainer2({Key? key, required this.widget, this.On = false})
      : super(key: key);
  Widget widget;
  @override
  _AnimtedContainer2State createState() => _AnimtedContainer2State();
}

class _AnimtedContainer2State extends State<AnimtedContainer2>
    with SingleTickerProviderStateMixin {
  AnimationController? controller;
  Animation<double>? animation;

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 2000,
      ),
    );
    animation = controller!
      ..addListener(() {
        // setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          controller?.reset();
        } else if (status == AnimationStatus.dismissed) {
          controller?.forward();
        }
      });
    controller?.forward();

    super.initState();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation as Listenable,
      builder: (context, child) {
        return
            // CustomPaint(
            // foregroundPainter: BorderPainter(controller!.value),
            // child:
            Container(

                // color: Colors.red,
                decoration: widget.On!
                    ? BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        gradient: SweepGradient(
                            tileMode: TileMode.repeated,
                            colors: [
                              Colors.yellow,
                              Colors.purple,
                              Colors.white,
                              Colors.black
                            ],
                            transform: GradientRotation(controller!.value * 6)))
                    : BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                      ),
                child: Padding(
                    padding: EdgeInsets.all(2.0),
                    child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(23),
                          color: Colors.white,
                        ),
                        alignment: Alignment.center,
                        child: widget.widget))
                // ),
                );
      },
    );
  }
}
  
class AppTheme {
  //
  AppTheme._();

  static ThemeData lightTheme({Color? color}) => ThemeData(
        useMaterial3: true,
        primarySwatch: createMaterialColor(color ?? primaryColor),
        primaryColor: color ?? primaryColor,
        colorScheme: ColorScheme.fromSeed(
            seedColor: color ?? primaryColor, outlineVariant: borderColor),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: GoogleFonts.workSans().fontFamily,
        bottomNavigationBarTheme:
            BottomNavigationBarThemeData(backgroundColor: Colors.white),
        iconTheme: IconThemeData(color: appTextSecondaryColor),
        textTheme: GoogleFonts.workSansTextTheme(),
        dialogBackgroundColor: Colors.white,
        unselectedWidgetColor: Colors.black,
        dividerColor: borderColor,
        bottomSheetTheme: BottomSheetThemeData(
          shape: RoundedRectangleBorder(
              borderRadius:
                  radiusOnly(topLeft: defaultRadius, topRight: defaultRadius)),
          backgroundColor: Colors.white,
        ),
        cardColor: cardColor,
        floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: color ?? primaryColor),
        appBarTheme: AppBarTheme(
            systemOverlayStyle: SystemUiOverlayStyle(
                statusBarIconBrightness: Brightness.light)),
        dialogTheme: DialogTheme(shape: dialogShape()),
        navigationBarTheme: NavigationBarThemeData(
            labelTextStyle:
                MaterialStateProperty.all(primaryTextStyle(size: 10))),
        pageTransitionsTheme: PageTransitionsTheme(
          builders: <TargetPlatform, PageTransitionsBuilder>{
            TargetPlatform.android: OpenUpwardsPageTransitionsBuilder(),
            TargetPlatform.linux: OpenUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      );

  static ThemeData darkTheme({Color? color}) => ThemeData(
        useMaterial3: true,
        primarySwatch: createMaterialColor(color ?? primaryColor),
        primaryColor: color ?? primaryColor,
        colorScheme: ColorScheme.fromSeed(
            seedColor: color ?? primaryColor, outlineVariant: borderColor),
        appBarTheme: AppBarTheme(
          systemOverlayStyle:
              SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light),
        ),
        scaffoldBackgroundColor: scaffoldColorDark,
        fontFamily: GoogleFonts.workSans().fontFamily,
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: scaffoldSecondaryDark),
        iconTheme: IconThemeData(color: Colors.white),
        textTheme: GoogleFonts.workSansTextTheme(),
        dialogBackgroundColor: scaffoldSecondaryDark,
        unselectedWidgetColor: Colors.white60,
        bottomSheetTheme: BottomSheetThemeData(
          shape: RoundedRectangleBorder(
              borderRadius:
                  radiusOnly(topLeft: defaultRadius, topRight: defaultRadius)),
          backgroundColor: scaffoldSecondaryDark,
        ),
        dividerColor: dividerDarkColor,
        floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: color ?? primaryColor),
        cardColor: scaffoldSecondaryDark,
        dialogTheme: DialogTheme(shape: dialogShape()),
        navigationBarTheme: NavigationBarThemeData(
            labelTextStyle: MaterialStateProperty.all(
                primaryTextStyle(size: 10, color: Colors.white))),
      ).copyWith(
        pageTransitionsTheme: PageTransitionsTheme(
          builders: <TargetPlatform, PageTransitionsBuilder>{
            TargetPlatform.android: OpenUpwardsPageTransitionsBuilder(),
            TargetPlatform.linux: OpenUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      );
}

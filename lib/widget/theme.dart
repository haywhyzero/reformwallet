
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

var kmyColorScheme = ColorScheme.fromSeed(
  seedColor: const Color.fromARGB(255, 40, 6, 82),
);
var kmyDarkColorScheme = ColorScheme.fromSeed(
  brightness: Brightness.dark,
  seedColor: const Color.fromARGB(255, 2, 24, 41),
);

ThemeData lightMode() {
return ThemeData(
      appBarTheme: AppBarTheme(
          foregroundColor: kmyColorScheme.copyWith().primaryContainer,
          backgroundColor: kmyColorScheme.copyWith().onPrimaryContainer
          ),
          colorScheme: kmyColorScheme,
           textTheme: TextTheme(
            bodyLarge: GoogleFonts.openSans(
              fontSize: 18,
              fontWeight: FontWeight.normal,
            ),
            titleLarge: GoogleFonts.robotoSerif(
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          brightness: Brightness.light,
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: kmyColorScheme.copyWith().primary,
            foregroundColor: kmyColorScheme.copyWith().onSecondary
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color.fromARGB(106, 255, 255, 255),
            prefixStyle: TextStyle(
              color: Colors.black87,
            ),
            hintStyle: TextStyle(
                  color: Colors.black26,
                ),
          )
          
    
);
}

ThemeData darkMode() {
  return ThemeData().copyWith(
    brightness: Brightness.dark,
        appBarTheme: AppBarTheme(
          foregroundColor: kmyDarkColorScheme.copyWith().onPrimaryContainer,
          backgroundColor: kmyDarkColorScheme.copyWith().primaryContainer
          ),
          scaffoldBackgroundColor: Colors.black,
          iconTheme: IconThemeData().copyWith(
            color: Colors.white,
          ),
          colorScheme: kmyDarkColorScheme,
          textTheme: TextTheme(
            bodyLarge: GoogleFonts.openSans(
              fontSize: 18,
              fontWeight: FontWeight.normal,
            ),
            titleLarge: GoogleFonts.robotoSerif(
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
            bodyMedium: GoogleFonts.openSans(
              color: Colors.white54
            ),
            bodySmall: GoogleFonts.openSans(
              color: Colors.black
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(                 
              backgroundColor: kmyDarkColorScheme.onSecondaryContainer,
              foregroundColor: kmyDarkColorScheme.onSecondary,                                                                               
            )
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
 
            )
          ),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: Colors.black,
            selectedItemColor: kmyDarkColorScheme.copyWith().primary,
            unselectedItemColor: kmyDarkColorScheme.copyWith().secondary
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: kmyDarkColorScheme.copyWith().primaryContainer,
          ),
          inputDecorationTheme: InputDecorationThemeData(
            prefixIconColor: Colors.white,
            hintStyle: TextStyle(
                  color: Colors.white24,
                ),
          ),
          dropdownMenuTheme: DropdownMenuThemeData(
            textStyle: TextStyle(
              color: Colors.black
              
            ),
            menuStyle: MenuStyle(
              backgroundColor: WidgetStateColor.resolveWith((context) => Colors.black )
            )
          ),
  );             


} 
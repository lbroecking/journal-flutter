import 'package:flutter/material.dart';

Widget zodiacIcon(String name, {double size = 15}) {
  return Image.asset(
    'assets/icons/$name.png',
    width: size,
    height: size,
  );
}


final Map<String, Widget> astroSigns = {
  'Aries': zodiacIcon('aries'),  // Widder
  'Taurus': zodiacIcon('aries'), // Stier
  'Gemini': zodiacIcon('gemini'),          // Zwillinge
  'Cancer': zodiacIcon('cancer'),    // Krebs
  'Leo': zodiacIcon('leo'),              // Löwe
  'Virgo': zodiacIcon('virgo'), // Jungfrau
  'Libra': zodiacIcon('libra'),           // Waage
  'Scorpio': zodiacIcon('scorpio'),    // Skorpion
  'Sagittarius': zodiacIcon('sagittarius'),    // Schütze
  'Capricorn': zodiacIcon('capricorn'), // Steinbock
  'Aquarius': zodiacIcon('aries'),        // Wassermann
  'Pisces': zodiacIcon('pisces'),          // Fische
};
import 'dart:ui';

import 'package:lcs_new_age/utils/colors.dart';

enum Alignment {
  liberal,
  moderate,
  conservative;

  Color get color {
    switch (this) {
      case liberal:
        return lightGreen;
      case moderate:
        return yellow;
      case conservative:
        return red;
    }
  }

  String get label {
    switch (this) {
      case liberal:
        return "Socialist";
      case moderate:
        return "Liberal";
      case conservative:
        return "Fascist";
    }
  }
  String get ism {
    switch (this) {
      case liberal:
        return "Socialism";
      case moderate:
        return "Liberalism";
      case conservative:
        return "Fascism";
    }
  }
}

enum DeepAlignment implements Comparable<DeepAlignment> {
  archConservative,
  conservative,
  moderate,
  liberal,
  eliteLiberal;

  Color get color {
    switch (this) {
      case eliteLiberal:
        return lightGreen;
      case liberal:
        return lightBlue;
      case moderate:
        return yellow;
      case conservative:
        return purple;
      case archConservative:
        return red;
    }
  }

  String get colorKey {
    switch (this) {
      case eliteLiberal:
        return ColorKey.lightGreen;
      case liberal:
        return ColorKey.lightBlue;
      case moderate:
        return ColorKey.yellow;
      case conservative:
        return ColorKey.purple;
      case archConservative:
        return ColorKey.red;
    }
  }

  String get label {
    switch (this) {
      case eliteLiberal:
        return "Revolutionary Socialist";
      case liberal:
        return "Socialist";
      case moderate:
        return "Liberal";
      case conservative:
        return "Reactionary";
      case archConservative:
        return "Fascist";
    }
  }

  String get short {
    switch (this) {
      case eliteLiberal:
        return "Soc+";
      case liberal:
        return "Soc";
      case moderate:
        return "Lib";
      case conservative:
        return "React";
      case archConservative:
        return "Fash";
    }
  }

  String get veryShort {
    switch (this) {
      case eliteLiberal:
        return "S+";
      case liberal:
        return "S ";
      case moderate:
        return "L ";
      case conservative:
        return "R ";
      case archConservative:
        return "F+";
    }
  }

  Alignment get shallow {
    switch (this) {
      case eliteLiberal:
      case liberal:
        return Alignment.liberal;
      case moderate:
        return Alignment.moderate;
      case conservative:
      case archConservative:
        return Alignment.conservative;
    }
  }

  bool operator >(DeepAlignment other) => index > other.index;
  bool operator <(DeepAlignment other) => index < other.index;
  bool operator >=(DeepAlignment other) => index >= other.index;
  bool operator <=(DeepAlignment other) => index <= other.index;
  @override
  int compareTo(DeepAlignment other) => index.compareTo(other.index);
}

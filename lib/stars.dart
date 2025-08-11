import 'coordinates.dart';

enum FovStars {
  //summer triangle
  deneb('Deneb', Coordinates(310, 45)),
  altair('Altair', Coordinates(298, 9)),
  vega('Vega', Coordinates(279, 39)),

  arcturus('Arcturus', Coordinates(214, 19)),
  antares('Antares', Coordinates(247, 26.42)),
  spica('Spica', Coordinates(201.25, -11.15)),
  fomalhaut('Fomalhaut', Coordinates(344.25, -29.62)),
  regulus('Regulus', Coordinates(152, 11.97)),
  bellatrix('Bellatrix', Coordinates(81.25, 6.33)),
  elnath('Elnath', Coordinates(81.5, 28.6)),
  polaris('Polaris', Coordinates(37.75, 89.25)),
  mirfak('Mirfak', Coordinates(51, 49.85)),
  algol('Algol', Coordinates(47, 40.95)),
  schedar('Schedar', Coordinates(10, 59.53)),
  dubhe('Dubhe', Coordinates(165.75, 61.75)),
  mizar('Mizar', Coordinates(200.75, 54.92)),
  rasalhague('Rasalhague', Coordinates(263.5, 12.55)),
  alpheratz('Alpheratz', Coordinates(2, 29.08)),
  hamal('Hamal', Coordinates(31.75, 23.45)),

  // winter hexagon
  rigel('Rigel', Coordinates(79, -8)),
  sirius('Sirius', Coordinates(101, -17)),
  procyon('Procyon', Coordinates(115, 5)),
  pollux('Pollux', Coordinates(116, 28)),
  capella('Capella', Coordinates(79, 46)),
  aldebaran('Aldebaran', Coordinates(69, 17)),
  castor('Castor', Coordinates(114, 32)),
  ;

  const FovStars(this.star, this.coords);
  final String star;
  final Coordinates coords;
}

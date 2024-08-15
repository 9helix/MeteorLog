import 'coordinates.dart';

enum FovStars {
  //summer triangle
  deneb('Deneb', Coordinates(310, 45)),
  altair('Altair', Coordinates(298, 9)),
  vega('Vega', Coordinates(279, 39)),

  arcturus('Arcturus', Coordinates(214, 19)),

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

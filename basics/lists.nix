let

  inherit (builtins) getAttr nixPath elem elemAt head tail length;

  getPath = getAttr "path";
  hasToveLo = elem "Tove Lo";
  hasSia = elem "Sia";
  firstElem = l: elemAt l 0;

  myArtists = [
    "Tove Lo"
    "Elliphant"
    "Florence and the Machine"
    "Tegan and Sara"
    "Sia"
  ];
  myArtistAt = elemAt myArtists;

  yourArtists = [
    "Rick Astley"
    "One Direction"
    "Take That"
    "Spice Girls"
  ];
  yourArtistAt = elemAt yourArtists;

  # Ok, only a tiny bit safer...because of null. Yuck. Sorry.
  saferHead = xs:
    if length xs > 0 then head xs else null;

  saferTail = xs:
    if length xs > 0 then tail xs else [];

in
{
  flattenedNixPath = map getPath nixPath;
  nixPath = nixPath;

  myArtistsContainsSia = hasSia myArtists;
  yourArtistsContainsToveLo = hasToveLo yourArtists;

  yourFirstArtist = yourArtistAt 0;
  yourArtistsHead = head yourArtists;
  yourArtistsTail = tail yourArtists;

  myFirstArtist = myArtistAt 0;
  myArtistsHead = head myArtists;
  myArtistsTail = tail myArtists;

  emptyListHead = head [];
  emptyListTail = tail [];

  emptyListSaferHead = saferHead [];
  emptyListSaferTail = saferTail [];

}

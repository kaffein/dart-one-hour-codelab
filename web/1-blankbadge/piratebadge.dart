// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:html';
import 'dart:math' show Random;
import 'dart:convert' show JSON;
import 'dart:async' show Future;

ButtonElement genButton;
final String TREASURE_KEY = 'pirateName';
SpanElement badgeNameElement;

void main() {
  // Your app starts here.
  // setBadgeName(getBadgeNameFromStorage());
  // querySelector('#inputName').onInput.listen(updateBadge);
  InputElement inputField = querySelector('#inputName');
  inputField.onInput.listen(updateBadge);
  genButton = querySelector('#generateButton');
  genButton.onClick.listen(generateBadge);
  badgeNameElement = querySelector('#badgeName');
  PirateName.readyThePirates().then((_) {
    //on success
    inputField.disabled = false;
    genButton.disabled = false;
    setBadgeName(getBadgeNameFromStorage());
  }).catchError((err){
    print('Error initializing pirate names : $err');
    badgeNameElement.text = 'Arrr! no names.';
  });
}

void updateBadge(Event e) {
  String inputName = (e.target as InputElement).value;
  setBadgeName(new PirateName(firstName: inputName));
  
  if(inputName.trim().isEmpty) {
    genButton..disabled = false
             ..text = 'Aye! Gimme a name!';
  } else {
    genButton..disabled = true
             ..text = 'Arrrr! Write yer name!';
  }
}

void setBadgeName(PirateName newName) {
  if(newName == null) {
    return;
  }
  
  querySelector('#badgeName').text = newName.pirateName;
  window.localStorage[TREASURE_KEY] = newName.jsonString;
}

void generateBadge(Event e) {
  setBadgeName(new PirateName());
}

PirateName getBadgeNameFromStorage() {
  String storedName = window.localStorage[TREASURE_KEY];
  if(storedName != null) {
    return new PirateName.fromJSON(storedName);
  } else {
    return null;
  }
}

class PirateName {
  
  static final Random indexGen = new Random();
  String _firstName;
  String _appellation;
  
  static List<String> names = [];
  static List<String> appellations = [];
    
    PirateName({String firstName, String appellation}) {
      if(firstName == null) {
        _firstName = names[indexGen.nextInt(names.length)];
      } else {
        _firstName = firstName;
      }
      
      if(appellation == null) {
        _appellation = appellations[indexGen.nextInt(appellations.length)];
      } else {
        _appellation = appellation;
      }
    }
    
    PirateName.fromJSON(String jsonString) {
      Map storedName = JSON.decode(jsonString);
      _firstName = storedName['f'];
      _appellation = storedName['a'];
    }
    
    String get pirateName => _firstName.isEmpty ? '' : '$_firstName then $_appellation';
    String get jsonString => JSON.encode({"f": _firstName, "a": _appellation });
    
    static Future readyThePirates() {
      var path = 'piratenames.json';
      return HttpRequest.getString(path).then(_parsePirateNamesFromJSON);
    }
    
    static _parsePirateNamesFromJSON(String jsonString) {
      Map pirateNames = JSON.decode(jsonString);
      names = pirateNames['names'];
      appellations = pirateNames['appellations'];
    }
}
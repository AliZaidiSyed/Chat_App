
String generateChatId(String userID1, String userID2){
  final ids=[userID1,userID2];
  ids.sort();
  return '${ids[0]}_${ids[1]}';
}
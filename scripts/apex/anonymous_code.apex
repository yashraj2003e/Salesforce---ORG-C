contact c = new contact(firstname = 'yy123');
contact c1 = new contact(firstname = 'yy1243');
List<contact> ls = new List<contact>{ c, c1 };
SavePoint sp = Database.setSavePoint();
List<Database.SaveResult> sr = Database.insert(ls, false);
for (Integer i = 0; i < sr.size(); i++) {
  Database.SaveResult s = sr[i];

  if (s.isSuccess()) {
    System.debug('Success Record: ' + ls[i]);
  } else {
    System.debug('Failed Record: ' + JSON.serialize(ls[i]));

    for (Database.Error d : s.getErrors()) {
      System.debug(d.getMessage());
      System.debug(d.getFields());
    }
  }
}
Database.rollback(sp);

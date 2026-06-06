// contact c = new contact(firstname = 'yy123');
// contact c1 = new contact(firstname = 'yy1243');
// List<contact> ls = new List<contact>{ c, c1 };
// SavePoint sp = Database.setSavePoint();
// List<Database.SaveResult> sr = Database.insert(ls, false);
// for (Integer i = 0; i < sr.size(); i++) {
//   Database.SaveResult s = sr[i];

//   if (s.isSuccess()) {
//     System.debug('Success Record: ' + ls[i]);
//   } else {
//     System.debug('Failed Record: ' + JSON.serialize(ls[i]));

//     for (Database.Error d : s.getErrors()) {
//       System.debug(d.getMessage());
//       System.debug(d.getFields());
//     }
//   }
// }
// Database.rollback(sp);

ID apacU = [SELECT id FROM user WHERE lastName = 'APAC' LIMIT 1].id;
ID amerU = [SELECT id FROM user WHERE lastName = 'AMER' LIMIT 1].id;
ID emeaU = [SELECT id FROM user WHERE lastName = 'EMEA' LIMIT 1].id;

List<market__c> apac = [
  SELECT id, ownerid
  FROM market__c
  WHERE region__c = 'APAC'
];
List<market__c> amer = [
  SELECT id, ownerid
  FROM market__c
  WHERE region__c = 'AMER'
];
List<market__c> emea = [
  SELECT id, ownerid
  FROM market__c
  WHERE region__c = 'EMEA'
];

for (market__c m : apac) {
  m.ownerid = apacU;
}
for (market__c m : amer) {
  m.ownerid = amerU;
}
for (market__c m : emea) {
  m.ownerid = emeaU;
}

update apac;
update amer;
update emea;

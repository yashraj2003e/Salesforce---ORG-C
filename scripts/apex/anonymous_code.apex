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

// ID apacU = [SELECT id FROM user WHERE lastName = 'APAC' LIMIT 1].id;
// ID amerU = [SELECT id FROM user WHERE lastName = 'AMER' LIMIT 1].id;
// ID emeaU = [SELECT id FROM user WHERE lastName = 'EMEA' LIMIT 1].id;

// List<market__c> apac = [
//   SELECT id, ownerid
//   FROM market__c
//   WHERE region__c = 'APAC'
// ];
// List<market__c> amer = [
//   SELECT id, ownerid
//   FROM market__c
//   WHERE region__c = 'AMER'
// ];
// List<market__c> emea = [
//   SELECT id, ownerid
//   FROM market__c
//   WHERE region__c = 'EMEA'
// ];

// for (market__c m : apac) {
//   m.ownerid = apacU;
// }
// for (market__c m : amer) {
//   m.ownerid = amerU;
// }
// for (market__c m : emea) {
//   m.ownerid = emeaU;
// }

// update apac;
// update amer;
// update emea;

// public Integer deactivationDays = 5;
// DateTime deactivationDate = System.now().addDays(-deactivationDays);
// List<User> users = [
//   SELECT id
//   FROM User
//   WHERE
//     profile.userLicense.name IN (
//       'Customer Community',
//       'Customer Community plus'
//     )
//     AND (lastlogindate < :deactivationDate
//     OR (lastlogindate = NULL
//     AND createddate < :deactivationDate))
// ];
// System.debug(users);

// String url = 'https://xyadadadz.com/abcd/ghi';

// Integer protocolEnd = url.indexOf('://');
// Integer pathStart = url.indexOf('/', protocolEnd + 3);

// String mainUrl = pathStart == -1
//     ? url
//     : url.substring(0, pathStart);

//System.debug(mainUrl);
// https://xyz.com

// List<CspTrustedSite> trustedSites = new List<CspTrustedSite>();

// trustedSites.add(new CspTrustedSite(
//     DeveloperName = 'Example1',
//     MasterLabel = 'Example1',
//     EndpointUrl = 'https://example1.com',
//     IsActive = true,
//     Context = 'ExperienceBuilder',
//     IsApplicableToConnectSrc = true,
//     IsApplicableToFrameSrc = true,
//     IsApplicableToImgSrc = false,
//     IsApplicableToStyleSrc = false,
//     IsApplicableToFontSrc = false,
//     IsApplicableToMediaSrc = false,
//     CanAccessCamera = false,
//     CanAccessMicrophone = false
// ));

// trustedSites.add(new CspTrustedSite(
//     DeveloperName = 'Example2',
//     MasterLabel = 'Example2',
//     EndpointUrl = 'https://example2.com',
//     IsActive = true,
//     Context = 'ExperienceBuilder',
//     IsApplicableToConnectSrc = true,
//     IsApplicableToFrameSrc = true,
//     IsApplicableToImgSrc = false,
//     IsApplicableToStyleSrc = false,
//     IsApplicableToFontSrc = false,
//     IsApplicableToMediaSrc = false,
//     CanAccessCamera = false,
//     CanAccessMicrophone = false
// ));

// insert trustedSites;

// csptrustedsite csp = new CspTrustedSite(
//     DeveloperName = 'Example2',
//     MasterLabel = 'Example2',
//     EndpointUrl = 'https://example2.com',
//     IsActive = true,
//     Context = 'ExperienceBuilder',
//     IsApplicableToConnectSrc = true,
//     IsApplicableToFrameSrc = true,
//     IsApplicableToImgSrc = false,
//     IsApplicableToStyleSrc = false,
//     IsApplicableToFontSrc = false,
//     IsApplicableToMediaSrc = false,
//     CanAccessCamera = false,
//     CanAccessMicrophone = false
// );

// insert csp;




// ID contactId = [select contactid from user where id = :UserInfo.getUserId()].contactId;

// string query = 'SELECT ' + dataToQuery + ' FROM CONTACT WHERE ID =: contactId';

// Contact contactData = database.query(query);


// List<String> params = new List<String>{'Name','Value'};
// System.debug(string.join(params,','));

System.debug('Before: ' + Limits.getQueries());

List<Account> accounts = [
    SELECT Id, Name
    FROM Account
];

System.debug('After: ' + Limits.getQueries());
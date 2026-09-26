// =====================================================================
// Seed data for video #1: lwc-apex-ai-code-review
//
// Run from the project root:
//   sf apex run --file scripts/apex/seed-test-data.apex --target-org <alias>
//
// Safe to re-run: deletes the previous seed Accounts (and their Contacts)
// first. Seed Accounts are tagged with AccountNumber 'SC-SEED-*'.
// =====================================================================

// ---- 1. Clean up any previous run ------------------------------------
List<Account> oldSeed = [SELECT Id FROM Account WHERE AccountNumber LIKE 'SC-SEED-%'];
if (!oldSeed.isEmpty()) {
    delete oldSeed; // Contacts on these Accounts are deleted with them
}

// ---- 2. Accounts -------------------------------------------------------
Account northwind  = new Account(Name = 'Northwind Traders',     AccountNumber = 'SC-SEED-001', Industry = 'Retail');
Account blueHarbor = new Account(Name = 'Blue Harbor Logistics', AccountNumber = 'SC-SEED-002', Industry = 'Transportation');
Account crestline  = new Account(Name = 'Crestline Health',      AccountNumber = 'SC-SEED-003', Industry = 'Healthcare'); // no Contacts: empty state
insert new List<Account>{ northwind, blueHarbor, crestline };

List<Contact> contacts = new List<Contact>();

// ---- 3. Edge-case Contacts on Northwind --------------------------------
// Row format: FirstName, LastName, Email, Phone, Title   (null = blank)
List<List<String>> edgeCases = new List<List<String>>{
    // Apostrophes: break string-concatenated SOQL in the search
    new List<String>{ 'Sean',      'O\'Brien',        'sean.obrien@example.com',     '(555) 010-1001',   'Procurement Manager' },
    new List<String>{ 'Priya',     'D\'Souza',        'priya.dsouza@example.com',    '555.010.1002',     'Head of Finance' },
    new List<String>{ 'Aoife',     'O\'Connor-Byrne', 'aoife.oconnor@example.com',   '+44 20 7946 0103', 'Operations Lead' },
    // Accented characters
    new List<String>{ 'Ana María', 'López',           'ana.lopez@example.com',       '555-010-1004',     'Regional Director' },
    // "ali" in a first name, a last name, and inside a name (Natalia): shows how search matches
    new List<String>{ 'Ali',       'Raza',            'ali.raza@example.com',        '+92 300 1234567',  'IT Manager' },
    new List<String>{ 'Alina',     'Petrova',         'alina.petrova@example.com',   '555-010-1006',     'Buyer' },
    new List<String>{ 'Khalid',    'Ali',             'khalid.ali@example.com',      '555-010-1007',     'Warehouse Supervisor' },
    new List<String>{ 'Natalia',   'Rosales',         'natalia.rosales@example.com', '555-010-1008',     'Account Executive' },
    // No first name
    new List<String>{ null,        'Jordan',          'jordan@example.com',          '555-010-1009',     'Consultant' },
    // Blank fields: inline edit on empty cells
    new List<String>{ 'Emma',      'Whitfield',       null,                          '555-010-1010',     'Office Manager' },
    new List<String>{ 'Marcus',    'Bell',            'marcus.bell@example.com',     null,               'Logistics Coordinator' },
    new List<String>{ 'Grace',     'Okafor',          'grace.okafor@example.com',    '555-010-1012',     null },
    new List<String>{ 'Tom',       'Hayes',           null,                          null,               null },
    // Very long title: column width / truncation
    new List<String>{ 'Victoria',  'Ashworth',        'v.ashworth@example.com',      '555-010-1014',
                      'Senior Vice President, Global Strategic Partnerships and Channel Enablement' }
};

for (List<String> r : edgeCases) {
    contacts.add(new Contact(
        AccountId = northwind.Id,
        FirstName = r[0],
        LastName  = r[1],
        Email     = r[2],
        Phone     = r[3],
        Title     = r[4]
    ));
}

// ---- 4. Filler Contacts on Northwind (volume for the table) ------------
List<String> firstNames = new List<String>{ 'James', 'Mei', 'Lucas', 'Elena', 'Daniel', 'Aisha', 'Noah',
                                            'Sofia', 'Ethan', 'Hana', 'Leo', 'Chloe', 'Rafael' };
List<String> lastNames  = new List<String>{ 'Carter', 'Nguyen', 'Silva', 'Fischer', 'Rahman', 'Kowalski' };
List<String> titles     = new List<String>{ 'Sales Rep', 'Buyer', 'Analyst', 'Engineer', 'Account Manager',
                                            'Support Specialist', 'Director of Operations' };

// 13 and 6 are coprime, so the first 78 name pairs are all unique
for (Integer i = 0; i < 25; i++) {
    String fn = firstNames[Math.mod(i, firstNames.size())];
    String ln = lastNames[Math.mod(i, lastNames.size())];
    contacts.add(new Contact(
        AccountId = northwind.Id,
        FirstName = fn,
        LastName  = ln,
        Email     = (fn + '.' + ln + '@example.com').toLowerCase(),
        Phone     = '555-020-' + String.valueOf(1000 + i),
        Title     = titles[Math.mod(i, titles.size())]
    ));
}

// ---- 5. A small, normal Account: Blue Harbor ---------------------------
List<List<String>> blueHarborRows = new List<List<String>>{
    new List<String>{ 'Oliver', 'Grant',    'oliver.grant@example.com',    '555-030-1001', 'Fleet Manager' },
    new List<String>{ 'Isla',   'Moreno',   'isla.moreno@example.com',     '555-030-1002', 'Dispatcher' },
    new List<String>{ 'Kenji',  'Watanabe', 'kenji.watanabe@example.com',  '555-030-1003', 'CFO' },
    new List<String>{ 'Amara',  'Obi',      'amara.obi@example.com',       '555-030-1004', 'Compliance Officer' },
    new List<String>{ 'Felix',  'Brandt',   'felix.brandt@example.com',    '555-030-1005', 'Driver Lead' },
    new List<String>{ 'Layla',  'Haddad',   'layla.haddad@example.com',    '555-030-1006', 'Customer Success' }
};

for (List<String> r : blueHarborRows) {
    contacts.add(new Contact(
        AccountId = blueHarbor.Id,
        FirstName = r[0],
        LastName  = r[1],
        Email     = r[2],
        Phone     = r[3],
        Title     = r[4]
    ));
}

insert contacts;

// ---- 6. Summary --------------------------------------------------------
for (AggregateResult ar : [
    SELECT Account.Name accName, COUNT(Id) total
    FROM Contact
    WHERE Account.AccountNumber LIKE 'SC-SEED-%'
    GROUP BY Account.Name
]) {
    System.debug(LoggingLevel.INFO, ar.get('accName') + ': ' + ar.get('total') + ' contacts');
}
System.debug(LoggingLevel.INFO, 'Crestline Health: 0 contacts (empty-state test)');

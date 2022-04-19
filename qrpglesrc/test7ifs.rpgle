**free

ctl-opt actgrp('TEST7IFS');

// data-gen examples
datagen_customer();

datagen_customer_morecomplex();

datagen_customer_toIFS();

// data-into examples
datainto_customer();

datainto_customer_morecomplex();

datainto_customer_fromIFS();

*inlr = '1';
return;

///
// data-gen simple example.
// How to use data-gen with a simple example.
///
dcl-proc datagen_customer;
    // @customer structure
    dcl-ds @customer qualified;
        name varchar(40);
        address varchar(40);
        city varchar(20);
        country varchar(40);
    end-ds;
    dcl-s @json varchar(1000);

    // Let's fill our structure
    @customer.name = 'Christian';
    @customer.address = 'My home';
    @customer.city = 'Málaga';
    @customer.country = 'Spain';

    // Let's use data-gen
    // This will generate a JSON string named @json with the structure
    // of the @customer data structure.
    data-gen @customer %data(@json) %gen('YAJL/YAJLDTAGEN');

end-proc;

///
// data-gen complex example.
// How to use data-gen with a little more complex example.
///
dcl-proc datagen_customer_morecomplex;

    // @customer structure
    // sometimes I need a "label" name that cannot be declared as a 
    // variable in rpg. I can do something like this:
    dcl-ds @customer qualified;
        name varchar(40);
        // this way, the "name" label will be named as "customer-name"
        namefor_name varchar(40) inz('customer-name');
        address varchar(40);
        namefor_address varchar(40) inz('customer-address');
        city varchar(20);
        country varchar(40);
    end-ds;
    dcl-s @json varchar(1000);

    // Let's fill our secound structure
    @customer.name = 'Christian';
    @customer.address = 'My home';
    @customer.city = 'Málaga';
    @customer.country = 'Spain';
    @json = *blanks;

    // It is important to use "renameprefix" option to change the 
    // label names, this way:
    data-gen @customer %data(@json:'renameprefix= namefor_') %gen('YAJL/YAJLDTAGEN');

end-proc;

///
// data-gen example 
// How to generate JSON in the IFS
///
dcl-proc datagen_customer_toIFS;
    // @customer structure
    dcl-ds @customer qualified;
        name varchar(40);
        address varchar(40);
        city varchar(20);
        country varchar(40);
    end-ds;
    dcl-s @myFile varchar(100);

    // Let's fill our structure
    @customer.name = 'Christian';
    @customer.address = 'My home';
    @customer.city = 'Málaga';
    @customer.country = 'Spain';

    // Let's use data-gen
    // This will generate a JSON file named EXAMPLE1.JSON with the structure
    // of the @customer data structure.
    @myFile = '/home/CLV/example1.json';

    data-gen @customer %data(@myFile: 'doc=file output=clear') %gen('YAJL/YAJLDTAGEN');

end-proc;

///
// data-into simple example.
// How to use data-into with a simple example.
///
dcl-proc datainto_customer;
    // @customer structure
    dcl-ds @customer qualified;
        name varchar(40);
        address varchar(40);
        city varchar(20);
        country varchar(40);
    end-ds;
    dcl-s @json varchar(1000);

    clear @customer;
    // Now, we have a json, and I need to import it to my structure...
    @json = '{ +
              "name" : "My name" ,  +
              "address" : "My Address" ,   +
              "city" : "My City" ,   +
              "country" : "My Country" +
            }';

    // It is as easy as this...
    data-into @customer %data(@json) %parser('YAJL/YAJLINTO');

end-proc;

///
// data-into more complex example.
// How to use data-into with a little more complex example.
///
dcl-proc datainto_customer_morecomplex;
    // @customer structure
    // This is a little more complex...
    dcl-ds @customer qualified dim(999);
        code zoned(5);
        name varchar(40);
        address varchar(40);
        city varchar(40);
        country varchar(40);
        // This is important, because I will have the "number of" items
        // in my "cars" substructure...
        numberof_cars int(10);
        dcl-ds cars dim(10);
            model char(40);
            age zoned(2);
        end-ds;
    end-ds;
    dcl-s @json varchar(1000);

    clear @customer;
    @json = '[{ +
              "code" : 1 ,  +
              "name" : "My Name" ,   +
              "address" : "My Address" ,   +
              "city" : "My City" ,   +
              "country" : "My Country" ,   +
              "cars" : [ +
                         { "model" : "Mercedes" , "age" : 2 } , +
                         { "model" : "Porsche" , "age" : 1 }   +
                        ] +
              } , +
              {   +
              "code" : 2 ,  +
              "name" : "Other Name" ,   +
              "address" : "Other Address" ,   +
              "city" : "Other City" ,   +
              "country" : "Other Country" ,   +
              "cars" : [ +
                         { "model" : "BMW" , "age" : 3 }  +
                        ] +
              } +
            ]';

    // If I need to "count" the number of items in my substructure "cars",
    // I have to define a "numberof_cars" variable, before the "cars" 
    // substructure, and use it this way:
    data-into @customer %DATA(@json:'countprefix=numberof_') %parser('YAJL/YAJLINTO');

end-proc;

///
// data-into example 
// How to read JSON directly from the IFS
///
dcl-proc datainto_customer_fromIFS;
    // @customer structure
    dcl-ds @customer qualified;
        name varchar(40);
        address varchar(40);
        city varchar(20);
        country varchar(40);
    end-ds;
    
    dcl-s @myFile varchar(100);

    clear @customer;

    // This will read a JSON file named EXAMPLE1.JSON and will
    // fill the @customer structure.

    @myFile = '/home/CLV/example1.json';
    
    // It is as easy as this...
    data-into @customer %data(@myFile:'doc=file') %parser('YAJL/YAJLINTO');

end-proc;
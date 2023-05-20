**free

ctl-opt actgrp('TEST7IFS') main(main);


dcl-proc main;

    exec sql
        set option commit = *none;
    
    dcl-pr QUSRJOBI extpgm;             
        *n  char(32766) options(*varsize);
        *n  int(10:0) const;              
        *n  char(8) const;                
        *n  char(26) const;               
        *n  char(16) const;               
    end-pr;                             
                                    
    dcl-ds Job len(86) qualified inz ;  
        Name  char(10) pos(9) ;         
        User   char(10) pos(19) ;        
        Number   char(6)  pos(29) ;        
    end-ds ;                            

    dcl-s #job char(50);

    QUSRJOBI(Job:%size(Job):'JOBI0100':'*':'') ;
    #job = %trim(job.number) + '/' + %trim(job.user) + '/' + %trim(job.name);

    // data-gen examples
    datagen_customer(#job); 

    datagen_customer_morecomplex();

    datagen_customer_toIFS();

    // data-into examples
    datainto_customer(#job);

    datainto_customer_morecomplex();

    datainto_customer_fromIFS();

    return;

end-proc;

///
// data-gen simple example.
// How to use data-gen with a simple example.
///
dcl-proc datagen_customer;
    dcl-pi *n;
        #job char(50);
    end-pi;
    // @customer structure
    dcl-ds @customer qualified;
        name varchar(40);
        address varchar(40);
        city varchar(20);
        country varchar(40);
    end-ds;
    dcl-s @json varchar(1000);
    dcl-s message_text varchar(100);
    dcl-s message_second_level_text varchar(200);
    dcl-s statement varchar(1000);

    // Let's fill our structure
    @customer.name = 'Christian';
    @customer.address = 'My home';
    @customer.city = 'Málaga';
    @customer.country = 'Spain';

    // Let's use data-gen
    // This will generate a JSON string named @json with the structure
    // of the @customer data structure.
    
    monitor;
        data-gen @customer %data(@json) %gen('YAJL/YAJLDTAGEN');
    on-error;
        statement = ' +
            select message_text, message_second_level_text +
            from table(QSYS2.JOBLOG_INFO(''' +
            %trim(#job) + 
            ''')) +
            where to_program = ''YAJLDTAGEN'' + 
            order by ordinal_position + 
            desc fetch first 1 row only';
            
        exec sql            
            prepare stmPrep from :statement;

        exec sql
            declare curPrep cursor for stmPrep;

        exec sql
            open curPrep;
        
        exec sql
            fetch curPrep into :message_text, :message_second_level_text;

        exec sql
            close curPrep;

        //exec sql
        //    select message_text, message_second_level_text into
        //    :message_text, :message_second_level_text
        //    from table('QSYS2.JOBLOG_INFO(:a)''')
        //    where to_program = 'YAJLDTAGEN'
        //    order by ordinal_position
        //    desc fetch first 1 row only
    endmon;
    return;

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
    return;

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
    @customer.city = 'Malaga';
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
    dcl-pi;
        #job char(50);
    end-pi;
    // @customer structure
    dcl-ds @customer qualified;
        name varchar(40);
        address varchar(40);
        city varchar(20);
        country varchar(40);
    end-ds;
    dcl-s @json varchar(1000);
    dcl-s message_text varchar(100);
    dcl-s message_second_level_text varchar(200);
    dcl-s statemen varchar(1000);

    clear @customer;
    // Now, we have a json, and I need to import it to my structure...
    @json = '{ +
              "name" : "My name" ,  +
              "address" : "My Address" ,   +
              "city" : "My City" ,   +
              "country" : "My Country" +
            }';

    // It is as easy as this...
    monitor;
        data-into @customer %data(@json) %parser('YAJL/YAJLINTO');
    on-error;
        statemen = ' +
            select message_text, message_second_level_text +
            from table(QSYS2.JOBLOG_INFO(''' +
            %trim(#job) + 
            ''')) +
            where to_program = ''YAJLINTO'' + 
            order by ordinal_position + 
            desc fetch first 1 row only';
            
        exec sql            
            prepare stmPre from :statemen;

        exec sql
            declare curPre cursor for stmPre;

        exec sql
            open curPre;
        
        exec sql
            fetch curPre into :message_text, :message_second_level_text;

        exec sql
            close curPre;
    endmon;

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
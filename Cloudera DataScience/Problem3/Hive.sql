---- HIVE FOR DATA PREPARATION AND VALIDATION -----

-- Pcdr --- Procedure data

create table pcdr
(
procedure_date date,
id string,
procedure_id string)

-- Changing the date from string to date data type
insert overwrite table pcdr
select to_date(from_unixtime(unix_timestamp(column1, 'yyyyMMdd'))) , column2, column3 from table_txt ;

create table pcdr_trfmd
(
procedure_date date,
id string,
procedure_id int)
ROW FORMAT DELIMITED
        FIELDS TERMINATED BY ','
STORED as TEXTFILE

insert overwrite table pcdr_trfmd
select procedure_date, id, cast(procedure_id as int) from pcdr

--- pntd_trfmd creating flags for gndr, age and income
create table pntd_trfmd
(
id string,
gndr string,
age string,
inc string,
gndrM int,
gndrF int,
ageGT65 int,
age65TO74 int,
age75TO84 int,
age85Plus int,
incLT16000 int,
inc16000to23900 int,
inc24000to31999 int,
inc32000to47999 int,
inc48000Plus int
)
ROW FORMAT DELIMITED
        FIELDS TERMINATED BY ','
STORED as TEXTFILE

--- case statement to create flags
insert overwrite table pntd_trfmd
select 
id,
gndr,
age,
inc, 
case when upper(trim(gndr))='M' then 1 else 0 end,
case when upper(trim(gndr))='F' then 1 else 0 end,
case when trim(age)='<65' then 1 else 0 end,
case when trim(age)='65-74' then 1 else 0 end,
case when trim(age)='75-84' then 1 else 0 end,
case when trim(age)='85+' then 1 else 0 end,
case when trim(inc) like '<16000%' then 1 else 0 end,
case when trim(inc) like '16000-23999%' then 1 else 0 end,
case when trim(inc) like '24000-31999%' then 1 else 0 end,
case when trim(inc) like '32000-47999%' then 1 else 0 end,
case when trim(inc) like '48000+%' then 1 else 0 end
from pntd

--- pcdr_pntd_trfmd - Join of tables pcdr and pntd_trfmd is stored in pcdr_pntd_trfmd
create table pcdr_pntd_trfmd
(
procedure_date date, procedure_id string, id string, gndr string, age string, inc string, gndrM int, gndrF int, ageGT65 int, age65TO74 int, age75TO84 int, age85Plus int, incLT16000 int,inc16000to23900 int, inc24000to31999 int, inc32000to47999 int, inc48000Plus int
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED as TEXTFILE

insert overwrite table pcdr_pntd_trfmd
select a.procedure_date, a.procedure_id, b.* from pcdr_trfmd a JOIN pntd_trfmd b ON (a.id = b.id)

--- pcdr_pntd_trfmd_review  - JOIN of review data and resultant of patient and procedure data
create table pcdr_pntd_trfmd_review
(
procedure_date date,

procedure_id string,
id string,
gndr string,
age string,
inc string,
gndrM int,
gndrF int,
ageGT65 int,
age65TO74 int,
age75TO84 int,
age85Plus int,
incLT16000 int,
inc16000to23900 int,
inc24000to31999 int,
inc32000to47999 int,
inc48000Plus int
)
ROW FORMAT DELIMITED
        FIELDS TERMINATED BY ','
STORED as TEXTFILE

insert overwrite table pcdr_pntd_trfmd_review
select b.* from pcdr_pntd_trfmd b JOIN review_id a on (b.id=a.id)

-- Denormalizing the pcdr data and creating one column for a given procedure
create table pcdr_trfmd_denorm
(procdure_date date,id string,isDRG int,isAPC int,is039 int,is057 int,is064 int,is065 int,is066 int,is069 int,is074 int,is101 int,is149 int,is176 int,is177 int,is178 int,is189 int,is190 int,is191 int,is192 int,is193 int,is194 int,is195 int,is202 int,is203 int,is207 int,is208 int,is238 int,is243 int,is244 int,is246 int,is247 int,is249 int,is251 int,is252 int,is253 int,is254 int,is280 int,is281 int,is282 int,is286 int,is287 int,is291 int,is292 int,is293 int,is300 int,is301 int,is303 int,is305 int,is308 int,is309 int,is310 int,is312 int,is313 int,is314 int,is315 int,is329 int,is330 int,is372 int,is377 int,is378 int,is379 int,is389 int,is390 int,is391 int,is392 int,is394 int,is418 int,is419 int,is439 int,is460 int,is469 int,is470 int,is473 int,is480 int,is481 int,is482 int,is491 int,is536 int,is552 int,is563 int,is602 int,is603 int,is638 int,is640 int,is641 int,is682 int,is683 int,is684 int,is689 int,is690 int,is698 int,is699 int,is811 int,is812 int,is853 int,is870 int,is871 int,is872 int,is885 int,is897 int,is917 int,is918 int,is948 int,is0012 int,is0013 int,is0015 int,is0019 int,is0020 int,is0073 int,is0074 int,is0078 int,is0096 int,is0203 int,is0204 int,is0206 int,is0207 int,is0209 int,is0265 int,is0267 int,is0269 int,is0270 int,is0336 int,is0368 int,is0369 int,is0377 int,is0604 int,is0605 int,is0606 int,is0607 int,is0608 int,is0690 int,is0692 int,is0698 int)

--- group by id and transposing the data - 300M records converted to 100M records for procedure data
create table pcdr_trfmd_denorm_1
(id string,isDRG int,isAPC int,is039 int,is057 int,is064 int,is065 int,is066 int,is069 int,is074 int,is101 int,is149 int,is176 int,is177 int,is178 int,is189 int,is190 int,is191 int,is192 int,is193 int,is194 int,is195 int,is202 int,is203 int,is207 int,is208 int,is238 int,is243 int,is244 int,is246 int,is247 int,is249 int,is251 int,is252 int,is253 int,is254 int,is280 int,is281 int,is282 int,is286 int,is287 int,is291 int,is292 int,is293 int,is300 int,is301 int,is303 int,is305 int,is308 int,is309 int,is310 int,is312 int,is313 int,is314 int,is315 int,is329 int,is330 int,is372 int,is377 int,is378 int,is379 int,is389 int,is390 int,is391 int,is392 int,is394 int,is418 int,is419 int,is439 int,is460 int,is469 int,is470 int,is473 int,is480 int,is481 int,is482 int,is491 int,is536 int,is552 int,is563 int,is602 int,is603 int,is638 int,is640 int,is641 int,is682 int,is683 int,is684 int,is689 int,is690 int,is698 int,is699 int,is811 int,is812 int,is853 int,is870 int,is871 int,is872 int,is885 int,is897 int,is917 int,is918 int,is948 int,is0012 int,is0013 int,is0015 int,is0019 int,is0020 int,is0073 int,is0074 int,is0078 int,is0096 int,is0203 int,is0204 int,is0206 int,is0207 int,is0209 int,is0265 int,is0267 int,is0269 int,is0270 int,is0336 int,is0368 int,is0369 int,is0377 int,is0604 int,is0605 int,is0606 int,is0607 int,is0608 int,is0690 int,is0692 int,is0698 int)
--- join the denormalized procedure data with patient data
create table pntd_pcdr_trfmd_denorm
(id string,isDRG int,isAPC int,is039 int,is057 int,is064 int,is065 int,is066 int,is069 int,is074 int,is101 int,is149 int,is176 int,is177 int,is178 int,is189 int,is190 int,is191 int,is192 int,is193 int,is194 int,is195 int,is202 int,is203 int,is207 int,is208 int,is238 int,is243 int,is244 int,is246 int,is247 int,is249 int,is251 int,is252 int,is253 int,is254 int,is280 int,is281 int,is282 int,is286 int,is287 int,is291 int,is292 int,is293 int,is300 int,is301 int,is303 int,is305 int,is308 int,is309 int,is310 int,is312 int,is313 int,is314 int,is315 int,is329 int,is330 int,is372 int,is377 int,is378 int,is379 int,is389 int,is390 int,is391 int,is392 int,is394 int,is418 int,is419 int,is439 int,is460 int,is469 int,is470 int,is473 int,is480 int,is481 int,is482 int,is491 int,is536 int,is552 int,is563 int,is602 int,is603 int,is638 int,is640 int,is641 int,is682 int,is683 int,is684 int,is689 int,is690 int,is698 int,is699 int,is811 int,is812 int,is853 int,is870 int,is871 int,is872 int,is885 int,is897 int,is917 int,is918 int,is948 int,is0012 int,is0013 int,is0015 int,is0019 int,is0020 int,is0073 int,is0074 int,is0078 int,is0096 int,is0203 int,is0204 int,is0206 int,is0207 int,is0209 int,is0265 int,is0267 int,is0269 int,is0270 int,is0336 int,is0368 int,is0369 int,is0377 int,is0604 int,is0605 int,is0606 int,is0607 int,is0608 int,is0690 int,is0692 int,is0698 int,gndrm                   int                ,gndrf                   int                    ,agegt65                 int                  ,age65to74               int                 ,age75to84               int                  ,age85plus               int                    ,inclt16000              int                     ,inc16000to23900         int               ,inc24000to31999         int                ,inc32000to47999         int                 ,inc48000plus            int)
ROW FORMAT DELIMITED        FIELDS TERMINATED BY ','
STORED as TEXTFILE

insert overwrite table pntd_pcdr_trfmd_denorm
select a.*, b.gndrm ,b.gndrf, b.agegt65 , b.age65to74   ,b.age75to84  ,
b.age85plus,b.inclt16000 ,b.inc16000to23900   ,b.inc24000to31999,b.inc32000to47999,
inc48000plus  
from pcdr_trfmd_denorm_1 a JOIN pntd_trfmd b ON (a.id = b.id)


insert overwrite table  pntd_pcdr_trfmd_denorm_review
select b.* from pntd_pcdr_trfmd_denorm b JOIN review_id a on (b.id=a.id)

-- join with patient_procedure data with review data to prepare the training data for positives/fraudulent
create table pntd_pcdr_trfmd_denorm_review(id string,isDRG int,isAPC int,is039 int,is057 int,is064 int,is065 int,is066 int,is069 int,is074 int,is101 int,is149 int,is176 int,is177 int,is178 int,is189 int,is190 int,is191 int,is192 int,is193 int,is194 int,is195 int,is202 int,is203 int,is207 int,is208 int,is238 int,is243 int,is244 int,is246 int,is247 int,is249 int,is251 int,is252 int,is253 int,is254 int,is280 int,is281 int,is282 int,is286 int,is287 int,is291 int,is292 int,is293 int,is300 int,is301 int,is303 int,is305 int,is308 int,is309 int,is310 int,is312 int,is313 int,is314 int,is315 int,is329 int,is330 int,is372 int,is377 int,is378 int,is379 int,is389 int,is390 int,is391 int,is392 int,is394 int,is418 int,is419 int,is439 int,is460 int,is469 int,is470 int,is473 int,is480 int,is481 int,is482 int,is491 int,is536 int,is552 int,is563 int,is602 int,is603 int,is638 int,is640 int,is641 int,is682 int,is683 int,is684 int,is689 int,is690 int,is698 int,is699 int,is811 int,is812 int,is853 int,is870 int,is871 int,is872 int,is885 int,is897 int,is917 int,is918 int,is948 int,is0012 int,is0013 int,is0015 int,is0019 int,is0020 int,is0073 int,is0074 int,is0078 int,is0096 int,is0203 int,is0204 int,is0206 int,is0207 int,is0209 int,is0265 int,is0267 int,is0269 int,is0270 int,is0336 int,is0368 int,is0369 int,is0377 int,is0604 int,is0605 int,is0606 int,is0607 int,is0608 int,is0690 int,is0692 int,is0698 int,gndrm                   int                ,gndrf                   int                    ,agegt65                 int                  ,age65to74               int                 ,age75to84               int                  ,age85plus               int                    ,inclt16000              int                     ,inc16000to23900         int               ,inc24000to31999         int                ,inc32000to47999         int                 ,inc48000plus            int)
ROW FORMAT DELIMITED        FIELDS TERMINATED BY ','
STORED as TEXTFILE

--- Additional variable (sumDRG  int,sumAPC int,APCgtDRG int,DRGminusAPC int,fraudProcedure int) --added
create table pntd_pcdr_trfmd_denorm_additional_variables
(id string,isDRG int,isAPC int,is039 int,is057 int,is064 int,is065 int,is066 int,is069 int,is074 int,is101 int,is149 int,is176 int,is177 int,is178 int,is189 int,is190 int,is191 int,is192 int,is193 int,is194 int,is195 int,is202 int,is203 int,is207 int,is208 int,is238 int,is243 int,is244 int,is246 int,is247 int,is249 int,is251 int,is252 int,is253 int,is254 int,is280 int,is281 int,is282 int,is286 int,is287 int,is291 int,is292 int,is293 int,is300 int,is301 int,is303 int,is305 int,is308 int,is309 int,is310 int,is312 int,is313 int,is314 int,is315 int,is329 int,is330 int,is372 int,is377 int,is378 int,is379 int,is389 int,is390 int,is391 int,is392 int,is394 int,is418 int,is419 int,is439 int,is460 int,is469 int,is470 int,is473 int,is480 int,is481 int,is482 int,is491 int,is536 int,is552 int,is563 int,is602 int,is603 int,is638 int,is640 int,is641 int,is682 int,is683 int,is684 int,is689 int,is690 int,is698 int,is699 int,is811 int,is812 int,is853 int,is870 int,is871 int,is872 int,is885 int,is897 int,is917 int,is918 int,is948 int,is0012 int,is0013 int,is0015 int,is0019 int,is0020 int,is0073 int,is0074 int,is0078 int,is0096 int,is0203 int,is0204 int,is0206 int,is0207 int,is0209 int,is0265 int,is0267 int,is0269 int,is0270 int,is0336 int,is0368 int,is0369 int,is0377 int,is0604 int,is0605 int,is0606 int,is0607 int,is0608 int,is0690 int,is0692 int,is0698 int,gndrm                   int                ,gndrf                   int                    ,agegt65                 int                  ,age65to74               int                 ,age75to84               int                  ,age85plus               int                    ,inclt16000              int                     ,inc16000to23900         int               ,inc24000to31999         int                ,inc32000to47999         int                 ,inc48000plus            int,sumDRG  int,sumAPC int,APCgtDRG int,DRGminusAPC int,fraudProcedure int)
ROW FORMAT DELIMITED        FIELDS TERMINATED BY ','
STORED as TEXTFILE
--- created 30% testing data
create table pntd_pcdr_trfmd_denorm_review_30pct
(id string,isDRG int,isAPC int,is039 int,is057 int,is064 int,is065 int,is066 int,is069 int,is074 int,is101 int,is149 int,is176 int,is177 int,is178 int,is189 int,is190 int,is191 int,is192 int,is193 int,is194 int,is195 int,is202 int,is203 int,is207 int,is208 int,is238 int,is243 int,is244 int,is246 int,is247 int,is249 int,is251 int,is252 int,is253 int,is254 int,is280 int,is281 int,is282 int,is286 int,is287 int,is291 int,is292 int,is293 int,is300 int,is301 int,is303 int,is305 int,is308 int,is309 int,is310 int,is312 int,is313 int,is314 int,is315 int,is329 int,is330 int,is372 int,is377 int,is378 int,is379 int,is389 int,is390 int,is391 int,is392 int,is394 int,is418 int,is419 int,is439 int,is460 int,is469 int,is470 int,is473 int,is480 int,is481 int,is482 int,is491 int,is536 int,is552 int,is563 int,is602 int,is603 int,is638 int,is640 int,is641 int,is682 int,is683 int,is684 int,is689 int,is690 int,is698 int,is699 int,is811 int,is812 int,is853 int,is870 int,is871 int,is872 int,is885 int,is897 int,is917 int,is918 int,is948 int,is0012 int,is0013 int,is0015 int,is0019 int,is0020 int,is0073 int,is0074 int,is0078 int,is0096 int,is0203 int,is0204 int,is0206 int,is0207 int,is0209 int,is0265 int,is0267 int,is0269 int,is0270 int,is0336 int,is0368 int,is0369 int,is0377 int,is0604 int,is0605 int,is0606 int,is0607 int,is0608 int,is0690 int,is0692 int,is0698 int,gndrm                   int                ,gndrf                   int                    ,agegt65                 int                  ,age65to74               int                 ,age75to84               int                  ,age85plus               int                    ,inclt16000              int                     ,inc16000to23900         int               ,inc24000to31999         int                ,inc32000to47999         int                 ,inc48000plus            int,sumDRG  int,sumAPC int,APCgtDRG int,DRGminusAPC int,fraudProcedure int)
ROW FORMAT DELIMITED        FIELDS TERMINATED BY ','
STORED as TEXTFILE

--- complete Review data
insert overwrite table  pntd_pcdr_trfmd_denorm_review
select b.* from pntd_pcdr_trfmd_denorm_additional_variables b JOIN review_id a on (b.id=a.id)

-- 70% positive data for training 

insert overwrite table  pntd_pcdr_trfmd_denorm_review_70pct
select * from pntd_pcdr_trfmd_denorm_review limit 35000

-- 30% positive data for testing 

insert overwrite table  pntd_pcdr_trfmd_denorm_review_30pct
select a.* from pntd_pcdr_trfmd_denorm_review  a  left outer JOIN pntd_pcdr_trfmd_denorm_review_70pct b on (a.id =b.id) where b.id is null

insert overwrite table  pntd_pcdr_trfmd_denorm_test_10m
select * from pntd_pcdr_trfmd_denorm_additional_variables limit 10500000

create table rf_prediction_review(id string, var string, probability float, prediction int) 
ROW FORMAT DELIMITED
        FIELDS TERMINATED BY ','
STORED as TEXTFILE

create table rf_prediction_50T_not_in_review
 (id string, var string, probability float, prediction int) 
ROW FORMAT DELIMITED
        FIELDS TERMINATED BY ','
STORED as TEXTFILE

create table rf_prediction_100M_FLOAT
 (id int, var string, probability float, prediction int) 
ROW FORMAT DELIMITED
        FIELDS TERMINATED BY ','
STORED as TEXTFILE
LOCATION ‘/tmp/ds/data/rf_prediction’
;
create table rf_prediction_10T
 (id string, var string, probability float, prediction int) 
ROW FORMAT DELIMITED
        FIELDS TERMINATED BY ','
STORED as TEXTFILE

Create table fraud_id
(id string)

---- 10 Million records which are not in Review for creating negative data
insert overwrite table  pntd_pcdr_trfmd_denorm_test_10m_notin_review
select a.* from pntd_pcdr_trfmd_denorm_test_10m  a  left outer JOIN pntd_pcdr_trfmd_denorm_review b on (a.id =b.id) where b.id is null
insert overwrite table  rf_prediction_review
select b.* from rf_prediction_100M_FLOAT b JOIN review_id a on (b.id=a.id)

--- Removing the Review data from the resultant trained data
insert overwrite table  rf_prediction_50T_not_in_review
select a.* from rf_prediction_100M_FLOAT a left outer JOIN review_id b on (a.id=b.id) where  a.prediction=1 and  b.id is null order by a.probability desc  limit 50000

create table RF_50T_FOR_VALIDATION
(id string,isDRG int,isAPC int,is039 int,is057 int,is064 int,is065 int,is066 int,is069 int,is074 int,is101 int,is149 int,is176 int,is177 int,is178 int,is189 int,is190 int,is191 int,is192 int,is193 int,is194 int,is195 int,is202 int,is203 int,is207 int,is208 int,is238 int,is243 int,is244 int,is246 int,is247 int,is249 int,is251 int,is252 int,is253 int,is254 int,is280 int,is281 int,is282 int,is286 int,is287 int,is291 int,is292 int,is293 int,is300 int,is301 int,is303 int,is305 int,is308 int,is309 int,is310 int,is312 int,is313 int,is314 int,is315 int,is329 int,is330 int,is372 int,is377 int,is378 int,is379 int,is389 int,is390 int,is391 int,is392 int,is394 int,is418 int,is419 int,is439 int,is460 int,is469 int,is470 int,is473 int,is480 int,is481 int,is482 int,is491 int,is536 int,is552 int,is563 int,is602 int,is603 int,is638 int,is640 int,is641 int,is682 int,is683 int,is684 int,is689 int,is690 int,is698 int,is699 int,is811 int,is812 int,is853 int,is870 int,is871 int,is872 int,is885 int,is897 int,is917 int,is918 int,is948 int,is0012 int,is0013 int,is0015 int,is0019 int,is0020 int,is0073 int,is0074 int,is0078 int,is0096 int,is0203 int,is0204 int,is0206 int,is0207 int,is0209 int,is0265 int,is0267 int,is0269 int,is0270 int,is0336 int,is0368 int,is0369 int,is0377 int,is0604 int,is0605 int,is0606 int,is0607 int,is0608 int,is0690 int,is0692 int,is0698 int,gndrm                   int                ,gndrf                   int                    ,agegt65                 int                  ,age65to74               int                 ,age75to84               int                  ,age85plus               int                    ,inclt16000              int                     ,inc16000to23900         int               ,inc24000to31999         int                ,inc32000to47999         int                 ,inc48000plus            int,sumDRG  int,sumAPC int,APCgtDRG int,DRGminusAPC int,fraudProcedure int)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED as TEXTFILE

--- after running the model create 50 Thousand positive data which will be tested again with Random
--- Forest and Naive Bayes
insert overwrite table RF_50T_FOR_VALIDATION
select a.* from pntd_pcdr_trfmd_denorm_additional_variables a JOIN rf_prediction_50T_not_in_review b on (b.id=a.id)


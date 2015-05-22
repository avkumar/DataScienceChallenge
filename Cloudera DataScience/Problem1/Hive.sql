
/* Loading Inpatient and outpatient data */
/* Validating the data .. processes created by Python and R */
create table procedure_data (
procedure_id string,
Provider_Id string,
Provider_Name string,
Provider_Street_Address string,
Provider_City string,
Provider_State string,
Provider_Zip_Code string,
Hospital_Referral_Region_Description string,
Outpatient_Services float,
Average_Estimated_Submitted_Charges float,
Average_Total_Payments float
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
STORED as TEXTFILE
location '/data/medicare1/'

//PART A - Answer
207 - RESPIRATORY SYSTEM DIAGNOSIS W VENTILATOR SUPPORT 96+ HOURS       929107.94
870 - SEPTICEMIA OR SEVERE SEPSIS W MV 96+ HOURS        637366.7
853 - INFECTIOUS & PARASITIC DISEASES W O.R. PROCEDURE W MCC    576285.0

// part b
creating a averages charges per procedure and provider 
create table provder_procedure_avg_charges
    (
     provider_id string,
     apc string,
     avg_charge float);

create table max_avg_charge
(max_avg_charge float)
create table provider_max_cost_procedure
(
HRR string
provider_id string,
apc string
)

/* average estimated cost per provider and procedure */

insert overwrite table provder_procedure_avg_charges
select provider_id, procedure_id , avg(Average_Estimated_Submitted_Charges) from procedure_data  group by provider_id,apc

/* Max of the average based on procedure */

insert overwrite table max_avg_charge
select max(avg_charge) from provder_procedure_avg_charges group by apc

/* Finding the max average per procedure falling under a particulare provider */ 

insert overwrite table provider_max_cost_procedure
select distinct a.provider_id,a.apc from provder_procedure_avg_charges a JOIN max_avg_charge b on (a.avg_charge=b.max_avg_charge);

/* Finding the provider who has maximum procedures having max cost */

select provider_id, count(apc) as apc_cnt from provider_max_cost_procedure order by apc_cnt desc

Answer 
310025  
390180  
50441   

part c
creating a averages charges per procedure and provider 
create table region_procedure_avg_charges
    (
     hrr string,
     apc string,
     avg_charge float);


create table region_max_avg_charge
(max_avg_charge float)

create table region_max_cost_procedure
(
hrr string,
apc string
)

/* (estimated charges*number of procedures per apc)/total procedures */
insert overwrite table region_procedure_avg_charges
select Hospital_Referral_Region_Description , procedure_id , (sum(Average_Estimated_Submitted_Charges*outpatient_services))/(sum(outpatient_services)) from procedure_data  group by Hospital_Referral_Region_Description ,procedure_id

/* Max average charge */
insert overwrite table region_max_avg_charge 
select max(avg_charge) from region_procedure_avg_charges group by apc

/* Region have max average charges and more procedures */
insert overwrite table region_max_cost_procedure
select distinct a.hrr,a.apc from region_procedure_avg_charges a JOIN region_max_avg_charge b on (a.avg_charge=b.max_avg_charge);
select hrr, count(apc) as apc_cnt from region_max_cost_procedure group by hrr order by apc_cnt desc

Answer

CA - Contra Costa County        39
CA - San Mateo County   27
CA - Santa Cruz 9

Partd

creating a averages charges per procedure and provider 
create table provider_claim_diff_charges
    (
     provider_id string,
     apc string,
     claim_diff float);


create table max_diff_charge
(max_diff_charge float)

create table provider_max_diff_procedure
(
provider_id string,
apc string
)

/*insert overwrite table provider_claim_diff_charges
select provider_id, procedure_id , sum(Average_Total_Payments) -sum(Average_Estimated_Submitted_Charges)  from procedure_data  group by provider_id,procedure_id
*/

insert overwrite table provider_claim_diff_charges
select provider_id, procedure_id , (Average_Estimated_Submitted_Charges-Average_Total_Payments )  from procedure_data 
-- group by provider_id,procedure_id


insert overwrite table max_diff_charge
select max(claim_diff) from provider_claim_diff_charges group by apc

insert overwrite table provider_max_diff_procedure
select distinct a.provider_id,a.apc from provider_claim_diff_charges a JOIN max_diff_charge b on (a.claim_diff=b.max_diff_charge);
select provider_id, count(apc) as apc_cnt from provider_max_diff_procedure group by provider_id order by apc_cnt desc


select provider_id, count(procedure_id) as cnt, sum(outpatient_services), sum(average_estimated_submitted_charges), sum(average_total_payments)  from procedure_data group by provider_id  order by cnt desc limit 100;

Answer
310025  27
390180  13
390290  8



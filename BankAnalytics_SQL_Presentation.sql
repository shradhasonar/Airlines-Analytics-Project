select * from finance1;
select * from finance2;

-- KPI 1 --Year wise loan amount Stat
select year(issue_d) as year,
concat(format(round(sum(loan_amnt)/1000000,2),2),"M") as total_loan_amount
from finance1
group by year
order by year;

-- KPI 2 -- Grade and sub grade wise revol_bal
select grade,sub_grade,
concat(format(round(sum(revol_bal)/1000000,2),2),"M") as total_revol_bal
from finance1 inner join finance2
on finance1.id = finance2.id
group by grade,sub_grade
order by grade,sub_grade;

-- KPI 3 -- Total Payment for Verified Status Vs Total Payment for Non Verified Status
select verification_status,
concat(format(round(sum(total_pymnt)/1000000,2),2),"M") as total_payment
from finance1 inner join finance2
on finance1.id = finance2.id
group by verification_status;

-- KPI 4 -- State wise and last_credit_pull_d wise loan status
select addr_state,last_credit_pull_d,loan_status,count(loan_status)
from finance1 inner join finance2
on finance1.id = finance2.id
WHERE last_credit_pull_d IS NOT NULL
group by addr_state,last_credit_pull_d,loan_status
order by last_credit_pull_d,addr_state;

-- KPI 5 -- Home ownership Vs last payment date stats
select home_ownership,last_pymnt_d,count(finance1.id) as Total_Loan_Application
from finance1 inner join finance2
on finance1.id = finance2.id
group by home_ownership,last_pymnt_d
order by last_pymnt_d;

-- KPI 6 --Top 10 States As per Loan Applications Received
select addr_state,count(finance1.id) as Total_Loan_Application
from finance1
group by addr_state
order by count(finance1.id) desc
LIMIT 10;

-- KPI 7 -- Home Owenership Based Funded Amt
select home_ownership,concat(format(round(sum(funded_amnt)/1000000,2),2),"M") as Total_Funded_Amt
from finance1
group by home_ownership
order by sum(funded_amnt) desc;








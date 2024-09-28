create database Fraud_detection

select * from Financial_Transcation.dbo.Financial

-------------------------------------------------------------Description of Columns------------------------------------------
---nameOrigin		    customer_initiating_transaction_ID
---nameDest		        transaction's recipient customer.
---oldbalanceDest		The initial recipient's balance before the transaction. Not applicable for customers identified by 'M' (Merchants).
---newbalanceDest		The new recipient's balance after the transaction. Not applicable for 'M' (Merchants).
---step                 Represents a unit of time in the real world, with 1 step equating to 1 hour.The total simulation spans 744 steps, equivalent to 30 days.

------------------------------------------------------------------------------------------
---Q -1 Data Cleaning (deleting the unused column) or we can say Normalization

select isFlaggedFraud from Financial_Transcation.dbo.Financial
where isFlaggedFraud >0

alter table Financial
drop column isFlaggedFraud

-------------------------------------------------------------------------------------------
---Q -2 Finding out the payment types with their highest transaction amount 

select type, sum(amount) as Transaction_
from Financial_Transcation.dbo.Financial
group by type
order by Transaction_ desc

-------------------------------------------------------------------------------------------
---Q -3 Finding out the Merchant payment details with total merchant account

select count(nameDestination) as Merchant_acc , type,sum(amount) as Merchant_Transc
from Financial_Transcation.dbo.Financial
where nameDestination like 'M%'
group by type
order by Merchant_Transc desc

-------------------------------------------------------------------------------------------

------Q -4 Finding out the potential money laundering chains where money is TRANSFERRED from one account to another across multiple steps
------with all transactions flagged as fraudulent

with Fraud_detectCTE as (
select nameOrigin as initial_acc,
newbalanceOrigin,
nameDestination as transferred_acc,
amount,step
from Financial_Transcation.dbo.Financial
where type = 'TRANSFER' and isFraud = 1 
)
select * from Fraud_detectCTE
where step >5 
order by step desc

--------------------------------------------------------------------------------------------

------Q -5 Finding out the account details with their highest transaction amount except the merchant account with change in balance equals to ZERO and 
---- flagged as fraudulent 

 With Largest_TransCTE as (
 select type, amount,
 nameOrigin as Initial_acc,
 newbalanceOrigin,
 oldbalanceOrigin,
 nameDestination as Receipt_acc,
 newbalanceDest as Receipt_balance,isFraud
 from Financial_Transcation.dbo.Financial
 where nameDestination not like 'M%'
 )
 select * from Largest_TransCTE
 where (oldbalanceOrigin - amount) = 0 and isFraud = 1
 order by amount desc
 

 --------------------------------------------------------------------------------------------

------Q -6 Finding out the account details with their highest transaction amount except the merchant account WITHOUT change in balance and 
---- flagged as fraudulent 


  With Largest_TransCTE as (
 select type, amount,
 nameOrigin as Initial_acc,
 newbalanceOrigin,
 oldbalanceOrigin,
 nameDestination as Receipt_acc,
 newbalanceDest as Receipt_balance,isFraud
 from Financial_Transcation.dbo.Financial
 where nameDestination not like 'M%'
 )
 select * from Largest_TransCTE
 where oldbalanceOrigin = newbalanceOrigin and isFraud = 1
 order by amount desc

  --------------------------------------------------------------------------------------------

------Q -7 Finding out the account details with computed new updated balance is equal to newbalanceDest 

with ComputedCTE as
(
 select type,amount,nameOrigin,nameDestination,
 (oldbalanceDestination + amount) as Computed_Balance,
 newbalanceDest
 from Financial_Transcation.dbo.Financial
 )
 select * from ComputedCTE
 where  newbalanceDest = Computed_Balance 
 order by amount desc

 
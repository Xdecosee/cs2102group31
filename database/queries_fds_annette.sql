/*view number of ratings received by riders for each month*/
SELECT Distinct DR.uid, EXTRACT(YEAR FROM O.date) as year, EXTRACT(MONTH FROM O.date) as month, count(D.rating) as totalRatings
FROM DeliveryRiders DR
LEFT JOIN Delivers D on DR.uid = D.uid
LEFT JOIN Orders O on D.orderID = O.orderID
GROUP BY DR.uid, EXTRACT(YEAR FROM O.date), EXTRACT(MONTH FROM O.date);

/*view average rating received for rider for each month*/
SELECT distinct DR.uid, EXTRACT(YEAR FROM O.date) as year, EXTRACT(MONTH FROM O.date) as month, avg(D.rating) as avgRatings
FROM DeliveryRiders DR
LEFT JOIN Delivers D on DR.uid = D.uid
LEFT JOIN Orders O on D.orderID = O.orderID
GROUP BY DR.uid, EXTRACT(YEAR FROM O.date), EXTRACT(MONTH FROM O.date);

/*View average delivery time by rider for each month */
SELECT distinct  DR.uid, EXTRACT(YEAR FROM O.date) as year, EXTRACT(MONTH FROM O.date) as month, avg(O.deliveryDuration) as avgDuration
FROM DeliveryRiders DR
LEFT JOIN Delivers D on DR.uid = D.uid
LEFT JOIN Orders O on D.orderID = O.orderID
GROUP BY DR.uid, EXTRACT(YEAR FROM O.date), EXTRACT(MONTH FROM O.date);

/* view total number of orders place at each hour for each location area (NSEWC)*/
SELECT distinct location, date, EXTRACT(HOUR FROM timeOrderPlace) AS hour, count(*) AS totalOrders 
FROM Orders 
GROUP BY location, date, EXTRACT(HOUR FROM timeOrderPlace);


/* view total number of orders delivered by each rider for each month */
/*FULL TIME*/
SELECT distinct F.uid, EXTRACT(YEAR FROM WW.workDate) as year, EXTRACT(MONTH FROM WW.workDate) as month, SUM(WW.numCompleted) as totalOrders
FROM FullTime F
INNER JOIN WorkingWeeks WW ON F.uid = WW.uid
GROUP BY F.uid, EXTRACT(YEAR FROM WW.workDate), EXTRACT(MONTH FROM WW.workDate)
UNION
/*PART TIME*/
SELECT distinct P.uid, EXTRACT(YEAR FROM WD.workDate) as year, EXTRACT(MONTH FROM WD.workDate) as month, SUM(WD.numCompleted) as totalOrders
FROM PartTime P
INNER JOIN WorkingDays WD ON P.uid = WD.uid
GROUP BY P.uid, EXTRACT(YEAR FROM WD.workDate), EXTRACT(MONTH FROM WD.workDate);




/* view total number of hours worked by rider for each month. Calculated by date and assumes the rider work through the whole day 
according to their schedule indicated.*/
/*FULL TIME*/
SELECT distinct F.uid, EXTRACT(YEAR FROM WW.workDate) as year, EXTRACT(MONTH FROM WW.workDate) as month, count(shiftID) * 8 as totalHours
FROM FullTime F
INNER JOIN WorkingWeeks WW on F.uid = WW.uid
WHERE WW.numCompleted > 0 
GROUP BY F.uid, EXTRACT(YEAR FROM WW.workDate), EXTRACT(MONTH FROM WW.workDate)
UNION
/*PART TIME*/
SELECT distinct P.uid, EXTRACT(YEAR FROM WD.workDate) as year, EXTRACT(MONTH FROM WD.workDate) as month, 
sum(DATE_PART('hour', WD.intervalEnd - WD.intervalStart) * 60 
+ DATE_PART('minute', WD.intervalEnd - WD.intervalStart))::decimal / 60 as totalHours
FROM PartTime P
INNER JOIN WorkingDays WD on P.uid = WD.uid
WHERE WD.numCompleted > 0 
GROUP BY P.uid, EXTRACT(YEAR FROM WD.workDate), EXTRACT(MONTH FROM WD.workDate);


/*view total salary earned by each rider for each month.*/
/*PARTTIME. Consolidate shows for each parttime rider, how many weeks they actually worked in a month (If they
work one day in a week, it will be counted in totalWeeksWorked) and how many deliveries completed in a month */
WITH ConsolidateP as (
SELECT distinct P1.uid as pUid, 
P1.weeklyBasePay as pBasePay, 
EXTRACT(YEAR FROM WD1.workDate) as pYear, 
EXTRACT(Month FROM WD1.workDate) as pMonth, 
count( distinct EXTRACT(WEEK FROM WD1.workDate)) as totalWeeksWorked, 
sum(WD1.numCompleted) as pComplete
FROM PartTime P1
INNER JOIN WorkingDays WD1 on P1.uid = WD1.uid
WHERE WD1.numCompleted > 0 /**Filter out weeks without any worked days at all for count(Extract(WEEK FROM WD.workDate))**/
GROUP BY P1.uid, EXTRACT(YEAR FROM WD1.workDate), EXTRACT(Month FROM WD1.workDate)
),
/*FULLTIME. ConsolidateF shows for each fulltime rider, how many months they actually worked (even if they worked one day in a month) 
and how many deliveries completed in a month */
ConsolidateF as (
SELECT distinct F1.uid as fUid,
F1.monthlyBasePay as fBasePay,
EXTRACT(YEAR FROM WW1.workDate) as fYear,
EXTRACT(MONTH FROM WW1.workDate) as fMonth,
sum(WW1.numCompleted) as fCompleted
FROM FullTime F1
INNER JOIN WorkingWeeks WW1 on F1.uid = WW1.uid
WHERE WW1.numCompleted > 0  /**Filter out months without any worked days at all**/
GROUP BY F1.uid, EXTRACT(YEAR FROM WW1.workDate), EXTRACT(MONTH FROM WW1.workDate)
)
SELECT DR.uid, 
CP.pYear as year, 
CP.pMonth as month,
CP.pComplete * DR.baseDeliveryFee + CP.pComplete * DR.deliveryBonus + CP.totalWeeksWorked * CP.pBasePay as monthSalary
FROM DeliveryRiders DR
INNER JOIN ConsolidateP CP on DR.uid = CP.pUid
UNION
/*FULLTIME*/
SELECT DR.uid, 
CF.fYear as year,
CF.fMonth as month,
CF.fCompleted * DR.baseDeliveryFee + CF.fCompleted * DR.deliveryBonus + CF.fBasePay as monthSalary
FROM DeliveryRiders DR
INNER JOIN ConsolidateF CF on DR.uid = CF.fUid;


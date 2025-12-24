--1.PATIENTS TABLE
CREATE TABLE patients(
	patient_id VARCHAR(50) PRIMARY KEY,
	first_name VARCHAR(50) NOT NULL,
	last_name VARCHAR(50) NOT NULL,
	gender CHAR(1),
	date_of_birth DATE,
	contact_number VARCHAR(15),
	address VARCHAR(200),
	regestration_date DATE,
	insurance_provider VARCHAR(50),
	insurance_number VARCHAR(50),
	email VARCHAR(100)
);

COMMENT ON TABLE patients IS 'master patient information with insurance details';


--2.DOCTORS TABLE
CREATE TABLE doctors(
	doctor_id VARCHAR(10) PRIMARY KEY,
	first_name VARCHAR(50) NOT NULL,
	last_name VARCHAR(50)  NOT NULL,
	specializations VARCHAR(50),
	phone_number VARCHAR(15),
	years_experience INTEGER,
	hospital_branch VARCHAR(50),
	email VARCHAR(100)
);

COMMENT ON TABLE doctors IS 'Doctor details with specialization and experience';


--3.APPOINTMENTS TABLE
CREATE TABLE appointments(
	appointment_id VARCHAR(50) PRIMARY KEY,
	patient_id VARCHAR(10) REFERENCES patients(patient_id),
	doctor_id VARCHAR(10) REFERENCES doctors(doctor_id),
	appointment_date DATE,
	appointment_time TIME,
	reason_for_visit VARCHAR(50),
	status VARCHAR(20)
);

COMMENT ON TABLE appointments IS 'Patient appointments with doctors';


--4. TREATMENTS TABLE
CREATE TABLE treatments (
    treatment_id VARCHAR(10) PRIMARY KEY,
    appointment_id VARCHAR(10) REFERENCES appointments(appointment_id),
    treatment_type VARCHAR(50),
    description VARCHAR(100),
    cost DECIMAL(10, 2),
    treatment_date DATE
);

COMMENT ON TABLE treatments IS 'medical treatments given during appointments';


--5.BILLING TABLE
CREATE TABLE billing (
    bill_id VARCHAR(10) PRIMARY KEY,
    patient_id VARCHAR(10) REFERENCES patients(patient_id),
    treatment_id VARCHAR(10) REFERENCES treatments(treatment_id),
    bill_date DATE,
    amount DECIMAL(10, 2),
    payment_method VARCHAR(20),
    payment_status VARCHAR(20)
);

COMMENT ON TABLE billing IS 'patient billing and payment records';


--total rows (records) in each table
SELECT 'patients' AS table_name,COUNT(*) AS total_records FROM patients
UNION ALL
SELECT 'doctors',COUNT(*) FROM doctors
UNION ALL
SELECT ' appointments',COUNT(*) FROM appointments
UNION ALL
SELECT 'treatments',COUNT(*) FROM treatments
UNION ALL
SELECT 'billing',COUNT(*) FROM billing
ORDER BY total_records;


-- Patient Demographic Analysis
--(i) how many patients are in each gender category ?
SELECT DISTINCT
	gender,COUNT(gender) AS gender_category
FROM 
	patients
GROUP BY 
	gender;


--(ii) what is the age distribution of the patients ?
SELECT 
	CASE
		WHEN EXTRACT(YEAR FROM AGE(date_of_birth)) < 18 THEN 'under  18'
		WHEN EXTRACT(YEAR FROM AGE(date_of_birth)) BETWEEN 18 AND 30 THEN '18 - 30'
		WHEN EXTRACT(YEAR FROM AGE(date_of_birth)) BETWEEN 31 AND 50 THEN '31 - 50'
		WHEN EXTRACT(YEAR FROM AGE(date_of_birth)) BETWEEN 51 AND 65 THEN '51 - 65'
		ELSE 'over 65'
	END AS age_group,
	COUNT(*) AS patient_count,
	ROUND(COUNT(*)*100.0/(SELECT COUNT(*) FROM patients),4) AS percentage
FROM patients
GROUP BY age_group
ORDER BY age_group;


--(iii) which insurance provider has most patients
SELECT DISTINCT
	insurance_provider,COUNT(insurance_provider) AS most_no_of_insurance_providers
FROM 
	patients
GROUP BY
	insurance_provider
ORDER BY 
	COUNT(insurance_provider) DESC
LIMIT 1;


--(iv) how maany patients registered each month in 2023
SELECT
	DATE_PART('year',regestration_date) AS regesteredYear,
	DATE_PART('month',regestration_date) AS regesteredMonth,
	COUNT(patient_id) AS regestered_patients
FROM
	patients
WHERE 
	DATE_PART('year',regestration_date) = 2023
GROUP BY
	regesteredYear,
	regesteredMonth
ORDER BY
	regesteredYear,
	regesteredMonth;



--Doctor and Specialization Analysis
--(i) how many doctors in each specialization ?
SELECT 
	specializations,COUNT(doctor_id) AS no_of_doctors
FROM 
	doctors
GROUP BY 
	specializations;


--(ii) which hospital branch has the most experienced doctors (avg years_experience)?
SELECT
	hospital_branch,AVG(years_experience) AS avg_exp
FROM 
	doctors
GROUP BY
 	hospital_branch;


--(iii) how many appointments does each doctor have ?
SELECT
	doctor_id,COUNT(doctor_id) AS no_of_appointments
FROM 
	appointments
GROUP BY
	doctor_id
ORDER BY
	doctor_id;
	

--(iv) Which doctor has the highest appointment completion rate (status='Completed')?
SELECT 
	d.doctor_id,d.first_name || ' ' || d.last_name AS doctor_name,
	COUNT(a.appointment_id) AS total_appointments,
	COUNT(CASE WHEN a.status = 'Completed' THEN 1 END) AS completed_appointments,
	ROUND(
		COUNT(CASE WHEN a.status = 'Completed' THEN 1 END) * 100.0 /
		NULLIF(COUNT(a.appointment_id),0),2
	) AS completion_percentage
FROM doctors d
LEFT JOIN appointments a USING (doctor_id)
GROUP BY 
	d.doctor_id,
	d.first_name,
	d.last_name
HAVING COUNT(a.appointment_id) > 0
ORDER BY completion_percentage DESC;


--(v) list doctors with their patient count (unique patients treated)
SELECT 
	d.doctor_id,
	d.first_name || ' ' || d.last_name AS doctor_name,
	d.specializations,
	COUNT(DISTINCT a.patient_id) AS unq_patient_treated
FROM 
	doctors d
LEFT JOIN
	appointments a USING (doctor_id)
GROUP BY 
	d.doctor_id,
	d.first_name,
	d.last_name,
	d.specializations
ORDER BY
	unq_patient_treated DESC;


--Appointment patterns
--(i) What is the distribution of appointment statuses?
SELECT 
	status,
	COUNT(status) AS total_appointments
FROM
	appointments
GROUP BY
	status
ORDER BY
	total_appointments DESC;


--(ii) Which day of the week has the most appointments?
SELECT
	TO_CHAR(appointment_date,'Day') AS day_of_week,
	COUNT(appointment_date) AS appointment_count,
	ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM appointments), 2) AS percentage
FROM
	appointments
GROUP BY
	TO_CHAR(appointment_date,'Day')
ORDER BY 
	percentage DESC;

	 --(OR)

SELECT
	EXTRACT(DOW FROM appointment_date) AS day_of_week,
	COUNT(appointment_date) AS appointment_count,
	ROUND(COUNT(appointment_date) * 100.0 / (SELECT COUNT(appointment_date) FROM appointments), 2) AS percentage
FROM appointments
GROUP BY
	EXTRACT(DOW FROM appointment_date)
ORDER BY
	EXTRACT(DOW FROM appointment_date);


--(iii) what are the most common reasons for visits
SELECT 
	reason_for_visit,
	COUNT(reason_for_visit)
FROM
	appointments
GROUP BY
	reason_for_visit
ORDER BY
	COUNT(reason_for_visit) DESC
LIMIT 1;


--(iv) What percentage of appointments result in treatments?
SELECT
	COUNT(DISTINCT a.appointment_id) AS total_appointments,
	COUNT(DISTINCT t.treatment_id) AS appointments_with_treatment,
	ROUND(
		COUNT(DISTINCT t.appointment_id) * 100.0 / 
		NULLIF(COUNT(DISTINCT a.appointment_id),0),2
	) AS percentage_with_treatment
FROM appointments a
LEFT JOIN treatments t USING (appointment_id);


--(v) Analyze no-show rate by doctor (doctor with highest no-show percentage)
WITH doctor_no_show AS(
	SELECT
		d.doctor_id,
		d.first_name|| ' ' ||d.last_name,
		d.specializations,
		COUNT(a.appointment_id) AS total_appointments,
		COUNT(CASE WHEN a.status = 'No-show' THEN 1 END) AS no_show_count,
		ROUND(
			COUNT(CASE WHEN a.status = 'No-show' THEN 1 END) * 100.0 / 
			NULLIF(COUNT(a.appointment_id),0),3
		) AS no_show_percentage
	FROM doctors d
	LEFT JOIN appointments a USING (doctor_id)
	GROUP BY
		d.doctor_id,d.first_name,d.last_name,d.specializations
	HAVING
		COUNT(a.appointment_id) > 0
)
SELECT * 
FROM
	doctor_no_show
ORDER BY
	no_show_percentage DESC
LIMIT 1;



--Treatment Analysis
--(i) What are the most common treatment types and their average cost?
SELECT
	treatment_type,
	COUNT(treatment_type) AS count_of_treatment_type,
	ROUND(AVG(cost),2) AS average_cost,
	MIN(cost) AS minimum_cost,
	MAX(cost) AS maximum_cost,
	ROUND(SUM(cost),2) AS total_cost
FROM 
	treatments
GROUP BY
	treatment_type
ORDER BY
	avg(cost);


--(ii) Which treatment type generates the highest total revenue?
WITH treatment_stats AS (
	SELECT 
		treatment_type,
		COUNT(treatment_type) AS total_treatments,
		SUM(cost) AS total_revenue,
		SUM(SUM(cost)) OVER() AS overall_total_revenue
	FROM treatments
	GROUP BY treatment_type
)
SELECT
	treatment_type,
	total_treatments,
	ROUND(total_revenue,2) AS total_revenue,
	ROUND(total_revenue * 100.0 / overall_total_revenue,2) AS revenue_percentage
FROM treatment_stats
ORDER BY total_revenue DESC;



--(iii) Which month had the highest treatment revenue in 2023?
SELECT 
	EXTRACT(MONTH FROM treatment_date) AS month_number,
	SUM(cost) AS total,
	ROUND(
		SUM(cost)*100/
		(SELECT SUM(cost) FROM treatments WHERE EXTRACT(YEAR FROM treatment_date) = 2023),2) 
	AS revenue_percentage
FROM
	treatments
WHERE EXTRACT(YEAR FROM treatment_date) = 2023
GROUP BY 
	EXTRACT(MONTH FROM treatment_date)
ORDER BY
	total DESC
LIMIT 1;



-- Billing and payment analysis
--(i) what is the total revenue collected vs pending ?
WITH revenue_collected AS(
	SELECT
		payment_status,
		SUM(amount) AS total_
	FROM 
		billing
	WHERE 
		payment_status = 'Paid'
	GROUP BY 
		payment_status
),
revenue_pending AS(
	SELECT
		payment_status,
		SUM(amount) AS to_be_received
	FROM 
		billing
	WHERE 
		payment_status = 'Pending'
	GROUP BY 
		payment_status
)
SELECT *
FROM revenue_pending,revenue_collected;


--(ii) what is the payment method distribution
SELECT
	payment_method,
	COUNT(payment_method) AS payment_methods
FROM 
	billing
GROUP BY
	payment_method;


-- (iii) which patients have the highest outstanding bills
SELECT DISTINCT
	p.patient_id,
	p.first_name|| ' ' ||p.last_name AS patient_name,
	b.amount
FROM 
	patients p
LEFT JOIN
	billing b USING (patient_id)
GROUP BY
	p.patient_id,
	p.first_name,
	p.last_name,
	b.amount
ORDER BY b.amount DESC
LIMIT 1;



--Patient journey
--What is the average time between patient registration and first appointment ?
WITH patient_first_app AS(
	SELECT
		p.patient_id,
		p.regestration_date,
		MIN(a.appointment_date) AS first_appointment_date
	FROM patients p
	INNER JOIN appointments a USING (patient_id)
	GROUP BY 
		p.patient_id,
		p.regestration_date
	HAVING
		MIN(a.appointment_date) IS NOT NULL
)
SELECT 
	ROUND(AVG(first_appointment_date - regestration_date),2) AS average_days_between,
	ROUND(MIN(first_appointment_date - regestration_date),2) AS minimum_days_between,
	ROUND(MAX(first_appointment_date - regestration_date),2) AS maximum_days_between
FROM 
	patient_first_app
WHERE
	first_appointment_date >= regestration_date;



--how many patients have multiple appointments ?
WITH patients_appointment_coungts AS(
	SELECT
		patient_id,
		COUNT(*) AS appointment_count
	FROM
		appointments
	GROUP BY
		patient_id
)
SELECT
	CASE 
		WHEN appointment_count = 1 THEN 'single appointment'
		WHEN appointment_count = 2 THEN 'two appointments'
		WHEN appointment_count BETWEEN 3 AND 5 THEN '3-5 apppoointments'
		ELSE 'more than 5 appointments'
	END AS appointment_category,
	SUM(appointment_count) AS total_appointments_in_category
FROM
	patients_appointment_coungts
GROUP BY
	appointment_category
ORDER BY
	appointment_category;



--calculate patient retention rate (patients with follow-up appointments)
WITH patient_appointment_sequel AS(
	SELECT
		patient_id,
		appointment_date,
		ROW_NUMBER() OVER(PARTITION BY patient_id ORDER BY appointment_date)
		AS appointment_number
		FROM appointments
		WHERE status != 'Cancelled'
),
patient_retention AS(
	SELECT
		patient_id,
		MAX(appointment_number) AS total_appointments,
		CASE WHEN MAX(appointment_number) > 1 THEN 1 ELSE 0 END AS retained_patient
	FROM patient_appointment_sequel
	GROUP BY patient_id
)
SELECT
	COUNT(patient_retention) AS total_patients_with_aappointments,
	SUM(retained_patient) AS retained_patients
FROM 
	patient_retention;
	


-- rank patients by total medicine expenses
WITH patient_amount_ranking AS(
	SELECT 
		p.patient_id,
		COUNT(*) AS patients_count,
		SUM(b.amount) AS patient_spend
	FROM 
		patients p
	INNER JOIN
		billing b USING (patient_id)
	GROUP BY 
		p.patient_id
)
SELECT
	patient_id,
	patient_spend,
	RANK() OVER(ORDER BY patient_spend DESC) AS ranking_patients
FROM patient_amount_ranking ;

	


	
	



SELECT * FROM patients;
SELECT * FROM doctors;
SELECT * FROM appointments;
SELECT * FROM treatments;
SELECT * FROM billing;























  ## **SQL Case Study: Longest Query Challenge**
 * Inspired by Ankit Bansal's SQL Case Study
 * Link: [https://lnkd.in/grwVRvVg](https://youtu.be/rFsgzSeG1X0?si=0WTiPy9ZG1XqHExp)


## **Summary:**

This exercise helped me practice and apply key SQL concepts including:
 * - Common Table Expressions (CTEs)
 * - Joins
 * - Aggregate functions
 * - Window functions
 * - Date functions
 * - COALESCE
 * - CASE WHEN statements

## **Create and Insert Statement:**


**-- Create employees table**


CREATE TABLE employees (

    employee_id INT PRIMARY KEY,
    name VARCHAR(10) NOT NULL,
    join_date DATE NOT NULL,
    department VARCHAR(10) NOT NULL

**-- Insert sample  data to  employees**

INSERT INTO employees (employee_id, name, join_date, department)
VALUES

    (1, 'Alice', '2018-06-15', 'IT'),
    (2, 'Bob', '2019-02-10', 'Finance'),
    (3, 'Charlie', '2017-09-20', 'HR'),
    (4, 'David', '2020-01-05', 'IT'),
    (5, 'Eve', '2016-07-30', 'Finance'),
    (6, 'Sumit', '2016-06-30', 'Finance');

**-- Create salary_history table**

CREATE TABLE salary_history (

    employee_id INT,
    change_date DATE NOT NULL,
    salary DECIMAL(10,2) NOT NULL,
    promotion VARCHAR(3)
);


-- Insert sample data


INSERT INTO salary_history (employee_id, change_date, salary, promotion)
VALUES

    (1, '2018-06-15', 50000, 'No'),
    (1, '2019-08-20', 55000, 'No'),
    (1, '2021-02-10', 70000, 'Yes'),
    (2, '2019-02-10', 48000, 'No'),
    (2, '2020-05-15', 52000, 'Yes'),
    (2, '2023-01-25', 68000, 'Yes'),
    (3, '2017-09-20', 60000, 'No'),
    (3, '2019-12-10', 65000, 'No'),
    (3, '2022-06-30', 72000, 'Yes'),
    (4, '2020-01-05', 45000, 'No'),
    (4, '2021-07-18', 49000, 'No'),
    (5, '2016-07-30', 55000, 'No'),
    (5, '2018-11-22', 62000, 'Yes'),
    (5, '2021-09-10', 75000, 'Yes'),
    (6, '2016-06-30', 55000, 'No'),
    (6, '2017-11-22', 50000, 'No'),
    (6, '2018-11-22', 40000, 'No'),
    (6, '2021-09-10', 75000, 'Yes');


   ## **🙌 Contributions & Suggestions**

Feel free to **fork this repository**, open an **issue**, or submit a **pull request** if you have any suggestions, improvements, or just want to use this solution in your own way.  
Your feedback is always welcome! 💡

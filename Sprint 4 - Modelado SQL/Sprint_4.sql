# Sprint 4: Creación de Base de Datos
-- Primero creo la base de datos, y posteriormente las tablas que contendrá.
CREATE DATABASE IF NOT EXISTS transactions_sprint_4;
USE transactions_sprint_4;

-- A la hora de crear las tablas procuro usar un VARCHAR(100) para asegurarme de que podré cargar el contenido de los archivos proporcionados con éxito.
CREATE TABLE IF NOT EXISTS company (
	id VARCHAR(100) NOT NULL PRIMARY KEY,
    name VARCHAR(100),
    phone VARCHAR(100),
    email VARCHAR(100),
    country VARCHAR(100),
    website VARCHAR(100));

CREATE TABLE IF NOT EXISTS credit_card (
	id VARCHAR(100) NOT NULL PRIMARY KEY,
    user_id VARCHAR(100),
    iban VARCHAR(100),
    pan VARCHAR(100),
    pin VARCHAR(100),
    cvv VARCHAR(100),
    track1 VARCHAR(100),
    track2 VARCHAR(100),
    expiring_date VARCHAR(100));

CREATE TABLE IF NOT EXISTS product (
	id VARCHAR(100) NOT NULL PRIMARY KEY,
    name VARCHAR(100),
    price VARCHAR(100),
    colour VARCHAR(100),
    weight VARCHAR(100),
    warehouse_id VARCHAR(100));

CREATE TABLE IF NOT EXISTS transaction (
	id VARCHAR(100) NOT NULL PRIMARY KEY,
    credit_card_id VARCHAR(100) REFERENCES credit_card(id),
    company_id VARCHAR(100)  REFERENCES company(id),
    timestamp VARCHAR(100),
    amount VARCHAR(100),
    declined VARCHAR(100),
    products_ids VARCHAR(100) REFERENCES product(id),
    user_id VARCHAR(100) REFERENCES user(id),
    lat VARCHAR(100),
    longitude VARCHAR(100));

CREATE TABLE IF NOT EXISTS user (
	id VARCHAR(100) NOT NULL PRIMARY KEY,
    name VARCHAR(100),
    surname VARCHAR(100),
    phone VARCHAR(100),
    email VARCHAR(100),
    birth_date VARCHAR(100),
    country VARCHAR(100),
    city VARCHAR(100),
    postal_code VARCHAR(100),
    address VARCHAR(100));

-- Ahora tengo que cargar los datos a sus respectivas tablas.
-- Lo primero fue subir los archivos hasta el server host "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/".
-- Si no hago esto no me permitirá correr la query "LOAD DATA INFILE".
LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/companies.csv"
INTO TABLE company
FIELDS TERMINATED BY ','
IGNORE 1 LINES;

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/credit_cards.csv"
INTO TABLE credit_card
FIELDS TERMINATED BY ','
IGNORE 1 LINES;

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/products.csv"
INTO TABLE product
FIELDS TERMINATED BY ','
IGNORE 1 LINES;

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/transactions.csv"
INTO TABLE transaction
FIELDS TERMINATED BY ';'
IGNORE 1 LINES;

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users_usa.csv"
INTO TABLE user
FIELDS TERMINATED BY ","
ENCLOSED BY '"'
LINES TERMINATED BY "\r\n"
IGNORE 1 LINES;

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users_uk.csv"
INTO TABLE user
FIELDS TERMINATED BY ","
ENCLOSED BY '"'
LINES TERMINATED BY "\r\n"
IGNORE 1 LINES;

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users_ca.csv"
INTO TABLE user
FIELDS TERMINATED BY ","
ENCLOSED BY '"'
LINES TERMINATED BY "\r\n"
IGNORE 1 LINES;

-- Lo siguiente después de cargar los datos es cambiar el formato de las columnas a uno más adecuado.
-- Para saber cual es la longitud máxima de las columnas. Esto lo repito en cada tabla (pero solo mostraré un ejemplo).
SELECT MAX(length(id)) AS id, MAX(length(name)) AS name, MAX(length(phone)) AS phone, MAX(length(email)) AS email, MAX(length(country)) AS country, MAX(length(website)) AS website
FROM COMPANY;

-- Hay algunos UPDATEs que haré de columnas enteras, y el SQL_SAFE_UPDATES no me lo permitirá si esta activo, así que lo desactivo. 
SET SQL_SAFE_UPDATES = 0;

-- Para modificar la longuitud de las columnas a una más próxima a su logitud mayor, más un margen por si acaso se quieren ingresar campos mas largos,
-- la idea es usar el menor espacio posible en la base de datos.
ALTER TABLE company
MODIFY COLUMN id CHAR(6),
MODIFY COLUMN name VARCHAR(50),
MODIFY COLUMN phone VARCHAR(14),
MODIFY COLUMN email VARCHAR(50),
MODIFY COLUMN country VARCHAR(20),
MODIFY COLUMN website VARCHAR(50);

-- Para cambiar el formato de expiring_date de: MM/DD/YY a: YYYY-MM-DD.
UPDATE credit_card
SET expiring_date = str_to_date(expiring_date, "%m/%d/%y");

ALTER TABLE credit_card
MODIFY COLUMN id CHAR(8),
MODIFY COLUMN user_id INT,
MODIFY COLUMN iban VARCHAR(50),
MODIFY COLUMN pan VARCHAR(40),
MODIFY COLUMN pin CHAR(4),
MODIFY COLUMN cvv CHAR(3),
MODIFY COLUMN track1 VARCHAR(50),
MODIFY COLUMN track2 VARCHAR(50),
MODIFY COLUMN expiring_date DATE;

-- Los datos de la columna price contienen $ como primer caracter, con SUBSTR(price, 2) solicito que se muestren los datos a partir del segundo caracter,
-- de esa manera podré modificar la columna price para que contenga decimales.
UPDATE product SET price = SUBSTR(price, 2);

ALTER TABLE product
MODIFY COLUMN id INT,
MODIFY COLUMN name VARCHAR(50),
MODIFY COLUMN price DEC(5,2),
MODIFY COLUMN colour CHAR(7),
MODIFY COLUMN weight DEC(2,1),
MODIFY COLUMN warehouse_id VARCHAR(10);

ALTER TABLE transaction
MODIFY COLUMN id VARCHAR(50),
MODIFY COLUMN credit_card_id CHAR(8),
MODIFY COLUMN company_id CHAR(6),
MODIFY COLUMN timestamp timestamp,
MODIFY COLUMN amount DEC(5,2),
MODIFY COLUMN declined TINYINT,
MODIFY COLUMN products_ids VARCHAR(15),
MODIFY COLUMN user_id INT,
MODIFY COLUMN lat VARCHAR(20),
MODIFY COLUMN longitude VARCHAR(20);

-- Para cambiar el formato de birth_date de: MMM DD, YYYY a: YYYY-MM-DD.
UPDATE user
SET birth_date = str_to_date(birth_date, "%b %e, %Y");

ALTER TABLE user
MODIFY COLUMN id INT,
MODIFY COLUMN name VARCHAR(20),
MODIFY COLUMN surname VARCHAR(20),
MODIFY COLUMN phone VARCHAR(20),
MODIFY COLUMN email VARCHAR(50),
MODIFY COLUMN birth_date DATE,
MODIFY COLUMN country VARCHAR(20),
MODIFY COLUMN city VARCHAR(30),
MODIFY COLUMN postal_code VARCHAR(10),
MODIFY COLUMN address VARCHAR(50);

-- Para agregar las FOREIGN KEYs.
ALTER TABLE transaction
ADD FOREIGN KEY (credit_card_id) REFERENCES credit_card(id),
ADD FOREIGN KEY (company_id) REFERENCES company(id),
ADD FOREIGN KEY (user_id) REFERENCES user(id);

-- Para volver a activar SQL_SAFE_UPDATES.
SET SQL_SAFE_UPDATES = 1;


# Nivel 1
## Ejercicio 1
### Realiza una subconsulta que muestre a todos los usuarios con más de 30 transacciones utilizando al menos 2 tablas.
-- Para hacer un conteo de cuantas transacciones registradas tienen los usuarios.
SELECT user_id, COUNT(id) AS tran_count
FROM transaction
GROUP BY user_id
HAVING COUNT(id) > 30;

-- Para saber los datos de los usuarios con más de 30 transacciones registradas, utilizando el conteo anterior como filtro.
SELECT *
FROM user AS u
HAVING id IN (
	SELECT user_id
	FROM transaction AS t
	GROUP BY user_id
	HAVING COUNT(id) > 30);

## Ejercicio 2
### Muestra la media de amount por IBAN de las tarjetas de crédito en la compañía Donec Ltd, utiliza por lo menos 2 tablas.
-- Para resolver el ejercicio utilizando un JOIN, y la SubQuery como filtro.
SELECT cc.iban, ROUND(AVG(t.amount),2) AS average
FROM transaction AS t
JOIN credit_card AS cc ON t.credit_card_id = cc.id
WHERE t.company_id IN (
	SELECT id
	FROM company
	WHERE name = "Donec Ltd")
GROUP BY cc.iban;

-- Para resolver el ejercicio utilizando las SubQuery como tabla temporal en el FROM.
SELECT iban, ROUND(AVG(amount),2) AS average
FROM (
	SELECT cc.iban, t.amount, c.name
	FROM transaction AS t
	JOIN credit_card AS cc ON t.credit_card_id = cc.id
	JOIN company AS c ON t.company_id = c.id) AS utility_table
WHERE name = "Donec Ltd"
GROUP BY iban;


# Nivel 2
## Crea una nueva tabla que refleje el estado de las tarjetas de crédito basado en si las últimas tres transacciones fueron declinadas y genera la siguiente consulta:
-- Uso ROW_NUMBER() en "date_order" para ordenar las transacciones por su fecha de manera descendente como le solicité.
-- Luego en "last_three" se lleva acabo el conteo de las transacciones rechazadas.
-- Finalmente se les asigna el estado a las tarjetas en base al resultado del conteo.
CREATE TABLE IF NOT EXISTS credit_card_state AS
WITH date_order AS (
    SELECT
        `timestamp`, `credit_card_id`, `declined`,
        ROW_NUMBER() OVER (PARTITION BY `credit_card_id` ORDER BY `timestamp` DESC) AS row_order
    FROM `transaction`),
last_three AS (
    SELECT
		`credit_card_id`,
        COUNT(*) AS declined_count
    FROM date_order
    WHERE row_order <= 3 AND `declined` = 1
    GROUP BY `credit_card_id`)
SELECT
    `credit_card_id`,
    declined_count < 3 AS `is_active`
FROM last_three
ORDER BY `credit_card_id`;

-- Para agregar la FOREIGN KEY.
ALTER TABLE credit_card_state
MODIFY COLUMN credit_card_id CHAR(8),
MODIFY COLUMN is_active TINYINT,
ADD FOREIGN KEY (credit_card_id) REFERENCES credit_card(id);

## Ejercicio 1
### ¿Cuántas tarjetas están activas?.
SELECT
    SUM(is_active = 1) AS active_cards_count,
    SUM(is_active = 0) AS inactive_cards_count
FROM credit_card_state;


# Nivel 3
## Crea una tabla con la que podamos unir los datos del nuevo archivo products.csv con la base de datos creada, teniendo en cuenta que desde transaction tienes product_ids. Genera la siguiente consulta:
-- Para crear la tabla "transaction_products" con los ids individuales correspondientes a cada transaction_id.
CREATE TABLE IF NOT EXISTS transaction_products AS
SELECT
	t.id AS transaction_id,
	TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(t.products_ids, ',', num), ',', -1)) AS product_id
FROM transaction AS t
JOIN (SELECT 1 AS num UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4) numbers
ON CHAR_LENGTH(t.products_ids) - CHAR_LENGTH(REPLACE(t.products_ids, ',', '')) >= num - 1
ORDER BY transaction_id;

-- Para modificar la tabla y agregar los FOREIGN KEY.
ALTER TABLE transaction_products
MODIFY COLUMN transaction_id VARCHAR(50),
MODIFY COLUMN product_id INT,
ADD FOREIGN KEY (product_id) REFERENCES product(id),
ADD FOREIGN KEY (transaction_id) REFERENCES transaction(id);

## Ejercicio 1
### Necesitamos conocer el número de veces que se ha vendido cada producto.
-- ¿Cuántas veces se ha vendido cada producto?.
SELECT p.name AS product_name, COUNT(tp.product_id) AS times_sold
FROM product AS p
JOIN transaction_products AS tp ON p.id = tp.product_id
GROUP BY name;
# Sprint 2: Nociones básicas SQL
#  Nivel 1
## Ejercicio 2
### Utilizando JOIN realizarás las siguientes consultas.
### 2.1 Listado de los países que están haciendo compras.
SELECT DISTINCT country
FROM transaction AS t
JOIN company AS c ON c.id = t.company_id;

### 2.2 Desde cuántos países se realizan las compras.
SELECT COUNT(DISTINCT country)
FROM transaction AS t
JOIN company AS c ON c.id = t.company_id;

### 2.3 Identifica a la compañía con la mayor media de ventas.
SELECT c.company_name, ROUND(AVG(t.amount),2) AS average
FROM transaction AS t
JOIN company AS c ON c.id = t.company_id
WHERE declined = 0
GROUP BY company_name
ORDER BY AVG(amount) DESC
LIMIT 1;

## Ejercicio 3
### Utilizando sólo subconsultas (sin utilizar JOIN).
### 3.1 Muestra todas las transacciones realizadas por empresas de Alemania.
-- Para mostrar el id de las compañias de Alemania, que usaré como filtro.
SELECT id
FROM company
WHERE country = "Germany";

-- Muestra todas las transaciones realizadas por empresas de Alemania.
SELECT *
FROM transaction
WHERE company_id IN (
	SELECT id
	FROM company
	WHERE country = "Germany");

### 3.2 Lista las empresas que han realizado transacciones por un amount superior a la media de todas las transacciones.
-- Para mostrar el promedio de todas las transacciones.
SELECT AVG(amount)
FROM transaction;

-- Para mostrar el identificador de las compañias con un gasto superior al gasto medio.
SELECT DISTINCT company_id
FROM transaction
WHERE amount > (
	SELECT AVG(amount)
	FROM transaction);

-- Para mostrar la lista de las empresas con una gasto superior a la media.    
SELECT *
FROM company
WHERE id IN (
	SELECT DISTINCT company_id
	FROM transaction
	WHERE amount > (
		SELECT AVG(amount)
		FROM transaction));

### 3.3 Eliminarán del sistema las empresas que no tienen transacciones registradas, entrega el listado de estas empresas.
-- De esta manera puedo ver las empresas que no tienen transacciones registradas.
SELECT *
FROM company AS c
WHERE NOT EXISTS (
	SELECT company_id
	FROM transaction AS t
	WHERE c.id = t.company_id);


# Nivel 2
## Ejercicio 1
### Identifica los cinco días que se generó la mayor cantidad de ingresos en la empresa por ventas.
### Muestra la fecha de cada transacción junto con el total de las ventas.
SELECT SUM(amount) AS income, DATE(timestamp) AS date
FROM transaction
WHERE declined = 0
GROUP BY DATE(timestamp)
ORDER BY SUM(amount) DESC
LIMIT 5;

## Ejercicio 2
### ¿Cuál es la media de ventas por país? Presenta los resultados ordenados de mayor a menor promedio.
SELECT country, AVG(amount)
FROM transaction AS t
JOIN company AS c ON c.id = t.company_id
WHERE declined = 0
GROUP BY country
ORDER BY AVG(amount) DESC;

## Ejercicio 3
### En tu empresa, se plantea un nuevo proyecto para lanzar algunas campañas publicitarias para hacer competencia a la compañía "Non Institute".
### Para ello, te piden la lista de todas las transacciones realizadas por empresas que están ubicadas en el mismo país que esta compañía.
-- Para saber el en que país se encuentra "Non Institute".
SELECT country
FROM company
WHERE company_name = "Non Institute";

### 3.1 Muestra el listado aplicando JOIN y subconsultas.
SELECT t.*
FROM transaction AS t JOIN company AS c ON c.id = t.company_id
WHERE company_name != "Non Institute" AND country = (
	SELECT country
	FROM company
	WHERE company_name = "Non Institute");

### 3.2 Muestra el listado aplicando solo subconsultas.
SELECT *
FROM transaction
WHERE company_id IN (
	SELECT id
	FROM company
	WHERE company_name != "Non Institute" AND country = (
		SELECT country
		FROM company
		WHERE company_name = "Non Institute"));


# Nivel 3
## Ejercicio 1
### Presenta el nombre, teléfono, país, fecha y amount, de aquellas empresas que realizaron transacciones con un valor comprendido entre 100 y 200 euros y en alguna de estas fechas:
### 29 de abril de 2021, 20 de julio de 2021 y 13 de marzo de 2022. Ordena los resultados de mayor a menor cantidad.
-- Para filtrar por las fechas del ejercicio.
SELECT DATE(timestamp)
FROM transaction
WHERE DATE(timestamp) IN ('2021-04-29', '2021-07-20', '2022-03-13');

-- Para mostrar los resultados filtrados por fecha y cantidad.
SELECT company_name, phone, country, DATE(timestamp) AS date, amount
FROM company AS c JOIN transaction AS t ON c.id = t.company_id
WHERE amount BETWEEN 100 AND 200 AND
DATE(timestamp) IN ('2021-04-29', '2021-07-20', '2022-03-13')
ORDER BY amount DESC;

## Ejercicio 2
### Necesitamos optimizar la asignación de los recursos y dependerá de la capacidad operativa que se requiera,
### por lo que te piden la información sobre la cantidad de transacciones que realizan las empresas,
### pero el departamento de recursos humanos es exigente y quiere un listado de las empresas donde especifiques si tienen más de 4 o menos transacciones.
-- Usaré esta consulta como tabla temporal para saber el número de transaciones que tiene cada empresa.
SELECT t.company_id, c.company_name, COUNT(t.id) AS transaction_count
FROM transaction AS t
JOIN company AS c ON c.id = t.company_id
GROUP BY company_id;

-- Para mostrar el listado de empresas que tienen más de 4 transacciones.
SELECT company_id, company_name, transaction_count,
CASE
	WHEN transaction_count > 4 THEN "Más de 4 transacciones"
	ELSE "Menos de 4 transacciones"
END AS "¿Más? o, ¿menos?"
FROM (
	SELECT t.company_id, c.company_name, COUNT(t.id) AS transaction_count
	FROM transaction AS t
	JOIN company AS c ON c.id = t.company_id
	GROUP BY company_id) AS trans_count
ORDER BY transaction_count DESC;